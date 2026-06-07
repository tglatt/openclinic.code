<%@page import="be.mxs.common.util.pdf.general.PDFAssetNormGenerator,java.io.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	private void getNorms(String serviceid,SortedMap normsdb,String structures){
		Service service = Service.getService(serviceid);
		if(service!=null){
			//First find the norms for this service
			if(checkString(service.costcenter).length()>0 && structures.contains(service.costcenter)){
				normsdb.put(serviceid,be.openclinic.assets.Util.getNormsForService(serviceid));
			}
			//Then find the norms for all the children
			Vector children=Service.getChildIds(serviceid);
			for(int n=0;n<children.size();n++){
				service = Service.getService((String)children.elementAt(n));
				if(service!=null && checkString(service.costcenter).length()>0 && structures.contains(service.costcenter)){
					normsdb.put((String)children.elementAt(n),be.openclinic.assets.Util.getNormsForService((String)children.elementAt(n)));
				}
			}
		}
	}
%>
<%
	SH.syslog(1);
	session.removeAttribute("normsreport");
	String serviceid = checkString(request.getParameter("serviceid"));
	String snorm = checkString(request.getParameter("nomenclature"));
	String structures = checkString(request.getParameter("structures"));
	if(checkString(request.getParameter("format")).equalsIgnoreCase("csv")){
		SH.syslog(2);
		SortedMap normsdb = new TreeMap();
		String nomenclature="";
		for(int n=0;n<snorm.split(";").length;n++){
			if(snorm.split(";")[n].split("\\@").length>1){
				nomenclature+=snorm.split(";")[n].split("\\@")[1]+";";
			}
		}
		//We calculate all norms for all services that descend form the root service
		getNorms(serviceid,normsdb,structures);
		SH.syslog(3+": "+serviceid+" - "+normsdb.size()+" - "+structures);
		StringBuffer report = new StringBuffer();
		//Create Header
		//*************
		report.append(";");
		//We make a list of all relevant norms
		SortedSet allnorms = new TreeSet();
		Iterator services = normsdb.keySet().iterator();
		Vector nomenclatures = new Vector(Arrays.asList(nomenclature.split(";")));
		while(services.hasNext()){
			String activeserviceid = (String)services.next();
			SortedMap activenorms = (SortedMap)normsdb.get(activeserviceid);
			Iterator norms = activenorms.keySet().iterator();
			while(norms.hasNext()){
				String activenorm = ((String)norms.next()).split(";")[0];
				if(nomenclature.length()==0 || nomenclatures.contains(activenorm)){
					allnorms.add(activenorm);
				}
			}
		}
		Iterator iNorms = allnorms.iterator();
		while(iNorms.hasNext()){
			report.append((iNorms.next()+";").toUpperCase());
		}
		report.append("\n");
		//Write content
		//*************
		services = normsdb.keySet().iterator();
		while(services.hasNext()){
			String activeserviceid = (String)services.next();
			//Write content for new service
			//*****************************
			report.append(activeserviceid+";");
			SortedMap activenorms = (SortedMap)normsdb.get(activeserviceid);
			Iterator norms = allnorms.iterator();
			while(norms.hasNext()){
				String an = ((String)norms.next());
				String activenorm = an.split(";")[0];
				if(nomenclature.length()==0 || nomenclature.contains(activenorm)){
					String sOk = "0";
					double situation=0;
					double minimumnorm=0;
					String result = (String)activenorms.get(activenorm);
					if(result!=null && result.split(";").length>1){
						minimumnorm = Double.parseDouble(result.split(";")[0]);
						situation = Double.parseDouble(result.split(";")[1]);
						sOk=situation>=minimumnorm?"1":minimumnorm>0?SH.formatDouble(situation/minimumnorm):"0";
						report.append(sOk+";");
					}
					else{
						report.append(";");
					}
				}
			}
			report.append("\n");
		}
		session.setAttribute("normsreport","done");
	    response.setContentType("application/octet-stream; charset=windows-1252");
	    response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicStatistic"+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".csv\"");
	    ServletOutputStream os = response.getOutputStream();
	    byte[] b = report.toString().getBytes();
	    for(int n=0; n<b.length; n++){
	        os.write(b[n]);
	    }
	    os.flush();
	    os.close();
	}
	else if(checkString(request.getParameter("format")).equalsIgnoreCase("csv2")){
		SortedMap normsdb = new TreeMap();
		StringBuffer report = new StringBuffer();
		String norms="";
		//We calculate all norms for all services that descend form the root service
		getNorms(serviceid,normsdb,structures);
		//Now we've got all norms for all structures starting from serviceid and lower
		//Run through each of the structures
		Iterator services = normsdb.keySet().iterator();
		while(services.hasNext()){
			String activeserviceid = (String)services.next();
			Service service = Service.getService(activeserviceid);
			int numberofnorms=0,numberofcompliantnorms=0;
			double compliance=0;
			//Write full service name to report
			report.append(service.getFullyQualifiedName(sWebLanguage)+"\n");
			//Write norm headers to report
			report.append(ScreenHelper.getTranNoLink("asset", "nomenclature", sWebLanguage)+";");
			report.append(ScreenHelper.getTranNoLink("asset", "norm", sWebLanguage)+";");
			report.append(ScreenHelper.getTranNoLink("asset", "minimum", sWebLanguage)+";");
			report.append(ScreenHelper.getTranNoLink("asset", "existing", sWebLanguage)+";");
			report.append(ScreenHelper.getTranNoLink("asset", "nonfunctional", sWebLanguage)+";");
			report.append(ScreenHelper.getTranNoLink("asset", "needed", sWebLanguage)+";");
			report.append("% "+ScreenHelper.getTranNoLink("asset", "compliant", sWebLanguage)+"\n");
			//Now we must run through all the norms and show the results of the relevant ones
			SortedMap servicenorms = (SortedMap)normsdb.get(activeserviceid);
			Iterator iservicenorms = servicenorms.keySet().iterator();
			while(iservicenorms.hasNext()){
				String sn_nomenclature = (String)iservicenorms.next();
				if(norms.length()==0 || (norms+";").contains(sn_nomenclature)){
					String sn_result = ScreenHelper.checkString((String)servicenorms.get(sn_nomenclature));
					if(sn_result.split(";").length>1){
						numberofnorms++;
						double sn_minimumquantity = Double.parseDouble(sn_result.split(";")[0]);
						double sn_foundquantity = Double.parseDouble(sn_result.split(";")[1]);
						double sn_nonfunctional = Double.parseDouble(sn_result.split(";")[2]);
						double sn_compliance = 0;
						if(sn_foundquantity>=sn_minimumquantity) {
							sn_compliance=1;
						}
						else if(sn_minimumquantity>0){
							sn_compliance=sn_foundquantity/sn_minimumquantity;
						}
						report.append(sn_nomenclature.toUpperCase() + ";");
						report.append(ScreenHelper.getTranNoLink("admin.nomenclature.asset", sn_nomenclature, sWebLanguage)+ ";");
						report.append(new Double(sn_minimumquantity).intValue()+";");
						report.append(sn_foundquantity==0?"0;":new Double(sn_foundquantity).intValue()+";");
						report.append(sn_nonfunctional==0?"0;":new Double(sn_nonfunctional).intValue()+";");
						report.append(sn_foundquantity>=sn_minimumquantity?"0;":new Double(sn_minimumquantity-sn_foundquantity).intValue()+";");
						if(sn_foundquantity>=sn_minimumquantity){
							report.append("100");
						}
						else{
							report.append(SH.formatDouble(sn_compliance*100));
						}
						report.append("\n");
						if(sn_foundquantity<sn_minimumquantity){
						}
						else{
							numberofcompliantnorms++;
						}
						compliance+=sn_compliance;
					}
				}
			}
			report.append(ScreenHelper.getTranNoLink("web", "conformityscore", sWebLanguage)+": ");
			report.append(SH.formatDouble(compliance*100/numberofnorms)+"%\n\n");
		}
		session.setAttribute("normsreport","done");
	    response.setContentType("application/octet-stream; charset=windows-1252");
	    response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicStatistic"+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".csv\"");
	    ServletOutputStream os = response.getOutputStream();
	    byte[] b = report.toString().getBytes();
	    for(int n=0; n<b.length; n++){
	        os.write(b[n]);
	    }
	    os.flush();
	    os.close();
	}
	else if(checkString(request.getParameter("format")).equalsIgnoreCase("pdf")){
		try{
			PDFAssetNormGenerator report = new PDFAssetNormGenerator(activeUser,checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase());
			ByteArrayOutputStream baosPDF = report.generatePDFDocumentBytes(request, serviceid, snorm, structures,sWebLanguage);
	        StringBuffer sbFilename = new StringBuffer();
	        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");
	
	        StringBuffer sbContentDispValue = new StringBuffer();
	        sbContentDispValue.append("inline; filename=")
	                          .append(sbFilename);
	
	        // prepare response
			session.setAttribute("normsreport","done");
		    response.setContentType("application/pdf; charset=windows-1252");
		    response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicStatistic"+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".pdf\"");
	        response.setContentLength(baosPDF.size());
	
	        // write PDF to servlet
	        ServletOutputStream sos = response.getOutputStream();
	        baosPDF.writeTo(sos);
	        sos.flush();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
%>