<%@page import="be.mxs.common.util.system.UpdateSystem"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="be.openclinic.system.MessageUtils"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%
	out.println("Getting update package from central server...");
	out.flush();
	Thread.sleep(200);
	HttpClient client = new HttpClient();
	PostMethod method = new PostMethod(SH.cs("partialServerCopyIncrementalURL","http://localhost:10088/openclinic/util/partialServerCopyIncremental.jsp"));
	NameValuePair[] nvp = new NameValuePair[4];
	nvp[0]= new NameValuePair("tables","*admin*adminprivate*adminextends*users*userparameters*userprofiles*userprofilepermissions*userservices*services*oc_labels*labanalysis*labprofiles*labprofilesanalysis*healthrecord*oc_encounters*transactions*items*requestedlabanalyses*oc_debets*oc_credits*oc_rfe*oc_diagnoses*");
	String start=SH.cs("lastBloodbankSync",SH.formatDate(new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay()*7),"yyyyMMddHHmmssSSS"));
	nvp[1]= new NameValuePair("ts",start);
	nvp[2]= new NameValuePair("from",SH.cs("offlineLocalPrefix",""));
	nvp[3]= new NameValuePair("mode","1");
	method.setRequestBody(nvp);
	String authStr = SH.cs("offlineSyncServer.username", "nil") + ":" + SH.cs("offlineSyncServer.password", "nil");
	String authEncoded = Base64.getEncoder().encodeToString(authStr.getBytes());
    method.setRequestHeader("Authorization", "Basic "+authEncoded);
    try{
		int statusCode = client.executeMethod(method);
    }
    catch(Exception e){
    	e.printStackTrace();
    }
	String sResponse=method.getResponseBodyAsString();
	out.println(" done. Response size = <b>"+new DecimalFormat("#,###").format(sResponse.length())+" bytes</b><br/>");
	String xml = MessageUtils.gzipDecompressFromBase64(sResponse.trim());
	out.println("Xml size = "+new DecimalFormat("#,###").format(xml.length())+" bytes ("+(xml.length()*100/sResponse.length())+"%)<br/>");
	int updates=0,inserts=0;
	Document doc = org.dom4j.DocumentHelper.parseText(xml);
	//Store text as xml file
	SH.writeTextFile("c:/tmp/fve/"+SH.formatDate(new java.util.Date(),"yyyyMMddHHmmss")+".xml",xml);
	Element root = doc.getRootElement();
	Iterator<Element> iTables = root.elementIterator("table");
	out.println("<hr/>Updating tables:<br/>");
	out.flush();
	Thread.sleep(200);
	int index=0;
	boolean bOk = true;
	while(iTables.hasNext()){
		index++;
		Element table = iTables.next();
		out.println("<li><b>"+table.attributeValue("name")+"</b> ["+table.elements("row").size()+"] <span id='error."+index+"'><span> <img id='img."+index+"' height='8px' src='"+sCONTEXTPATH+"/_img/themes/default/ajax-loader.gif'/></li>");
		out.flush();
		Thread.sleep(200);
		if(table.attributeValue("name").equalsIgnoreCase("oc_encounter_services")){
			//Special import for oc_encounter_services
			Connection conn=SH.getOpenClinicConnection();
			conn.setAutoCommit(false);
			String sSql = "delete from oc_encounter_services where oc_encounter_serverid=? and oc_encounter_objectid=? and oc_encounter_servicebegindate=?";
			Iterator<Element> rows = table.elementIterator("row");
			try{
				while(rows.hasNext()){
					Element row = rows.next();
					String[] values = row.getText().split("\\|");
					PreparedStatement ps = conn.prepareStatement(sSql);
					ps.setInt(1,Integer.parseInt(values[0]));
					ps.setInt(2,Integer.parseInt(values[1]));
					ps.setTimestamp(3,SH.getSQLTimestamp(SH.parseDate(values[6],"yyyyMMddHHmmssSSS")));
					ps.execute();
					ps.close();
				}
				conn.commit();
				rows = table.elementIterator("row");
				while(rows.hasNext()){
					Element row = rows.next();
					String[] values = row.getText().split("\\|");
					PreparedStatement ps = conn.prepareStatement("insert into oc_encounter_services(oc_encounter_serverid,oc_encounter_objectid,oc_encounter_serviceuid,oc_encounter_beduid,oc_encounter_serviceenddate,oc_encounter_manageruid,oc_encounter_servicebegindate) values (?,?,?,?,?,?,?)");
					ps.setInt(1,Integer.parseInt(values[0]));
					ps.setInt(2,Integer.parseInt(values[1]));
					ps.setString(3,values[2]);
					ps.setString(4,values[3]);
					if(values[4].length()>0){
						ps.setTimestamp(5,SH.getSQLTimestamp(SH.parseDate(values[4],"yyyyMMddHHmmssSSS")));
					}
					else{
    					ps.setNull(5,java.sql.Types.NULL);
					}
					ps.setString(6,values[5]);
					if(values[6].length()>0){
						ps.setTimestamp(7,SH.getSQLTimestamp(SH.parseDate(values[6],"yyyyMMddHHmmssSSS")));
					}
					else{
    					ps.setNull(7,java.sql.Types.NULL);
					}
					ps.execute();
					ps.close();
					inserts++;
				}
			}
			catch(Exception q){
				q.printStackTrace();
				bOk=false;
				out.println("<script>document.getElementById('error."+index+"').innerHTML='Error!';</script>");
				out.flush();
			}
			conn.commit();
			conn.close();
		}
		else{
			String ts = table.attributeValue("ts");
			String[] keys = table.attributeValue("key").split(",");
			String[] columns = table.attributeValue("columns").split(",");
			String[] types = table.attributeValue("types").split(",");
			Connection conn = null;
			if(table.attributeValue("database").equalsIgnoreCase("admin")){
				conn=SH.getAdminConnection();
			}
			else if(table.attributeValue("database").equalsIgnoreCase("openclinic")){
				conn=SH.getOpenClinicConnection();
			}
			conn.setAutoCommit(false);
			String sSql = "delete from "+table.attributeValue("name")+" where ";
			for(int n=0;n<keys.length;n++){
				if(n>0){
					sSql+=" AND ";
					}
				sSql+=keys[n]+"=?";
			}
			
			Iterator<Element> rows = table.elementIterator("row");
			try{
				while(rows.hasNext()){
					Element row = rows.next();
					String[] values = row.getText().split("\\|");
					PreparedStatement ps = conn.prepareStatement(sSql);
					for(int n=0;n<keys.length;n++){
						for(int i=0;i<columns.length;i++){
							if(keys[n].equalsIgnoreCase(columns[i])){
				    			if(types[i].equalsIgnoreCase("varchar") || types[i].equalsIgnoreCase("char") || types[i].equalsIgnoreCase("text") || types[i].equalsIgnoreCase("longtext")){
				    				ps.setString(n+1,values[i]);
				    			}
				    			else if(types[i].equalsIgnoreCase("datetime")){
				    				ps.setTimestamp(n+1,SH.getSQLTimestamp(SH.parseDate(values[i],"yyyyMMddHHmmssSSS")));
				    			}
				    			else if(types[i].equalsIgnoreCase("double") || types[i].equalsIgnoreCase("float")){
				    				ps.setDouble(n+1,Double.parseDouble(values[i]));
				    			}
				    			else if(types[i].equalsIgnoreCase("int")){
				    				ps.setInt(n+1,Integer.parseInt(values[i]));
				    			}
							}
						}
					}
					ps.execute();
					ps.close();
					//Insert
					String sSql2 = "insert into "+table.attributeValue("name")+"("+table.attributeValue("columns")+") values(";
					for(int n=0;n<columns.length;n++){
						if(n>0){
							sSql2+=",";
						}
						sSql2+="?";
					}
					sSql2+=")";
					PreparedStatement ps2 = conn.prepareStatement(sSql2);
					for(int n=0;n<columns.length;n++){
		    			if(types[n].equalsIgnoreCase("varchar") || types[n].equalsIgnoreCase("char") || types[n].equalsIgnoreCase("text") || types[n].equalsIgnoreCase("longtext")){
		    				if(values.length>n){
		    					try{
		    						ps2.setString(n+1,values[n]);
		    					}
		    					catch(Exception t){
		        					ps2.setNull(n+1,java.sql.Types.NULL);
		    					}
		    				}
		    				else{
		    					ps2.setNull(n+1,java.sql.Types.NULL);
		    				}
		    			}
		    			else if(types[n].equalsIgnoreCase("datetime")){
		    				if(values.length>n && values[n].length()>0){
		    					try{
			    					ps2.setTimestamp(n+1,SH.getSQLTimestamp(SH.parseDate(values[n],"yyyyMMddHHmmssSSS")));
		    					}
		    					catch(Exception t){
		        					ps2.setNull(n+1,java.sql.Types.NULL);
		    					}
		    				}
		    				else{
		    					ps2.setNull(n+1,java.sql.Types.NULL);
		    				}
		    			}
		    			else if(types[n].equalsIgnoreCase("double") || types[n].equalsIgnoreCase("float")){
		    				if(values.length>n && values[n].length()>0){
		    					try{
		    						ps2.setDouble(n+1,Double.parseDouble(values[n]));
		    					}
		    					catch(Exception t){
		        					ps2.setNull(n+1,java.sql.Types.NULL);
		    					}
		    				}
		    				else{
		    					ps2.setNull(n+1,java.sql.Types.NULL);
		    				}
		    			}
		    			else if(types[n].equalsIgnoreCase("int")){
		    				if(values.length>n && values[n].length()>0){
								try{
									ps2.setInt(n+1,Integer.parseInt(values[n]));
								}
								catch(Exception t){
			    					ps2.setNull(n+1,java.sql.Types.NULL);
								}
		    				}
		    				else{
		    					ps2.setNull(n+1,java.sql.Types.NULL);
		    				}
		    			}
		    			else if(types[n].equalsIgnoreCase("longblob")){
		    				if(values.length>n && values[n].length()>0){
		    					try{
		    						ps2.setBytes(n+1,Base64.getDecoder().decode(values[n].getBytes(java.nio.charset.StandardCharsets.UTF_8)));
		    					}
		    					catch(Exception t){
		        					ps2.setNull(n+1,java.sql.Types.NULL);
		    					}
		    				}
		    				else{
		    					ps2.setNull(n+1,java.sql.Types.NULL);
		    				}
		    			}
		    			else{
							ps2.setNull(n+1,java.sql.Types.NULL);
		    			}
					}
					ps2.execute();
					ps2.close();
					inserts++;
				}
				conn.commit();
			}
			catch(Exception q){
				q.printStackTrace();
				bOk=false;
				out.println("<script>document.getElementById('error."+index+"').innerHTML='Error!';</script>");
				out.flush();
			}
			conn.setAutoCommit(true);
			conn.close();
		}
		out.println("<script>document.getElementById('img."+index+"').style.display='none';</script>");
		out.flush();
		Thread.sleep(200);
	}
	UpdateSystem systemUpdate = new UpdateSystem();
	systemUpdate.updateCounters();
	systemUpdate.reloadSingleton();

	out.println("<hr/><b>"+new DecimalFormat("#,###").format(inserts)+" records updated</b><br/>");
	if(bOk){
		out.println("New timestamp = "+root.attributeValue("ts")+"<br/>");
		MedwanQuery.getInstance().setConfigString("lastBloodbankSync", root.attributeValue("ts"));
	}
	else{
		out.println("Errors detected, timestamp not updated!<br/>");
	}
	MedwanQuery.getInstance().getObjectCache().reset();
%>
