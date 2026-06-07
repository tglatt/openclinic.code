package be.openclinic.finance;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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
import net.admin.Service;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.common.ObjectReference;

import com.itextpdf.text.pdf.PdfPTable;

import be.openclinic.finance.PatientInvoice;
import be.openclinic.system.SH;

public class CsvCmsck2 {
	
    static DecimalFormat priceFormatInsurar = new DecimalFormat(SH.cs("priceFormatInsurarCsv", "#0.00"),new DecimalFormatSymbols(Locale.getDefault()));

	public static String getOutput(javax.servlet.http.HttpServletRequest request){
		double pageTotalAmount85=0;
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
		String sOutput="";
		if(invoiceuid!=null){
			double general_total = 0;
	        Vector debets = getDebetsSummary(invoiceuid);
	        
	        if(debets.size() > 0){
	           
	            String sPatientName="", 
	            		sPrevPatientName = "",
	            		patientUID = "";
	            
	            
	            Date date=null,prevdate=null;
	            boolean displayPatientName=false,displayDate=false;
	   
	            double total85pct=0,generaltotal100pct=0,generaltotal85pct=0,generaltotalcomp=0,daytotal100pct=0,daytotal85pct=0,daytotalcomp=0;
	            String invoiceid="",adherent="",recordnumber="",insurarreference="",status="",sService="",sServiceUid,sPrevService="";
	            int linecounter=1;
	            boolean initialized=false;
            	int debetcount=0;
	
	          
            	total85pct=0;
            	//totalcomp=0;
            	generaltotal100pct=0;
            	generaltotal85pct=0;
            	generaltotalcomp=0;
        		daytotal100pct=0;
        		daytotal85pct=0;
        		daytotalcomp=0;
            	invoiceid="";
            	adherent="";
            	recordnumber="";
            	insurarreference="";
        
         
		            linecounter=1;
		            initialized=false;
		             Sum sum;
	           
	            	sOutput+="\r\n"+" N�;NOMS et PRENOMS; N� BC ; MONTANT;\r\n";
	            	debetcount=0;
		            for(int i=0; i<debets.size(); i++){
		            	sum = (Sum)debets.get(i);
		          
		               
		                    sPatientName = sum.getFname() + " "+
		                    		sum.getlName(); 
		                    insurarreference = sum.getPaInv(); 
		                    total85pct = sum.getSum();
		           
		                    
		                	
		                 	sOutput+=linecounter+";";
		                	sOutput+=sPatientName +";";
		                	sOutput+=insurarreference+";";
		                	sOutput+=priceFormatInsurar.format(total85pct)+";";
		                	sOutput+=patientUID+"\r\n";
		                	
		      
		                	
		                	linecounter++;
		           
		                
		  
		                debetcount++;
		                general_total = general_total +  total85pct;
		            } 
		       
		            
	            sOutput+="\r\n";
            	sOutput+="Grand total "+";";
            	sOutput+=";";
            	sOutput+=";";
            
            	sOutput+=priceFormatInsurar.format(general_total)+";";
            	
         
	        }
		}
		return sOutput;
	}
	
	
	 public static Vector getDebetsSummary(String sInvoiceUid){
	        
		 PreparedStatement ps = null;
	        ResultSet rs = null;
	        Vector debetssammary = new Vector();
	        //SortedMap sortedDebets = new TreeMap();
	        
	        String sSelect = "";

	        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	        try{
	            sSelect = " SELECT a.lastname, a.firstname,a.personid, sum(d.oc_debet_insuraramount) AS sum , d.OC_DEBET_PATIENTINVOICEUID "
	            		+ " FROM OC_DEBETS d, OC_INSURARINVOICES i, OC_ENCOUNTERS e, AdminView a, OC_PRESTATIONS c "
	            		+ " WHERE d.OC_DEBET_INSURARINVOICEUID = ? "
	            		+ " AND i.OC_INSURARINVOICE_OBJECTID = replace(d.OC_DEBET_INSURARINVOICEUID,'1.','') "
	            		+ " AND e.OC_ENCOUNTER_OBJECTID = replace(d.OC_DEBET_ENCOUNTERUID,'1.','') "
	            		+ " AND c.OC_PRESTATION_OBJECTID = replace(d.OC_DEBET_PRESTATIONUID,'1.','') "
	            		+ " AND e.OC_ENCOUNTER_PATIENTUID = a.personid "
	            		+ " GROUP BY a.personid "
	            		+ " ORDER BY a.personid ;";
	            ps = loc_conn.prepareStatement(sSelect);
	            ps.setString(1,sInvoiceUid);
	            rs = ps.executeQuery();
	            
	            Sum sum = null;
	            
	            while(rs.next()){
	            	
	            	sum = new Sum();
	            	
	            	sum.setSum(rs.getDouble ("sum"));
	            	sum.setFname(rs.getString("firstname"));
	            	sum.setlName(rs.getString("lastname"));
	            	sum.setPersonid(rs.getString("personid"));
	            	sum.setPaInv(PatientInvoice.get(rs.getString("OC_DEBET_PATIENTINVOICEUID")).getInsurarreference() );
	                
	                debetssammary.add(sum);
  
	            }
	        }
	        catch(Exception e){
	            e.printStackTrace();
	            Debug.println("OpenClinic => CsvCmsck2.java => getDebetsSummary => "+e.getMessage()+" = "+sSelect);
	        }
	        finally{
	            try{
	                if(rs!=null) rs.close();
	                if(ps!=null) ps.close();
	                loc_conn.close();
	            }
	            catch(Exception e){
	                e.printStackTrace();
	            }
	        }
	              
	        return debetssammary;
	    }
	
}




