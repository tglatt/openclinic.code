package be.openclinic.datacenter;

import java.io.ByteArrayInputStream;
import java.sql.Connection;
import java.util.Iterator;
import java.util.Vector;

import org.dom4j.*;
import org.dom4j.io.SAXReader;

import java.sql.PreparedStatement;

import be.openclinic.system.SH;

public class GHBMessage {
	protected Document message = null;

	public GHBMessage(String xml) {
		loadMessage(xml);
	}
	
	public boolean loadMessage(String xml) {
        SAXReader reader = new SAXReader(false);
    	try {
			message = reader.read(new ByteArrayInputStream(xml.getBytes()));
			return true;
		} catch (DocumentException e) {
			e.printStackTrace();
		}
		return false;
	}
	
	public Vector<GHBData> getData(){
		Vector<GHBData> data = new Vector<GHBData>();
		Iterator<Element> iData = message.getRootElement().elementIterator("data");
		while(iData.hasNext()) {
			Element e = iData.next();
			GHBData d = GHBData.fromElement(e);
			if(d!=null) {
				data.add(d);
			}
		}
		return data;
	}
	
	public boolean storeData() {
		Connection conn = SH.getOpenClinicConnection();
		try {
			conn.setAutoCommit(false);
			Vector<GHBData> data = getData();
			for(int n=0;n<data.size();n++) {
				GHBData d = data.elementAt(n);
				PreparedStatement ps = conn.prepareStatement("");
			}
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.commit();
				conn.setAutoCommit(true);
				conn.close();
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}
		return false;
	}
}
