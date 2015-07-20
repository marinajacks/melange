/**
 */
package fr.inria.diverse.melange.metamodel.melange;

import org.eclipse.emf.common.util.EList;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Slice</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link fr.inria.diverse.melange.metamodel.melange.Slice#getLanguage <em>Language</em>}</li>
 *   <li>{@link fr.inria.diverse.melange.metamodel.melange.Slice#getRoots <em>Roots</em>}</li>
 *   <li>{@link fr.inria.diverse.melange.metamodel.melange.Slice#getMappingRules <em>Mapping Rules</em>}</li>
 * </ul>
 *
 * @see fr.inria.diverse.melange.metamodel.melange.MelangePackage#getSlice()
 * @model
 * @generated
 */
public interface Slice extends Operator {
	/**
	 * Returns the value of the '<em><b>Language</b></em>' reference.
	 * <!-- begin-user-doc -->
	 * <p>
	 * If the meaning of the '<em>Language</em>' reference isn't clear,
	 * there really should be more of a description here...
	 * </p>
	 * <!-- end-user-doc -->
	 * @return the value of the '<em>Language</em>' reference.
	 * @see #setLanguage(Metamodel)
	 * @see fr.inria.diverse.melange.metamodel.melange.MelangePackage#getSlice_Language()
	 * @model
	 * @generated
	 */
	Metamodel getLanguage();

	/**
	 * Sets the value of the '{@link fr.inria.diverse.melange.metamodel.melange.Slice#getLanguage <em>Language</em>}' reference.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @param value the new value of the '<em>Language</em>' reference.
	 * @see #getLanguage()
	 * @generated
	 */
	void setLanguage(Metamodel value);

	/**
	 * Returns the value of the '<em><b>Roots</b></em>' attribute list.
	 * The list contents are of type {@link java.lang.String}.
	 * <!-- begin-user-doc -->
	 * <p>
	 * If the meaning of the '<em>Roots</em>' attribute list isn't clear,
	 * there really should be more of a description here...
	 * </p>
	 * <!-- end-user-doc -->
	 * @return the value of the '<em>Roots</em>' attribute list.
	 * @see fr.inria.diverse.melange.metamodel.melange.MelangePackage#getSlice_Roots()
	 * @model
	 * @generated
	 */
	EList<String> getRoots();

	/**
	 * Returns the value of the '<em><b>Mapping Rules</b></em>' containment reference list.
	 * The list contents are of type {@link fr.inria.diverse.melange.metamodel.melange.ClassBinding}.
	 * <!-- begin-user-doc -->
	 * <p>
	 * If the meaning of the '<em>Mapping Rules</em>' containment reference list isn't clear,
	 * there really should be more of a description here...
	 * </p>
	 * <!-- end-user-doc -->
	 * @return the value of the '<em>Mapping Rules</em>' containment reference list.
	 * @see fr.inria.diverse.melange.metamodel.melange.MelangePackage#getSlice_MappingRules()
	 * @model containment="true"
	 * @generated
	 */
	EList<ClassBinding> getMappingRules();

} // Slice
