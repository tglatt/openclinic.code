<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'><td colspan='2'><%=getTran(request,"web","exportquicksoft",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin' width='1%' nowrap><%=getTran(request,"web","month",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<select class='text' name='month' id='month'>
					<%
						long day = 24*3600*1000;
						long m=30*day;
						java.util.Date activeMonth = new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("15/MM/yyyy").format(new java.util.Date()));
						for(int n=0;n<61;n++){
							java.util.Date dPeriod=new java.util.Date(activeMonth.getTime()-n*m);
							out.println("<option value='"+new SimpleDateFormat("yyyyMM").format(dPeriod)+"' "+(n==1?"selected":"")+">"+new SimpleDateFormat("yyyyMM").format(dPeriod)+"</option>");
						}
					%>
				</select>
				<input class='text' type='checkbox' name='onlynew' checked/><%=getTran(request,"web","exportonlynew",sWebLanguage) %>
			</td>
		</tr>
	</table>
	<input type='submit' name='exportButton' value='<%=getTranNoLink("web","export",sWebLanguage)%>'/>
</form>
<table width='100%'>
<%
	if(SH.p(request,"exportButton").length()>0){
		int counter=1;
		boolean bOnlyNew=SH.p(request,"onlynew").length()>0;
		String month = SH.p(request,"month",SH.formatDate(new java.util.Date(),"yyyyMM"));
		java.util.Date begin = SH.parseDate("01"+month, "ddyyyyMM");
		java.util.Date end = SH.parseDate("01"+SH.formatDate(new java.util.Date(begin.getTime()+SH.getTimeDay()*35),"yyyyMM"), "ddyyyyMM");
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		Connection qsConn = DriverManager.getConnection("jdbc:sqlserver://"+SH.cs("quicksoft_sqlserver_host","localhost")+":"+SH.cs("quicksoft_sqlserver_port","1433")+";databaseName="+SH.cs("quicksoft_sqlserver_database","QuickSoft")+";user="+SH.cs("quicksoft_sqlserver_login","openclinic")+";password="+SH.cs("quicksoft_sqlserver_password","openclinic"));
		Connection conn = SH.getOpenClinicConnection();
		//First run the query for patient invoices (cash)
		PreparedStatement ps = conn.prepareStatement("select * from oc_patientinvoices where "+
													 " oc_patientinvoice_status='closed' and"+
													 " oc_patientinvoice_date>=? and oc_patientinvoice_date<?"+
													 " order by oc_patientinvoice_date");
		ps.setTimestamp(1, SH.getSQLTimestamp(begin));
		ps.setTimestamp(2, SH.getSQLTimestamp(end));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			Hashtable prestations = new Hashtable();
			PatientInvoice invoice = PatientInvoice.get(rs.getInt("oc_patientinvoice_serverid")+"."+rs.getInt("oc_patientinvoice_objectid"));
			if(bOnlyNew && Pointer.getPointer("quickSoftExport."+invoice.getUid()).equalsIgnoreCase("1")){
				continue;
			}
			double paid=invoice.getAmountPaid();
			double amount = invoice.getPatientAmount();
			Vector debets = invoice.getDebets();
			if(amount!=0){
				for(int n=0;n<debets.size();n++){
					Debet debet = (Debet)debets.elementAt(n);
					double prestationAmount=debet.getAmount();
					if(prestations.get(debet.getPrestationUid())==null){
						prestations.put(debet.getPrestationUid(),prestationAmount);
					}
					else{
						prestations.put(debet.getPrestationUid(),(Double)prestations.get(debet.getPrestationUid())+prestationAmount);
					}
				}
				Enumeration e = prestations.keys();
				while(e.hasMoreElements()){
					String key = (String)e.nextElement();
					Prestation prestation = Prestation.get(key);
					double prestationAmount = (Double)prestations.get(key);
					//Register sales
					String ref=prestation.getUid()+"/"+invoice.getUid()+"/"+invoice.getPatientUid();
					PreparedStatement sqPs = qsConn.prepareStatement("insert into GhpBrouillard("+
																	 "numero_piece,"+
																	 "code_journal,"+
																	 "compte,"+
																	 "libelle,"+
																	 "reference,"+
																	 "date_ecriture,"+
																	 "debit,"+
																	 "credit,"+
																	 "utilisateur,"+
																	 "date_saisie,"+
																	 "NumeroFacture,"+
																	 "CodeAn,"+
																	 "datedebut,"+
																	 "datefin"+
																		") values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
					sqPs.setInt(1,invoice.getObjectId());
					sqPs.setString(2,SH.cs("quicksoft_journalcode_patientinvoices","ACS"));
					sqPs.setString(3,prestation.getInvoiceGroup()); // Code 700...
					sqPs.setString(4,prestation.getDescription());
					sqPs.setString(5,ref);
					sqPs.setString(6,SH.formatDate(invoice.getDate(),"yyyy-MM-dd HH:mm:ss"));
					sqPs.setDouble(7,0);
					sqPs.setDouble(8,prestationAmount);
					sqPs.setString(9,User.getFullUserName(invoice.getUpdateUser()));
					sqPs.setString(10,SH.formatDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss"));
					sqPs.setString(11,invoice.getUid());
					sqPs.setString(12,prestation.getCostCenter());
					sqPs.setString(13,SH.formatDate(begin,"yyyy-MM-dd HH:mm:ss"));
					sqPs.setString(14,SH.formatDate(end,"yyyy-MM-dd HH:mm:ss"));
					sqPs.execute();
					sqPs.close();
					//Register payment
					sqPs = qsConn.prepareStatement("insert into GhpBrouillard("+
								 "numero_piece,"+
								 "code_journal,"+
								 "compte,"+
								 "libelle,"+
								 "reference,"+
								 "date_ecriture,"+
								 "debit,"+
								 "credit,"+
								 "utilisateur,"+
								 "date_saisie,"+
								 "NumeroFacture,"+
								 "CodeAn,"+
								 "datedebut,"+
								 "datefin"+
								") values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
					sqPs.setInt(1,invoice.getObjectId());
					sqPs.setString(2,SH.cs("quicksoft_journalcode_patientinvoices","ACS"));
					sqPs.setString(3,SH.cs("quicksoft_journalcode_cashpayment","500000"));
					sqPs.setString(4,SH.cs("quicksoft_journalcode_cashlabel","CASH"));
					sqPs.setString(5,prestation.getUid()+"/"+invoice.getUid()+"/"+invoice.getPatientUid());
					sqPs.setString(6,SH.formatDate(invoice.getDate(),"yyyy-MM-dd HH:mm:ss"));
					sqPs.setDouble(7,prestationAmount);
					sqPs.setDouble(8,0);
					sqPs.setString(9,User.getFullUserName(invoice.getUpdateUser()));
					sqPs.setString(10,SH.formatDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss"));
					sqPs.setString(11,invoice.getUid());
					sqPs.setString(12,prestation.getCostCenter());
					sqPs.setString(13,SH.formatDate(begin,"yyyy-MM-dd HH:mm:ss"));
					sqPs.setString(14,SH.formatDate(end,"yyyy-MM-dd HH:mm:ss"));
					sqPs.execute();
					sqPs.close();
				}
				Pointer.storePointer("quickSoftExport."+invoice.getUid(), "1");
				%>
				<tr><td><%=counter+++". "+getTran(request,"web","patientinvoiceexportedwithid",sWebLanguage) %> <b><%=invoice.getUid() %></b> - <%=SH.formatPrice(amount) %> [<%=SH.formatDate(invoice.getDate()) %>] => <%=AdminPerson.getFullName(invoice.getPatientUid()) %> (<b><%=invoice.getPatientUid() %></b>)</td></tr>
				<%
			}
		}
		rs.close();
		ps.close();
	
		//Now run the query for insurer invoices
		ps = conn.prepareStatement("select * from oc_insurarinvoices where "+
													 " oc_insurarinvoice_status='closed' and"+
													 " oc_insurarinvoice_date>=? and oc_insurarinvoice_date<?"+
													 " order by oc_insurarinvoice_date");
		ps.setTimestamp(1, SH.getSQLTimestamp(begin));
		ps.setTimestamp(2, SH.getSQLTimestamp(end));
		rs = ps.executeQuery();
		while(rs.next()){
			Hashtable prestations = new Hashtable();
			InsurarInvoice invoice = InsurarInvoice.get(rs.getInt("oc_insurarinvoice_serverid")+"."+rs.getInt("oc_insurarinvoice_objectid"));
			if(bOnlyNew && Pointer.getPointer("quickSoftExport."+invoice.getUid()).equalsIgnoreCase("1")){
				continue;
			}
			double amount = invoice.getAmount();
			Vector debets = invoice.getDebets();
			if(amount!=0){
				for(int n=0;n<debets.size();n++){
					Debet debet = (Debet)debets.elementAt(n);
					double prestationAmount=debet.getInsurarAmount();
					if(prestations.get(debet.getPrestationUid())==null){
						prestations.put(debet.getPrestationUid(),prestationAmount);
					}
					else{
						prestations.put(debet.getPrestationUid(),(Double)prestations.get(debet.getPrestationUid())+prestationAmount);
					}
				}
				Enumeration e = prestations.keys();
				while(e.hasMoreElements()){
					String key = (String)e.nextElement();
					Prestation prestation = Prestation.get(key);
					double prestationAmount = (Double)prestations.get(key);
					String ref=prestation.getUid()+"/"+invoice.getUid()+"/"+invoice.getInsurarUid();
					//Register sales
					PreparedStatement sqPs = qsConn.prepareStatement("insert into GhpBrouillard("+
																	 "numero_piece,"+
																	 "code_journal,"+
																	 "compte,"+
																	 "libelle,"+
																	 "reference,"+
																	 "date_ecriture,"+
																	 "debit,"+
																	 "credit,"+
																	 "utilisateur,"+
																	 "date_saisie,"+
																	 "NumeroFacture,"+
																	 "CodeAn,"+
																	 "datedebut,"+
																	 "datefin"+
																		") values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
					sqPs.setInt(1,invoice.getObjectId());
					sqPs.setString(2,SH.cs("quicksoft_journalcode_patientinvoices","ACS"));
					sqPs.setString(3,prestation.getInvoiceGroup()); // Code 700...
					sqPs.setString(4,prestation.getDescription());
					sqPs.setString(5,ref);
					sqPs.setString(6,SH.formatDate(invoice.getDate(),"yyyy-MM-dd HH:mm:ss"));
					sqPs.setDouble(7,0);
					sqPs.setDouble(8,prestationAmount);
					sqPs.setString(9,User.getFullUserName(invoice.getUpdateUser()));
					sqPs.setString(10,SH.formatDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss"));
					sqPs.setString(11,invoice.getUid());
					sqPs.setString(12,prestation.getCostCenter());
					sqPs.setString(13,SH.formatDate(begin,"yyyy-MM-dd HH:mm:ss"));
					sqPs.setString(14,SH.formatDate(end,"yyyy-MM-dd HH:mm:ss"));
					sqPs.execute();
					sqPs.close();
					//Register payment
					sqPs = qsConn.prepareStatement("insert into GhpBrouillard("+
								 "numero_piece,"+
								 "code_journal,"+
								 "compte,"+
								 "libelle,"+
								 "reference,"+
								 "date_ecriture,"+
								 "debit,"+
								 "credit,"+
								 "utilisateur,"+
								 "date_saisie,"+
								 "NumeroFacture,"+
								 "CodeAn,"+
								 "datedebut,"+
								 "datefin"+
								") values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
					sqPs.setInt(1,invoice.getObjectId());
					sqPs.setString(2,SH.cs("quicksoft_journalcode_patientinvoices","ACS"));
					sqPs.setString(3,invoice.getInsurar().getAccountingCode()); // Code 400...
					sqPs.setString(4,invoice.getInsurar().getName());
					sqPs.setString(5,prestation.getUid()+"/"+invoice.getUid()+"/"+invoice.getInsurarUid());
					sqPs.setString(6,SH.formatDate(invoice.getDate(),"yyyy-MM-dd HH:mm:ss"));
					sqPs.setDouble(7,prestationAmount);
					sqPs.setDouble(8,0);
					sqPs.setString(9,User.getFullUserName(invoice.getUpdateUser()));
					sqPs.setString(10,SH.formatDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss"));
					sqPs.setString(11,invoice.getUid());
					sqPs.setString(12,prestation.getCostCenter());
					sqPs.setString(13,SH.formatDate(begin,"yyyy-MM-dd HH:mm:ss"));
					sqPs.setString(14,SH.formatDate(end,"yyyy-MM-dd HH:mm:ss"));
					sqPs.execute();
					sqPs.close();
				}
				Pointer.storePointer("quickSoftExport."+invoice.getUid(), "1");
				%>
				<tr><td><%=counter+++". "+getTran(request,"web","insurerinvoiceexportedwithid",sWebLanguage) %> <b><%=invoice.getUid() %></b> - <%=SH.formatPrice(amount) %> [<%=SH.formatDate(invoice.getDate()) %>] => <%=invoice.getInsurar().getName() %></td></tr>
				<%
			}
		}
		rs.close();
		ps.close();
			
		
		conn.close();
		qsConn.close();
	}
%>
</table>