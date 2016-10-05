package fr.inria.diverse.melange.utils

import com.google.inject.Inject
import fr.inria.diverse.melange.ast.AspectExtensions
import fr.inria.diverse.melange.ast.LanguageExtensions
import fr.inria.diverse.melange.ast.ModelingElementExtensions
import fr.inria.diverse.melange.metamodel.melange.Aspect
import fr.inria.diverse.melange.metamodel.melange.Language
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.IWorkspace
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.emf.ecore.EClass
import org.eclipse.jdt.core.ICompilationUnit
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.core.JavaModelException
import org.eclipse.jdt.core.dom.AST
import org.eclipse.jdt.core.dom.ASTParser
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.CompilationUnit
import org.eclipse.jface.text.Document
import org.eclipse.text.edits.TextEdit
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.common.types.JvmDeclaredType
import java.util.Set

class AspectRenamer {
	@Inject extension IQualifiedNameConverter
	@Inject extension AspectExtensions
	@Inject extension LanguageExtensions
	@Inject extension ModelingElementExtensions
	@Inject extension IQualifiedNameProvider

	private static final Logger log = Logger.getLogger(AspectRenamer)
	
	/**
	 * Apply renaming rules on the Aspects' files generated by Kermeta3
	 */
	def void processRenaming(List<Aspect> aspects, Language l, Set<String> sourceAspectNs, List<RenamingRuleManager> rulesManagers){
		
		val allClasses = l.syntax.allClasses.toList
								
		val IWorkspace workspace = ResourcesPlugin.getWorkspace();
    	val IWorkspaceRoot root = workspace.getRoot();
    	val IProject[] projects = root.getProjects();
    	val targetProject = projects.findFirst[name == l.externalRuntimeName]
		val javaProject = JavaCore.create(targetProject)

		val roots = <IPackageFragmentRoot>newArrayList
		try {
			roots += javaProject.allPackageFragmentRoots
		} catch (JavaModelException e) {
			log.error(e)
			return
		}

		val src_genFolder = roots.findFirst[elementName == "src-gen"]
		
		val k3Patterns = convertToPattern(aspects, rulesManagers)
		
		val allAspectNamespaces = aspects
			.map[(aspectTypeRef.type as JvmDeclaredType).packageName]
			.toSet
		allAspectNamespaces.addAll(sourceAspectNs)
	    val targetAspectNamespace = l.aspectsNamespace
		
		aspects.forEach[asp | 
	    	val aspectNamespace = src_genFolder.getPackageFragment(targetAspectNamespace.toString)
	    	
			processRenaming(asp, aspectNamespace, rulesManagers, k3Patterns, allClasses, allAspectNamespaces, targetAspectNamespace)

			try {
				targetProject.refreshLocal(IResource.DEPTH_INFINITE, null)
			} catch (CoreException e) {
				log.error("Couldn't refresh resource", e)
			}
		]
	}
	
	/**
	 * Apply renaming rules on the Aspect's files generated by Kermeta3
	 */
	private def void processRenaming(Aspect asp, IPackageFragment aspectNamespace, List<RenamingRuleManager> rulesManagers, List<Pair<String,String>> k3Pattern, List<EClass> allClasses, Set<String> allAspectNamespaces, String targetAspectNamespace){
		
		val aspName = asp.aspectTypeRef.simpleName 
		
		val fileName1 = aspName+".java"
		val cu1 = aspectNamespace.getCompilationUnit(fileName1)
		rulesManagers.forEach[rulesManager|
			applyRenaming(cu1, new RenamerVisitor(rulesManager,allClasses),k3Pattern,allAspectNamespaces,targetAspectNamespace)
		]
		
		if(asp.hasAspectAnnotation){
			val targetClass = asp.aspectedClass.name
	    	val targetFqName = asp.targetedClassFqn
	    	val rule = rulesManagers.map[getClassRule(targetFqName)].filterNull.head
	    	val newClass = 
	    		if(rule !== null){
		    		rule.value.toQualifiedName.lastSegment
	    		}
	    		else{
	    			targetClass.toQualifiedName.lastSegment
	    		}
			
			val fileName2 = aspName+targetClass+"AspectContext.java"
			val fileName3 = aspName+targetClass+"AspectProperties.java"
			
			val cu2 = aspectNamespace.getCompilationUnit(fileName2)
			val cu3 = aspectNamespace.getCompilationUnit(fileName3)
			
			rulesManagers.forEach[rulesManager|
				applyRenaming(cu2, new RenamerVisitor(rulesManager,allClasses),k3Pattern,allAspectNamespaces,targetAspectNamespace)
				applyRenaming(cu3, new RenamerVisitor(rulesManager,allClasses),k3Pattern,allAspectNamespaces,targetAspectNamespace)
			]

			try {
				cu2.rename(aspName+newClass+"AspectContext.java",true,null)
				cu3.rename(aspName+newClass+"AspectProperties.java",true,null)
			} catch (JavaModelException e) {
				log.error("Couldn't rename aspect classes", e)
			}
		}
	}
	
	/**
	 * Visit {@link sourceUnit} with {@link renamer} and apply changes in
	 * the corresponding textual file.
	 */
	private def void applyRenaming(ICompilationUnit sourceUnit, ASTVisitor renamer, List<Pair<String,String>> k3pattern, Set<String> allAspectNamespaces, String targetAspectNamespace){
		try {
			// textual document
			val String source = sourceUnit.getSource();
			val Document document= new Document(source);

			// get the AST
			val ASTParser parser = ASTParser.newParser(AST.JLS8)
			parser.setSource(sourceUnit)
			//parser.setResolveBindings(true) --not working
			val astRoot = parser.createAST(null) as CompilationUnit

			// start record of the modifications
			astRoot.recordModifications()

			astRoot.accept(renamer)

			// computation of the text edits
		   	val TextEdit edits = astRoot.rewrite(document, sourceUnit.getJavaProject().getOptions(true))

		   	// computation of the new source code
		   	edits.apply(document);
		   	var String newSource = document.get()
			newSource = newSource.replacePatterns(k3pattern)
			newSource = newSource.replaceNamespace(allAspectNamespaces,targetAspectNamespace)

		   	// update of the compilation unit
		   	sourceUnit.getBuffer().setContents(newSource)
		   	sourceUnit.getBuffer().save(null,true)
		} catch (Exception e) {
			log.error("Couldn't apply renaming rules", e)
		}
	}
	
	/**
	 * Rename AspectContext & AspectProperties in fileContent when exist a renaming rule for their base Class
	 */
	private def String replacePatterns(String fileContent, List<Pair<String,String>> patternRules){
		val StringBuilder newContent = new StringBuilder(fileContent)
		for(rule : patternRules){
			val oldPattern = rule.key
			val newPattern = rule.value
			newContent.replaceAll(oldPattern,newPattern)
		}
		return newContent.toString
	}
	
	/**
	 * Change the package name of the class
	 */
	private def String replaceNamespace(String fileContent, Set<String> allAspectNamespaces, String targetAspectNamespace) {
		val StringBuilder newContent = new StringBuilder(fileContent)
		allAspectNamespaces.forEach[sourceAspectNamespace |
			newContent.replaceAll(sourceAspectNamespace,targetAspectNamespace)
		]
		return newContent.toString
	}
	
	/**
	 * Deduce k3's Aspect patterns from {@link rulesManager} and associated replacement patterns
	 */
	private def List<Pair<String,String>> convertToPattern(List<Aspect> aspects, List<RenamingRuleManager> rulesManagers){
		val res = newArrayList
		aspects.filter[hasAspectAnnotation].forEach[asp|
    		val targetFqName = asp.targetedClassFqn
    		val aspName = asp.aspectTypeRef.simpleName
    		val rule = rulesManagers.map[getClassRule(targetFqName)].filterNull.head
    		if(rule !== null){
    			val oldClassName =  rule.key.substring( rule.key.lastIndexOf(".")+1)
				val newClassName =  rule.value.substring( rule.value.lastIndexOf(".")+1)
				res.add(aspName+oldClassName+"AspectContext" -> aspName+newClassName+"AspectContext")
				res.add(aspName+oldClassName+"AspectProperties" -> aspName+newClassName+"AspectProperties")
    		}
		]
		return res
	}
	
	private def replaceAll(StringBuilder string, String oldPattern, String newPattern){
		val oldPatternSize = oldPattern.length
		val newPatternSize = newPattern.length
		
		var startIndex = 0
		var index = string.indexOf(oldPattern)
		while(index != -1){
			val previousChar = string.charAt(index - 1)
			val followingChar = string.charAt(index + oldPatternSize)
			if(!Character.isJavaIdentifierPart(previousChar) && !Character.isJavaIdentifierPart(followingChar)){
				string.replace(index, index+oldPatternSize, newPattern)
				startIndex = index + newPatternSize
			}
			else{
				startIndex = index + oldPatternSize
			}
			index = string.indexOf(oldPattern, startIndex)
		}
	}
}
