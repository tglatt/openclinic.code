<%@page import="be.openclinic.openimis.*,be.openclinic.pharmacy.*,be.openclinic.finance.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	int total=-1;
	if(SH.p(request,"submitButton").length()>0){
		if(SH.p(request,"clearPrestations").length()>0){
			Connection conn = SH.getOpenClinicConnection();
			PreparedStatement ps = conn.prepareStatement("delete from oc_prestations");
			ps.execute();
			ps.close();
			conn.close();
		}
		Vector<GraphQLMedicalItem> items = GraphQLMedicalItem.get("","","","");
		for(int n=0;n<items.size();n++){
			Prestation prestation = items.elementAt(n).getPrestation();
			if(Prestation.getByCode(prestation.getCode()).hasValidUid()){
				prestation.setUid(Prestation.getByCode(prestation.getCode()).getUid());
			}
			out.println(prestation.getUid()+" - "+prestation.getCode()+": "+prestation.getDescription()+" ["+prestation.getPrice()+"]<br/>");
			out.flush();
			prestation.store();
		}
		total=items.size();
		Vector<GraphQLMedicalService> services = GraphQLMedicalService.get("","","","");
		for(int n=0;n<services.size();n++){
			Prestation prestation = services.elementAt(n).getPrestation();
			if(Prestation.getByCode(prestation.getCode()).hasValidUid()){
				prestation.setUid(Prestation.getByCode(prestation.getCode()).getUid());
			}
			out.println(prestation.getCode()+": "+prestation.getDescription()+" ["+prestation.getPrice()+"]<br/>");
			out.flush();
			prestation.store();
		}
		total+=services.size();
	}
%>
<form name='transactionForm' method='post'>
	<input type='checkbox' class='text' name='clearPrestations' value='1'/><%=getTran(request,"web","clearprestations",sWebLanguage) %><br/>
	<input type='submit' name='submitButton' value='<%=getTranNoLink("web","load",sWebLanguage) %>'/>
</form>
<br/><br/><br/>
<% if(total>-1){ %>
	<%=total %> <%=getTran(request,"web","prestations",sWebLanguage) %> <%=getTran(request,"web","loaded",sWebLanguage) %>
<%}%>