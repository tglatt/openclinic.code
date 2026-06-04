package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.PdfBarcode;
import be.openclinic.system.SH;
import be.mxs.common.util.db.MedwanQuery;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import net.admin.User;
import net.admin.AdminPerson;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.annotations.XYTextAnnotation;
import org.jfree.chart.axis.DateAxis;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.chart.renderer.xy.XYSplineRenderer;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.time.Day;
import org.jfree.data.time.Hour;
import org.jfree.data.time.Minute;
import org.jfree.data.time.TimeSeries;
import org.jfree.data.time.TimeSeriesCollection;
import org.jfree.data.xy.XYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.ui.TextAnchor;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.geom.Ellipse2D;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFNeonatologyMonitor extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    private String type;
    PdfWriter docWriter=null;
    public void addHeader(){
    }
    public void addContent(){
    }



    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFNeonatologyMonitor(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(int personid, java.util.Date begin, java.util.Date end) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
			doc.setPageSize(PageSize.A4);
            doc.setMargins(10,10,10,10);
            doc.open();
            
            generateMonitor(personid,begin,end);
            
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

    private void generateMonitor(int personid,java.util.Date begin, java.util.Date end) throws DocumentException, SQLException, IOException {
    	AdminPerson patient = AdminPerson.get(personid+"");
    	table = new PdfPTable(100);
        table.setWidthPercentage(100);
        cell= createBoldBorderlessCell("Neonatal Monitor Measurements", 100, 14);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        table.addCell(cell);
        table.addCell(createBorderlessCell("\n", 100));
        cell= createBorderlessCell2("Patient:", 15,9);
        table.addCell(cell);
        cell= createBoldBorderlessCell(patient.getFullName(), 85,9);
        table.addCell(cell);
        cell= createBorderlessCell2("Date of birth:", 15,9);
        table.addCell(cell);
        cell= createBoldBorderlessCell(patient.dateOfBirth, 85,9);
        table.addCell(cell);
        cell= createBorderlessCell2("Gender:", 15,9);
        table.addCell(cell);
        cell= createBoldBorderlessCell(patient.gender.toUpperCase(), 85,9);
        table.addCell(cell);
        cell= createBorderlessCell2("From:", 15,9);
        table.addCell(cell);
        cell= createBoldBorderlessCell(SH.formatDate(begin,"dd/MM/yyyy HH:mm"), 85,9);
        table.addCell(cell);
        cell= createBorderlessCell2("To:", 15,9);
        table.addCell(cell);
        cell= createBoldBorderlessCell(SH.formatDate(end,"dd/MM/yyyy HH:mm"), 85,9);
        table.addCell(cell);
        
        JFreeChart chart = getMonitoringChart("8867-4", personid, begin, end, "Heart rate");
        ByteArrayOutputStream osHR = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osHR,chart,680,350);
        // put image in cell
        cell = new PdfPCell();
        cell.setColspan(100);
        cell.setImage(com.itextpdf.text.Image.getInstance(osHR.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPadding(10);
        table.addCell(cell);

        chart = getMonitoringChart("8310-5", personid, begin, end, "Temperature");
        osHR = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osHR,chart,680,350);
        // put image in cell
        cell = new PdfPCell();
        cell.setColspan(100);
        cell.setImage(com.itextpdf.text.Image.getInstance(osHR.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPadding(10);
        table.addCell(cell);

        chart = getMonitoringChart("9279-1", personid, begin, end, "Respiratory rate");
        osHR = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osHR,chart,680,350);
        // put image in cell
        cell = new PdfPCell();
        cell.setColspan(100);
        cell.setImage(com.itextpdf.text.Image.getInstance(osHR.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPadding(10);
        table.addCell(cell);

        chart = getMonitoringChart("59408-5", personid, begin, end, "SpO2");
        osHR = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osHR,chart,680,350);
        // put image in cell
        cell = new PdfPCell();
        cell.setColspan(100);
        cell.setImage(com.itextpdf.text.Image.getInstance(osHR.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPadding(10);
        table.addCell(cell);

        chart = getMonitoringChart("73798-1", personid, begin, end, "Perfusion index");
        osHR = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osHR,chart,680,350);
        // put image in cell
        cell = new PdfPCell();
        cell.setColspan(100);
        cell.setImage(com.itextpdf.text.Image.getInstance(osHR.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPadding(10);
        table.addCell(cell);

        doc.add(table);
    }

    protected JFreeChart getMonitoringChart(String code,int personid,java.util.Date begin, java.util.Date end, String title) throws SQLException {
        TimeSeriesCollection dataset = new TimeSeriesCollection();
        TimeSeries series  = new TimeSeries(title);
        TimeSeries seriesmax  = new TimeSeries("max");
        TimeSeries seriesmin  = new TimeSeries("min");
        Connection conn = SH.getOpenClinicConnection();
        PreparedStatement ps = conn.prepareStatement("select HOUR(ts) time,AVG(VALUE) mean ,STDDEV(VALUE) stdev from oc_observations_history where code=? and personid=? and ts>=? and ts<? GROUP BY HOUR(ts) order by HOUR(ts)");
        ps.setString(1, code);
        ps.setInt(2, personid);
        ps.setTimestamp(3, SH.getSQLTimestamp(begin));
        ps.setTimestamp(4, SH.getSQLTimestamp(end));
        ResultSet rs = ps.executeQuery();
        while(rs.next()) {
        	series.addOrUpdate(new Hour(new java.util.Date(begin.getTime()+rs.getInt("time")*SH.getTimeHour())),rs.getFloat("mean"));
        	seriesmax.addOrUpdate(new Hour(new java.util.Date(begin.getTime()+rs.getInt("time")*SH.getTimeHour())),rs.getFloat("mean")+rs.getFloat("stdev"));
        	seriesmin.addOrUpdate(new Hour(new java.util.Date(begin.getTime()+rs.getInt("time")*SH.getTimeHour())),rs.getFloat("mean")-rs.getFloat("stdev"));
        }
        rs.close();
        ps.close();
        conn.close();
        dataset.addSeries(series);
        dataset.addSeries(seriesmax);
        dataset.addSeries(seriesmin);
        // create chart
        JFreeChart chart = createChart(dataset,code,title,begin, end);
        // visual customization
        chart.setBackgroundPaint(Color.WHITE);   
        return chart;
    }
    
    protected void addAnnotation(String label, java.awt.Font font, XYPlot plot, double xPos, double yPos){                
        XYTextAnnotation annotation = new XYTextAnnotation(label,xPos,yPos);
        annotation.setFont(font);
        annotation.setTextAnchor(TextAnchor.HALF_ASCENT_LEFT);
        plot.addAnnotation(annotation);
    }

    protected JFreeChart createChart(TimeSeriesCollection dataset, String subtitle, String yTitle, java.util.Date begin,java.util.Date end) {
        JFreeChart chart = ChartFactory.createTimeSeriesChart(
            null,
            "Time",
            yTitle,
            dataset,
            false,
            true,
            false
        );
                                         
        // add titles
        TextTitle t1 = new TextTitle(yTitle,new java.awt.Font("SansSerif",Font.BOLD,15));
        chart.addSubtitle(t1);

        // setup axes
        XYPlot plot = chart.getXYPlot();
        plot.setBackgroundPaint(new Color(0xffffe0));
        plot.setDomainGridlinesVisible(true);
        plot.setDomainGridlinePaint(Color.lightGray);
        plot.setRangeGridlinePaint(Color.lightGray);
        
        // x
        DateAxis domainAxis = (DateAxis)plot.getDomainAxis();
        domainAxis.setStandardTickUnits(DateAxis.createStandardDateTickUnits());
        domainAxis.setRange(begin, end);

        // y
        NumberAxis rangeAxis = (NumberAxis)plot.getRangeAxis();
        rangeAxis.setAutoRangeIncludesZero(false);
        rangeAxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        if(subtitle.equalsIgnoreCase("8310-5")) {
        	rangeAxis.setRange(31,42);
        }
        else if(subtitle.equalsIgnoreCase("73798-1")) {
        	rangeAxis.setRange(0,20);
        }
        else if(subtitle.equalsIgnoreCase("59408-5")) {
        	rangeAxis.setRange(50,100);
        }

        XYSplineRenderer renderer = new XYSplineRenderer();
        plot.setRenderer(renderer);
        renderer.setSeriesPaint(0,Color.BLACK);
        renderer.setSeriesShapesVisible(0,false);
        renderer.setSeriesPaint(1,Color.LIGHT_GRAY);
        renderer.setSeriesShapesVisible(1,false);
        renderer.setSeriesStroke(1, new BasicStroke(
                2.0f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND,
                1.0f, new float[] {6.0f, 6.0f}, 0.0f
            ));
        renderer.setSeriesPaint(2,Color.LIGHT_GRAY);
        renderer.setSeriesShapesVisible(2,false);
        renderer.setSeriesStroke(2, new BasicStroke(
                2.0f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND,
                1.0f, new float[] {6.0f, 6.0f}, 0.0f
            ));

        return chart;
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
