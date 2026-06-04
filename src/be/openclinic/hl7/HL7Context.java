package be.openclinic.hl7;

import ca.uhn.hl7v2.DefaultHapiContext;
import ca.uhn.hl7v2.parser.CanonicalModelClassFactory;

public class HL7Context extends DefaultHapiContext {
	HL7Parser pipeParser = null;

	public HL7Context() {
        CanonicalModelClassFactory mcf = new CanonicalModelClassFactory("2.5.1");
        this.setModelClassFactory(mcf);
	}
	
	@Override
	public synchronized HL7Parser getGenericParser() {
		if (pipeParser == null) {
			pipeParser = new HL7Parser(this);
		}
		return pipeParser;
	}

}
