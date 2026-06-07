<%@page import="be.openclinic.finance.*"%>
<%@page import="java.util.*,
                java.text.*" %>
<%@include file="/includes/validateUser.jsp"%>

<%!
	class Income{
		public double patient=0;
		public double insurar=0;
		public double extrainsurar=0;
		public double reduction=0;
		
		public double getTotal(){
			return patient+insurar+extrainsurar+reduction;
		}
	}
%>

<%
    String sStart = checkString(request.getParameter("start")),
           sEnd   = checkString(request.getParameter("end"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************* statistics/incomeVentilation.jsp *******************");
		Debug.println("sStart : "+sStart);
		Debug.println("sEnd   : "+sEnd+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	String sTitle = getTranNoLink("Web","statistics.incomeVentilationPerCategoryAndService",sWebLanguage)+": <i>"+sStart+" "+getTran(request,"web","to",sWebLanguage)+" "+sEnd+"</i>";
%>

<%=writeTableHeaderDirectText(sTitle,sWebLanguage," window.close()")%>
	
<table width="100%" class="sortable" id="searchresults" cellspacing="1" bottomRowCount="1" cellpadding="0">
	<%-- HEADER --%>
	<tr class="gray">
		<td><%=getTran(request,"web","invoice.category",sWebLanguage)%></td>
		<td><%=getTran(request,"web","total.amount",sWebLanguage)%></td>
		<td><%=getTran(request,"web","patient.amount",sWebLanguage)%></td>
		<td><%=getTran(request,"web","insurar.amount",sWebLanguage)%></td>
		<td><%=getTran(request,"web","extrainsurar.amount",sWebLanguage)%></td>
		<td><%=getTran(request,"web","reduction",sWebLanguage)%></td>
	</tr>
	
<%
	java.util.Date start = ScreenHelper.fullDateFormat.parse(checkString(request.getParameter("start"))+" 00:00"),
	               end   = ScreenHelper.fullDateFormat.parse(checkString(request.getParameter("end"))+" 23:59");

	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery = "select oc_debet_objectid, oc_prestation_invoicegroup, oc_debet_serviceuid,"+
	                "  oc_debet_amount, oc_debet_insuraramount, oc_debet_extrainsuraramount, oc_debet_patientinvoiceuid"+
			    	" from oc_debets a, oc_prestations b"+
				    "  where oc_prestation_objectid = replace(oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
				    "   and oc_debet_date between ? and ?"+
				    "   and oc_debet_patientinvoiceuid is not null"+
			        "   and oc_debet_patientinvoiceuid <> ''"+
				    "  order by oc_debet_objectid";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
	ResultSet rs = ps.executeQuery();
	
	String priceFormat = MedwanQuery.getInstance().getConfigString("priceFormatExtended","#,##0.00");
	String currency = " "+MedwanQuery.getInstance().getConfigString("currency","");
	double totalpatient = 0, totalinsurar = 0, totalextrainsurar = 0, totalreduction=0, patientamount, insuraramount, extrainsuraramount;
	SortedMap incomes = new TreeMap();
	String group, debetid, serviceuid, servicename;
	DecimalFormat deci = new DecimalFormat(priceFormat);
	Hashtable<String,Double> patientInvoices = new Hashtable();
	Income income = null;
	Service service;
	Vector<String> lines = new Vector();
	while(rs.next()){
		lines.add(	rs.getString("oc_debet_objectid")+";"+							//0		
					checkString(rs.getString("oc_prestation_invoicegroup"))+";"+	//1
					checkString(rs.getString("oc_debet_serviceuid"))+";"+			//2
					rs.getDouble("oc_debet_amount")+";"+							//3
					rs.getDouble("oc_debet_insuraramount")+";"+						//4
					rs.getDouble("oc_debet_extrainsuraramount")+";"+				//5
					checkString(rs.getString("oc_debet_patientinvoiceuid"))+";"		//6
				);
		patientInvoices.put(checkString(rs.getString("oc_debet_patientinvoiceuid")),0.0);
	}		
	rs.close();
	ps.close();
	conn.close();
	
	Enumeration<String> e = patientInvoices.keys();
	while(e.hasMoreElements()){
		String uid = e.nextElement();
		PatientInvoice invoice = PatientInvoice.get(uid);
		double patientAmount = invoice.getPatientOwnAmount();
		double reductions = 0;
		Vector<String> credits = invoice.getCredits();
		for(int n=0;n<credits.size();n++){
			PatientCredit credit = PatientCredit.get(credits.elementAt(n));
			if(checkString(credit.getType()).equalsIgnoreCase("reduction")){
				reductions+=credit.getAmount();
			}
		}
		if(patientAmount>0){
			patientInvoices.put(uid,(patientAmount-reductions)/patientAmount);
		}
	}
	for(int n=0;n<lines.size();n++){
		String[] values = lines.elementAt(n).split(";");
		debetid = values[0];
		group = values[1];
		
		if(group.length()==0){
			serviceuid = values[2];
			servicename = "";
			service = Service.getService(serviceuid);
			if(service!=null){
				servicename = service.getLabel(sWebLanguage);
				group = "S: "+serviceuid+" "+servicename;
			}
			else{
				group = "?";
			}
		}
		else{
			group = "C: "+group;
		}
		
		income = (Income)incomes.get(group);
		if(income==null){
			income = new Income();
		}
		double reductionFactor = patientInvoices.get(values[6]);
		income.patient+= Double.parseDouble(values[3])*reductionFactor;
		income.insurar+= Double.parseDouble(values[4]);
		income.extrainsurar+= Double.parseDouble(values[5]);
		income.reduction+= Double.parseDouble(values[3])*(1-reductionFactor);
		incomes.put(group,income);
	}
	
	Iterator iter = incomes.keySet().iterator();
	String sClass = "1";
	int recordCount = 0;
	while(iter.hasNext()){
		recordCount++;
	
		group = (String)iter.next();
		income = (Income)incomes.get(group);
		
		totalpatient+= income.patient;
		totalinsurar+= income.insurar;
		totalextrainsurar+= income.extrainsurar;
		totalreduction+= income.reduction;

		// alternate row-style
   		if(sClass.length()==0) sClass = "1";
   		else                   sClass = "";
		
		out.print("<tr class='"+sClass+"'>"+
		           "<td>"+group+"</td>"+
		           "<td>"+deci.format(income.getTotal())+currency+"</td>"+
		           "<td>"+deci.format(income.patient)+currency+"</td>"+
		           "<td>"+deci.format(income.insurar)+currency+"</td>"+
		           "<td>"+deci.format(income.extrainsurar)+currency+"</td>"+
		           "<td>"+deci.format(income.reduction)+currency+"</td>"+
		          "</tr>");
	}
	
	// total
	out.print("<tr class='admin'>"+
	           "<td>"+getTran(request,"Web","total",sWebLanguage)+"</td>"+
	           "<td>"+deci.format(totalpatient+totalinsurar+totalextrainsurar+totalreduction)+currency+"</td>"+
	           "<td>"+deci.format(totalpatient)+currency+"</td>"+
	           "<td>"+deci.format(totalinsurar)+currency+"</td>"+
	           "<td>"+deci.format(totalextrainsurar)+currency+"</td>"+
	           "<td>"+deci.format(totalreduction)+currency+"</td>"+
	          "</tr>");
%>
</table>
    
<%
	if(recordCount > 0){
		%><%=recordCount%> <%=getTran(request,"web","recordsFound",sWebLanguage)%><%
	}
	else{
		%><%=getTran(request,"web","noRecordsFound",sWebLanguage)%><%
    }
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="window.close();"/>
<%=ScreenHelper.alignButtonsStop()%>