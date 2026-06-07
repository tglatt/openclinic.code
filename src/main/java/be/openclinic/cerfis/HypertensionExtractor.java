package be.openclinic.cerfis;

import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;

import java.util.Iterator;
import java.util.Vector;

import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.Diagnosis;
import be.openclinic.system.SH;

public class HypertensionExtractor extends OpenClinicExtractor {
	//Extraction criteria
	//ICD10 codes: I10,I11,I11.0,I11.9,I12,I12.0,I12.9,I13,I13.0,I13.1,I13.2,I13.9,I15,I15.0,I15.1,I15.2,I15.8,I15.9
	//SBP >= 130mmHg or DBP >=80 (stage1), SBP >= 140mmHg or DBP >=90 (stage2), SBP >= 180mmHg or DBP >=120 (stage3)
	
	private final String icd10="I10,I11,I11.0,I11.9,I12,I12.0,I12.9,I13,I13.0,I13.1,I13.2,I13.9,I15,I15.0,I15.1,I15.2,I15.8,I15.9";
	private final HashSet<String> hICD10 = new HashSet<String>(Arrays.asList(icd10.split(",")));
	
	private boolean isHypertensionICD10Code(String code) {
		Iterator<String> i = hICD10.iterator();
		while(i.hasNext()) {
			if(code.startsWith(i.next())) {
				return true;
			}
		}
		return false;
	}

	public HypertensionExtractor(Date begin, Date end) {
		super(begin, end);
		//Set data header
		data.append("patientid;gender;age;encountertype;begin;end;duration;diagnosis;maxsbp;maxdbp;stage\n");
	}

	public void run() {
		data=new StringBuffer();
		int countHypertensionEncounters=0;
		//First select all patient encounters from the selected period
		Vector<Encounter> encounters = Encounter.selectEncounters("", "", SH.formatDate(begin), SH.formatDate(end), "", "", "", "", "", "");
		for(int n=0;n<encounters.size();n++) {
			if(n%100==0) {
				SH.syslog(n+"/"+encounters.size()+" - "+countHypertensionEncounters+" hypertension encounters");
			}
			Encounter encounter = encounters.elementAt(n);
			boolean bHypertensionDiagnosis = false;
			//First check for ICD10 codes
			Vector<Diagnosis> diagnoses = Diagnosis.selectDiagnoses("", "", encounter.getUid(), "", "", "", "", "", "", "", "", "icd10", "");
			for(int d=0;d<diagnoses.size() && ! bHypertensionDiagnosis;d++) {
				Diagnosis diagnosis = diagnoses.elementAt(d);
				if(isHypertensionICD10Code(diagnosis.getCode())) {
					bHypertensionDiagnosis=true;
				}
			}
			//Then check for hypertension criteria
			double maxsbp=0,maxdbp=0;
			Vector<TransactionVO> transactions = MedwanQuery.getInstance().getTransactionsByEncounter(Integer.parseInt(encounter.getPatientUID()), encounter.getUid());
			for(int t=0;t<transactions.size();t++) {
				TransactionVO transaction = transactions.elementAt(t);
				String sbp = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT");
				String dbp = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT");
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
			}
			if(bHypertensionDiagnosis || maxsbp>=130 || maxdbp>=80) {
				countHypertensionEncounters++;
				//This is a hypertension case
				data.append(encounter.getPatientUID()+";");
				data.append(encounter.getPatient().gender+";");
				data.append(encounter.getPatient().getAge()+";");
				data.append(encounter.getType()+";");
				data.append(SH.formatDate(encounter.getBegin())+";");
				data.append(SH.formatDate(encounter.getEnd())+";");
				data.append((SH.dateDiffInDays(begin, end)+1)+";");
				data.append(bHypertensionDiagnosis?"1;":"0;");
				data.append(maxsbp+";");
				data.append(maxdbp+";");
				if(maxsbp>=180 || maxdbp>=120) {
					data.append("3");
				}
				else if(maxsbp>=140 || maxdbp>=90) {
					data.append("2");
				}
				else if(maxsbp>=130 || maxdbp>=80) {
					data.append("1");
				}
				else {
					data.append("0");
				}
				data.append("\n");
			}
		}
	}
}
