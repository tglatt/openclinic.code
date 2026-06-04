package be.openclinic.openimis;

import java.net.MalformedURLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.json.JsonObject;

import be.openclinic.system.SH;

public class GraphQL {
	
	public String getJsonString(JsonObject jo,String name) {
		String s= "";
		if(!jo.isNull(name)) s=jo.getString(name);
		return s;
	}
	
	public int getJsonInt(JsonObject jo,String name) {
		int n=0;
		if(!jo.isNull(name)) n=jo.getInt(name);
		return n;
	}
	
	public boolean getJsonBoolean(JsonObject jo,String name) {
		boolean b = false;;
		if(!jo.isNull(name)) b=jo.getBoolean(name);
		return b;
	}
	
	public Date getJsonDateTime(JsonObject jo, String name) {
		java.util.Date d=null;
		try {
			if(!jo.isNull(name)) d=new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(jo.getString(name));
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return d;
	}

	public Date getJsonDate(JsonObject jo, String name) {
		java.util.Date d=null;
		try {
			if(!jo.isNull(name)) d=new SimpleDateFormat("yyyy-MM-dd").parse(jo.getString(name));
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return d;
	}
	
	public static boolean isOpenIMISReachable() {
		return SH.isHostReachable(SH.cs("InternetCheckURL", "8.8.8.8"));
	}
}
