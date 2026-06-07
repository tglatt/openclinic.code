<%@page import="be.openclinic.finance.PatientInvoice,
                java.util.Vector,
                java.text.DecimalFormat,
                be.mxs.common.util.io.OBR,
                be.mxs.common.util.io.MedHub,
                be.mxs.common.util.io.Medhubmessage,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindInvoicePatientId  = checkString(request.getParameter("FindInvoicePatientId")),
           sFindInvoiceDate       = checkString(request.getParameter("FindInvoiceDate")),
           sFindInvoiceNr         = checkString(request.getParameter("FindInvoiceNr")),
           sFindInvoiceBalanceMin = checkString(request.getParameter("FindInvoiceBalanceMin")),
           sFindInvoiceBalanceMax = checkString(request.getParameter("FindInvoiceBalanceMax")),
           sFindInvoiceStatus     = checkString(request.getParameter("FindInvoiceStatus"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldInvoiceUid    = checkString(request.getParameter("ReturnFieldInvoiceUid")),
           sReturnFieldInvoiceNr     = checkString(request.getParameter("ReturnFieldInvoiceNr")),
           sReturnFieldInvoiceBalance    = checkString(request.getParameter("ReturnFieldInvoiceBalance")),
           sReturnFieldInvoiceMaxBalance = checkString(request.getParameter("ReturnFieldInvoiceMaxBalance")),
           sReturnFieldInvoiceStatus = checkString(request.getParameter("ReturnFieldInvoiceStatus"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************** searchByAjax/searchPatientInvoiceShow.jsp **************");
        Debug.println("sAction                   : "+sAction);
        Debug.println("sFindInvoicePatientId     : "+sFindInvoicePatientId);
        Debug.println("sFindInvoiceDate          : "+sFindInvoiceDate);
        Debug.println("sFindInvoiceNr            : "+sFindInvoiceNr);
        Debug.println("sFindInvoiceType (static) : P");
        Debug.println("sFunction                 : "+sFunction+"\n");
        Debug.println("sFindInvoiceBalanceMin    : "+sFindInvoiceBalanceMin);
        Debug.println("sFindInvoiceBalanceMax    : "+sFindInvoiceBalanceMax);
        Debug.println("sFindInvoiceStatus        : "+sFindInvoiceStatus+"\n");
        Debug.println("sReturnFieldInvoiceUid        : "+sReturnFieldInvoiceUid);
        Debug.println("sReturnFieldInvoiceNr         : "+sReturnFieldInvoiceNr);
        Debug.println("sReturnFieldInvoiceBalance    : "+sReturnFieldInvoiceBalance);
        Debug.println("sReturnFieldInvoiceMaxBalance : "+sReturnFieldInvoiceMaxBalance);
        Debug.println("sReturnFieldInvoiceStatus     : "+sReturnFieldInvoiceStatus+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","");
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));

    //*** SEARCH **************************************************************
    if(sAction.equals("search")){
        Vector vInvoices = PatientInvoice.searchInvoices(sFindInvoiceDate,sFindInvoiceNr,sFindInvoicePatientId,
        		                                         sFindInvoiceStatus,sFindInvoiceBalanceMin,sFindInvoiceBalanceMax);

        int recCount = 0;
        StringBuffer sHtml = new StringBuffer();
        String sClass = "1", sInvoiceUid, sInvoiceDate, sInvoiceNr, sInvoiceStatus;
        PatientInvoice invoice;
        
        Iterator iter = vInvoices.iterator();
        while(iter.hasNext()){
            invoice = (PatientInvoice)iter.next();
            sInvoiceUid = invoice.getUid();
            recCount++;

            sInvoiceNr = sInvoiceUid.substring(sInvoiceUid.indexOf(".")+1);
            sInvoiceStatus = getTranNoLink("finance.patientinvoice.status",invoice.getStatus(),sWebLanguage);

            // date
            if(invoice.getDate()!=null){
                sInvoiceDate = ScreenHelper.stdDateFormat.format(invoice.getDate());
            }
            else{
                sInvoiceDate = "";
            }
            
          //*** OBR BEGIN ******
            String rez = "";
            String rez2 = "";
            
            rez = rez + "&nbsp;" ;
            
            if(MedwanQuery.getInstance().getConfigInt("enableMedHub",0)==1){
            if(activeUser.getAccessRight("financial.modifyinvoice.select")){
            	rez = rez +"M";
            rez = rez +"&nbsp;";
            rez = rez + MedHub.getSendingStatus(invoice.getUid(),sCONTEXTPATH);
            }
            }
            
            if(MedwanQuery.getInstance().getConfigInt("enableOBR",0)==1){
            	if(activeUser.getAccessRight("financial.modifyinvoice.select")){
            rez = rez + "&nbsp;";
            rez = rez + "O" + "&nbsp;" +  OBR.getSendingStatus(invoice.getUid(),sCONTEXTPATH);
            }	
            }
            
            if(activeUser.getAccessRight("financial.modifyinvoice.select")){
            rez2 = rez2 + "&nbsp;";
            rez2 = rez2 + Medhubmessage.countInvoiceMessages(invoice.getUid(),sCONTEXTPATH);
            rez2 = rez2 + "&nbsp;";
            }
          //*** OBR END ******

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";
            
            sHtml.append("<tr class='list"+sClass+"' onmouseover=\"this.style.cursor='hand';\" onmouseout=\"this.style.cursor='default';\"")
                  .append(" onclick=\"selectInvoice('"+sInvoiceUid+"','"+sInvoiceDate+"','"+sInvoiceNr+"','"+invoice.getBalance()+"','"+HTMLEntities.htmlentities(sInvoiceStatus)+"');\">")
                  .append("<td>"+sInvoiceDate+"</td>")
                  .append("<td>"+sInvoiceNr+rez+"</td>")
                  .append("<td style='text-align:right;'>"+SH.getTotalPriceString(invoice.getBalance())+"&nbsp;</td>");
                  
           
                       sHtml.append("<td>")
                       .append(HTMLEntities.htmlentities(sInvoiceStatus))
                     //*** OBR BEGIN ******
                       .append(rez2)
                     //*** OBR END ******
                       .append("</td>");  
                 
                  
                   sHtml.append("</tr>");
        }

        if(recCount > 0){
		    %>
			   <table id="searchresults" width="100%">
			       <%-- header --%>
			       <tr class="admin">
			           <td nowrap><%=HTMLEntities.htmlentities(getTran(request,"web","date",sWebLanguage))%></td>
			           <td nowrap><%=HTMLEntities.htmlentities(getTran(request,"web","invoicenumber",sWebLanguage))%></td>
			           <td nowrap style="text-align:right;">
			               <%=HTMLEntities.htmlentities(getTran(request,"web","balance",sWebLanguage))%>&nbsp;&nbsp;
			           </td>
			           <td  nowrap>
			               <%=HTMLEntities.htmlentities(getTran(request,"web.finance","patientinvoice.status",sWebLanguage))%>
			           </td>
			       </tr>
			
			       <%=sHtml.toString()%>
			   </table>
			   
               <%=recCount%> <%=HTMLEntities.htmlentities(getTran(request,"web","recordsfound",sWebLanguage))%>
               <script>sortables_init();</script>
		   <%
        }
        else{
            // display 'no results' message
            %><%=HTMLEntities.htmlentities(getTran(request,"web","norecordsfound",sWebLanguage))%><%
        }
    }
%>