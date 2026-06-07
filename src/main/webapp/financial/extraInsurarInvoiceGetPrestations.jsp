<%@page import="be.openclinic.finance.*,
                be.openclinic.adt.Encounter,
                java.util.*,
                be.mxs.common.util.system.HTMLEntities,
                be.openclinic.finance.ExtraInsurarInvoice"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	System.out.println("START");
%>

<%!
	//--- ADD DEBETS ------------------------------------------------------------------------------
	private String addDebets(Vector vDebets, String sClass, String sWebLanguage, boolean bChecked){
	    StringBuffer sReturn = new StringBuffer();
		try{
	        if(vDebets!=null){
	            Debet debet;
	            Prestation prestation;
	            String sEncounterName, sPrestationDescription, sPatientName,sDate;
	            String oldname="",oldencounter="",olddate="";
	            Hashtable hSort = new Hashtable();
	
	            String sImage = "_img/themes/default/check.gif";
	            if(!bChecked){
	                sImage = " _img/themes/default/uncheck.gif";
	            }
	            int count=0,count2=0;
	
	            // sort the records
	            for(int i=0; i<vDebets.size(); i++){
	                debet = (Debet)vDebets.elementAt(i);
	                if(debet!=null){
	    				count2++;
	                    hSort.put(debet.getPatientName()+"="+debet.getDate().getTime()+"="+debet.getUid(),debet);
	                }
	            }
	            
	            Vector keys = new Vector(hSort.keySet());
	            Collections.sort(keys);
	            Iterator it = keys.iterator();
	            while(it.hasNext()){
	                debet = (Debet)hSort.get(it.next());
	                if(checkString(debet.getUid()).length() > 0){
	                	if(debet != null){
	                    	count++;
	                    	
	                        if(!oldname.equalsIgnoreCase(debet.getPatientName())){
	                            sPatientName = debet.getPatientName();
	                            oldname=sPatientName;
	                            if (debet.getEncounter()!=null){
	                                sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
	                            }
	                            else{
	                                sEncounterName=debet.getEncounterUid();
	                            }
	                            oldencounter=sEncounterName;
	                            sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                            olddate=sDate;
	                        }
	                        else {
	                            sPatientName="";
	                            
	                            if(!oldencounter.equalsIgnoreCase(debet.getEncounter().getEncounterDisplayNameService(sWebLanguage))){
	                                sPatientName = debet.getPatientName();
	                                oldname=sPatientName;
	                                if (debet.getEncounter()!=null){
	                                    sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
	                                }
	                                else{
	                                    sEncounterName=debet.getEncounterUid();
	                                }
	                                oldencounter=sEncounterName;
	                                sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                                olddate=sDate;
	                            }
	                            else {
	                                sEncounterName="";
	                                if(!olddate.equalsIgnoreCase(ScreenHelper.stdDateFormat.format(debet.getDate()))){
	                                    sPatientName = debet.getPatientName();
	                                    oldname=sPatientName;
	                                    if (debet.getEncounter()!=null){
	                                        sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
	                                    }
	                                    else{
	                                        sEncounterName=debet.getEncounterUid();
	                                    }
	                                    oldencounter=sEncounterName;
	                                    sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                                    olddate=sDate;
	                                }
	                                else {
	                                    sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                                }
	                            }
	                        }
	
	                        sPrestationDescription = "";
	
	                        if (checkString(debet.getPrestationUid()).length() > 0) {
	                            prestation = debet.getPrestation();
	
	                            if (prestation != null) {
	                                sPrestationDescription = checkString(prestation.getDescription());
	                            }
	                        }
	
	                        // alternate row-style
	                        if(sClass.equals("")) sClass = "1";
	                        else                  sClass = "";
	
	                        sReturn.append("<tr class='list"+sClass+"'><td><img src='"+sImage+"' name='cbDebet"+debet.getUid()+"="+debet.getExtraInsurarAmount()+"' onclick='doBalance(this, true)'></td>"
                                    +"<td>"+HTMLEntities.htmlentities(sPatientName)+"</td>"
                                    +"<td>"+HTMLEntities.htmlentities(sEncounterName)+"</td>"
                                    +"<td><a href='javascript:openPatientInvoice("+debet.getPatientInvoiceUid().replaceAll(MedwanQuery.getInstance().getConfigInt("serverId")+"\\.","")+");'>"+HTMLEntities.htmlentities(debet.getPatientInvoiceUid().replaceAll(MedwanQuery.getInstance().getConfigInt("serverId")+"\\.",""))+"</a></td>"
                                    +"<td>" + HTMLEntities.htmlentities(sDate) + "</td>"
                                    +"<td>" +debet.getQuantity()+" x "+ HTMLEntities.htmlentities(sPrestationDescription) + "</td>"
                                    +"<td nowrap>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","0.00")).format(debet.getExtraInsurarAmount())+" "+MedwanQuery.getInstance().getConfigParam("currency", "€")+"</td>"
                                    + "</tr>");
	                    }
	                }
	            }
	
	        }
		}
		catch(Exception e){
			e.printStackTrace();
		}
		
	    return sReturn.toString();
	}

//--- ADD PERIOD DEBETS -----------------------------------------------------------------------
private String addPeriodDebets(Vector vDebets, String sClass, String sWebLanguage, boolean bChecked,
		                       java.util.Date begin, java.util.Date end, String sServiceUid, String sShowSummarizedOnly,int[] selecteddebets){
    StringBuffer sReturn = new StringBuffer();
    boolean bBaseInvoicingOnPatientInvoiceDate=false;

    try{
	    if (vDebets != null) {
	        Debet debet;
	        Prestation prestation;
	        String sEncounterName, sPrestationDescription, sPatientName,sDate;
	        Hashtable hSort = new Hashtable();
	        HashSet hSummarizedInvoices=new HashSet();
	        HashSet hNotSummarizedInvoices=new HashSet();
	
	        String sImage = "_img/themes/default/check.gif";
	        if (!bChecked) {
	            sImage = " _img/themes/default/uncheck.gif";
	        }
	        String oldname="",oldencounter="",olddate="";
	        // sort the records
	        for (int i=0;i<vDebets.size(); i++){
	            debet = (Debet) vDebets.elementAt(i);
	            if(debet!=null){
	            	if(hNotSummarizedInvoices.contains(debet.getPatientInvoiceUid())){
	            		continue;
	            	}
	            	else if(!hSummarizedInvoices.contains(debet.getPatientInvoiceUid()) && sShowSummarizedOnly.equalsIgnoreCase("true")){
	            		if(debet.isSummarized()){
	            			hSummarizedInvoices.add(debet.getPatientInvoiceUid());
	            		}
	            		else {
	            			hNotSummarizedInvoices.add(debet.getPatientInvoiceUid());
	            			continue;
	            		}
	            	}
	            	if(i==0){
	            		bBaseInvoicingOnPatientInvoiceDate=(debet.getInsurance()!=null && debet.getInsurance().getInsurar()!=null && debet.getInsurance().getInsurar().getIncludeAllPatientInvoiceDebets()==1);
	            	}
	                hSort.put(debet.getPatientName()+"="+debet.getDate().getTime()+"="+debet.getUid(),debet);
	            }
	        }
	        Vector keys = new Vector(hSort.keySet());
	        Collections.sort(keys);
	        Iterator it = keys.iterator();
	
	        while (it.hasNext()){
	            debet = (Debet) hSort.get(it.next());
	
	            if (checkString(debet.getUid()).length() > 0) {
	                if (debet != null) {
	                    if(begin!=null & begin.after(debet.getDate())){
	                        //continue;
	                    }
	                    if(end!=null & end.before(debet.getDate())){
	                        //continue;
	                    }
	                    if(sServiceUid.length()>0){
	                   		if(sServiceUid.toUpperCase().indexOf("'"+debet.determineServiceUid().toUpperCase()+"'")<0){
	                   			continue;
	                   		}
	                    }
	                    
	                    if(!oldname.equalsIgnoreCase(debet.getPatientName())){
	                        sPatientName = debet.getPatientName();
	                        oldname=sPatientName;
	                        if (debet.getEncounter()!=null){
	                            sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
	                        }
	                        else{
	                            sEncounterName=debet.getEncounterUid();
	                        }
	                        oldencounter=sEncounterName;
	                       	sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                        olddate=sDate;
	                    }
	                    else {
	                        sPatientName="";
	                        if(!oldencounter.equalsIgnoreCase(debet.getEncounter().getEncounterDisplayNameService(sWebLanguage))){
	                            sPatientName = debet.getPatientName();
	                            oldname=sPatientName;
	                            if (debet.getEncounter()!=null){
	                                sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
	                            }
	                            else{
	                                sEncounterName=debet.getEncounterUid();
	                            }
	                            oldencounter=sEncounterName;
	                           	sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                            olddate=sDate;
	                        }
	                        else {
	                            sEncounterName="";
	                            if(!olddate.equalsIgnoreCase(ScreenHelper.stdDateFormat.format(debet.getDate()))){
	                                sPatientName = debet.getPatientName();
	                                oldname=sPatientName;
	                                if (debet.getEncounter()!=null){
	                                    sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
	                                }
	                                else{
	                                    sEncounterName=debet.getEncounterUid();
	                                }
	                                oldencounter=sEncounterName;
	                               	sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                                olddate=sDate;
	                            }
	                            else {
	                               	sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                            }
	                        }
	                    }
	
	                    sPrestationDescription = "";
	
	                    if (checkString(debet.getPrestationUid()).length() > 0) {
	                        prestation = debet.getPrestation();
	
	                        if (prestation != null) {
	                            sPrestationDescription = checkString(prestation.getDescription());
	                        }
	                    }
	
	                    // alternate row-style
	                    if(sClass.equals("")) sClass = "1";
	                    else                  sClass = "";
	
	                    sReturn.append("<tr class='list"+sClass+"'><td><img src='"+sImage+"' name='cbDebet"+debet.getUid()+"="+debet.getExtraInsurarAmount()+"' onclick='doBalance(this, true)'></td>"
	                                   +"<td>"+HTMLEntities.htmlentities(sPatientName)+"</td>"
	                                   +"<td>"+HTMLEntities.htmlentities(sEncounterName)+"</td>"
	                                   +"<td><a href='javascript:openPatientInvoice("+debet.getPatientInvoiceUid().replaceAll(MedwanQuery.getInstance().getConfigInt("serverId")+"\\.","")+");'>"+HTMLEntities.htmlentities(debet.getPatientInvoiceUid().replaceAll(MedwanQuery.getInstance().getConfigInt("serverId")+"\\.",""))+"</a>"+(bBaseInvoicingOnPatientInvoiceDate?" [<b>"+ScreenHelper.stdDateFormat.format(debet.getCreateDateTime())+"</b>]":"")+"</td>"
	                                   +"<td>"+HTMLEntities.htmlentities(sDate)+"</td>"
	                                   +"<td>" +debet.getQuantity()+" x "+ HTMLEntities.htmlentities(sPrestationDescription)+"</td>"
	                                   +"<td>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","0.00")).format(debet.getExtraInsurarAmount())+" "+MedwanQuery.getInstance().getConfigParam("currency", "€")+"</td>"
	                                   +"</tr>");
	                    selecteddebets[0]++;
	                }
	            }
	        }
	    }
    }
    catch(Exception e){
    	e.printStackTrace();
    }
    return sReturn.toString();
}
%>
<table width="100%" cellspacing="1" cellpadding="0">
    <tr class="gray">
        <td width="50"/>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web.control","output_h_4",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web.finance","encounter",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web.finance","patientinvoice",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web", "date", sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web","prestation",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web","amount",sWebLanguage))%></td>
    </tr>
<%
	String sServiceUid = checkString(request.getParameter("EditInvoiceService"));
	if(sServiceUid.length()>0){
		sServiceUid = Service.getChildIdsAsString(sServiceUid);
	}
    String sEditInsurarInvoiceUID = checkString(request.getParameter("EditInsurarInvoiceUID"));
    String sEditBegin = checkString(request.getParameter("EditBegin"));
    String sEditEnd = checkString(request.getParameter("EditEnd"));
    String sClass = "";
    ExtraInsurarInvoice insurarInvoice = null;

    if(sEditInsurarInvoiceUID.length() > 0) {
        insurarInvoice = ExtraInsurarInvoice.get(sEditInsurarInvoiceUID);
        Vector vDebets = insurarInvoice.getDebets();
        out.print(addDebets(vDebets, sClass, sWebLanguage, true));
    }

    if((insurarInvoice==null)||(!checkString(insurarInvoice.getStatus()).equalsIgnoreCase("closed") && !checkString(insurarInvoice.getStatus()).equalsIgnoreCase("canceled"))) {
        String sInsurarUid = checkString(request.getParameter("InsurarUid"));
        java.util.Date begin = ScreenHelper.parseDate("01/01/1900");
        java.util.Date end = new java.util.Date();
        try{
            begin = ScreenHelper.parseDate(sEditBegin);
        }
        catch(Exception e){}
        try{
            end = ScreenHelper.parseDate(sEditEnd);
            end = new java.util.Date(end.getTime()+(24*3600*1000)-1);
        }
        catch(Exception e){}
        
        Vector vUnassignedDebets=new Vector();
		Insurar insurar = Insurar.get(sInsurarUid);
        if(insurar!=null && insurar.getRequireValidation()==1){
            vUnassignedDebets = Debet.getUnassignedValidatedAndSignedExtraInsurarDebets(sInsurarUid,begin,end);
        }
        else {
            vUnassignedDebets = Debet.getUnassignedExtraInsurarDebets(sInsurarUid,begin,end);
        }
        
        int[] selecteddebets={0};
        out.print(addPeriodDebets(vUnassignedDebets, sClass, sWebLanguage, false,begin,end,sServiceUid,"false",selecteddebets));
       	out.print("<tr><td colspan='6'>"+vUnassignedDebets.size()+" "+getTranNoLink("web","records.loaded",sWebLanguage)+"</td></tr>");
    }
    else {
    }
%>
</table>
