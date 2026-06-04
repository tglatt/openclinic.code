<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
{
	"invoiceuid": "<%=SH.getServerId()+"."+MedwanQuery.getInstance().getOpenclinicCounter("OC_INVOICES") %>"
}