<%@page import="org.dom4j.*"%><%@include file="/includes/helper.jsp"%><%@page errorPage="/includes/error.jsp"%><%
	try{
		SH.syslog("Receiving malaria post from "+request.getHeader("x-real-ip")+ " ["+request.getRemoteAddr()+"]");
		String xml = SH.p(request,"xml");
		int count=0;
		if(xml.length()>0){
			Document doc = DocumentHelper.parseText(xml);
			Element root = doc.getRootElement();
			Iterator<Element> encounters = root.elementIterator("encounter");
			while(encounters.hasNext()){
				count++;
				Element encounter = encounters.next();
				Connection conn = SH.getStatsConnection();
				try{
					String sSql = "delete from OC_MALARIASTATS where OC_MALARIASTATS_ID=? AND OC_MALARIASTATS_BEGIN=?";
					PreparedStatement ps = conn.prepareStatement(sSql);
					ps.setInt(1,Integer.parseInt(encounter.attributeValue("id")));
					try{
						ps.setTimestamp(2,SH.getSQLTimestamp(SH.parseDate(SH.c(encounter.attributeValue("begin")),"yyyyMMddHHmmss")));
					}
					catch(Exception d){
						ps.setNull(2,Types.NULL);
					}
					ps.execute();
					ps.close();
					sSql = "insert into OC_MALARIASTATS(OC_MALARIASTATS_ID,"+
							  		  "OC_MALARIASTATS_TYPE,"+
									  "OC_MALARIASTATS_BEGIN,"+
									  "OC_MALARIASTATS_END,"+
									  "OC_MALARIASTATS_TEMPERATURE,"+
									  "OC_MALARIASTATS_SEVERITYSIGNS,"+
									  "OC_MALARIASTATS_OTHERSIGNS,"+
									  "OC_MALARIASTATS_MALARIADIAGNOSIS,"+
									  "OC_MALARIASTATS_MALARIATREATMENT,"+
									  "OC_MALARIASTATS_COMPLICATIONSTREATMENT,"+
									  "OC_MALARIASTATS_RAPIDTEST,"+
									  "OC_MALARIASTATS_COMPLICATIONSNEURO,"+
									  "OC_MALARIASTATS_COMPLICATIONSDIGESTIVE,"+
									  "OC_MALARIASTATS_COMPLICATIONSSKIN,"+
									  "OC_MALARIASTATS_COMPLICATIONSRESPIRATORY,"+
									  "OC_MALARIASTATS_GENDER,"+
									  "OC_MALARIASTATS_AGE,"+
									  "OC_MALARIASTATS_ENCOUNTERTYPE,"+
									  "OC_MALARIASTATS_LENGTHOFSTAY,"+
									  "OC_MALARIASTATS_SITE,"+
									  "OC_MALARIASTATS_THICKSMEAR,"+
									  "OC_MALARIASTATS_OTHERDIAGNOSIS) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
								  ;
					ps=conn.prepareStatement(sSql);
					ps.setInt(1,Integer.parseInt(encounter.attributeValue("id")));
					ps.setString(2,SH.c(encounter.attributeValue("type")));
					try{
						ps.setTimestamp(3,SH.getSQLTimestamp(SH.parseDate(SH.c(encounter.attributeValue("begin")),"yyyyMMddHHmmss")));
					}
					catch(Exception d){
						ps.setNull(3,Types.NULL);
					}
					try{
						ps.setTimestamp(4,SH.getSQLTimestamp(SH.parseDate(SH.c(encounter.attributeValue("end")),"yyyyMMddHHmmss")));
					}
					catch(Exception d){
						ps.setNull(4,Types.NULL);
					}
					try{
						double temp =Double.parseDouble(SH.c(encounter.attributeValue("temperature")));
						if(temp>0){
							ps.setDouble(5,temp);
						}
						else{
							ps.setNull(5,Types.NULL);
						}
					}
					catch(Exception d){
						ps.setNull(5,Types.NULL);
					}
					ps.setString(6,SH.c(encounter.attributeValue("severitysigns")));
					ps.setString(7,SH.c(encounter.attributeValue("othersigns")));
					ps.setString(8,SH.c(encounter.attributeValue("malariadiagnosis")));
					ps.setString(9,SH.c(encounter.attributeValue("malariatreatment")));
					ps.setString(10,SH.c(encounter.attributeValue("complicationstreatment")));
					ps.setString(11,SH.c(encounter.attributeValue("rapidtest")));
					ps.setString(12,SH.c(encounter.attributeValue("complicationsneuro")));
					ps.setString(13,SH.c(encounter.attributeValue("complicationsdigestive")));
					ps.setString(14,SH.c(encounter.attributeValue("complicationsskin")));
					ps.setString(15,SH.c(encounter.attributeValue("complicationsrespiratory")));
					ps.setString(16,SH.c(encounter.attributeValue("gender")));
					try{
						ps.setDouble(17,Double.parseDouble(SH.c(encounter.attributeValue("age"))));
					}
					catch(Exception d){
						ps.setNull(17,Types.NULL);
					}
					ps.setString(18,SH.c(encounter.attributeValue("encountertype")));
					try{
						double los = Double.parseDouble(SH.c(encounter.attributeValue("lengthofstay")));
						if(los>=0){
							ps.setDouble(19,los);
						}
						else{
							ps.setNull(19,Types.NULL);
						}
					}
					catch(Exception d){
						ps.setNull(19,Types.NULL);
					}
					ps.setString(20,SH.c(encounter.attributeValue("site")));
					ps.setString(21,SH.c(encounter.attributeValue("thicksmear")));
					ps.setString(22,SH.c(encounter.attributeValue("otherdiagnosis")));
					ps.execute();
					ps.close();
				}
				catch(Exception e){
					e.printStackTrace();
				}
				conn.close();
			}
		}
		out.println("<response error='0' encountersUpdated='"+count+"'/>");
	}
	catch(Exception ex){
		out.println("<response error='"+ex.getMessage()+"'/>");
	}
%>