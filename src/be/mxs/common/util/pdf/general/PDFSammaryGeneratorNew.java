package be.mxs.common.util.pdf.general;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.io.MedHub;
import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.EndPage;
import be.mxs.common.util.pdf.official.EndPageCard;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.PdfBarcode;
import be.mxs.common.util.system.Picture;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.finance.Insurar;
import be.openclinic.finance.PatientInvoice;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import net.admin.AdminPerson;
import net.admin.Service;
import net.admin.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.hnrw.report.Report_Identification;

import java.io.ByteArrayOutputStream;
import java.net.URL;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;


public class PDFSammaryGeneratorNew extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    PdfWriter docWriter=null;
    int red=-1;
    int green=-1;
    int blue=-1;

    public int getRed() {
		return red;
	}
	public void setRed(int red) {
		this.red = red;
	}
	public int getGreen() {
		return green;
	}
	public void setGreen(int green) {
		this.green = green;
	}
	public int getBlue() {
		return blue;
	}
	public void setBlue(int blue) {
		this.blue = blue;
	}
	public void addHeader(){
    }
    public void addContent(){
    }

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFSammaryGeneratorNew(User user, String sProject){
    	
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req,String debut,String fin, String status, String module,String EditEncounterService,String insurarUid) throws Exception {
        
    	ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

        String sURL = req.getRequestURL().toString();
        if(sURL.indexOf("openclinic",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinic", 10));
        }

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;

        //docWriter.setPageEvent(new EndPageCard(url,contextPath,projectDir,red,green,blue));
        
		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
           // Rectangle rectangle = new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("patientCardWidth",1500)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("patientCardHeight",2000)*72/254).floatValue());
            doc.setPageSize(PageSize.A4);
            doc.setMargins(50,50,50,50);
            doc.open();

            // add content to document
            printSummary( debut, fin,  status,  module, EditEncounterService, insurarUid);
		}
		catch(Exception e){
			baosPDF.reset();
			e.printStackTrace();
		}
		finally{
			if(doc!=null) doc.close();
            if(docWriter!=null) docWriter.close();
		}

		if(baosPDF.size() < 1){
			throw new DocumentException("document has no bytes");
		}

		return baosPDF;
	}

    //---- ADD PAGE HEADER ------------------------------------------------------------------------
    private void addPageHeader() throws Exception {
    	
    }
    
    
    
    private void addHeading() throws Exception {
    	
        table = new PdfPTable(5);
        table.setWidthPercentage(pageWidth);

        try {
            //*** logo ***
        	try{
                Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
                img.scaleToFit(75, 75);
                cell = new PdfPCell(img);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);
            }
            catch(Exception e){
                Debug.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
                e.printStackTrace();
                cell = new PdfPCell();
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);
            }
            doc.add(table);
            //addBlankRow();

        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    

    protected void printSummary(String debut,String fin, String status, String module,String Serv,String insurarUid){
        try {
        
        	Integer array_size = 1;
        	Serv  = Service.getChildIdsAsString(Serv);
        	String[] ServArray = Serv.split(",");
        	array_size = ServArray.length;
        	
      
        	
        	addHeading();
        	
            table = new PdfPTable(1000);
            table.setWidthPercentage(pageWidth);
 
            
            //ajouter un tableau de 4 collonnes 
            PdfPTable table2 = new PdfPTable(1000);
            cell=createLabel("Debut " ,10,250,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
           
            cell=createLabel("" +debut ,10,750,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell = new PdfPCell(table2);   
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            
             table2 = new PdfPTable(1000);
             
            cell=createLabel("Fin " ,10,250,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell=createLabel("" +fin ,10,750,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
        
            cell = new PdfPCell(table2);   
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            
            
            table2 = new PdfPTable(1000);
            cell=createLabel("Status: " + status ,10,750,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell=createLabel(" ", 10,250,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell = new PdfPCell(table2);   
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            
            
            table2 = new PdfPTable(1000);
            cell=createLabel("Module: "+ module ,10,750,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell=createLabel("", 10,250,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell = new PdfPCell(table2);   
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            
            
            
            table2 = new PdfPTable(1000);
            cell=createLabel("Assureur: "+Insurar.get(insurarUid).getOfficialName() ,10,750,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell=createLabel(" ", 10,250,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell = new PdfPCell(table2);   
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            
            table2 = new PdfPTable(1000);
            cell=createLabel("Status: "+status,10,750,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell=createLabel(" ", 10,250,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell = new PdfPCell(table2);   
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
   
   
  
            table2 = new PdfPTable(1000);
            cell=createLabel(" " ,10,250,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell=createLabel(" ", 10,750,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell = new PdfPCell(table2);   
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            
          
            
            table2 = new PdfPTable(1000);
            
            cell=createLabel("Service" ,10,750,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setBorder(PdfPCell.BOX);
            table2.addCell(cell);
            cell=createLabel("Montant", 10,250,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setBorder(PdfPCell.BOX);
            table2.addCell(cell);
            
            cell = new PdfPCell(table2);   
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            
            DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));  
   
            Double totageneral = 0.0;
            
          	if(array_size > 0) {
        		for(int j = 0; j < array_size; j++  ) {
        			
        	              if(ServArray[j].toString().trim().length() > 2) {
        	 
         table2 = new PdfPTable(1000);
         Double totalligne = 0.0;
         Double amount = 0.0;
     	Double amount1 = 0.0;
     	Double amount2  = 0.0;
     	
     	
        	      
     	if(insurarUid!="") {
        	 amount = MedHub.ListAmountInvoices( debut, fin, status, module, insurarUid, ServArray[j], 0);
        	 amount1 = MedHub.ListAmountInvoices( debut, fin, status, module, insurarUid, ServArray[j], 1);
        	 amount2 =  MedHub.ListAmountInvoices( debut, fin, status, module, insurarUid, ServArray[j], 2);
        	 amount = amount +  amount1 + amount2;
     	}else {
     		 amount =  MedHub.ListAmountInvoices( debut, fin, status, module, insurarUid, ServArray[j], 0);
     	}
     	
     	
     	
     	 


     	 if(amount!=0) {
     		 
         cell=createLabel(ServArray[j].replaceAll("'","")  ,10,750,Font.BOLD);
         cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
         cell.setBorder(PdfPCell.BOX);
         table2.addCell(cell);
         
       
         cell=createLabel("" + String.format("%,.0f", amount) +" "+ MedwanQuery.getInstance().getConfigString("currency"), 10,250,Font.BOLD);
         cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
         cell.setBorder(PdfPCell.BOX);
         table2.addCell(cell);
         
     	 }
         
         totageneral = totageneral + amount ;
        
         //ajouter un tableau de 4 collonnes
        
         cell = new PdfPCell(table2);   
         cell.setColspan(1000);
         cell.setBorder(PdfPCell.NO_BORDER);
         table.addCell(cell);
         
        	
        	              }
        		     }
        	}
         
          	
            table2 = new PdfPTable(1000);
            cell=createLabel(" " ,10,750,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            cell=createLabel(" ", 10,250,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            

          	
         table2 = new PdfPTable(1000); 
         cell=createLabel("Total ", 10,750,Font.BOLD);
         cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
         cell.setBorder(PdfPCell.BOX);
         table2.addCell(cell);
         
         cell=createLabel(""+String.format("%,.0f",totageneral)+" "+ MedwanQuery.getInstance().getConfigString("currency"), 10,250,Font.BOLD);
         cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
         cell.setBorder(PdfPCell.BOX);
         table2.addCell(cell);
        
        
         //ajouter un tableau de 4 collonnes
         
       
         cell = new PdfPCell(table2);   
         cell.setColspan(1000);
         cell.setBorder(PdfPCell.NO_BORDER);
         table.addCell(cell);
         
          	
          	

            doc.add(table);

        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //################################### UTILITY FUNCTIONS #######################################

    //--- CREATE UNDERLINED CELL ------------------------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.UNDERLINE))); // underlined
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- PRINT VECTOR ----------------------------------------------------------------------------
    protected String printVector(Vector vector){
        StringBuffer buf = new StringBuffer();
        for(int i=0; i<vector.size(); i++){
            buf.append(vector.get(i)).append(", ");
        }

        // remove last comma
        if(buf.length() > 0) buf.deleteCharAt(buf.length()-2);

        return buf.toString();
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabel(String msg, int fontsize, int colspan,int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL --------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

}
