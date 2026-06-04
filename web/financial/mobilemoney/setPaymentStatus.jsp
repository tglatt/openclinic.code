<%@page import="be.mxs.common.util.system.Pointer"%>
<%@include file="/includes/helper.jsp"%>
<%
	String sOCTransactionId=SH.p(request,"uid");
	String sDecodedUid = new String(Base64.getDecoder().decode(sOCTransactionId));
	String sPaymentStatus=SH.p(request,"status");
	SH.syslog("Received mobile money payment status for "+sOCTransactionId+": "+sPaymentStatus);
	
	if(sPaymentStatus.equalsIgnoreCase("ok")){
		String sInvoiceUid = sDecodedUid.split(";")[1];
		Double nAmount = Double.parseDouble(sDecodedUid.split(";")[2]);
		String sPhoneNumber = sDecodedUid.split(";")[3];
		//Todo: Create PatientCredit for invoice
	}
	//Register payment status
	Pointer.storePointer("mm."+sDecodedUid, sPaymentStatus);
%>