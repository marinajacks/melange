/*
 * generated by Xtext
 */
package fr.inria.diverse.melange;

import org.eclipse.xtext.junit4.IInjectorProvider;

import com.google.inject.Injector;

public class MelangeUiInjectorProvider implements IInjectorProvider {

	@Override
	public Injector getInjector() {
		return fr.inria.diverse.melange.ui.internal.MelangeActivator.getInstance().getInjector("fr.inria.diverse.melange.Melange");
	}

}
