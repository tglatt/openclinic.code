<%@ page import="be.openclinic.finance.*,
                 be.openclinic.adt.Encounter,
                 java.text.*,
                 javax.json.*,
                 be.mxs.common.util.io.OBR,
                 be.mxs.common.util.system.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	try{
		String sNewInvoiceUid="";
		
		String invoceuid=checkString(request.getParameter("invoiceuid"));
		//invoceuid = "1.4486802";
		String motif=checkString(request.getParameter("motif"));
		//motif = "Facture no conforme";
		
	
		
		JsonObject jo = OBR.cancelInvoice(invoceuid, motif, false);
		
		Boolean success = jo.getBoolean("success");
		if(success){
			Pointer.storePointer("OBR.CANC."+invoceuid, invoceuid);
			out.print("{\"invoiceuid\":\""+success+"\"}");
		}else{
			out.print("{\"invoiceuid\":\""+jo.toString()+"\"}");
		}
		
	}
	catch(Exception e){
		e.printStackTrace();
		out.print("{\"error\":\""+e.toString() +"\"}");
	}
%>