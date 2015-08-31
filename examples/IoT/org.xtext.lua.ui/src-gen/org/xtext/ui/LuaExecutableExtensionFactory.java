/*
 * generated by Xtext
 */
package org.xtext.ui;

import org.eclipse.xtext.ui.guice.AbstractGuiceAwareExecutableExtensionFactory;
import org.osgi.framework.Bundle;

import com.google.inject.Injector;

import org.xtext.ui.internal.LuaActivator;

/**
 * This class was generated. Customizations should only happen in a newly
 * introduced subclass. 
 */
public class LuaExecutableExtensionFactory extends AbstractGuiceAwareExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return LuaActivator.getInstance().getBundle();
	}
	
	@Override
	protected Injector getInjector() {
		return LuaActivator.getInstance().getInjector(LuaActivator.ORG_XTEXT_LUA);
	}
	
}
