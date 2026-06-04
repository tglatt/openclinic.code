package be.mxs.common.util.pdf.official;

import com.itextpdf.text.Document;
import com.itextpdf.text.ExceptionConverter;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfWriter;

import be.mxs.common.util.system.Miscelaneous;
import be.openclinic.system.SH;
import be.mxs.common.util.db.MedwanQuery;

public class EndPagePatientIDCard extends PdfPageEventHelper {

    //--- ON END PAGE -----------------------------------------------------------------------------
    // add "duplicata" in background of each page of the PDF document.
    //---------------------------------------------------------------------------------------------
    public void onEndPage(PdfWriter writer, Document document) {
        try{
            // load image
        	String sImage= "chukwatermark.gif";
            if(SH.cs("countrycode", "be").equalsIgnoreCase("bi")) {
            	sImage = "mspls.gif";
            }
            Image watermarkImg = Miscelaneous.getImage(sImage,MedwanQuery.getInstance().getConfigString("defaultProject",""));
            watermarkImg.setRotationDegrees(30);
            int[] transparencyValues = {100,100};
            watermarkImg.setTransparency(transparencyValues);
            watermarkImg.setAbsolutePosition(document.leftMargin()+ MedwanQuery.getInstance().getConfigInt("cardWatermarkLeftMargin",7),MedwanQuery.getInstance().getConfigInt("cardWatermarkTopMargin",10));

            /*
            java.awt.Image awtImage = Miscelaneous.getImage("duplicata.gif");
            Image pdfImage = Image.getInstance(awtImage,new Color(220,220,220));
            pdfImage.setRotationDegrees(45);
            pdfImage.setAbsolutePosition(document.leftMargin()+7,150);
            */

			// these are the canvases we are going to use
            PdfContentByte under = writer.getDirectContentUnder();
            under.addImage(watermarkImg);
        }
        catch(Exception e) {
            throw new ExceptionConverter(e);
        }
    }

}
