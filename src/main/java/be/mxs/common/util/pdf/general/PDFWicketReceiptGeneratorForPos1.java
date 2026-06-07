package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;

import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.*;
import net.admin.*;

import javax.servlet.http.HttpServletRequest;

public class PDFWicketReceiptGeneratorForPos1 extends PDFInvoiceGenerator {

    private WicketCredit wicketCredit=null;
    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFWicketReceiptGeneratorForPos1(User user, WicketCredit operation, String sProject, String sPrintLanguage){
        this.user = user;
        this.wicketCredit = operation;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;

        doc = new Document();
    }

    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, Invoice inv) throws Exception {
    	return null;
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String sCreditUid) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;
		

        // reset totals
        this.patientDebetTotal = 0;
        this.insurarDebetTotal = 0;
        this.creditTotal = 0;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
            Rectangle rectangle = new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("patientReceiptWidth",720)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("patientReceiptHeight",5000)*72/254).floatValue());
            doc.setPageSize(rectangle);
            doc.setMargins(MedwanQuery.getInstance().getConfigInt("patientReceiptLeftMargin",0), MedwanQuery.getInstance().getConfigInt("patientReceiptRightMargin",0), MedwanQuery.getInstance().getConfigInt("patientReceiptTopMargin",0), MedwanQuery.getInstance().getConfigInt("patientReceiptBottomMargin",0));
            doc.open();

            
            addHeading(wicketCredit);
            printCreditReceipt(wicketCredit);
            
    		if(MedwanQuery.getInstance().getConfigInt("autoPrintReceipt",0)==1){
    			PdfAction action = new PdfAction(PdfAction.PRINTDIALOG);
    			docWriter.setOpenAction(action);
    		}
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

    //---- ADD HEADING (logo & barcode) -----------------------------------------------------------
    private void addHeading(WicketCredit credit) throws Exception {

    	
    	double titleScaleFactor = new Double(MedwanQuery.getInstance().getConfigInt("PDFReceiptTitleFontScaleFactor",100))/100;
    	double scaleFactor = new Double(MedwanQuery.getInstance().getConfigInt("PDFReceiptFontScaleFactor",100))/100;
    	
    	
    	table = new PdfPTable(50);
        table.setWidthPercentage(98);
    	
        try {
            //*** logo ***
           // try{
               // Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
               // img.scaleToFit(75, 75);
               // cell = new PdfPCell(img);
               // cell.setBorder(PdfPCell.NO_BORDER);
               // cell.setColspan(1);
               // table.addCell(cell);
           // }
            //catch(Exception e){
              //  Debug.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
               // e.printStackTrace();
               // cell = new PdfPCell();
               // cell.setBorder(PdfPCell.NO_BORDER);
                //cell.setColspan(1);
               // table.addCell(cell);
            //}
            
            addBlankRow();
            
            cell = createBorderlessCell(ScreenHelper.getTranNoLink("web","wicketpaymentreceipt",sPrintLanguage).toUpperCase()
            		+" #"+credit.getUid().split("\\.")[1]+" - "+ScreenHelper.stdDateFormat.format(credit.getOperationDate())
            		, 1,50,new Double(10*titleScaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        table.addCell(cell);
	        
	        addBlankRow();
	        
	        doc.add(table);
	        
	       //

            //*** title ***
           // table.addCell(createTitleCell(getTran("web","wicketpaymentreceipt").toUpperCase()+" #"+credit.getUid().split("\\.")[1]+" - "+ScreenHelper.stdDateFormat.format(credit.getOperationDate()),"",4));
 
            
            //addBlankRow();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT INVOICE ---------------------------------------------------------------------------
    private void printCreditReceipt(WicketCredit credit){
        try {
        	
        	double titleScaleFactor = new Double(MedwanQuery.getInstance().getConfigInt("PDFReceiptTitleFontScaleFactor",100))/100;
	    	double scaleFactor = new Double(MedwanQuery.getInstance().getConfigInt("PDFReceiptFontScaleFactor",100))/100;
	    	
	    	
	    	table = new PdfPTable(50);
	        table.setWidthPercentage(98);
	    
	    	//PdfPTable creditTable = new PdfPTable(100);
	    	 cell = createGrayCell(ScreenHelper.getTran(null,"web","ID",sPrintLanguage), 20,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);   
		     table.addCell(cell);
		
		     cell = createValueCell(credit.getUid(), 30,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		     table.addCell(cell);
		     
		     cell = createGrayCell(ScreenHelper.getTran(null,"web","wicket",sPrintLanguage).toUpperCase(), 20,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);   
		     table.addCell(cell);
		
		     cell = createValueCell(getTran("service",Wicket.get(credit.getWicketUID()).getServiceUID()), 30,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		     table.addCell(cell);
		     
		     cell = createGrayCell(ScreenHelper.getTran(null,"web","operator",sPrintLanguage).toUpperCase(), 20,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);   
		     table.addCell(cell);
		
		     cell = createValueCell(user.person.firstname.toUpperCase()+" "+user.person.lastname, 30,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		     table.addCell(cell);
		     
		     
		     cell = createGrayCell(ScreenHelper.getTran(null,"web","date",sPrintLanguage).toUpperCase(), 20,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);   
		     table.addCell(cell);
		
		     cell = createValueCell(ScreenHelper.stdDateFormat.format(credit.getOperationDate()), 30,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		     table.addCell(cell);
   
   
		     cell = createGrayCell(ScreenHelper.getTran(null,"web","operation.type",sPrintLanguage).toUpperCase(), 20,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);   
		     table.addCell(cell);
		
		     cell = createValueCell(getTran("wicketcredit.type",credit.getOperationType()), 30,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		     table.addCell(cell);
		     
		     cell = createGrayCell(ScreenHelper.getTran(null,"web","amount",sPrintLanguage).toUpperCase(), 20,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);   
		     table.addCell(cell);
		
		     cell = createValueCell(credit.getAmount()+" "+sCurrency, 30,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		     table.addCell(cell);
		     
		     
		     cell = createGrayCell(ScreenHelper.getTran(null,"web","comment",sPrintLanguage).toUpperCase(), 20,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);   
		     table.addCell(cell);
		
		     cell = createValueCell(credit.getComment()+"", 30,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		     table.addCell(cell);
		     
		     cell = createGrayCell(getTran("web","operator.signature").toUpperCase(), 50,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		     table.addCell(cell);
            
		     cell = createValueCell(user.person.firstname.toUpperCase()+" "+user.person.lastname, 50,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		     table.addCell(cell);
           
            
           
            //if(user.activeService!=null){
               // creditTable.addCell(createValueCell(user.activeService.getLabel(user.person.language),100));
            //}
           // creditTable.addCell(createEmptyCell(100));
           
           // creditTable.addCell(createGrayCell(getTran("web","payor.signature").toUpperCase(),100));
           // creditTable.addCell(createEmptyCell(100));
           

           // table.addCell(createCell(new PdfPCell(creditTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            //table.addCell(createEmptyCell(1));

            // "printed by" info
           // table.addCell(createCell(new PdfPCell(getPrintedByInfo()),1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //### PRIVATE METHODS #########################################################################


}