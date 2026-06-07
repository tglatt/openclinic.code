<%@page import="be.openclinic.system.Screen"%>
<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.system.HTMLEntities,
                java.text.DecimalFormat,
                be.openclinic.finance.Insurance,
                java.util.Date,
                be.mxs.common.util.io.OBR,
                be.mxs.common.util.io.MedHub,
                be.openclinic.medical.ReasonForEncounter,
                be.mxs.common.util.system.*"%>         
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>


<%
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
    String sFindDateBegin = checkString(request.getParameter("FindDateBegin"));
    String sFindDateEnd = checkString(request.getParameter("FindDateEnd"));   
    String smodule = checkString(request.getParameter("module"));
    String sPeriodicSummaService = checkString(request.getParameter("EditEncounterService"));
    String sinsurarUid = checkString(request.getParameter("insurarUid"));
    String selectstatus = checkString(request.getParameter("selectstatus"));
    
    String begin_select = checkString(request.getParameter("begindiv"));
    String max_selection = checkString(request.getParameter("maxdiv"));
    String end_select = checkString(request.getParameter("enddiv"));
    String sdirection = checkString(request.getParameter("direction"));
   
 
/*      out.print("Date d"+sFindDateBegin);
     out.print("<br>");
     out.print("Date f "+sFindDateEnd);
     out.print("<br>");
     out.print("mod: " +smodule);
     out.print("<br>");
     out.print("periode: "+sPeriodicSummaService);
     out.print("<br>");
     out.print("ins: "+sinsurarUid);
     out.print("<br>");
     out.print("status: "+selectstatus);
     out.print("<br>");
     out.print("egin: "+begin_select);
     out.print("<br>");
     out.print("max: "+max_selection);
     out.print("<br>");
     out.print("end: "+end_select);
     out.print("<br>");
     out.print("dir: "+sdirection);
     out.print("<br>"); */
    
     //sFindDateBegin = "04/01/2005";
     //sFindDateEnd = "06/03/2023"; 
     //smodule = "MedHub";
      //sPeriodicSummaService = "";
      //sinsurarUid = "";
     // selectstatus = "";
     
     //begin_select = "40";
     //max_selection = "10";
      //direction = "DESC";
      //end_select = "50";
    
    
    //out.print(selectstatus);
    out.print(MedHub.ListClosedInvoices(sFindDateBegin,sFindDateEnd,selectstatus,smodule,sinsurarUid, sPeriodicSummaService, begin_select , max_selection, end_select, sdirection, sCONTEXTPATH ));
 
    
  %>
    

           
            
      
       