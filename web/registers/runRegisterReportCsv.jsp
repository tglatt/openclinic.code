<%@page import="be.openclinic.medical.Diagnosis"%>
<%@page import="be.openclinic.medical.RequestedLabAnalysis"%>
<%@page import="be.openclinic.reporting.*"%>
<%@include file="/includes/helper.jsp"%>
<%
	try{
	response.setContentType("application/octet-stream");
	ServletOutputStream os = response.getOutputStream();
	StringBuffer sOutput = new StringBuffer();
	String sLanguage = checkString(request.getParameter("language"));
	String sBegindate = checkString(request.getParameter("begindate"));
	String sEnddate = checkString(request.getParameter("enddate"));
	String id = checkString(request.getParameter("id"));
	String sServiceId = checkString(request.getParameter("serviceid"));
    String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + MedwanQuery.getInstance().getConfigString("registersfile","registers.xml");
    SAXReader reader = new SAXReader(false);
    Document document = reader.read(new URL(sDoc));
    Iterator registers = document.getRootElement().elementIterator("register");
    while(registers.hasNext()){
    	Element register = (Element)registers.next();
    	if(checkString(register.attributeValue("id")).equalsIgnoreCase(id)){
    	    response.setContentType("application/octet-stream; charset=windows-1252");
    		response.setHeader("Content-Disposition", "Attachment;Filename=\""+getTran(request,"web.occup",register.attributeValue("transactiontype"),sLanguage)+"_"+(sServiceId.length()==0?"":sServiceId+"_")+ new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()) + ".csv\"");
    		Iterator columns = register.element("columns").elementIterator("column");
			while(columns.hasNext()){
				Element column = (Element)columns.next();
				sOutput.append(getTranNoLink(column.attributeValue("labelid").split(";")[0],column.attributeValue("labelid").split(";")[1],sLanguage)+";");
			}
			sOutput.append("\n");
    		//This is the register that is needed
    		String transactiontype = register.attributeValue("transactiontype");
    		//We first construct the register query
    		String sSql="select h.personid, t.* from healthrecord h, transactions t where"+
    					" h.healthrecordid=t.healthrecordid and"+
    					" t.transactiontype=? and"+
    					" t.updatetime>=? and"+
    					" t.updatetime<=? and"+
    					" t.serverid=?"+
    					" order by t.updatetime,t.transactionid";
    		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
    		PreparedStatement ps = conn.prepareStatement(sSql);
    		ps.setString(1,transactiontype);
    		ps.setDate(2,new java.sql.Date(ScreenHelper.parseDate(sBegindate).getTime()));
    		ps.setTimestamp(3,new java.sql.Timestamp(ScreenHelper.parseDate(sEnddate).getTime()+SH.getTimeDay()-1));
    		ps.setInt(4,MedwanQuery.getInstance().getConfigInt("serverId"));
    		ResultSet rs = ps.executeQuery();
    		String sValidServices="";
			//First check if there is a department limitation
			if(SH.c(sServiceId).length()>0) {
				sValidServices=Service.getChildIdsAsString(sServiceId);
			}
    		int counter=0;
    		while(rs.next()){
    			//Each result is a row in the registry
    			//Now we will browse through the columns in order to compose the register line
    			Register reg = new Register(MedwanQuery.getInstance().getConfigInt("serverId"), rs.getInt("transactionid"),rs.getInt("personid"),sLanguage);
    			if(sValidServices.length()>0) {
    				if(reg.getEncounter()!=null && !sValidServices.contains(reg.getEncounter().getServiceUID())){
    					continue;
    				}
    			}
    			//Check if we don't have to exclude the transaction
    			if(SH.c(register.attributeValue("labtestsneeded")).length()>0) {
    				boolean bFound=false;
    				//At least one of the lab tests must be present to consider this transaction
    				for(int n=0;n<register.attributeValue("labtestsneeded").split(";").length;n++) {
    					RequestedLabAnalysis analysis = RequestedLabAnalysis.get(SH.getServerId(), rs.getInt("transactionid"), register.attributeValue("labtestsneeded").split(";")[n]);
    					if(analysis!=null && analysis.getRequestDate()!=null) {
    						bFound=true;
    						break;
    					}
    				}
    				if(!bFound) {
    					continue;
    				}
    			}
				if(SH.c(register.attributeValue("loinccodesneeded")).length()>0) {
					boolean bFound=false;
					String[] loinccodes = register.attributeValue("loinccodesneeded").split(";");
					for(int n=0;n<loinccodes.length;n++) {
						RequestedLabAnalysis analysis = RequestedLabAnalysis.getByLOINC(SH.getServerId(), rs.getInt("transactionid"), loinccodes[n]);
						if(analysis!=null  && analysis.getRequestDate()!=null) {
							bFound=true;
							break;
						}
					}
					if(!bFound) {
						continue;
					}
				}
    			if(SH.c(register.attributeValue("itemtypeneeded")).length()>0) {
    				if(reg.getTransaction().getItem(register.attributeValue("itemtypeneeded"))==null) {
    					continue;
    				}
    				else if(SH.c(register.attributeValue("itemvalueneeded")).length()>0) {
    					if(!reg.getTransaction().getItemValue(register.attributeValue("itemtypeneeded")).equals(SH.c(register.attributeValue("itemvalueneeded")))) {
    						continue;
    					}
    				}
    			}
    			Vector<Register> regs = new Vector<Register>();
    			if(SH.c(register.attributeValue("splittransaction")).length()==0){
    				regs.add(reg);
    			}
    			else if(register.attributeValue("splittransaction").equalsIgnoreCase("icd10diagnosis")){
    				Collection items =reg.getTransaction().getItems();
    				Iterator iItems = items.iterator();
    				int nDiags=0;
    				while(iItems.hasNext()){
    					ItemVO item =(ItemVO)iItems.next();
    					if(item.getType().startsWith("ICD10Code")){
    						if(SH.c(register.attributeValue("newcasediagnosis")).equals("1")){
    							if(!Diagnosis.isNC(MedwanQuery.getInstance().getConfigInt("serverId")+"."+rs.getInt("transactionid"), "icd10", item.getType().replaceAll("ICD10Code", ""))){
    								continue;
    							}
    						}
		    				Register newreg = new Register(MedwanQuery.getInstance().getConfigInt("serverId"), rs.getInt("transactionid"),rs.getInt("personid"),sLanguage);
							newreg.setTransaction(MedwanQuery.getInstance().loadTransactionNoCacheNoStore(reg.getTransaction().getServerId(),reg.getTransaction().getTransactionId()));
		    				Collection newitems =newreg.getTransaction().getItems();
    	    				Iterator inewItems = newitems.iterator();
    	    				while(inewItems.hasNext()){
    	    					ItemVO newitem =(ItemVO)inewItems.next();
    	    					if(newitem.getType().startsWith("ICD10Code") && !newitem.getType().equals(item.getType())){
    	    						newitem.setType("void");
    	    					}
    	    				}
    	    				regs.add(newreg);
    	    				nDiags++;
    					}
    				}
    				if(nDiags==0){
    					regs.add(reg);
    				}
    			}
    			for(int r=0;r<regs.size();r++){
    				reg=regs.elementAt(r);
	    			reg.setCounter(counter);
        			Iterator<org.dom4j.Element> columnsets = register.elementIterator("columns");
        			while(columnsets.hasNext()) {
            			counter++;
            			org.dom4j.Element columnset = columnsets.next();
            			//Now check if we have to handle this columnset
            			String val="";
            			if(checkString(columnset.attributeValue("source")).length()>0){
		    				val=reg.getValue(columnset.attributeValue("source"), columnset.attributeValue("name"), "");
		    				if(checkString(columnset.attributeValue("contains")).length()>0){
		    					boolean bContains=false;
		    					for(int n=0;n<val.split(",").length;n++){
		    						if(val.split(",")[n].equals(columnset.attributeValue("contains"))){
		    							bContains=true;
		    						}
		    					}
		    					if(!bContains){
		    						val="";
		    					}
		    				}
		    				if(checkString(columnset.attributeValue("in")).length()>0){
		    					boolean bIn=false;
		    					for(int n=0;n<val.split(",").length;n++){
		    						if(columnset.attributeValue("in").indexOf(val.split(",")[n])>-1){
		    							bIn=true;
		    						}
		    					}
		    					if(!bIn){
		    						val="";
		    					}
		    				}
		    				if(val.length()==0) {
		    					continue;
		    				}
            			}
            			columns = columnset.elementIterator("column");
            			while(columns.hasNext()){
            				org.dom4j.Element column = (org.dom4j.Element)columns.next();
		        			String concatval="";
		    				val="";
		    				Vector<String> sourceValues=new Vector<String>();
		    				for(int i=0;i<column.attributeValue("source").split(";").length;i++){
		    					try{
				    				val=reg.getValue(column.attributeValue("source").split(";",-1)[i], column.attributeValue("name").split(";",-1)[i], checkString(column.attributeValue("translateresult")).split(";",-1).length<=i?"":checkString(column.attributeValue("translateresult")).split(";",-1)[i]);
				    				if(checkString(column.attributeValue("contains")).split(";",-1).length>i && checkString(column.attributeValue("contains")).split(";",-1)[i].length()>0){
				    					boolean bContains=false;
				    					for(int n=0;n<val.split(",").length;n++){
				    						if(val.split(",")[n].equals(column.attributeValue("contains").split(";",-1)[i])){
				    							bContains=true;
				    							if(SH.c(column.attributeValue("outputsource")).length()==0){
				    								break;
				    							}
				    						}
				    					}
				    					if(!bContains){
				    						val="";
				    					}
				    				}
				    				if(checkString(column.attributeValue("in")).split(";",-1).length>i && checkString(column.attributeValue("in")).split(";",-1)[i].length()>0){
				    					boolean bIn=false;
				    					for(int n=0;n<val.split(",").length;n++){
				    						if(column.attributeValue("in").split(";",-1)[i].indexOf(val.split(",")[n])>-1){
				    							bIn=true;
				    							if(SH.c(column.attributeValue("outputsource")).length()==0){
				    								break;
				    							}
				    						}
				    					}
				    					if(!bIn){
				    						val="";
				    					}
				    				}
				    				if(val.length()>0 && checkString(column.attributeValue("concatenate")).equals("1")){
				    					if(concatval.length()>0){
				    						if(column.attributeValue("separator")!=null) {
					    						concatval+=column.attributeValue("separator");
				    						}
				    						else {
				    							concatval+=", ";
				    						}
				    					}
				    					concatval+=val;
				    				}
				    				else if(val.length()==0 && !checkString(column.attributeValue("concatenate")).equals("1")){
		    							if(SH.c(column.attributeValue("outputsource")).length()==0){
		    								break;
		    							}
				    				}
		    					}
		    					catch(Exception e){
		    						e.printStackTrace();
		    					}
			    				sourceValues.add(val);
		    				}
		    				if(concatval.length()>0){
		    					val=concatval;
		    				}
		    				if(checkString(column.attributeValue("outputsource")).length()>0 && checkString(column.attributeValue("outputname")).length()>0){
		        				val="";
		        				int validValues=0;
		        				for(int n=0;n<sourceValues.size();n++){
		        					if(sourceValues.elementAt(n).length()>0){
		        						validValues++;
		        					}
		        				}
		        				if(SH.c(column.attributeValue("criterianeeded")).length()==0 || Integer.parseInt(column.attributeValue("criterianeeded"))<=validValues){
			        				for(int i=0;i<column.attributeValue("outputsource").split(";").length;i++){
			        					if(sourceValues.size()<=i || sourceValues.elementAt(i).length()>0){
				        					if(val.length()>0) {
				        						val+="{sep} ";
				        					}
				        					val+=reg.getValue(column.attributeValue("outputsource").split(";")[i], column.attributeValue("outputname").split(";")[i], checkString(column.attributeValue("outputtranslateresult")).split(";").length<=i?"":checkString(column.attributeValue("outputtranslateresult")).split(";")[i]);
			        					}
			        				}
		        				}
		    				}
		    				if(val.length()>0 && checkString(column.attributeValue("output")).length()>0){
		    					val=column.attributeValue("output");
		    				}
		    				sOutput.append(val.replaceAll("\\{sep\\}",", ")+";");
		    				if(checkString(column.attributeValue("columns")).length()>0){
		    					int cols = Integer.parseInt(column.attributeValue("columns"));
		    					for(int n=1;n<cols;n++){
		    						sOutput.append(";");
		    					}
		    				}
		    			}
		    			sOutput.append("\n");
        			}
    			}
    		}
    		rs.close();
    		ps.close();
    		conn.close();
    	}
    }
    byte[] b = sOutput.toString().getBytes("ISO-8859-1");
    for (int n=0;n<b.length;n++) {
        os.write(b[n]);
    }
    os.flush();
    os.close();
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
