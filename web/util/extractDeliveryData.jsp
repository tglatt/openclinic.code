<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.io.FileWriter"%>
<%@page import="java.io.BufferedWriter"%>
<%@page import="be.openclinic.medical.*"%>
<%@page import="org.apache.poi.ss.usermodel.*,org.apache.poi.ss.util.*,org.apache.poi.xssf.usermodel.*"%>
<%@include file="/includes/helper.jsp"%>
<%!
	private java.util.Date getDateAdd(java.util.Date date,long millis){
		return new java.util.Date(date.getTime()+millis);
	}
	private Vector<Diagnosis> getPatientDiagnoses(String code, String codetype, String patientuid, java.util.Date from, java.util.Date to) {
		Vector<Diagnosis> i = new Vector<Diagnosis>();
	    Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
	    try {
	    	String sQuery = "select d.* from oc_diagnoses d,oc_encounters e where"+
							" e.oc_encounter_patientuid = ? and"+
							" d.oc_diagnosis_encounteruid = e.oc_encounter_serverid||'.'||e.oc_encounter_objectid";
	    	if(SH.c(codetype).length()>0)	sQuery+=" and d.oc_diagnosis_codetype=?";
	    	if(SH.c(code).length()>0)		sQuery+=" and d.oc_diagnosis_code=?";
	        if(from!=null)     				sQuery+= " and e.OC_ENCOUNTER_ENDDATE >= ?";
	        if(to!=null)       				sQuery+= " and e.OC_ENCOUNTER_BEGINDATE < ?";
	        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	        int n=1;
	        ps.setString(n++,patientuid);
	    	if(SH.c(codetype).length()>0)	ps.setString(n++,codetype);
	    	if(SH.c(code).length()>0)		ps.setString(n++,code);
	        if(from!=null)     				ps.setTimestamp(n++,SH.getSQLTimestamp(from));
	        if(to!=null)       				ps.setTimestamp(n++,SH.getSQLTimestamp(to));
	        ResultSet rs = ps.executeQuery();
	        while(rs.next()) {
	            Diagnosis dTmp = new Diagnosis();
	            
	            dTmp.setUid(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_SERVERID"))+"."+ ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_OBJECTID")));
	            dTmp.setCode(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CODE")));
	            if(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_DATE")).length() > 0){
	                dTmp.setDate(rs.getDate("OC_DIAGNOSIS_DATE"));
	            }
	            if(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_ENDDATE")).length() > 0){
	                dTmp.setEndDate(rs.getTimestamp("OC_DIAGNOSIS_ENDDATE"));
	            }
	            if(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CERTAINTY")).length() > 0){
	                dTmp.setCertainty(Integer.parseInt(rs.getString("OC_DIAGNOSIS_CERTAINTY")));
	            }
	            if(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_GRAVITY")).length() > 0){
	                dTmp.setGravity(Integer.parseInt(rs.getString("OC_DIAGNOSIS_GRAVITY")));
	            }   
	            dTmp.setCreateDateTime(rs.getTimestamp("OC_DIAGNOSIS_CREATETIME"));
	            dTmp.setUpdateDateTime(rs.getTimestamp("OC_DIAGNOSIS_UPDATETIME"));
	            dTmp.setLateralisation(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_LATERALISATION"))));
	            dTmp.setEncounterUID(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_ENCOUNTERUID")));
	            dTmp.setAuthorUID(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_AUTHORUID")));
	            dTmp.setCodeType(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CODETYPE")));
	            dTmp.setPOA(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_POA")));
	            dTmp.setNC(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_NC")));
	            dTmp.setServiceUid(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_SERVICEUID")));
	            dTmp.setFlags(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_FLAGS")));
	            dTmp.setReferenceType(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_REFERENCETYPE")));
	            dTmp.setReferenceUID(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_REFERENCEUID")));
	            i.addElement(dTmp);
	        }
	        rs.close();
	        ps.close();
	    }
	    catch(Exception e) {
	    	e.printStackTrace();
	    }
	    finally {
	    	try {
				oc_conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
	    }
	    return i;
	}
	private Cell setCellValue(int nCol, Row row, String sValue){
		Cell cell = row.createCell(nCol);
		cell.setCellValue(SH.c(sValue));
		return cell;
	}
	
	private void setCellValue(int nCol, Row row, Integer sValue){
		Cell cell = row.createCell(nCol);
		cell.setCellValue(sValue);
	}
	
	private void setCellValue(int nCol, Row row, Double sValue){
		Cell cell = row.createCell(nCol);
		cell.setCellValue(sValue);
	}
	
	private void setCellIntValue(int nCol, Row row, String sValue){
		Cell cell = row.createCell(nCol);
		try{
			int value = Integer.parseInt(sValue);
			cell.setCellValue(value);
		}
		catch(Exception e){
			cell.setCellValue("");
		}
	}

	private void setCellIntValue(int nCol, Row row, String sValue,int min, int max){
		Cell cell = row.createCell(nCol);
		try{
			int value = Integer.parseInt(sValue);
			if(value>=min && value<=max){
				cell.setCellValue(value);
			}
			else{
				cell.setCellValue("");
			}
		}
		catch(Exception e){
			cell.setCellValue("");
		}
	}

	private void setCellDoubleValue(int nCol, Row row, String sValue){
		Cell cell = row.createCell(nCol);
		try{
			double value = Double.parseDouble(sValue);
			cell.setCellValue(value);
		}
		catch(Exception e){
			cell.setCellValue("");
		}
	}

	private void setCellDoubleValue(int nCol, Row row, String sValue,double min, double max){
		Cell cell = row.createCell(nCol);
		try{
			double value = Double.parseDouble(sValue);
			if(value>=min && value<=max){
				cell.setCellValue(value);
			}
			else{
				cell.setCellValue("");
			}
		}
		catch(Exception e){
			cell.setCellValue("");
		}
	}

	private void setSumCell(int col,Row row){
		String letter = CellReference.convertNumToColString(col);
		setCellFormula(col,row,"concatenate(countif("+letter+"1:"+letter+(row.getRowNum()-2)+",1),\" (\",round(countif("+letter+"1:"+letter+(row.getRowNum()-2)+",1)*100/(counta("+letter+"1:"+letter+(row.getRowNum()-2)+")-countblank("+letter+"1:"+letter+(row.getRowNum()-2)+")),2),\"%)\")");
	}

	private void setAverageCell(int col,Row row){
		String letter = CellReference.convertNumToColString(col);
		setCellFormula(col,row,"round(averagea("+letter+"1:"+letter+(row.getRowNum()-2)+"),2)");
	}

	private void setSumCell(int col,Row row,String value){
		String letter = CellReference.convertNumToColString(col);
		setCellFormula(col,row,"concatenate(countif("+letter+"1:"+letter+(row.getRowNum()-2)+",\""+value+"\"),\" (\",round(countif("+letter+"1:"+letter+(row.getRowNum()-2)+",\""+value+"\")*100/(counta("+letter+"1:"+letter+(row.getRowNum()-2)+")-countblank("+letter+"1:"+letter+(row.getRowNum()-2)+")),2),\"%)\")");
	}

	private void setCellFormula(int nCol, Row row, String sValue){
		Cell cell = row.createCell(nCol);
		cell.setCellFormula(SH.c(sValue));
	}

	private boolean isICD10Code(HashSet<String> hICD10, String code) {
		Iterator<String> i = hICD10.iterator();
		while(i.hasNext()) {
			if(code!=null && code.startsWith(i.next())) {
				return true;
			}
		}
		return false;
	}

%>
<%
	String glycemiacodes=SH.p(request,"glycemiacodes","1011a:7;1011b:7;5059:7;5010:7;6000:7;6001:7;5010:7;21:7;805:7;5301:7;E56:7;9001:7");	
	String diabetesdrugs=SH.p(request,"diabetesdrugs","insul;metmor");
	String icd10hypertension=SH.p(request,"hypertensionicd10","I10,I11,I12,I13,I15");
	String icd10diabetes=SH.p(request,"diabetesicd10","E10,E11,E12,E13,E14");
	HashSet<String> hICD10Hypertension = new HashSet<String>(Arrays.asList(icd10hypertension.split(",")));
	HashSet<String> hICD10Diabetes = new HashSet<String>(Arrays.asList(icd10hypertension.split(",")));
%>
<form name="transactionForm" method="post">
	<table width='100%'>
		<tr class='admin'><td colspan='2'>Exportation de données: accouchements (exervice CERFIS)</td></tr>
		<tr>
			<td class='admin'>Codes CIM10 pour hypertension</td>
			<td class='admin2'><input type='text' size='100' name='hypertensionicd10' value='<%=icd10hypertension%>'/></td>
		</tr>
		<tr>
			<td class='admin'>Codes CIM10 pour diabète</td>
			<td class='admin2'><input type='text' size='100' name='diabetesicd10' value='<%=icd10diabetes%>'/></td>
		</tr>
		<tr>
			<td class='admin'>Médicaments pour diabète</td>
			<td class='admin2'><input type='text' size='100' name='diabetesdrugs' value='<%=diabetesdrugs%>'/></td>
		</tr>
		<tr>
			<td class='admin'>Analyses labo pour glycémie</td>
			<td class='admin2'><input type='text' size='100' name='glycemiacodes' value='<%=glycemiacodes%>'/></td>
		</tr>
	</table>
	<input type='submit' class='button' name='exportButton' value='Exporter'/>
</form>
<span id='progress'></span>
<%
	out.flush();
	if(SH.p(request,"exportButton").length()>0){
		XSSFWorkbook workbook = new XSSFWorkbook();
		XSSFSheet sheet = workbook.createSheet("DELIVERIES");
		StringBuffer result = new StringBuffer();
		int rownum=0;
		int colnum=0;
        Font font = workbook.createFont();
        font.setBoldweight(Font.BOLDWEIGHT_BOLD);
        CellStyle bold = workbook.createCellStyle();
        bold.setFont(font);
		Row row = sheet.createRow(rownum++);
		setCellValue(colnum++,row,"PATIENTID").setCellStyle(bold);
		setCellValue(colnum++,row,"DATE").setCellStyle(bold);
		setCellValue(colnum++,row,"HIVSTATUS").setCellStyle(bold);
		setCellValue(colnum++,row,"ON ART").setCellStyle(bold);
		setCellValue(colnum++,row,"BIRTHWEIGHT").setCellStyle(bold);
		setCellValue(colnum++,row,"BIRTHHEIGHT").setCellStyle(bold);
		setCellValue(colnum++,row,"HEADCIRCUMFERENCE").setCellStyle(bold);
		setCellValue(colnum++,row,"GENDER CHILD").setCellStyle(bold);
		setCellValue(colnum++,row,"BORNALIVE").setCellStyle(bold);
		setCellValue(colnum++,row,"BORNDEAD").setCellStyle(bold);
		setCellValue(colnum++,row,"APGAR 1MIN").setCellStyle(bold);
		setCellValue(colnum++,row,"MOTHER DECEASED").setCellStyle(bold);
		setCellValue(colnum++,row,"WEEKS").setCellStyle(bold);
		setCellValue(colnum++,row,"TYPE").setCellStyle(bold);
		setCellValue(colnum++,row,"HYPERTENSION").setCellStyle(bold);
		setCellValue(colnum++,row,"DIABETES").setCellStyle(bold);
		setCellValue(colnum++,row,"ADMISSIONTYPE").setCellStyle(bold);
		setCellValue(colnum++,row,"HTDIAGNOSIS").setCellStyle(bold);
		setCellValue(colnum++,row,"MAXSBP").setCellStyle(bold);
		setCellValue(colnum++,row,"MAXDBP").setCellStyle(bold);
		setCellValue(colnum++,row,"HYPERTENSIONSTAGE").setCellStyle(bold);
		setCellValue(colnum++,row,"HIGHGLYCEMIA").setCellStyle(bold);
		setCellValue(colnum++,row,"DIABETESDRUGS").setCellStyle(bold);
		setCellValue(colnum++,row,"DIABETESDIAGNOSIS").setCellStyle(bold);
		setCellValue(colnum++,row,"TOTAL ANC").setCellStyle(bold);
		setCellValue(colnum++,row,"CHILD STATUS").setCellStyle(bold);
		setCellValue(colnum++,row,"AGE MOTHER").setCellStyle(bold);
		setCellValue(colnum++,row,"GESTITY").setCellStyle(bold);
		setCellValue(colnum++,row,"PARITY").setCellStyle(bold);
		setCellValue(colnum++,row,"ABORTION").setCellStyle(bold);
		setCellValue(colnum++,row,"PREVIOUS_CESARIAN").setCellStyle(bold);
		setCellValue(colnum++,row,"ANEMIA").setCellStyle(bold);
		setCellValue(colnum++,row,"QUALIFICATION").setCellStyle(bold);
	
		Vector<String> vTrans = new Vector<String>();
		Connection conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("select * from transactions where transactiontype='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DELIVERY_MSPLS'");
		ResultSet rs = ps.executeQuery();
		int count=0, hivpos=0,hivneg=0;
		while(rs.next()){
			vTrans.add(rs.getInt("serverid")+"."+rs.getInt("transactionid"));
		}
		rs.close();
		ps.close();
		conn.close();
		for(int nt=0;nt<vTrans.size();nt++){
		//for(int nt=0;nt<501;nt++){
			String uid=vTrans.elementAt(nt);
			TransactionVO transaction = MedwanQuery.getInstance().loadTransaction(uid);
			try{
				if(transaction!=null && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE").length()>0){
					if(nt%100==0) {
						SH.syslog(nt+"/"+vTrans.size());
						out.println("<script>document.getElementById('progress').innerHTML='<center style=\"font-size: 14px;font-weight: bolder\">"+nt+"/"+vTrans.size()+" = "+(nt*100/vTrans.size())+"%</center>'</script>");
						out.flush();
					}
					count++;
					row = sheet.createRow(rownum++);
					colnum=0;
					//setCellValue(colnum++,row,(transaction.getHealthrecordId()+"CERFIS").hashCode()+"");
					setCellValue(colnum++,row,(rownum-1)+"");
					setCellValue(colnum++,row,ScreenHelper.formatDate(transaction.getUpdateTime()));
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PREGNANCY_VIH"));
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PREGNANCY_ARV").equalsIgnoreCase("medwan.common.true")?"1":"0");
					setCellIntValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDWEIGHT"),200,7000);
					setCellIntValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDHEIGHT"),5,75);
					setCellDoubleValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDCRANIEN"),5,60);
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER"));
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE").equalsIgnoreCase("openclinic.common.bornalive")?"1":"0");
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE").equalsIgnoreCase("openclinic.common.borndead")?"1":"0");
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_1"));
					boolean bDeceased=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEATH").equalsIgnoreCase("medwan.common.true");
					if(!bDeceased && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID").length()>0){
						Encounter encounter = Encounter.get(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID"));
						if(encounter!=null && ScreenHelper.checkString(encounter.getOutcome()).startsWith("dead")){
							bDeceased=true;
						}
					}
					setCellValue(colnum++,row,bDeceased?"1":"0");
					setCellDoubleValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_DATE_DR").trim().replace(" ",".").replace(",","."),22,44);
					if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_EUSTOCIC").equalsIgnoreCase("medwan.common.true")){
						setCellValue(colnum++,row,"E");
					}
					else if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_DYSTOCIC").equalsIgnoreCase("medwan.common.true")){
						setCellValue(colnum++,row,"D");
					}
					else {
						setCellValue(colnum++,row,"");
					}
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HISTORY_HTA").equalsIgnoreCase("medwan.common.true")?"1":"0");
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HISTORY_DIABETES").equalsIgnoreCase("medwan.common.true")?"1":"0");
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION").replaceAll("gynaeco.admission.",""));
					//First check for ICD10 codes
					boolean bHypertensionDiagnosis = false, bDiabetesDiagnosis = false;
					Vector<Diagnosis> diagnoses = getPatientDiagnoses("", "icd10", transaction.getPatientUid()+"", null,getDateAdd(transaction.getUpdateDateTime(), SH.getTimeDay()*7));
					for(int d=0;d<diagnoses.size() && ! bHypertensionDiagnosis;d++) {
						Diagnosis diagnosis = diagnoses.elementAt(d);
						if(isICD10Code(hICD10Hypertension,diagnosis.getCode())) {
							bHypertensionDiagnosis=true;
						}
					}
					for(int d=0;d<diagnoses.size() && ! bDiabetesDiagnosis;d++) {
						Diagnosis diagnosis = diagnoses.elementAt(d);
						if(isICD10Code(hICD10Diabetes,diagnosis.getCode())) {
							bDiabetesDiagnosis=true;
						}
					}
					setCellValue(colnum++,row,bHypertensionDiagnosis?"1":"0");
					//Then check for hypertension and diabetes criteria
					boolean bDiabetesdrugs=false;
					double maxsbp=0,maxdbp=0;
					Hashtable<Integer,Hashtable> transactions = new Hashtable<Integer,Hashtable>();
					conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
					ps = conn.prepareStatement("select i.* from items i,transactions t where t.healthrecordid=? and t.updatetime<? and i.serverid=t.serverid and i.transactionid=t.transactionid and i.type in ('be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT','be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT','be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_TREATMENT','be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FOLLOWUP')");
					ps.setInt(1,transaction.getHealthrecordId());
					ps.setTimestamp(2,SH.getSQLTimestamp(transaction.getUpdateTime()));
					rs=ps.executeQuery();
					while(rs.next()){
						if(transactions.get(rs.getInt("transactionid"))==null){
							transactions.put(rs.getInt("transactionid"),new Hashtable<String,String>());
						}
						Hashtable<String,String> items=transactions.get(rs.getInt("transactionid"));
						items.put(rs.getString("type"),rs.getString("value"));
					}
					rs.close();
					ps.close();
					conn.close();				
					Enumeration eTransactions = transactions.keys();
					while(eTransactions.hasMoreElements()) {
						Hashtable<String,String> items=(Hashtable<String,String>)transactions.get(eTransactions.nextElement());
						String sbp = SH.c(items.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT"));
						String dbp = SH.c(items.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT"));
						try {
							if(sbp.length()>0 && Double.parseDouble(sbp)>maxsbp && Double.parseDouble(sbp)<300) {
								maxsbp=Double.parseDouble(sbp);
							}
							if(dbp.length()>0 && Double.parseDouble(dbp)>maxdbp && Double.parseDouble(dbp)<250) {
								maxdbp=Double.parseDouble(dbp);
							}
						}
						catch(Exception e) {
							SH.syslog("error with bloodpressure: "+sbp+"/"+dbp);
							//e.printStackTrace();
						}
						//Check references to diabetesdrugs in freetext
						String treatment=	SH.c(items.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_TREATMENT"))+
								SH.c(items.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FOLLOWUP"));
						if(treatment.length()>0){
							for(int q=0;q<diabetesdrugs.split(";").length && !bDiabetesdrugs;q++){
								if(treatment.toLowerCase().contains(diabetesdrugs.split(";")[q])){
									bDiabetesdrugs=true;
								}
							}
						}
					}
					setCellIntValue(colnum++,row,maxsbp>0?maxsbp+"":"");
					setCellIntValue(colnum++,row,maxdbp>0?maxdbp+"":"");
					if(maxsbp>=180 || maxdbp>=120) {
						setCellValue(colnum++,row,"3");
					}
					else if(maxsbp>=140 || maxdbp>=90) {
						setCellValue(colnum++,row,"2");
					}
					else if(maxsbp>=130 || maxdbp>=80) {
						setCellValue(colnum++,row,"1");
					}
					else {
						setCellValue(colnum++,row,"");
					}
					//Check glycemia
					boolean bHighGlycemia=false;
					for(int n=0;n<glycemiacodes.split(";").length && !bHighGlycemia;n++){
						Vector<RequestedLabAnalysis> analyses = RequestedLabAnalysis.find("", "", transaction.getPatientUid()+"", glycemiacodes.split(";")[n].split(":")[0], "", "", "", "", "", "", "", "", "", "", "", "", false, "");
						for(int a=0;a<analyses.size();a++){
							RequestedLabAnalysis analysis = analyses.elementAt(a);
							if(analysis.getRequestDate()!=null && analysis.getRequestDate().before(transaction.getUpdateTime()));
							try{
								if(SH.c(analysis.getResultValue()).length()>0 && Double.parseDouble(analysis.getResultValue())>Double.parseDouble(glycemiacodes.split(";")[n].split(":")[1])){
									bHighGlycemia=true;
									break;
								}
							}
							catch(Exception r){
								SH.syslog("error with glycemia: "+analysis.getResultValue());
							}
						}
					}
					setCellValue(colnum++,row,bHighGlycemia?"1":"0");
					//Check diabetesdrugs prescriptions
					Vector<Prescription> drugs = Prescription.find(transaction.getPatientUid()+"", "", "", "", "", "", "", "");
					for(int n=0;n<drugs.size() && !bDiabetesdrugs;n++){
						Prescription prescription = drugs.elementAt(n);
						for(int q=0;q<diabetesdrugs.split(";").length && !bDiabetesdrugs;q++){
							if(prescription.getProduct()!=null && SH.c(prescription.getProduct().getName()).toLowerCase().contains(diabetesdrugs.split(";")[q])){
								bDiabetesdrugs=true;
							}
						}
					}
					setCellValue(colnum++,row,bDiabetesdrugs?"1":"0");
					setCellValue(colnum++,row,bDiabetesDiagnosis?"1":"0");
					setCellIntValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PREGNANCY_NUMBEROFCPN"),0,15);
					String sChildStatus=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE");
					
					if(sChildStatus.equalsIgnoreCase("openclinic.common.borndead")){
						String sDeathType=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEAD_TYPE");						
						if(sDeathType.equalsIgnoreCase("gynaeco.dead_type_frais")){
							setCellValue(colnum++,row,"MNF");
						}
						else if(sDeathType.equalsIgnoreCase("gynaeco.dead_type_macere")){
							setCellValue(colnum++,row,"MNM");
						}
						else {
							setCellValue(colnum++,row,"MN");
						}
					}
					else if(sChildStatus.equalsIgnoreCase("openclinic.common.bornalive")){
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_DEADIN24H").equalsIgnoreCase("medwan.common.true")){
							setCellValue(colnum++,row,"DCD");
						}
						else if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_DEADAFTER24H").equalsIgnoreCase("medwan.common.true")){
							setCellValue(colnum++,row,"DCD");
						}
						else{
							setCellValue(colnum++,row,"VBP");
						}
					}
					else{
						setCellValue(colnum++,row,"");
					}
					AdminPerson patient = transaction.getPatient();
					setCellIntValue(colnum++,row,patient.getAgeOnDate(SH.parseDate(patient.dateOfBirth), transaction.getUpdateTime())+"",10,60);
					setCellIntValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HISTORY_GESTITY"),0,15);
					setCellIntValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HISTORY_PARITY"),0,15);
					setCellIntValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HISTORY_ABORTIONS"),0,15);
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HISTORY_CS").equalsIgnoreCase("medwan.common.true")?"1":"0");
					setCellValue(colnum++,row,transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HISTORY_ANEMIA").equalsIgnoreCase("medwan.common.true")?"1":"0");
					setCellValue(colnum++,row,getTranNoLink("delivery.performers",transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_EXAMINATIONPERFORMEDBY"),"fr"));

					if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PREGNANCY_VIH").equalsIgnoreCase("+")){
						hivpos++;
					}
					if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PREGNANCY_VIH").equalsIgnoreCase("-")){
						hivneg++;
					}
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		row = sheet.createRow(rownum++);
		colnum=0;
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"HIV POSITIVE").setCellStyle(bold);
		setCellValue(colnum++,row,"ON ART").setCellStyle(bold);
		setCellValue(colnum++,row,"AVG BIRTHWEIGHT").setCellStyle(bold);
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"BORNALIVE").setCellStyle(bold);
		setCellValue(colnum++,row,"BORNDEAD").setCellStyle(bold);
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"MOTHER DECEASED").setCellStyle(bold);
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"HYPERTENSION").setCellStyle(bold);
		setCellValue(colnum++,row,"DIABETES").setCellStyle(bold);
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"HTDIAGNOSIS").setCellStyle(bold);
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"");
		setCellValue(colnum++,row,"HYPERTENSIONSTAGE").setCellStyle(bold);
		setCellValue(colnum++,row,"HIGHGLYCEMIA").setCellStyle(bold);
		setCellValue(colnum++,row,"DIABETESDRUGS").setCellStyle(bold);
		setCellValue(colnum++,row,"DIABETESDIAGNOSIS").setCellStyle(bold);
		setCellValue(colnum++,row,"AVG ANC").setCellStyle(bold);
		//Formulas
		row = sheet.createRow(rownum++);
		setSumCell(2,row,"+");
		setSumCell(3,row);
		setAverageCell(4,row);
		setSumCell(8,row);
		setSumCell(9,row);
		setSumCell(11,row);
		setSumCell(14,row);
		setSumCell(15,row);
		setSumCell(17,row);
		setCellFormula(20,row,"concatenate(\"I: \",countif(U1:U"+(rownum-2)+",1),\" (\",round(countif(U1:U"+(rownum-2)+",1)*100/(counta(T1:T"+(rownum-2)+")-countblank(T1:T"+(rownum-2)+")),2),\"%)\")");
		setSumCell(21,row);
		setSumCell(22,row);
		setSumCell(23,row);
		setAverageCell(24,row);
		row = sheet.createRow(rownum++);
		setCellFormula(20,row,"concatenate(\"II: \",countif(U1:U"+(rownum-2)+",2),\" (\",round(countif(U1:U"+(rownum-2)+",2)*100/(counta(T1:T"+(rownum-2)+")-countblank(T1:T"+(rownum-2)+")),2),\"%)\")");
		row = sheet.createRow(rownum++);
		setCellFormula(20,row,"concatenate(\"III: \",countif(U1:U"+(rownum-2)+",3),\" (\",round(countif(U1:U"+(rownum-2)+",3)*100/(counta(T1:T"+(rownum-2)+")-countblank(T1:T"+(rownum-2)+")),2),\"%)\")");
		//----------------
		for(int n=0;n<28;n++){
			sheet.autoSizeColumn(n);
		}
		String f = System.currentTimeMillis()+".xlsx";
		String filename=SH.cs("DocumentsFolder","")+"/"+f;
		SH.syslog("file="+filename);
		OutputStream os = new FileOutputStream(filename);
		workbook.write(os);
		os.flush();
		os.close();
		%>
		<p/>
		<script>document.getElementById('progress').innerHTML=''</script>
		<center><a href="<%=sCONTEXTPATH%>/documents/<%=f%>">Download file</a></center>
		<%
	}
%>