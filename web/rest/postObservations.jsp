<%@page import="be.openclinic.system.SH,org.apache.commons.io.IOUtils,java.sql.*,org.dom4j.*,java.util.*"%><%!
	public boolean isAuthorized(HttpServletRequest request){
		try{
			String credentials = SH.c(request.getHeader("Authorization"));
			if(credentials.startsWith("Basic ")){
				credentials=new String(Base64.getDecoder().decode(credentials.substring(6)));
				if(credentials.split(":").length>1){
					String login = credentials.split(":")[0];
					String password = credentials.split(":")[1];
					if(SH.cs("devAPIUser."+login,"").equalsIgnoreCase(password)){
						return true;
					}
				}
			}
			return false;
		}
		catch(Exception e){
			e.printStackTrace();
			return false;
		}
	}
%><%
	String sErrorCode="0";
	if(isAuthorized(request)){
		try{
			Connection conn = SH.getOpenClinicConnection();
			String sBody = IOUtils.toString(request.getReader());
			Document document = DocumentHelper.parseText(sBody);
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("o")){
				Iterator<Element> iDevices = root.elementIterator("d");
				while(iDevices.hasNext()){
					Element device = iDevices.next();
					String id=SH.c(device.attributeValue("id"));
					if(id.length()>0){
						String patientid = SH.cs("deviceMap."+id,"");
						Iterator<Element> iValues = device.elementIterator("v");
						while(iValues.hasNext()){
							Element value = iValues.next();
							String code=SH.c(value.attributeValue("code"));
							java.util.Date ts =SH.parseDate(value.attributeValue("ts"),"yyyyMMddHHmmssSSS");
							float result = Float.parseFloat(value.getText());
							if(result<=0){
								continue;
							}
							if(code.equalsIgnoreCase("8310-5")){
								result+=SH.cd("deviceTemperatureCalibration."+id,0);
							}
							if(code.equalsIgnoreCase("8867-4")){
							}
							if(result==0 && !code.equalsIgnoreCase("0000-9")){
								continue;
							}
							if(code.equalsIgnoreCase("0000-9")){
								result*=100;
							}
							try{
								PreparedStatement ps = conn.prepareStatement("insert into oc_observations(personid,id,ts,code,value) values(?,?,?,?,?)");
								ps.setString(1,patientid);
								ps.setString(2,id);
								ps.setTimestamp(3, SH.getSQLTimestamp(ts));
								ps.setString(4,code);
								ps.setFloat(5, result);
								ps.execute();
								ps.close();
								//System.out.print(".");
							}
							catch(Exception es){
								es.printStackTrace();
								sErrorCode="200";
							}
						}
					}
					else{
						sErrorCode="100";
						break;
					}
				}
			}
			else{
				sErrorCode="100";
			}
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
			sErrorCode="900";
		}
	}
	else{
		sErrorCode="400";
	}
%><response><%=sErrorCode%></response>
