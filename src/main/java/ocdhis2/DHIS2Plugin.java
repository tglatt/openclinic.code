package ocdhis2;

import java.util.Date;
import java.util.Hashtable;
import java.util.Vector;

import org.dom4j.Element;

public abstract class DHIS2Plugin {
	protected static Object refObject=null;
	protected static String refObjectId="";
	
	public static String getRefObjectId() {
		return refObjectId;
	}

	public static void setRefObjectId(String refObjectId) {
		DHIS2Plugin.refObjectId = refObjectId;
	}

	public static Object getRefObject() {
		return refObject;
	}

	public static void setRefObject(Object refObject) {
		DHIS2Plugin.refObject = refObject;
	}

	// Returned items have a fixed format:
	// 0: personid
	// 1: gender
	// 2: dateofbirth
	// 3: value
	// 4: date
	// 5: department
	// 6: itemid
	public abstract Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters);
	
	// Returned items have a fixed format:
	// 0: value
	// 1: category
	// 2: attribute
	public abstract Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters);
}
