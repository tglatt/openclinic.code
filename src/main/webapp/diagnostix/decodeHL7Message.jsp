<%@page import="ca.uhn.hl7v2.*,ca.uhn.hl7v2.parser.*"%>
<%@include file="/includes/helper.jsp"%>
<%!
	String setBold(String line,int field){
		String s = "";
		String[] fields = line.split("\\|");
		if(fields.length>field){
			for(int n=0;n<field;n++){
				if(s.length()>0){
					s+="|";
				}
				s+=fields[n];
			}
			if(s.length()>0){
				s+="|";
			}
			s+="<b>"+fields[field]+"</b>";
			for(int n=field+1;n<fields.length;n++){
				if(s.length()>0){
					s+="|";
				}
				s+=fields[n];
			}
		}
		else{
			s=line;
		}
		return s;
	}
%>
<font style='font-family: Courier New,Courier,Lucida Sans Typewriter,Lucida Typewriter,monospace; font-size: 12px'>
<%
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_hl7in where oc_hl7in_id=?");
	ps.setString(1,SH.p(request,"id"));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		try{
			String message = new String(rs.getBytes("oc_hl7in_message"));
			String[] messageLines = message.split("\r");
			for(int n=0;n<messageLines.length;n++){
				String s =setBold(messageLines[n],0);
				if(messageLines[n].split("\\|")[0].equalsIgnoreCase("PID") || messageLines[n].split("\\|")[0].equalsIgnoreCase("OBX")){
					s=setBold(setBold(s, 3), 5);
				}
				else if(messageLines[n].split("\\|")[0].equalsIgnoreCase("SPM")){
					s=setBold(s, 3);
				}
				else if(messageLines[n].split("\\|")[0].equalsIgnoreCase("MSH")){
					s=setBold(s, 9);
				}
				out.println(s+"<br/>");
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>
</font>