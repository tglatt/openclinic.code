<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFLabSampleLabelGenerator,
                be.openclinic.medical.LabRequest,be.openclinic.medical.LabSample,
                be.mxs.common.util.pdf.general.PDFImmoLabelGenerator,
                be.chuk.Article,
                java.util.*"%>
<%
	ByteArrayOutputStream baosPDF = null;
	String id = SH.p(request,"id");
	String name = SH.p(request,"name");
	Article article = new Article();
	article.id=id;
	article.name=name;
	Vector articles = new Vector();
	articles.add(article);
    try {
        // PDF generator
        PDFImmoLabelGenerator pdfImmoLabelGenerator = new PDFImmoLabelGenerator(activeUser, sProject);
        baosPDF = pdfImmoLabelGenerator.generatePDFDocumentBytes(request, articles);
        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");
        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=").append(sbFilename);

        // prepare response
        response.setHeader("Cache-Control", "max-age=30");
        response.setContentType("application/pdf");
        response.setHeader("Content-disposition", sbContentDispValue.toString());
        response.setContentLength(baosPDF.size());

        // write PDF to servlet
        ServletOutputStream sos = response.getOutputStream();
        baosPDF.writeTo(sos);
        sos.flush();
    }
    catch (DocumentException dex) {
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName() + " caught an exception: " + dex.getClass().getName() + "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally {
        if (baosPDF != null) {
            baosPDF.reset();
        }
    }

%>