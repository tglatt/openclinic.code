<%@page import="be.openclinic.finance.Insurance"%>
<%@page import="org.dom4j.DocumentException,
                java.util.*,
                be.openclinic.adt.Encounter,
                java.util.Date"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>
<%
    session.removeAttribute("activePatient");
    ScreenHelper.getSQLDate("");
    
    String simmatnew        = checkString(request.getParameter("findimmatnew")).toUpperCase(),
           sArchiveFileCode = checkString(request.getParameter("findArchiveFileCode")).toUpperCase(),
           sPersonID        = checkString(request.getParameter("findPersonID")).toUpperCase(),
           snatreg          = checkString(request.getParameter("findnatreg")),
           sName            = checkString(request.getParameter("findName")).toUpperCase(),
           sFirstname       = checkString(request.getParameter("findFirstname")).toUpperCase(),
           sDateOfBirth     = checkString(request.getParameter("findDateOfBirth")),
           sDistrict        = checkString(request.getParameter("findDistrict")),
           sSector        	= checkString(request.getParameter("findSector")),
           sUnit            = checkString(request.getParameter("findUnit"));

    String sAction  = checkString(request.getParameter("Action")),
           sRSIndex = checkString(request.getParameter("RSIndex"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    Debug.println("\n************************ _common/patientslist.jsp *********************");
    Debug.println("sAction      : "+sAction);
    Debug.println("sRSIndex     : "+sRSIndex);
    Debug.println("simmatnew    : "+simmatnew);
    Debug.println("sArchiveFileCode : "+sArchiveFileCode);
    Debug.println("sPersonID    : "+sPersonID);
    Debug.println("snatreg      : "+snatreg);
    Debug.println("sName        : "+sName);
    Debug.println("sFirstname   : "+sFirstname);
    Debug.println("sDateOfBirth : "+sDateOfBirth);
    Debug.println("sDistrict    : "+sDistrict);
    Debug.println("sSector      : "+sSector);
    Debug.println("sUnit        : "+sUnit+"\n");
    ///////////////////////////////////////////////////////////////////////////////////////////////

    List lResults = null;
    int iMaxResultSet = SH.ci("maximumPatientsOnScreen",100), iCounter = 0, iOverallCounter = 0;

    if(checkString(request.getParameter("ListAction")).length() > 0){
        lResults = (List)session.getAttribute("searchResultsList");
    }
    
    if(lResults==null && activeUser!=null){
        if(sAction.equals("MY_HOSPITALIZED")){
            lResults = AdminPerson.getUserHospitalized(activeUser.userid);
        } 
        else if(sAction.equals("MY_VISITS")){
            lResults = AdminPerson.getUserVisits(activeUser.userid);
        } 
        else if(sUnit.length() > 0){
            lResults = AdminPerson.getPatientsInEncounterServiceUID(simmatnew,sArchiveFileCode,snatreg,sName,sFirstname,sDateOfBirth,sUnit,sPersonID,sDistrict,sSector);
        } 
        else{
            if((simmatnew+sArchiveFileCode+snatreg+sName+sFirstname+sDateOfBirth+sPersonID+sDistrict+sSector).length()>0){
            	lResults = AdminPerson.getAllPatients(simmatnew,sArchiveFileCode,snatreg,sName,sFirstname,sDateOfBirth,sPersonID,sDistrict,SH.ci("maxNumberOfPatientsInResultSet",10000),sSector);
            }
            else {
            	lResults = new ArrayList();
            }
        }
        session.setAttribute("searchResultsList",lResults);
    }
    boolean bRS = false;

    if(lResults.size() > 0){
        StringBuffer sResult = new StringBuffer(); 
        String sLink = "", sClass = "", sPage;
        sPage = activeUser.getParameter("DefaultPage");

        // put a new SessionContainerWO in het session when a patient is searched,
        // otherwise 'Previousvalue' has the content of the previous patient.
        // Keep the user !
        SessionContainerWO sessionContainerWO_old = (SessionContainerWO) session.getAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER");
        session.setAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER",null);
        SessionContainerWO sessionContainerWO_new = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        sessionContainerWO_new.setUserVO(sessionContainerWO_old.getUserVO());
        session.setAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER",sessionContainerWO_new);

        SAXReader xmlReader = new SAXReader();
        String sDefaultPageXML = MedwanQuery.getInstance().getConfigString("templateSource")+"defaultPages.xml";
        Document document;

        Hashtable hDefaultPages = new Hashtable();
        boolean bXMLDocumentError = false;
        try{
            document = xmlReader.read(new URL(sDefaultPageXML));
            if(document!=null){
                Element root = document.getRootElement();
                if(root!=null){
                    Element ePage;
                    Iterator elements = root.elementIterator("defaultPage");
                    String sType, sPageLink;
                    while (elements.hasNext()){
                        ePage = (Element) elements.next();
                        sType = checkString(ePage.attributeValue("type")).toLowerCase();
                        sPageLink = checkString(ePage.elementText("page"));
                        hDefaultPages.put(sType,sPageLink);
                    }
                }
            }
        }
        catch(DocumentException e){
            Debug.println("XML-Document Exception in patientslist.jsp");
            bXMLDocumentError = true;
        }

        if(sPage==null || sPage.trim().length()==0 || bXMLDocumentError && (activeUser.getAccessRight("patient.administration.select"))){
            sPage = "patientdata.do?ts="+getTs()+"&personid=";
        }
        else {
            String sType = checkString((String) hDefaultPages.get(sPage.toLowerCase()));
            if(sType.length() > 0){
                if(sPage.equals("administration")){
                    sPage = "patientdata.do?ts="+getTs()+"&personid=";
                }
                else{
                    sPage = sType+"&ts="+getTs()+"&PersonID=";
                }
            }
            else{
                sPage = "";
            }
        }

        if(sRSIndex.length() > 0){
            iOverallCounter = Integer.parseInt(sRSIndex);
        }
        
        String sTmpServiceID, sInactive, sBed, sCity;
        AdminPerson tempPat;
        Encounter enc;
        boolean bShowCity=(MedwanQuery.getInstance().getConfigInt("showCityInPatientsList",0)==1);
        HashSet pats = new HashSet();

        while((iOverallCounter+iCounter) < lResults.size() && iCounter < iMaxResultSet){
            tempPat = (AdminPerson) lResults.get(iCounter+iOverallCounter);
            if(pats.contains(tempPat.personid)){
            	iCounter++;
            	continue;
            }
            pats.add(tempPat.personid);
            sTmpServiceID = "";
            sBed="";

            enc = Encounter.getActiveEncounter(tempPat.personid);
            if(enc!=null){
                sInactive = "";
                sTmpServiceID = enc.getServiceUID();
                if(enc.getBed()!=null){
                	sBed = checkString(enc.getBed().getName());
                }
            }
            else {
                sInactive = "Text";
            }
            if(sPage.trim().length() > 0){
                sLink = sPage+checkString(tempPat.personid);
                sResult.append("<tr");
            }
            else{
                sLink = "";
                sResult.append("<tr");
            }

            if(enc!=null && "On".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("showServiceInPatientList"))){
                if(sTmpServiceID.trim().length() > 0){
                	String img="";
                	if(MedwanQuery.getInstance().getConfigInt("checkPatientListInvoices",0)==1 && enc.hasInvoices()){
                		img+="<img style='vertical-align: middle' src='"+sCONTEXTPATH+"/_img/icons/icon_money.gif'/>";
                	}
                	if(MedwanQuery.getInstance().getConfigInt("checkPatientListTransactions",0)==1 && enc.hasTransactions()){
                		img+="<img style='vertical-align: middle' src='"+sCONTEXTPATH+"/_img/icons/icon_admin.gif'/>";
                	}
                	
                    String sHospDate = "<td onClick='window.location.href=\""+sLink+"\";'>"+ScreenHelper.fullDateFormat.format(enc.getBegin())+" "+img+"</td>";
                    long duration = (new Date().getTime() - enc.getBegin().getTime());
                    long days = 24 * 3600 * 1000;
                    days = days * 90;
                    if(enc.getEnd()!=null){
	                    String manager= (enc.getManagerUID()!=null && enc.getManagerUID().length()>0? User.getFullUserName(enc.getManagerUID()):"");
	                    sTmpServiceID = "<td  onClick='window.location.href=\""+sLink+"\";' style='text-decoration: line-through'>"+sTmpServiceID+" "+getTran(request,"Service",sTmpServiceID,sWebLanguage)+"</td><td  onClick='window.location.href=\""+sLink+"\";' style='text-decoration: line-through'>"+manager+"</td><td  onClick='window.location.href=\""+sLink+"\";' style='text-decoration: line-through'>"+sBed+"</td><td  onClick='window.location.href=\""+sLink+"\";' style='text-decoration: line-through'>"+ScreenHelper.fullDateFormat.format(enc.getBegin())+" "+img+"</td>";
                    }
                    else{
	                    if(duration > days || duration < 0){
	                        sHospDate = "<td  onClick='window.location.href=\""+sLink+"\";' style='color: red'>"+ScreenHelper.fullDateFormat.format(enc.getBegin())+" "+img+ "</td>";
	                    }
                    
	                    String manager= (!(enc==null) && enc.getManagerUID()!=null && enc.getManagerUID().length()>0? User.getFullUserName(enc.getManagerUID()):"");
	                    sTmpServiceID = "<td onClick='window.location.href=\""+sLink+"\";'>"+sTmpServiceID+" "+getTran(request,"Service",sTmpServiceID,sWebLanguage)+"</td><td onClick='window.location.href=\""+sLink+"\";'>"+manager+"</td><td onClick='window.location.href=\""+sLink+"\";'>"+sBed+"</td>"+sHospDate;
                    }
                }
                else {
                    sTmpServiceID = "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
                }
            }

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";
            
            
            String sImmatNew = "";
            String sNatReg = "";
            Iterator iter = tempPat.ids.iterator();
            AdminID tempAdminID;

            while(iter.hasNext()){
                tempAdminID = (AdminID)iter.next();
                
                if(tempAdminID.type.equals("ImmatNew")){
                    sImmatNew = tempAdminID.value;
                } 
                else if(tempAdminID.type.equals("NatReg")){
                    sNatReg = tempAdminID.value;
                }
            }
            sCity="";
        	String[] privateDetails= new String[20];
            if(bShowCity || activeUser.getParameter("patientlist", "compact").equalsIgnoreCase("extended")){
            	AdminPrivateContact.getPrivateDetails(tempPat.personid, privateDetails);
            	sCity="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;("+checkString(privateDetails[4])+")";
            }
            sResult.append(" class='list"+sInactive+sClass+"'>"
                   +"<td onClick='window.location.href=\""+sLink+"\";'><img src='"+sCONTEXTPATH+"/_img/icons/icon_view.png' alt='"+getTranNoLink("Web","view",sWebLanguage)+"'></td>"
                   +"<td onClick='window.location.href=\""+sLink+"\";'>"+checkString(sImmatNew)+"</td>");
		           if(SH.ci("enableSearchOnHealthInsurance",0)==1){
		        	   sResult.append("<td onClick='window.location.href=\""+sLink+"\";'>"+SH.c((String)tempPat.adminextends.get("insurancenr"))+"</td>");
		           }
		           sResult.append("<td onClick='window.location.href=\""+sLink+"\";'>"+checkString(sNatReg)+"</td>"
                   +"<td onClick='window.location.href=\""+sLink+"\";'><b>"+checkString(tempPat.lastname)+"  "+checkString(tempPat.firstname)+"</b>"+sCity+"</td>"
                   +"<td onClick='window.location.href=\""+sLink+"\";'>"+checkString(tempPat.gender.toUpperCase())+"</td>"
                   +"<td nowrap><span onClick='window.location.href=\""+sLink+"\";'>"+tempPat.dateOfBirth+"</span>"+(sAction.equals("MY_VISITS") && enc!=null && enc.getEnd()==null?" <img height='16px' src='"+sCONTEXTPATH+"/_img/icons/mobile/lock.png' onclick='closeMyEncounter(\""+enc.getUid()+"\");'/>":"")+(sAction.equals("MY_VISITS") && enc!=null?" <img height='16px' src='"+sCONTEXTPATH+"/_img/icons/mobile/edit.png' onclick='editMyEncounter(\""+enc.getUid()+"\");'/>":"")+"</td>"
                   +""+sTmpServiceID
                   +"</tr>");
            if(activeUser.getParameter("patientlist", "compact").equalsIgnoreCase("extended")){
            	//Add an extra line of patient information
				String post="",village="",district="",address=SH.c(privateDetails[3]),ins="",phone="";
    			Insurance insurance = Insurance.getMostInterestingInsuranceForPatient(tempPat.personid);
    			if(insurance!=null){
    				ins=insurance.getInsurar().getName();
    				if(SH.c(insurance.getInsuranceNr()).length()>0){
    					ins+=": "+insurance.getInsuranceNr();
    				}
    			}
    			String sSmallFontStyle="color: #4975A7;font-weight: bold";
    			if(sInactive.length()>0){
    				sSmallFontStyle="color: #4975A7";
    			}
                sResult.append("<tr onClick='window.location.href=\""+sLink+"\";' class='list"+sInactive+sClass+"small'><td colspan='3'/><td>"+getTran(request,"web","address",sWebLanguage)+": <font style='"+sSmallFontStyle+"'>"+SH.c(privateDetails[3])+"</font></td><td colspan='2'>"+getTran(request,"web","district",sWebLanguage)+": <font style='"+sSmallFontStyle+"'>"+SH.c(privateDetails[14])+"</font></td><td>"+getTran(request,"web","telephone",sWebLanguage)+": <font style='"+sSmallFontStyle+"'>"+SH.c(privateDetails[7]).trim()+" "+SH.c(privateDetails[9]).trim()+"</font></td><td colspan='2'>"+getTran(request,"web","city",sWebLanguage)+": <font style='"+sSmallFontStyle+"'>"+SH.c(privateDetails[4]).trim()+"</font></td><td><font style='"+sSmallFontStyle+"'>"+ins+"</font></td></tr>");
            }
            iCounter++;
        }

        String sNext = "", sPrevious = "&nbsp;";
        if(iOverallCounter > 0){
            sPrevious = "<a href='#' title='"+getTranNoLink("Web","begin",sWebLanguage)
            +"' OnClick=\"SF.RSIndex.value='0';SF.ListAction.value='Previous';SF.submit();\">"
            +"<img height='10px' src='"+sCONTEXTPATH+"/_img/themes/default/arrow-doubleleft.gif' border='0'></a>";
            sPrevious += "&nbsp;<a href='#' title='"+getTranNoLink("Web","Previous",sWebLanguage)
            +"' OnClick=\"SF.RSIndex.value='"+(iOverallCounter - iCounter - (iMaxResultSet - iCounter))+"';SF.ListAction.value='Previous';SF.submit();\">"
            +"<img height='10px' src='"+sCONTEXTPATH+"/_img/themes/default/arrow-left.gif' border='0'></a>";
        }
        if(lResults.size() > iOverallCounter+iCounter){
            sNext = "<a href='#' title='"+getTranNoLink("Web","Next",sWebLanguage)+"' OnClick=\"SF.RSIndex.value='"
                    +(iOverallCounter+iCounter)+"';SF.ListAction.value='Next';SF.submit();\"><img height='10px' src='"+sCONTEXTPATH+"/_img/themes/default/arrow-right.gif' border='0'></a>";
            sNext += "&nbsp;<a href='#' title='"+getTranNoLink("Web","end",sWebLanguage)+"' OnClick=\"SF.RSIndex.value='"
                    +(lResults.size()-iMaxResultSet)+"';SF.ListAction.value='Next';SF.submit();\"><img height='10px' src='"+sCONTEXTPATH+"/_img/themes/default/arrow-doubleright.gif' border='0'></a>";
        }
        
        if(iCounter==0){
            // display 'no results' message
            %><tr><td><%=getTran(request,"web","nopatientsfound",sWebLanguage)%></td></tr><%
        }
        else if(pats.size()==1 && !bRS && sLink.length()>0){
            %><script>window.location.href = "<c:url value=''/><%=sLink%>";</script><%
        }
        else{
        	String sTableClass="sortable";
        	if(activeUser.getParameter("patientlist", "compact").equalsIgnoreCase("extended")){
        		sTableClass="";
        	}

            %>
                <%-- previous, patient-count, next --%>
                <div style="text-align:right;padding:2px;">
                    <%                    
                        if(sPrevious.trim().length()>0){
                            %><%=sPrevious%>&nbsp;&nbsp;<%
      		            }
                    %>
                    
                    <%=getTran(request,"web","patients",sWebLanguage)+" "+(iOverallCounter+1)+"-"+(iOverallCounter+iCounter)+" "+getTran(request,"web","of",sWebLanguage)+" "+lResults.size()%>
                
                    <%                    
                        if(sNext.trim().length()>0){
                            %>&nbsp;&nbsp;<a class="topButton" href="#topp">&nbsp;</a><%=sNext%><%
      		            }
                    %>
                </div>
				<table width="100%" cellspacing="0" class="<%=sTableClass %>" id="searchresults">
				    <%-- header --%>
				    <tr height="20" class="admin">
				        <td></td>
				        <td><%=getTran(request,"Web","immatnew",sWebLanguage)%></td>
				        <%
				        	if(SH.ci("enableSearchOnHealthInsurance",0)==1){
				        		%>
				        		<td><%=getTran(request,"Web","healthInsuranceCode",sWebLanguage)%></td>
				        		<%
				        	}
				        %>
				        <td><%=getTran(request,"Web","natreg.short",sWebLanguage)%></td>
				        <td><%=getTran(request,"Web","name",sWebLanguage)%></td>
				        <td><%=getTran(request,"Web","gender",sWebLanguage)%>&nbsp;</td>
				        <td><%=getTran(request,"Web","dateofbirth",sWebLanguage)%></td>
				        <%
				            if("On".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("showServiceInPatientList"))){
				                %>
				                    <td><%=getTran(request,"Web","service",sWebLanguage)%></td>
				                    <td><%=getTran(request,"Web","manager",sWebLanguage)%></td>
				                    <td><%=getTran(request,"Web","bed",sWebLanguage)%></td>
				                    <td><%=getTran(request,"Web","date",sWebLanguage)%></td>
				                <%
				            }
				
				        %>
				        <td></td>
				    </tr>
				    <tbody class="hand"><%=sResult.toString()%></tbody>
				</table>

                <%-- previous, patient-count, next --%>
                <div style="text-align:right;padding:2px;">
                    <%                    
                        if(sPrevious.trim().length()>0){
                            %><%=sPrevious%>&nbsp;&nbsp;<%
      		            }
                    %>
                    
                    <%=getTran(request,"web","patients",sWebLanguage)+" "+(iOverallCounter+1)+"-"+(iOverallCounter+iCounter)+" "+getTran(request,"web","of",sWebLanguage)+" "+lResults.size()%>
                
                    <%                    
                        if(sNext.trim().length()>0){
                            %>&nbsp;&nbsp;<a class="topButton" href="#topp">&nbsp;</a><%=sNext%><%
      		            }
                    %>
                </div>
            <%
        }
    }
    else{
        %><b><%=getTran(request,"web","nopatientsfound",sWebLanguage)%></b><%
        		
        if(MedwanQuery.getInstance().getConfigInt("enableMPI",0)==1 && sPersonID.length()>0 && ScreenHelper.convertFromUUID(sPersonID)>-1){
        	out.println("<br/><br/><a href='javascript:findMPIrecord(\""+sPersonID+"\");'>"+getTran(request,"web","lookupmpiid",sWebLanguage)+": <b>"+sPersonID+"</b></a>");
        	out.println("<br/><div id='divmpisearch'/>");
        }
        if(MedwanQuery.getInstance().getConfigInt("enableOpenIMIS",0)==1 && snatreg.length()>=SH.ci("openIMISMinimumNatregLength",11)){
        	out.println("<br/><br/>"+getTran(request,"web","lookupopenimisid",sWebLanguage)+": <input type='button' class='button' onclick='findOpenIMISrecord(\""+snatreg+"\");' value='"+getTranNoLink("web","checkopenimis",sWebLanguage)+"'/>");
        	out.println("<br/><div id='divopenimissearch'/>");
        }
        // if admin : create dossier and go to agenda
        if((sName.length()>0 || sFirstname.length() > 0 || sDateOfBirth.length()>0 || simmatnew.length()>0) && 
        	activeUser.getAccessRight("patient.administration.add")){
	        %>
	            <br><br>
	            <%if(SH.ci("enableFastEncounter",0)==0){ %>
	            <img src="<%=sCONTEXTPATH%>/_img/themes/default/pijl.gif"/>&nbsp;<a href="<c:url value='/patientnew.do'/>?PatientNew=true&pLastname=<%=sName%>&pFirstname=<%=sFirstname%>&pImmatnew=<%=simmatnew%>&pNatreg=<%=snatreg%>&pDateofbirth=<%=sDateOfBirth%>&pDistrict=<%=sDistrict%>"><%=getTran(request,"web","new_patient",sWebLanguage)%></a><br>
	            <%}
	              else{
	            %>
	            <img src="<%=sCONTEXTPATH%>/_img/themes/default/pijl.gif"/>&nbsp;<a href="<c:url value='/main.jsp'/>?Page=_common/patient/patientEditCompact.jsp&lastname=<%=sName%>&firstname=<%=sFirstname%>&dateofbirth=<%=sDateOfBirth%>"><%=getTran(request,"web","new_patient",sWebLanguage)%></a><br>
	            <%} %>
	            <%if(SH.ci("enableFastPatientAgendaCreate",0)==1){ %>
		            <img src="<%=sCONTEXTPATH%>/_img/themes/default/pijl.gif"/>&nbsp;<a href="<c:url value='/_common/patient/patienteditSave.jsp'/>?Lastname=<%=sName%>&Firstname=<%=sFirstname%>&DateOfBirth=<%=sDateOfBirth%>&NatReg=<%=snatreg%>&ImmatNew=<%=simmatnew%>&PDistrict=<%=sDistrict%>&PBegin=<%=getDate()%>&NextPage=planning/findPlanning.jsp&SavePatientEditForm=ok"><%=getTran(request,"web","create_person_and_go_to_agenda",sWebLanguage)%></a>
	            <%} %>
	        <%
        }
    }
%>

<script>
	function closeMyEncounter(uid){
	    var params = "uid="+uid;
		var url = "<%=sCONTEXTPATH%>/adt/closeEncounter.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			window.location.reload();
		}
		});
	}
	function editMyEncounter(uid){
	    openPopup("adt/editEncounter.jsp&EditEncounterUID="+uid+"&Popup=yes&ts=<%=getTs()%>",800,600);
	}
	function findMPIrecord(mpiid){
		document.getElementById('divmpisearch').style.display='';
	    document.getElementById('divmpisearch').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
	    var params = "mpiid="+mpiid;
		var url = "<%=sCONTEXTPATH%>/curative/retrieveMPIID.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			document.getElementById('divmpisearch').innerHTML=resp.responseText;
		}
		});
	}
	
	function findOpenIMISrecord(natreg){
		document.getElementById('divopenimissearch').style.display='';
	    document.getElementById('divopenimissearch').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
	    var params = "natreg="+natreg;
		var url = "<%=sCONTEXTPATH%>/curative/retrieveOpenIMISID.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			document.getElementById('divopenimissearch').innerHTML=resp.responseText;
		}
		});
	}
	
	function importmpiid(mpiid){
		document.getElementById('divmpisearch').style.display='';
	    document.getElementById('divmpisearch').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
	    var params = "mpiid="+mpiid;
		var url = "<%=sCONTEXTPATH%>/curative/importMPIID.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			window.location.href='<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp';
		}
		});
	}
	
  	function importOpenIMISInsuree(natreg){
		document.getElementById('divopenimissearch').style.display='';
		document.getElementById('divopenimissearch').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
	    var params = "natreg="+natreg;
		var url = "<%=sCONTEXTPATH%>/curative/importOpenIMISID.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			var label = eval('('+resp.responseText+')');
			window.location.href='<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp&PersonID='+label.personid;
		}
		});
	}

  	function selectpatient(personid){
		window.location.href='<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp&PersonID='+personid;
	}
	
	function linkMPIID(mpiid,personid,name){
		if(window.confirm('<%=getTranNoLink("web","doyouwanttolinklocalrecord",sWebLanguage)%> '+name+' <%=getTranNoLink("web","tompiid",sWebLanguage)%> ['+mpiid+']?')){
			document.getElementById('divmpisearch').style.display='';
		    document.getElementById('divmpisearch').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
		    var params = "mpiid="+mpiid+"&personid="+personid;
			var url = "<%=sCONTEXTPATH%>/curative/linkMPIID.jsp";
			new Ajax.Request(url,{
			method: "POST",
			parameters: params,
			onSuccess: function(resp){
				window.location.href='<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp&PersonID='+personid;
			}
			});
		}
	}
</script>
