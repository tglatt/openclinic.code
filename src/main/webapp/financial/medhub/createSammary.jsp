<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.*" %>

<%
    ByteArrayOutputStream baosPDF = null;

    try {
        // PDF generator
        String FindDateBegin = checkString(request.getParameter("FindDateBegin"));
        String FindDateEnd = checkString(request.getParameter("FindDateEnd"));
        String EditEncounterService = checkString(request.getParameter("EditEncounterService"));
        String module = checkString(request.getParameter("module"));
        String selectstatus = checkString(request.getParameter("selectstatus"));
        String insurarUid = checkString(request.getParameter("insurarUid"));
        
        String selectstatus_to_send = ""; 
        
        switch(selectstatus){
        case "1":
       	 selectstatus_to_send = "all";  
       	 break;
        case "2":
       	 selectstatus_to_send = "canceled";	
       	 break;
        case "3":
       	 selectstatus_to_send = "open";
       	 break;
        case "4":
       	 selectstatus_to_send = "closed";
       	 break;
        case "5":
       	 selectstatus_to_send = "validated";	
       	 break;
        case "6":
       	 selectstatus_to_send = "novalidated";
       	 break;
        case "7":
       	 selectstatus_to_send = "sent";
       	 break;
        case "8":
       	 selectstatus_to_send = "errors";
       	 break;
        case "9":
         selectstatus_to_send = "noservsignature";
        break;
        }
        
        
        
      
        PDFSammaryGeneratorNew PDFSammaryGenerator = new PDFSammaryGeneratorNew(activeUser, sProject);
        	//String[] colors = checkString((String)activePatient.adminextends.get("usergroup")).split("\\.");
        	//if(colors.length==3){
        		
        		//PDFSammaryGenerator.setRed(Integer.parseInt(colors[0]));
        		//PDFSammaryGenerator.setGreen(Integer.parseInt(colors[1]));
        		//PDFSammaryGenerator.setBlue(Integer.parseInt(colors[2]));
        		
        	//}
        	
    	baosPDF = PDFSammaryGenerator.generatePDFDocumentBytes(request,FindDateBegin, FindDateEnd,selectstatus_to_send,module,EditEncounterService, insurarUid);
       
       
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