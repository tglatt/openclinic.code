<%@page import="ocdhis2.*,be.mxs.common.util.system.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<style>
	.progress_bar {
	  position:fixed;
	  top: 0;
	  height: 6px;
	  background:url(../../_img/themes/default/tradmin_bg.gif) no-repeat #4975A7;
	  width: 0%;
	  -moz-transition: all 4s ease;
	  -moz-transition-delay: 1s;
	  -webkit-transition: all 4s ease;
	  -webkit-transition-delay: 1s;
	  transition: all 4s ease;
	  transition-delay: 1s;
	}
	
	body {
	     padding-top: 10px; 
	}
</style>
<%
	String uids = checkString(request.getParameter("uids"));
	String organisationlevel=checkString(request.getParameter("organisationlevel"));
	MedwanQuery.getInstance().setConfigString("activeservice", organisationlevel);
	try{
		long day = 24*3600*1000;
		long month=32*day;
		DHIS2Exporter exporter = new DHIS2Exporter(uids);
		if(organisationlevel.length()>0){
			exporter.setPluginParameter("organisationlevel", organisationlevel);
		}
		
		String format = checkString(request.getParameter("format"));
		if(ScreenHelper.parseDate(request.getParameter("begin"))!=null && ScreenHelper.parseDate(request.getParameter("end"))!=null){
			exporter.setBegin(ScreenHelper.parseDate(request.getParameter("begin")));
			exporter.setEnd(ScreenHelper.parseDate(request.getParameter("end")));
		}
		else if(ScreenHelper.parseDate(request.getParameter("begin"))!=null && ScreenHelper.parseDate(request.getParameter("end"))==null){
			exporter.setBegin(ScreenHelper.parseDate(request.getParameter("begin")));
			exporter.setEnd(new java.util.Date(ScreenHelper.parseDate(request.getParameter("begin")).getTime()+ SH.getTimeDay()));
		}
		else if (SH.p(request,"year").length()>0){
			exporter.setBegin(new SimpleDateFormat("yyyyMMdd").parse(request.getParameter("year")+"0101"));
			exporter.setEnd(new SimpleDateFormat("yyyyMMdd").parse((Integer.parseInt(request.getParameter("year"))+1)+"0101"));
		}
		else if (SH.p(request,"quarter").length()>0){
			String quarter=request.getParameter("quarter");
			if(quarter.contains("Q1")){
				exporter.setBegin(new SimpleDateFormat("yyyyMMdd").parse(request.getParameter("quarter").split("Q")[0]+"0101"));
				exporter.setEnd(new SimpleDateFormat("yyyyMMdd").parse(request.getParameter("quarter").split("Q")[0]+"0401"));
			}
			else if(quarter.contains("Q2")){
				exporter.setBegin(new SimpleDateFormat("yyyyMMdd").parse(request.getParameter("quarter").split("Q")[0]+"0401"));
				exporter.setEnd(new SimpleDateFormat("yyyyMMdd").parse(request.getParameter("quarter").split("Q")[0]+"0701"));
			}
			else if(quarter.contains("Q3")){
				exporter.setBegin(new SimpleDateFormat("yyyyMMdd").parse(request.getParameter("quarter").split("Q")[0]+"0701"));
				exporter.setEnd(new SimpleDateFormat("yyyyMMdd").parse(request.getParameter("quarter").split("Q")[0]+"1001"));
			}
			else if(quarter.contains("Q4")){
				exporter.setBegin(new SimpleDateFormat("yyyyMMdd").parse(request.getParameter("quarter").split("Q")[0]+"1001"));
				exporter.setEnd(new SimpleDateFormat("yyyyMMdd").parse((Integer.parseInt(request.getParameter("quarter").split("Q")[0])+1)+"0101"));
			}
		}
		else{
			exporter.setBegin(new SimpleDateFormat("yyyyMMdd").parse(request.getParameter("period")+"01"));
			exporter.setEnd(new SimpleDateFormat("yyyyMMdd").parse(new SimpleDateFormat("yyyyMM").format(new java.util.Date(exporter.getBegin().getTime()+month))+"01"));
		}
		exporter.setDhis2document(MedwanQuery.getInstance().getConfigString("templateDirectory","/var/tomcat/webapps/openclinic/_common_xml")+"/"+MedwanQuery.getInstance().getConfigString("dhis2document","dhis2.bi.xml"));
		exporter.setLanguage(sWebLanguage);
		if(format.equalsIgnoreCase("html") && exporter.export("html")){
			%>
				<p>
					<a href='javascript:copyToClipboard();'><%=getTran(request,"web","copytoclipboardcsv",sWebLanguage) %></a>
				</p>
			<%
			out.println(exporter.getHtml());
		}
		else if(format.equalsIgnoreCase("htmlfull") && exporter.export("htmlfull")){
			%>
				<p>
					<a href='javascript:copyToClipboard();'><%=getTran(request,"web","copytoclipboardcsv",sWebLanguage) %></a>
				</p>
			<%
			out.println(exporter.getHtml());
		}
		else if(format.equalsIgnoreCase("dhis2server")){
			exporter.setJspWriter(out);
			out.println("<div id='progressBar' class='progress_bar'></div><script>document.getElementById('progressBar').style.width='0%';</script>");
			out.flush();
			
			if(exporter.export("dhis2server")){
				Thread.sleep(4000);
				out.println("<font style='font-size: 16px; font-weight: bold'><br/>"+getTran(request,"web","successfultransmission",sWebLanguage)+"</font><script>document.body.scrollTop = document.body.scrollHeight;</script>");
			}
			else{
				out.println("Error sending data to DHIS2!<p/>"+DHIS2Helper.sError+"<script>document.body.scrollTop = document.body.scrollHeight;</script>");
			}
		}
		else if(format.equalsIgnoreCase("dhis2serverdelete")){
			exporter.setJspWriter(out);
			out.println("<div id='progressBar' class='progress_bar'></div>");
			if(exporter.export("dhis2serverdelete")){
				Thread.sleep(5000);
				out.println("<font style='font-size: 16px; font-weight: bold'>"+getTran(request,"web","successfultransmission",sWebLanguage)+"</font><script>document.body.scrollTop = document.body.scrollHeight;</script>");
			}
			else{
				out.println("Error sending data to DHIS2!<p/>"+DHIS2Helper.sError+"<script>document.body.scrollTop = document.body.scrollHeight;</script>");
			}
		}
		else{
			out.println("Error sending data to DHIS2!<p/>"+DHIS2Helper.sError);
		}
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>

<script>
	function showRecords(dataset,dataelement,option,attributeoption,datasettitle){
		var URL="/statistics/showDHIS2Records.jsp&datasettitle="+datasettitle+"&dataset="+dataset+"&dataelement="+dataelement+"&option="+option+"&attributeoption="+attributeoption+"&period=<%=request.getParameter("period")%>&end=<%=request.getParameter("end")%>&begin=<%=request.getParameter("begin")%>";
		openPopup(URL,800,600,"OpenClinic-DHIS2-Records");
	}
	
	function copyToClipboard(){
		var s="";
		tables = document.getElementsByTagName("table");
		for(n=0;n<tables.length;n++){
			if(tables[n].getAttribute("data-tag") && tables[n].getAttribute("data-tag")=='dhis2'){
				rows = tables[n].getElementsByTagName("tr");
				for(m=0;m<rows.length;m++){
					cells=rows[m].getElementsByTagName("td");
					for(l=0;l<cells.length;l++){
						s+=cells[l].innerHTML.replace("<center>","").replace("</center>","").replace("<b>","").replace("</b>","")+"\t";
					}
					s+="\n";
				}
				s+="\n";
			}
		}
		if (navigator && navigator.clipboard && navigator.clipboard.writeText){
			navigator.clipboard.writeText(s);
			alert('<%=getTranNoLink("web","copiedtoclipboardcsv",sWebLanguage)%>');
		}
	}
	
</script>
