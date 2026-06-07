<%@page import="be.openclinic.medical.RequestedLabAnalysis"%>
<%@page import="be.openclinic.medical.LabProfile"%>
<%@page import="be.openclinic.medical.LabAnalysis"%>
<%@page import="be.dpms.medwan.common.model.vo.administration.PersonVO"%>
<%@page import="be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO"%>
<%@page import="be.mxs.common.model.vo.healthrecord.*,be.mxs.common.model.vo.healthrecord.util.*"%>
<!DOCTYPE html>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<head>
	<link rel="apple-touch-icon" sizes="180x180" href="/openclinic/apple-touch-icon.png">
	<link rel="icon" type="image/png" sizes="32x32" href="/openclinic/favicon-32x32.png">
	<link rel="icon" type="image/png" sizes="16x16" href="/openclinic/favicon-16x16.png">
	<link rel="manifest" href="/openclinic/site.webmanifest">
	<link rel="mask-icon" href="/openclinic/safari-pinned-tab.svg" color="#5bbad5">
	<meta name="msapplication-TileColor" content="#da532c">
	<meta name="theme-color" content="#ffffff">
</head>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public String getProfileNameForCode(String sCode, String sWebLanguage){
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    StringBuffer sQuery = new StringBuffer();
	    String sName = sCode;
	    
	    sQuery.append("SELECT OC_LABEL_VALUE as name")
	          .append(" FROM LabProfiles p, OC_LABELS l")
	          .append(" WHERE "+ MedwanQuery.getInstance().convert("varchar","p.profileID")+" = l.OC_LABEL_ID")
	          .append(" AND l.OC_LABEL_TYPE = 'labprofiles'")
	          .append(" AND l.OC_LABEL_LANGUAGE = ?")
	          .append(" AND p.deletetime IS NULL")
	          .append(" AND p.profilecode = ?");
	    Connection loc_conn = SH.getOpenclinicConnection();
	    try{
	        ps = loc_conn.prepareStatement(sQuery.toString());
	        ps.setString(1,sWebLanguage.toLowerCase());
	        ps.setString(2,sCode);
	        rs = ps.executeQuery();
	
	        if(rs.next()){
	        	sName = rs.getString("name");
	        }
	    }
	    catch(Exception e){
	        e.printStackTrace();
	    }
	    finally{
	        try{
	            if(rs!=null)rs.close();
	            if(ps!=null)ps.close();
	            loc_conn.close();
	        }
	        catch(Exception e){
	            e.printStackTrace();
	        }
	    }
	    return sName;		
	}
%>
<%
    if(activeUser==null || activeUser.person==null){
        out.println("<script>window.location.href='login.jsp';</script>");
        out.flush();
    }
    else{
    	if(SH.p(request,"formaction").equalsIgnoreCase("save")){
    		//Save the labrequest transaction
    		//First make a list of all analysis that were requested
    		HashSet hAnalyses = new HashSet();
    		Map parameters = request.getParameterMap();
    		Iterator<String> i = parameters.keySet().iterator();
    		while(i.hasNext()){
    			String parameter = i.next();
    			if(parameter.startsWith("anal.")){
    				LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(parameter.substring(5));
    				if(analysis!=null && analysis.getUnavailable()==0){
    					hAnalyses.add(parameter.substring(5));
    				}
    			}
    			if(parameter.startsWith("analprof.")){
    				Vector<Hashtable> profileAnalyses = LabProfile.searchLabProfilesDataByProfileCode(parameter.substring(9));
    				for(int n=0;n<profileAnalyses.size();n++){
    					Hashtable<String,String> hAnalysis = profileAnalyses.elementAt(n);
        				LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabID(hAnalysis.get("labID"));
        				if(analysis!=null && analysis.getUnavailable()==0){
        					hAnalyses.add(analysis.getLabcode()+"");
        				}
    				}
    			}
    		}
    		//Then save the transaction
    		java.util.Date date = new java.util.Date();
    		try{
    			date = new SimpleDateFormat("yyyy-MM-dd").parse(request.getParameter("date"));
    			Vector<ItemVO> itemsVO = new Vector();
                itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                		IConstants.IConstants_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID",
                        Encounter.getActiveEncounter(activePatient.personid).getUid(),
                        new java.util.Date(),
                        null));
                SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
                TransactionVO transactionVO = new TransactionVO(    new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                IConstants.TRANSACTION_TYPE_LAB_REQUEST,
                                                                new java.util.Date(),
                                                                date,
                                                                IConstants.TRANSACTION_STATUS_CLOSED,
                                                                sessionContainerWO.getUserVO(),
                                                                itemsVO);
                transactionVO = MedwanQuery.getInstance().updateTransaction(Integer.parseInt(activePatient.personid), transactionVO);
        		//Then save the requestedlabanalyses
        		Iterator<String> iAnalyses = hAnalyses.iterator();
        		while(iAnalyses.hasNext()){
        			String code = iAnalyses.next();
        			RequestedLabAnalysis ra = new RequestedLabAnalysis();
        			ra.setAnalysisCode(code);
        			ra.setPatientId(activePatient.personid);
        			ra.setRequestDate(new java.util.Date());
        			ra.setRequestUserId(activeUser.userid);
        			ra.getResultRefMax();
        			ra.getResultRefMin();
        			ra.setUpdatetime(new java.util.Date());
        			ra.setServerId(transactionVO.getServerId()+"");
        			ra.setTransactionId(transactionVO.getTransactionId()+"");
        			ra.store();
        		}
        		//If no errors, redirect to Labs list
        		%>
        		<script>window.location.href='getLab.jsp';</script>
        		<%
        		out.flush();
    		}
    		catch(Exception e){
    			e.printStackTrace();
    		}
    	}
%>
<%=sCSSNORMAL %>
<title><%=getTran(request,"web","labresults",sWebLanguage) %></title>
<html>
	<body>
		<form name='transactionForm' method='post'>
			<input type='hidden' name='formaction' id='formaction'/>
			<table width='100%'>
				<tr>
					<td colspan='2' style='font-size:8vw;text-align: right'>
						<img onclick="window.location.href='getPatient.jsp?searchpersonid=<%=activePatient.personid %>'" src='<%=sCONTEXTPATH%>/_img/icons/mobile/patient.png'/>
						<img onclick="window.location.href='findPatient.jsp'" src='<%=sCONTEXTPATH%>/_img/icons/mobile/find.png'/>
						<img onclick="window.location.href='getLab.jsp'" src='<%=sCONTEXTPATH%>/_img/icons/mobile/lab.png'/>
						<img onclick="window.location.href='welcome.jsp'" src='<%=sCONTEXTPATH%>/_img/icons/mobile/home.png'/>
					</td>
				</tr>
				<tr>
					<td colspan='2' class='mobileadmin' style='font-size:6vw;'>
						<%
							out.println("["+activePatient.personid+"] "+activePatient.getFullName());
						%>
					</td>
				</tr>
				<tr>
					<td colspan='2' class='mobileadmin' style='font-size:6vw;'>
						<%=getTran(request,"web","newlaborder",sWebLanguage) %>
						<img onclick='save();' style='max-width:10%;height:auto;vertical-align:middle' src='<%=sCONTEXTPATH %>/_img/icons/mobile/save.png'/>
					</td>
				</tr>
				<tr>
					<td class='mobileadmin' style='font-size: 4vw;'>
						<%=getTranNoLink("web","date",sWebLanguage) %>:&nbsp;
					</td>
					<td class='mobileadmin2' style='font-size: 4vw;'>
						<input style='padding:4px; font-size: 4vw;' type='date' name='date' value='<%=new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>' size='10'/>
					</td>
				</tr>
				<%
					String s = MedwanQuery.getInstance().getConfigString("quickLabList."+activeUser.userid,"");
					if(s.length()==0){
						s=MedwanQuery.getInstance().getConfigString("quickLabList","");
					}
					String[] sLabAnalyses = s.split(";");
					for(int n=0;n<sLabAnalyses.length;n++){
						String sCode = sLabAnalyses[n].split("£")[0];
						if(sCode.length()>0 && !sCode.startsWith("$")){
							if(sCode.startsWith("^")){
								%>
									<tr>
										<td class='mobileadmin2' style='font-size:6vw;text-align: center'>
											<input name='analprof.<%=sCode.substring(1)%>' id='analprof.<%=sCode.substring(1)%>' type='checkbox' style='transform: scale(2);'/>
										</td>
										<td class='mobileadmin2' style='font-size:6vw;'>
											<img height='30px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png'/>
											<%= getProfileNameForCode(sCode.substring(1), sWebLanguage) %>
										</td>
									</tr>
								<%	
							}
							else{
								LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(sCode);
								if(labAnalysis!=null && LabAnalysis.labelForCode(sCode, sWebLanguage)!=null){
									%>
										<tr>
											<td class='mobileadmin2' style='font-size:6vw;text-align: center'>
												<input  name='anal.<%=sCode%>' id='anal.<%=sCode%>'type='checkbox' <%=(labAnalysis.getUnavailable()>0?"disabled":"")%> style='transform: scale(2);'/>
											</td>
											<td class='mobileadmin2' style='font-size:6vw;'><%= LabAnalysis.labelForCode(sCode, sWebLanguage) %></td>
										</tr>
									<%	
								}
							}
						}
					}
				%>
			</table>
		</form>
	</body>
</html>
<script>
	function save(){
		document.getElementById("formaction").value="save";
		transactionForm.submit();
	}

	window.parent.parent.scrollTo(0,0);
</script>
<%
    }
%>