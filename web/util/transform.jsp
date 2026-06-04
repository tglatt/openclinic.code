<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Connection conn = SH.getAdminConnection();
	PreparedStatement ps = conn.prepareStatement("delete from services WHERE serviceid REGEXP '[0-9]';");
	ps.execute();
	ps.close();
	
	Hashtable hparents = new Hashtable();
	Hashtable hchildren = new Hashtable();
	SAXReader reader = new SAXReader(false);
	Document document = reader.read(new File("c:/tmp/gmao/niger/servicescsi.xml"));
	Element root = document.getRootElement();
	Iterator iservices = root.elementIterator("parent");
	while(iservices.hasNext()){
		Element parent = (Element)iservices.next();
		hparents.put(parent.attributeValue("id"),parent.elementText("name"));
		Iterator children =parent.elementIterator("child");
		while(children.hasNext()){
			Element child = (Element)children.next();
			hchildren.put(child.attributeValue("id"),parent.elementText("name")+"/"+child.elementText("name"));
		}
	}
	
	ps=conn.prepareStatement("select * from services where costcenter='cds'");
	ResultSet rs =ps.executeQuery();
	while(rs.next()){
		String serviceid=rs.getString("serviceid");
		Enumeration e1 = hparents.keys();
		while(e1.hasMoreElements()){
			String key=(String)e1.nextElement();
			PreparedStatement ps2 = conn.prepareStatement("insert into services(serviceid,country,"+
					"updatetime,serviceparentid,servicelanguage,updateuserid,contactcountry,inactive)"+
					" values(?,'ne',now(),?,'fr',4,'ne',0)");
			ps2.setString(1,serviceid+"."+key);
			ps2.setString(2,serviceid);
			ps2.execute();
			ps2.close();
			MedwanQuery.getInstance().updateLabel("service", (serviceid+"."+key).toLowerCase(), "fr", (String)hparents.get(key));
			MedwanQuery.getInstance().updateLabel("service", (serviceid+"."+key).toLowerCase(), "en", (String)hparents.get(key));
            MedwanQuery.getInstance().removeLabelFromCache("service",(serviceid+"."+key).toLowerCase(),"fr");
            MedwanQuery.getInstance().removeLabelFromCache("service",(serviceid+"."+key).toLowerCase(),"en");
            MedwanQuery.getInstance().getLabel("service",(serviceid+"."+key).toLowerCase(),"fr");
            MedwanQuery.getInstance().getLabel("service",(serviceid+"."+key).toLowerCase(),"en");
		}
		e1 = hchildren.keys();
		while(e1.hasMoreElements()){
			String key=(String)e1.nextElement();
			PreparedStatement ps2 = conn.prepareStatement("insert into services(serviceid,country,"+
					"updatetime,serviceparentid,servicelanguage,updateuserid,contactcountry,inactive)"+
					" values(?,'ne',now(),?,'fr',4,'ne',0)");
			ps2.setString(1,serviceid+"."+key);
			ps2.setString(2,serviceid+"."+key.split("\\.")[0]);
			ps2.execute();
			ps2.close();
			MedwanQuery.getInstance().updateLabel("service", (serviceid+"."+key).toLowerCase(), "fr", ((String)hchildren.get(key)).toUpperCase());
			MedwanQuery.getInstance().updateLabel("service", (serviceid+"."+key).toLowerCase(), "en", ((String)hchildren.get(key)).toUpperCase());
            MedwanQuery.getInstance().removeLabelFromCache("service",(serviceid+"."+key).toLowerCase(),"fr");
            MedwanQuery.getInstance().removeLabelFromCache("service",(serviceid+"."+key).toLowerCase(),"en");
            MedwanQuery.getInstance().getLabel("service",(serviceid+"."+key).toLowerCase(),"fr");
            MedwanQuery.getInstance().getLabel("service",(serviceid+"."+key).toLowerCase(),"en");
		}
	}
	rs.close();
	ps.close();
	
	Hashtable hmappings = new Hashtable();
	document = reader.read(new File("c:/tmp/gmao/niger/mappings.xml"));
	root = document.getRootElement();
	Iterator imappings = root.elementIterator("mapping");
	while(imappings.hasNext()){
		Element mapping = (Element)imappings.next();
		String id="99.99";
		if(SH.c(mapping.elementText("csi")).length()>0){
			id=mapping.elementText("csi");
		}
		hmappings.put(mapping.elementText("name").toUpperCase(),id);
	}
	
	SH.syslog("##########################################################");
	SH.syslog("##########################################################");
	SH.syslog("##########################################################");
	SH.syslog("##########################################################");
	SH.syslog("##########################################################");
	conn.close();
	conn=SH.getOpenClinicConnection();
	ps=conn.prepareStatement("select * from oc_assets");
	rs = ps.executeQuery();
	while(rs.next()){
		String serviceid = rs.getString("oc_asset_service");
		String comment8 = rs.getString("oc_asset_comment8");
		while("0123456789".contains(serviceid.split("\\.")[serviceid.split("\\.").length-1].substring(0,1))){
			serviceid=serviceid.replaceAll("."+serviceid.split("\\.")[serviceid.split("\\.").length-1],"");
		}
		Service service = Service.getService(serviceid);
		if(service!=null && service.costcenter.equalsIgnoreCase("cds")){
			String newservice=(String)hmappings.get(comment8.toUpperCase());
			if(newservice==null){
				newservice="99.99";
			}
			newservice = serviceid+"."+newservice;
			SH.syslog(comment8+" ==> "+newservice);
			PreparedStatement ps2 = conn.prepareStatement("update oc_assets set oc_asset_service=?,oc_asset_code=? where oc_asset_objectid=?");
			ps2.setString(1,newservice);
			ps2.setString(2,serviceid+"."+rs.getInt("oc_asset_objectid"));
			ps2.setInt(3,rs.getInt("oc_asset_objectid"));
			ps2.execute();
			ps2.close();
		}
	}
	rs.close();
	ps.close();
	conn.close();
	
%>
	