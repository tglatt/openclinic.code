package be.openclinic.hl7;

import be.openclinic.system.SH;
import ca.uhn.hl7v2.DefaultHapiContext;
import ca.uhn.hl7v2.HL7Exception;
import ca.uhn.hl7v2.model.Message;
import ca.uhn.hl7v2.parser.*;
import ca.uhn.hl7v2.util.Terser;

public class HL7Parser extends GenericParser {
	
	public HL7Parser(HL7Context context){
		setHapiContext(context);
	}
	
	@Override
	protected Message doParse(String message, String version) throws HL7Exception {
		/****************************************
		 * Replace specific strings in the HL7 message
		 */
		String sReplace[] = SH.cs("s5.hl7.preparser.replace", "ORU_R01=ORU\\$R01").split("\\|");
		for(int n=0;n<sReplace.length;n++) {
			if(sReplace[n].split("=").length>1) {
				String sBefore = sReplace[n].split("=")[0].replaceAll("&equal;", "=").replaceAll("&pipe;", "|");
				String sAfter = sReplace[n].split("=")[1].replaceAll("&equal;", "=").replaceAll("&pipe;", "|");
				if(sReplace[n].split("=").length<3 || message.contains("|"+sReplace[n].split("=")[2].replaceAll("&equal;", "=").replaceAll("&pipe;", "|")+"|")) {
					message = message.replaceAll(sBefore, sAfter);
				}
			}
		}
		GenericParser parser = new GenericParser(new CanonicalModelClassFactory("2.5.1"));
		Message m = parser.parse(message);
		return m;
	}

}
