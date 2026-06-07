<%@page import="be.openclinic.knowledge.OpenAI"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("select nupsref.* from nupsref,nupspharma where nupsref.nups=nupspharma.nups and contraindications is null and domain='MED'");
	ResultSet rs = ps.executeQuery();
	Vector<String> drugs = new Vector<String>();
	while(rs.next()){
		String nups = rs.getString("nups");
		String en = rs.getString("en").split(";")[0];
		String code=rs.getString("originalcode");
		drugs.add(nups+";"+en+";"+code);
	}
	rs.close();
	ps.close();
	conn.close();
	for(int n=0;n<drugs.size();n++){
		String nups = drugs.elementAt(n).split(";")[0];
		String en = drugs.elementAt(n).split(";")[1];
		String code = drugs.elementAt(n).split(";")[2];
		try{
			if(code.startsWith("R-")){
				String question="What are absolute contra-indications for the drug "+en+". Give the response in HTML format and add the WHO ICD10 code within <icd> tags for each contra-indication.";
				SH.syslog(question);
				String s = OpenAI.getPlainTextResponse(question);
				SH.syslog(nups+" - "+en+": "+s);
				if(s.trim().length()==0){
					s="-";
				}
				conn = SH.getOpenClinicConnection();
				PreparedStatement ps2 = conn.prepareStatement("update nupspharma set contraindications=? where nups=?");
				ps2.setString(1,s);
				ps2.setString(2,nups);
				ps2.execute();
				ps2.close();
				conn.close();
			}
		}
		catch(Exception e){
			SH.syslog(e.getMessage());
		}
	}
	
%>