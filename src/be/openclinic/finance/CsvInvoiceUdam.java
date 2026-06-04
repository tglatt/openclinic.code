package be.openclinic.finance;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Locale;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.Vector;

import net.admin.AdminPerson;
import net.admin.Service;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.system.SH;

import com.itextpdf.text.pdf.PdfPTable;

public class CsvInvoiceUdam {
    static DecimalFormat priceFormatInsurar = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatInsurarCsv","#,##0.00"),new DecimalFormatSymbols(Locale.getDefault()));

	public static String getOutput(javax.servlet.http.HttpServletRequest request,String sWebLanguage){
		double pageTotalAmount=0,pageTotalAmount85=0,pageTotalAmount100=0;
		String invoiceuid=request.getParameter("invoiceuid");
		int coverage=85;
		InsurarInvoice invoice = InsurarInvoice.get(invoiceuid);
		if(invoice!=null){
			Insurar insurar=invoice.getInsurar();
	        if(insurar!=null && insurar.getInsuraceCategories()!=null && insurar.getInsuraceCategories().size()>0){
	        	try{
	        		coverage=100-Integer.parseInt(((InsuranceCategory)insurar.getInsuraceCategories().elementAt(0)).getPatientShare());
	        	}
	        	catch(Exception e){
	        		e.printStackTrace();
	        	}
	        }
		}
		String sOutput="\r\n#;DATE;PRENOMS;NOM;NAISSANCE;SEXE;ID;NRO FACTURE;NRO ASSURE;PRESTATION;SERVICE;FORFAIT;PATIENT;ASSUREUR\r\n";
		if(invoiceuid!=null){
	        Vector debets = InsurarInvoice.getDebetsForInvoiceSortByDate(invoiceuid);
	        if(debets.size() > 0){
	            // print debets
	            Debet debet;
	            boolean initialized=false;
            	int debetcount=0;
	            for(int i=0; i<debets.size(); i++){
	                debet = (Debet)debets.get(i);
	                sOutput+=(i+1)+";";
	                sOutput+=SH.formatDate(debet.getDate())+";";
	                AdminPerson person = debet.getPatient();
	                sOutput+=SH.capitalize(person.firstname)+";";
	                sOutput+=person.lastname.toUpperCase()+";";
	                sOutput+=person.dateOfBirth+";";
	                sOutput+=person.gender+";";
	                sOutput+=person.personid+";";
	                sOutput+=debet.getPatientInvoiceUid().split("\\.").length==1?"":debet.getPatientInvoiceUid().split("\\.")[1]+";";
	                sOutput+=debet.getInsurance().getInsuranceNr()+";";
	                sOutput+=debet.getPrestation().getCode()+" - "+debet.getPrestation().getDescription()+";";
	                sOutput+=(debet.getService()!=null?debet.getService().getLabel(sWebLanguage):debet.getServiceUid())+";";
	                sOutput+=new Double(debet.getTotalAmount()).intValue()+";";
	                sOutput+=new Double(debet.getAmount()).intValue()+";";
	                sOutput+=new Double(debet.getInsurarAmount()).intValue()+";";
	                sOutput+="\r\n";
		        }
	        }
		}
		return sOutput;
	}
	
    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private static String printDebet2(SortedMap categories, boolean displayDate, Date date, String invoiceid,String adherent,String beneficiary,double total100pct,double total85pct,String recordnumber,int linecounter,String insurarreference,String beneficiarynr,String beneficiaryage,String beneficiarysex,String affiliatecompany){
    	String sOutput="";
        sOutput+=linecounter+";";
        sOutput+=ScreenHelper.stdDateFormat.format(date)+";";
        sOutput+=insurarreference+";";
        sOutput+=invoiceid+";";
        sOutput+=beneficiarynr+";";
        sOutput+=beneficiaryage+";";
        sOutput+=beneficiarysex+";";
        sOutput+=beneficiary+";";
        sOutput+=adherent+";";
        sOutput+=affiliatecompany+";";
        String amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C"));
        sOutput+=amount==null?"0;":amount+";";
        String otherprice="+0";
        String allcats=	"*"+MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M")+"*";
        Iterator iterator = categories.keySet().iterator();
        while (iterator.hasNext()){
        	String cat = (String)iterator.next();
        	if(allcats.indexOf("*"+cat+"*")<0 && ((String)categories.get(cat)).length()>0){
        		otherprice+="+"+(String)categories.get(cat);
        	}
        }
        sOutput+=otherprice+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M"));
        sOutput+=amount==null?"0;":amount+";";
        sOutput+=priceFormatInsurar.format(total100pct)+";";
        sOutput+=priceFormatInsurar.format(total85pct)+"\r\n";
        return sOutput;
    }

}
