package finitestatemachines;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import FSM.interfaces.Context;
import family.StandaloneSetup;
import family.fsmrtcmt.fsm.StateMachine;

public class ExecuteFsm {
	public static void execute(StateMachine fsm, String input, String output) {
		Context c = new Context(input);
		fsm.eval(c, output);
	}

	public static void main(String[] args) {
		StandaloneSetup.doSetup();
		ResourceSet rs = new ResourceSetImpl();

		List<String> models = new ArrayList<>();
		models.add("melange:/file/input/dummie.xmi?mt=family.FsmRtcMT");
		models.add("melange:/file/input/timeddummie.xmi?mt=family.FsmRtcMT");
		models.add("melange:/file/input/compositedummie.xmi?mt=family.FsmRtcMT");
		models.add("melange:/file/input/timedcompositedummie.xmi?mt=family.FsmRtcMT");

		int i = 0;
		for (String uri : models) {
			Resource res = rs.getResource(URI.createURI(uri), true);
			StateMachine root = (StateMachine) res.getContents().get(0);
			execute(root, "{x;y;z,o;p;q}", "output-" + ++i + ".pdf");
		}
	}
}
