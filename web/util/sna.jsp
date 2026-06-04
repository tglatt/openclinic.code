<%@page import="be.openclinic.medical.RequestedLabAnalysis"%>
<%@page import="java.io.*"%>
<%@page import="be.openclinic.pharmacy.ProductStockOperation"%>
<%@page import="be.openclinic.finance.Debet"%>
<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%!
	private void updateUserLinks(Hashtable<String,Integer> userlinks,HashSet<String> users){
		Iterator<String> i = users.iterator();
		while(i.hasNext()){
			String user = i.next();
			Iterator<String> i2 = users.iterator();
			while(i2.hasNext()){
				String user2 = i2.next();
				if(user2.equalsIgnoreCase(user)){
					continue;
				}
				if(userlinks.get(user+";"+user2)!=null){
					userlinks.put(user+";"+user2,userlinks.get(user+";"+user2)+1);
				}
				else if(userlinks.get(user2+";"+user)!=null){
					userlinks.put(user2+";"+user,userlinks.get(user2+";"+user)+1);
				}
				else{
					userlinks.put(user+";"+user2,1);
				}
			}
		}
	}
%>
<table>
	<tr>
		<td>Progress:</td>
		<td id='progress'></td>
	</tr>
</table>
<%
	Hashtable<String,Integer> userlinks = new Hashtable<String,Integer>();
	HashSet<String> usernodes = new HashSet();
	Vector<String> encounters = new Vector<String>();
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_encounters where oc_encounter_begindate>? order by oc_encounter_begindate");
	ps.setDate(1,SH.toSQLDate(new java.util.Date().getTime()-SH.getTimeYear()));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		encounters.add(rs.getInt("oc_encounter_serverid")+"."+rs.getInt("oc_encounter_objectid"));
	}
	rs.close();
	ps.close();
	conn.close();
	Iterator<String> iEncounters = encounters.iterator();
	int counter=0;
	while(iEncounters.hasNext()){
		HashSet<String> users = new HashSet();
		String uid = iEncounters.next();
		Encounter encounter = Encounter.get(uid);
		if(encounter.hasValidUid()){
			if(counter%1000==0){
				out.println("<script>document.getElementById('progress').innerHTML='"+(counter*100/encounters.size())+" %';</script>");
				out.flush();
			}
			counter++;
			try{
				//Add encounter user
				users.add(encounter.getUpdateUser());
			}
			catch(Exception e){
				e.printStackTrace();
			}			
			try{
				//Add transaction users
				Vector<TransactionVO> transactions = MedwanQuery.getInstance().getTransactionsByEncounter(Integer.parseInt(encounter.getPatientUID()), encounter.getUid());
				for(int t=0;t<transactions.size();t++){
					TransactionVO transaction = transactions.elementAt(t);
					users.add(transaction.getUser().userId+"");
					try{
						if(transaction.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST")){
							//Add laboratory users
							Hashtable<String,RequestedLabAnalysis> analyses = RequestedLabAnalysis.getLabAnalysesForLabRequest(transaction.getServerId(), transaction.getTransactionId());
							Enumeration<String> el = analyses.keys();
							while(el.hasMoreElements()){
								String code = el.nextElement();
								RequestedLabAnalysis analysis = analyses.get(code);
								if(SH.c(analysis.getResultUserId()).length()>0){
									users.add(analysis.getResultUserId());
								}
							}
						}
					}
					catch(Exception er){
						er.printStackTrace();
					}			
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}			
			try{
				//Add debet users
				Vector<String> debets = Debet.getPatientDebets(encounter.getPatientUID(),SH.formatDate(encounter.getBegin()), SH.formatDate(encounter.getEnd()));
				for(int d=0;d<debets.size();d++){
					Debet debet = Debet.get(debets.elementAt(d));
					users.add(debet.getUpdateUser());
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}			
			try{
				//Add pharmacy users
				Vector<ProductStockOperation> operations = ProductStockOperation.getPatientDeliveries(encounter.getPatientUID(), encounter.getBegin(), encounter.getEnd(), "", "");
				for(int p=0;p<operations.size();p++){
					ProductStockOperation operation = operations.elementAt(p);
					users.add(operation.getUpdateUser());
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}			
		}
		updateUserLinks(userlinks,users);
	}
	out.println("<script>document.getElementById('progress').innerHTML='100 %';</script>");
	out.flush();
	StringBuffer links = new StringBuffer();
	StringBuffer nodes = new StringBuffer();
	Enumeration<String> e = userlinks.keys();
	links.append("Source,Target,Type,Id,Label,timeset,Weight\n");
	counter=0;
	while(e.hasMoreElements()){
		String userid=e.nextElement();
		String[] users = userid.split(";");
		if(users.length>1){
			usernodes.add(users[0]);
			usernodes.add(users[1]);
			links.append(users[0]+","+users[1]+",Undirected,"+counter+++",,,"+userlinks.get(userid)+"\n");
		}
	}
	session.setAttribute("snalinks", links);	
	nodes.append("\nId,Label,Name,Department,Gender,Profile\n");
	Iterator<String> iUserNodes =usernodes.iterator();
	while(iUserNodes.hasNext()){
		String un = iUserNodes.next();
		try{
			User user = User.get(Integer.parseInt(un));
			nodes.append(user.userid+","+user.userid+",\""+user.getFullName()+"\","+user.getParameter("defaultserviceid").toUpperCase()+","+user.person.gender+","+SH.normalizeSpecialCharacters(UserProfile.getUserProfileById(Integer.parseInt(user.getParameter("userprofileid"))).getUserprofilename()).toUpperCase()+"\n");
		}
		catch(Exception err){
			SH.syslog("ERROR: un ="+un);
			err.printStackTrace();
		}
	}
	session.setAttribute("snanodes", nodes);	
%>
<a href='<%=sCONTEXTPATH %>/util/getSNANodes.jsp'/>SNA nodes CSV file</a><br/>
<a href='<%=sCONTEXTPATH %>/util/getSNALinks.jsp'/>SNA links CSV file</a><br/>
