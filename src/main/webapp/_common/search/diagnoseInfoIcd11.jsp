<%@page import="java.util.Vector,
                be.mxs.common.util.system.HTMLEntities,
                be.openclinic.medical.ReasonForEncounter,
                be.openclinic.medical.Diagnosis"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSCRPTACULOUS%> 

<%

	String icd11URL = MedwanQuery.getInstance().getConfigString("icd11server");
    String sicd10Code ="";
    String sicd10Label = "";

    String sReturnField = checkString(request.getParameter("returnField"));
	String sShowPatientEncounters = checkString(request.getParameter("showpatientencounters"));
	
	String sCode  = checkString(request.getParameter("Code")),
           sValue = checkString(request.getParameter("Value")),
           sLabel = checkString(request.getParameter("Label")),
           sType  = checkString(request.getParameter("Type"));
    
    String flags = Diagnosis.getFlags(sType,sCode,"");
    
    String sPatientUid = checkString(request.getParameter("patientuid"));
    if(sPatientUid.length()==0 && activePatient!=null){
    	sPatientUid=activePatient.personid;
    }
    
    String sServiceUid = checkString(request.getParameter("serviceUid"));
    String sEncounterUid = checkString(request.getParameter("EncounterUid"));
%>

<form name="diagnoseInfoForm" method="post">
    <%=HTMLEntities.htmlentities(writeTableHeader("Web","diagnosegravityandcertainty",sWebLanguage,""))%>
    
    <table class="list" width="100%" cellspacing="1">
        <%-- Diagnose code --%>
        <tr>
            <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","diagnosiscode",sWebLanguage)%> *</td>
            <td class="admin2"><%=sCode%></td>
        </tr>
        <%-- Diagnose label--%>
        <tr>
            <td class="admin"><%=getTran(request,"web",sType,sWebLanguage)%></td>
            <td class="admin2"><%=sLabel%></td>
        </tr>
        <%-- Diagnose label,ICD10  equivalent--%>
        
       
        <tr>
            <td class="admin"><%=getTran(request,"web","ICD10",sWebLanguage)%></td>
            <td class="admin2">
                <%
                    String sFindCode = sCode;
                    String[] sMultipleCode=sFindCode.split("/");
                    String sFirstCode=sFindCode.split("/")[0];
                    Vector alternatives = MedwanQuery.getInstance().getAlternativeDiagnosisCodesICD11(sType,sFirstCode);
                    
                    for (int i=0;i<sMultipleCode.length;i++){
                    	String sSingleCode= sFindCode.split("/")[i];
                    	alternatives = MedwanQuery.getInstance().getAlternativeDiagnosisCodesICD11(sType,sSingleCode);
                    	if(alternatives.size()==1){
                            out.print(alternatives.elementAt(0)+" "+MedwanQuery.getInstance().getDiagnosisLabel("ICD10",(String)alternatives.elementAt(0),sWebLanguage));
                            flags = Diagnosis.getFlags("ICD10",(String)alternatives.elementAt(0),flags);
                            
                             sicd10Code = alternatives.elementAt(0).toString();
                             sicd10Label = MedwanQuery.getInstance().getDiagnosisLabel("ICD10",(String)alternatives.elementAt(0),sWebLanguage);
                            
                            out.print("<input type='hidden' id='alternativeCode' name='alternativeCode' value='"+alternatives.elementAt(0)+"'/>");
                            out.print("<input type='hidden' name='alternativeCodeLabel' value='"+MedwanQuery.getInstance().getDiagnosisLabel("ICD10",(String)alternatives.elementAt(0),sWebLanguage)+"'/><br/>");
                        }
                    	else if (alternatives.size()>1){
                            out.print("<select class='text' id='alternativeCode' name='alternativeCode' onclick=\"document.getElementsByName('alternativeCodeLabel')[0].value=document.getElementsByName('alternativeCode')[0].options[document.getElementsByName('alternativeCode')[0].selectedIndex].text.substring(document.getElementsByName('alternativeCode')[0].options[document.getElementsByName('alternativeCode')[0].selectedIndex].text.indexOf(' ')+1);\">");
    						out.print("<option vlaue=''></option>");
                            for(int n=0; n<alternatives.size(); n++){
                                out.print("<option onclick='setGravity(this.value);' value='"+alternatives.elementAt(n)+"'>"+alternatives.elementAt(n)+" "+ScreenHelper.left(MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(n),sWebLanguage),80)+"</option>");
                                flags = Diagnosis.getFlags(sType.equalsIgnoreCase("icd11")?"ICD10":"icd11",(String)alternatives.elementAt(n),flags);
                            }
                            out.print("</select>");
                            
                            out.print("<input type='hidden' name='alternativeCodeLabel' value='"+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),sWebLanguage)+"'/>");
                        }
                    }
                             
                    
                %>
            </td>
        </tr>
      
        
          <%-- Diagnose label, ICD11 equivalent--%>
    
        
       
        <%-- certainty --%>
      <tr>
            <td class="admin"><%=getTran(request,"medical.diagnosis","certainty",sWebLanguage)%> *</td>
            <td class="admin2" style="height:35px;">
              
                <div id="DiagnosisCertainty_slider" class="slider" style="margin-left:5px;width:560px;">
                    <div id="DiagnosisCertainty_handle" class="handle"><span style="width:30px">500</span></div>
                </div>
                <input type="hidden" name="DiagnosisCertainty" id="DiagnosisCertainty" value="" />
            </td>
        </tr>
        <%-- gravity --%>
        
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran(request,"medical.diagnosis","gravity",sWebLanguage))%> *</td>
            <td class="admin2" style="height:35px;">
                 <div id="DiagnosisGravity_slider" class="slider" style="margin-left:5px;width:560px;">
                    <div id="DiagnosisGravity_handle" class="handle"><span style="width:30px">500</span></div>
                </div>
                <input type="hidden" value="" name="DiagnosisGravity" id="DiagnosisGravity" />
            </td>
        </tr>
      
        <%-- present on admission --%>
    	<tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran(request,"medical.diagnosis","present.on.admission",sWebLanguage))%></td>
            <td class="admin2">
                <table width="100%"><tr><td><input type="checkbox" name="DiagnosisPresentOnAdmission"/></td></tr></table>
            </td>
        </tr>
        <%-- new case --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran(request,"medical.diagnosis","newcase",sWebLanguage))%></td>
            <td class="admin2">
            	<table width="100%">
            		<tr>
		            	<%
		            		String checked = "checked", altInfo = "<table>";
		            		if(sPatientUid.length() > 0){
			            		Vector oldKPGS = Diagnosis.getPatientKPGSDiagnosesByICPC(sCode,sType,sPatientUid,sWebLanguage);
			            		if(oldKPGS.size() > 0){
			            			checked = "";
			            			for(int n=0; n<oldKPGS.size(); n++){
			            				altInfo+= "<tr><td nowrap>"+((String)oldKPGS.elementAt(n)).split(":")[0]+"</td><td><b>"+((String)oldKPGS.elementAt(n)).split(":")[1]+"</b></td></tr>";
			            				if(n > 8){
				            				altInfo+= "<tr><td colspan='2'>...</td></tr>";
				            				break;
			            				}
			            			}
			            		}
		            		}
		            		altInfo+= "</table>";
		            	
		            	    %><td><input type="checkbox" name="DiagnosisNewCase" <%=checked%>/></td><%
		            			
		                	if(checked.length()==0){
		                        %><td><%=altInfo %></td><%
		                	}
		                %>
                	</tr>
                </table>
            </td>
        </tr>
        

        <%
	        if(flags.indexOf("B")>-1){
        %>
            <%-- bloody --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","bloody",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="bloody" id="bloody" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="bloody" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("C")>-1){
        %>
            <%-- confirmed --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","confirmed",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="confirmed" id="confirmed" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="confirmed" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("W")>-1){
        %>
            <%-- confirmed --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","suspected",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="confirmed" id="confirmed" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="confirmed" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
	        if(flags.indexOf("D")>-1){
        %>
            <%-- digestif --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","digestive.problems",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="digestive" id="digestive" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="digestive" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
			AdminPerson thePatient = AdminPerson.getAdminPerson(sPatientUid);
	        if(flags.indexOf("E")>-1 && thePatient!=null && !thePatient.gender.equalsIgnoreCase("m") && thePatient.getAge()>14 && activePatient.getAge()<50){
        %>
            <%-- pregnant --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","pregnant",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="pregnant" id="pregnant" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="pregnant" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("H")>-1){
        %>
            <%-- severe --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","deshydration",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="deshydration" id="deshydration" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="deshydration" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("J")>-1){
                %>
                    <%-- tbresistance --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","tbresistance",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input type="radio" name="tbresistance" id="tbresistance" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                            <input type="radio" name="tbresistance" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                        </td>
                    </tr>
                <%
                    }
            if(flags.indexOf("K")>-1){
                %>
                    <%-- bloody --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","bkplus",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input type="radio" name="bkplus" id="bkplus" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                            <input type="radio" name="bkplus" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                        </td>
                    </tr>
                <%
                    }
            if(flags.indexOf("L")>-1){
        %>
            <%-- bloody --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","cutaneous",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="cutaneous" id="cutaneous" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="cutaneous" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
	        if(flags.indexOf("M")>-1){
        %>
            <%-- pregnant --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","neurologic",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="neurologic" id="neurologic" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="neurologic" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("O")>-1){
        %>
            <%-- chronic --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","open",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="open" id="open" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="open" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("R")>-1){
        %>
            <%-- chronic --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","chronic",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="chronic" id="chronic" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="chronic" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("S")>-1){
        %>
            <%-- severe --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","severe",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="severe" id="severe" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="severe" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("X")>-1){
        %>
            <%-- severe --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","bacillaire",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="bacillaire" id="bacillaire" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="bacillaire" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("V")>-1){
        %>
            <%-- severe --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","tobereported",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="tobereported" id="tobereported" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="tobereported" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("Y")>-1){
        %>
            <%-- severe --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","amibienne",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="amibienne" id="amibienne" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="amibienne" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("Z")>-1){
        %>
            <%-- severe --%>
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","shigellosis",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="shigellosis" id="shigellosis" value="medwan.common.true"/><%=getTran(request,"web","yes",sWebLanguage)%>
                    <input type="radio" name="shigellosis" value="medwan.common.false"/><%=getTran(request,"web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
        %>
        <%-- transfer to problem list --%>
        
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran(request,"web","service",sWebLanguage))%></td>
            <td class="admin2">
                <%
                	Hashtable<String,String> hServices = new Hashtable<String,String>();
                	
                    //Make a list of acceptable services
	            	//1. The active encounter's service
                	Vector<String> services = new Vector<String>();
	            	SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
	                java.util.Date activeDate = new java.util.Date();
	            	TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
	            	String activetransaction = "?";
	            	if(curTran!=null && curTran.getUpdateTime()!=null){
	                	activetransaction = getTran(request,"web.occup",curTran.getTransactionType(),sWebLanguage);
	                	activeDate = curTran.getUpdateTime();
	                }
	            	
	                Encounter activeEnc=null;
	                if(curTran!=null && curTran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID").length()>0){
	                	activeEnc = Encounter.get(curTran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID"));
	                }
	                if((activeEnc==null || !activeEnc.hasValidUid()) && sEncounterUid.length()>0){
	                	activeEnc = Encounter.get(sEncounterUid);
	                }
	                if((activeEnc==null || !activeEnc.hasValidUid())) {
	                	activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(activeDate.getTime()),sPatientUid);
	                }
					String activeEncParents="",activeService="";
	                if(activeEnc!=null && activeEnc.getService()!=null){
	                	activeEncParents=","+activeEnc.getServiceUID()+","+Service.getParentIds(activeEnc.getServiceUID())+",";
	                	activeService = activeEnc.getService().getLabel(sWebLanguage);
	                	if(hServices.get(activeEnc.getServiceUID())==null){
		            		services.add(activeEnc.getServiceUID()+";"+activeEnc.getService().getLabel(sWebLanguage));
		            		hServices.put(activeEnc.getServiceUID(),"1");
	                	}
	                }
					//2. The user's service
	            	if(activeUser.activeService!=null && hServices.get(activeUser.activeService.code)==null){
	            		services.add(activeUser.activeService.code+";"+activeUser.activeService.getLabel(sWebLanguage));
	            		hServices.put(activeUser.activeService.code,"1");
	            	}
					
	                //3. All services the current transactionType is available for
	                boolean bMatch = false;
	                if(curTran!=null && curTran.getTransactionType()!=null && !sShowPatientEncounters.equalsIgnoreCase("1")){
		                Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		                String sQuery = "select distinct a.serviceid from serviceexaminations a, examinations b"+
		                                " where a.examinationid = b.id and transactionType = ?";
		                PreparedStatement ps = conn.prepareStatement(sQuery);
		                ps.setString(1,curTran.getTransactionType());
		                ResultSet rs = ps.executeQuery();
		                while(rs.next()){
		                	String serviceuid = rs.getString("serviceid");
	                		Service service = Service.getService(serviceuid);
	                		if(service!=null){
			                	if(activeEncParents.indexOf(","+serviceuid+",")>-1){
			                		bMatch = true;
			                	}
			                	if(serviceuid!=null && hServices.get(serviceuid)==null){
				            		services.add(serviceuid+";"+service.getLabel(sWebLanguage));
				            		hServices.put(serviceuid,"1");
		                		}
		                	}
		                }
		                rs.close();
		                ps.close();
		                conn.close();
	                }
	                else{
	                	//4. all services the patient has been admitted to
	                	Vector encounters = Encounter.selectEncounters("","","","","","","","",sPatientUid,"");
	                	for(int n=0; n<encounters.size(); n++){
	                		Encounter encounter = (Encounter)encounters.elementAt(n);
		                	if(encounter.getServiceUID()!=null && encounter.getServiceUID().length()>0 && encounter.getService()!=null && hServices.get(encounter.getServiceUID())==null){
			            		services.add(encounter.getServiceUID()+";"+encounter.getService().getLabel(sWebLanguage));
			            		hServices.put(encounter.getServiceUID(),"1");
		                	}
	                	}
	                	
	                }
	                if(services.size()>0){
	                	out.print("<select name='serviceUid' id='serviceUid' class='text'>");
	                	for(int n=0; n<services.size(); n++){
	                		if(((String)services.elementAt(n)).split(";").length>1){
	                			out.print("<option value='"+((String)services.elementAt(n)).split(";")[0]+"'>"+((String)services.elementAt(n)).split(";")[1]+"</option>");
	                		}
	                	}
	                	out.print("</select>");
	                	
	                	if(!bMatch){
	                		out.print("<br/><font color='red'>"+getTran(request,"web","diagnosis.servicemismatch",sWebLanguage).replaceAll("#activeservice#",activeService).replaceAll("#activetransaction#",activetransaction)+"</font>");
	                	}
	                }
                %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran(request,"web","author",sWebLanguage))%></td>
            <td class="admin2">
            	<%
            		String authorid = activeUser.userid;
            		String authorname= activeUser.person.getFullName();
            		if(checkString(request.getParameter("AuthorUID")).length()>0){
            			authorid=request.getParameter("AuthorUID");
            			authorname=User.getFullUserName(authorid);
            		}
            	%>
                <input type="hidden" name="diagnosisUser" id="diagnosisUser" value="<%=authorid%>">
                <input class="text" type="text" name="diagnosisUserName" id="diagnosisUserName" readonly size="<%=sTextWidth%>" value="<%=authorname%>">
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"web","select",sWebLanguage)%>" onclick="searchUser('diagnosisUser','diagnosisUserName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"web","clear",sWebLanguage)%>" onclick="diagnoseInfoForm.diagnosisUser.value='';diagnoseInfoForm.diagnosisUserName.value='';">
       		</td>
        </tr>
        
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="EditAddButton" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="doAdd();">&nbsp;
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    
    <%=getTran(request,"Web","colored_fields_are_obligate",sWebLanguage)%>
</form>

<script>
  function searchUser(managerUidField,managerNameField){
	openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no&FindServiceID="+document.getElementById('serviceUid').value,650,600);
    document.getElementById(diagnosisUserName).focus();
  }
  
  
  function doAdd(){
	  
	  var certainty = diagnoseInfoForm.DiagnosisCertainty.value;
	  var gravity = diagnoseInfoForm.DiagnosisGravity.value;
	  
	  // Returned string will be stored in icd11Code
	  
	  var returnString = 'icd11Code';
	  // ICD 11 CODE 
	  
	  var icd11Code = '<%=sCode%>';
	  varMyOpener = window.opener;
      varOpener = varMyOpener.opener;
      // split multiple codes separated by slash
      const table_size = icd11Code.split("/");
            
      for(let i=0; i<table_size.length; i++){
    	  
    	  const currentCode = table_size[i];
    	  var contentLine = "<span id='ICD11"+currentCode+"'>";
          var userid = "<%= authorid %>"
          var   serviceUid = document.getElementById("serviceUid").value;
          // BUtton efface 
          contentLine += "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' onclick='document.getElementById(\"ICD11"+currentCode+"\").innerHTML=\"\";'/>";
          // Input for saving       
          contentLine += "<input type='hidden' name='ICD11Code"+currentCode+"' value='"+currentCode+"' />";
          contentLine += "<input type='hidden' name='ServiceICD11Code"+currentCode+"' value='"+ serviceUid +"'/>";
          contentLine += "<input type='hidden' name='UserICD11Code"+currentCode+"' value=\""+userid+"\"/>";
          contentLine += "<input type='hidden' name='CertaintyICD11Code"+currentCode+"' value=\""+certainty+"\"/>";
          contentLine += "<input type='hidden' name='GravityICD11Code"+currentCode+"' value=\""+gravity+"\"/>";
          
        
          if(document.getElementsByName('alternativeCode')[0]){
        	  contentLine += "<input type='hidden' name='ICD10Code<%=sicd10Code%>' value='<%=sicd10Code%>' />";
              contentLine += "<input type='hidden' name='ServiceICD10Code<%=sicd10Code%>' value='"+ serviceUid +"'/>";
              contentLine += "<input type='hidden' name='UserICD10Code<%=sicd10Code%>' value=\""+userid+"\"/>";
              contentLine += "<input type='hidden' name='CertaintyICD10Code<%=sicd10Code%>' value=\""+certainty+"\"/>";
              contentLine += "<input type='hidden' name='GravityICD10Code<%=sicd10Code%>' value=\""+gravity+"\"/>";
          }
          
          // Label on dashboard 
          contentLine +=  "<span>";
          contentLine += " <i><b>ICD11</b></i> &nbsp;&nbsp;";
          contentLine += " <b>"+currentCode+"</b>  &nbsp;&nbsp; <b><%=sLabel%></b>&nbsp; &nbsp; &nbsp; &nbsp; ";
          contentLine += "<br/>  &nbsp; &nbsp; ICD10  <b><%= sicd10Code %> &nbsp; &nbsp; <%=sicd10Label%>  &nbsp; &nbsp  </b> <br/> ";
          contentLine +=  "</span>";
    	  varOpener.document.getElementById(returnString).innerHTML+= contentLine;
      }
		     	
		window.close();
  }

  
  
  var sliderCertainty, sliderGravity;
  setSliders = function(){
    sliderCertainty = new Control.Slider("DiagnosisCertainty_handle","DiagnosisCertainty_slider", {
      range: $R(0, 1000),
      sliderValue: 500,
      values:[<%for(int i=0;i<=1000;i=i+5){out.write((i==0)?"0":","+i);}%>],
      onSlide: function(values){
        $("DiagnosisCertainty_handle").firstChild.innerHTML= values;
      },
      onChange: function(value){
        $("DiagnosisCertainty").value = value;
      }
    });   

    sliderGravity = new Control.Slider("DiagnosisGravity_handle","DiagnosisGravity_slider", {
      range: $R(0, 1000),
      values:[<%for(int i=0;i<=1000;i=i+5){out.write((i==0)?"0":","+i);}%>],
      sliderValue: 500,
      onSlide: function(values){
        $("DiagnosisGravity_handle").firstChild.innerHTML= values;
      },
      onChange: function(value){
        $("DiagnosisGravity").value = value;
      }
    });

	// todo: set initial slider value to default for the selected disease      
	sliderCertainty.setValue(500);
	document.getElementById("DiagnosisCertainty_handle").innerHTML='<span style="width:30px">'+500+'</span>';
	<%
		if(alternatives.size()==0){
	        %>
	    	sliderGravity.setValue(500);
		    document.getElementById("DiagnosisGravity_handle").innerHTML='<span style="width:30px">'+500+'</span>';
            <%
		}
		else{
		    %>setGravity('<%=sType.equalsIgnoreCase("ICD10")?sCode:(String)alternatives.elementAt(0)%>');<%
		}
     %>
  }
  setSliders();

  function setGravity(code){
	var codetype='ICD10';
    var url = '<c:url value="/healthrecord/ajax/getDiagnosisGravity.jsp"/>?ts='+new Date();
    new Ajax.Request(url,{
       method: "POST",
       postBody: 'code='+code+
                 '&codetype='+codetype,
      onSuccess: function(resp){
	    $("DiagnosisGravity_handle").innerHTML='<span style="width:30px">'+resp.responseText+'</span>';
	    sliderGravity.setValue(resp.responseText);
      }
    });
  }
</script>


<script src="_common/_css/icd11/icd11ect-1.5.1.js"></script>
    <script>
    	
        // Embedded Coding Tool settings object
        // please note that only the property "apiServerUrl" is required
        // the other properties are optional
        const mySettings = {
        		//icd11server
            apiServerUrl: "<%= icd11URL %>",   
            apiSecured: false ,
           // popupMode: true
            
        };

        // example of an Embedded Coding Tool using the callback selectedEntityFunction 
        // for copying the code selected in an <input> element and clear the search results
        const myCallbacks = {
            selectedEntityFunction: (selectedEntity) => { 
                // paste the code into the <input>
                document.getElementById('paste-selectedEntity').value = selectedEntity.code;        
                // clear the searchbox and delete the search results
                ECT.Handler.clear("1")    
            }
        };

        // configure the ECT Handler with mySettings and myCallbacks
        ECT.Handler.configure(mySettings, myCallbacks);
    </script>   