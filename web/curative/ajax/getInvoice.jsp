<%@page import="be.openclinic.finance.Insurar"%>
<%@page import="org.json.JSONObject"%>
<%@page import="be.openclinic.finance.PatientInvoice"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String invoiceUid = SH.p(request,"id");
	if(invoiceUid.split("\\.").length<2){
		invoiceUid=SH.getServerId()+"."+invoiceUid;
	}
	PatientInvoice invoice = PatientInvoice.get(invoiceUid);
	JSONObject jo = new JSONObject();
	jo.put("invoiceuid",invoice.getUid());
	jo.put("reference",invoice.getComment());
	jo.put("amount",new DecimalFormat(SH.cs("priceFormat","0.00")).format(invoice.getBalance()));
	String serviceid="",servicename="",encountertype="",encountermanager="",encountermanagername="",
			encounterorigin="",encountersituation="",activeinsurer="";
	HashSet services = invoice.getServices();
	if(services.size()>0){
		serviceid = (String)services.iterator().next();
	}
	HashSet encounters = invoice.getEncounters();
	if(encounters.size()>0){
		Encounter encounter = Encounter.get((String)encounters.iterator().next());
		if(encounter!=null){
			encountertype = encounter.getType();
			encountermanager = encounter.getManagerUID();
			encountermanagername = encounter.getManager()==null?"":encounter.getManager().getFullName();
			encounterorigin = encounter.getOrigin();
			encountersituation=encounter.getSituation();
		}
	}
	String insurers = invoice.getInsurerIds();
	if(insurers.length()>0){
		String insurerid = insurers.split(",")[0];
		Insurar insurar = Insurar.get(insurerid);
		activeinsurer=insurar.getName();
	}
	jo.put("serviceid",serviceid);
	jo.put("servicename",getTranNoLink("service",serviceid,sWebLanguage));
	jo.put("encountertype",encountertype);
	jo.put("encountermanager",encountermanager);
	jo.put("encountermanagername",encountermanagername);
	jo.put("encounterorigin",encounterorigin);
	jo.put("encountersituation",encountersituation);
	jo.put("activeinsurer",activeinsurer);
	out.println(jo);
%>