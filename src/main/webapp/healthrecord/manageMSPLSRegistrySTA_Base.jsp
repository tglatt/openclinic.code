<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.medical.Problem,
                be.openclinic.medical.Diagnosis,
                be.openclinic.system.Transaction,
                be.openclinic.system.Item,
                be.openclinic.medical.Prescription,
                java.util.*" %>
<%@ page import="java.sql.Date" %>
<%@ page import="be.openclinic.medical.PaperPrescription" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String accessright="mspls.registry.sta";
%>
<%=checkPermission(accessright,"select",activeUser)%>
<%!
    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid) {
        // search for product in products-table
        Product product = Product.get(sProductUid);

        if (product != null && product.getName() == null) {
            // search for product in product-history-table
            product = product.getProductFromHistory(sProductUid);
        }

        return product;
    }

    //--- GET ACTIVE PRESCRIPTIONS FROM RS --------------------------------------------------------
    private Vector getActivePrescriptionsFromRs(StringBuffer prescriptions, Vector vActivePrescriptions, String sWebLanguage) throws SQLException {
        Vector idsVector = new Vector();
        java.util.Date tmpDate;
        Product product = null;
        String sClass = "1", sPrescriptionUid = "", sDateBeginFormatted = "", sDateEndFormatted = "",
                sProductName = "", sProductUid = "", sPreviousProductUid = "", sTimeUnit = "", sTimeUnitCount = "",
                sUnitsPerTimeUnit = "", sPrescrRule = "", sProductUnit = "", timeUnitTran = "";
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");
        SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
                deleteTran = getTranNoLink("Web", "delete", sWebLanguage);
        Iterator iter = vActivePrescriptions.iterator();

        // run thru found prescriptions
        Prescription prescription;

        while (iter.hasNext()) {
            prescription = (Prescription)iter.next();
            sPrescriptionUid = prescription.getUid();
            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            idsVector.add(sPrescriptionUid);

            // format begin date
            tmpDate = prescription.getBegin();
            if (tmpDate != null) sDateBeginFormatted = stdDateFormat.format(tmpDate);
            else sDateBeginFormatted = "";

            // format end date
            tmpDate = prescription.getEnd();
            if (tmpDate != null) sDateEndFormatted = stdDateFormat.format(tmpDate);
            else sDateEndFormatted = "";

            // only search product-name when different product-UID
            sProductUid = prescription.getProductUid();
            if (!sProductUid.equals(sPreviousProductUid)) {
                sPreviousProductUid = sProductUid;
                product = getProduct(sProductUid);
                if (product != null) {
                    sProductName = product.getName();
                } else {
                    sProductName = "";
                }
                if (sProductName.length() == 0) {
                    sProductName = "<font color='red'>" + getTran(null,"web", "nonexistingproduct", sWebLanguage) + "</font>";
                }
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit = prescription.getTimeUnit();
            sTimeUnitCount = Integer.toString(prescription.getTimeUnitCount());
            sUnitsPerTimeUnit = Double.toString(prescription.getUnitsPerTimeUnit());

            // only compose prescriptio-rule if all data is available
            if (!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")) {
                sPrescrRule = getTran(null,"web.prescriptions", "prescriptionrule", sWebLanguage);
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));
                if (product != null) {
                    sProductUnit = product.getUnit();
                } else {
                    sProductUnit = "";
                }
                // productunits
                if (Double.parseDouble(sUnitsPerTimeUnit) == 1) {
                    sProductUnit = getTran(null,"product.unit", sProductUnit, sWebLanguage);
                } else {
                    sProductUnit = getTran(null,"product.units", sProductUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                // timeunits
                if (Integer.parseInt(sTimeUnitCount) == 1) {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                    timeUnitTran = getTran(null,"prescription.timeunit", sTimeUnit, sWebLanguage);
                } else {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                    timeUnitTran = getTran(null,"prescription.timeunits", sTimeUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
            }

            //*** display prescription in one row ***
            prescriptions.append("<tr class='list" + sClass + "'  title='" + detailsTran + "'>")
                    .append("<td align='center'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.png' border='0' title='" + deleteTran + "' onclick=\"doDelete('" + sPrescriptionUid + "');\">")
                    .append("<td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sProductName + "</td>")
                    .append("<td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sDateBeginFormatted + "</td>")
                    .append("<td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sDateEndFormatted + "</td>")
                    .append("<td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sPrescrRule.toLowerCase() + "</td>")
                    .append("</tr>");
        }
        return idsVector;
    }

    private class TransactionID {
        public int transactionid = 0;
        public int serverid = 0;
    }

    //--- GET MY TRANSACTION ID -------------------------------------------------------------------
    private TransactionID getMyTransactionID(String sPersonId, String sItemTypes, JspWriter out) {
        TransactionID transactionID = new TransactionID();
        Transaction transaction = Transaction.getSummaryTransaction(sItemTypes, sPersonId);
        try {
            if (transaction != null) {
                String sUpdateTime = ScreenHelper.getSQLDate(transaction.getUpdatetime());
                transactionID.transactionid = transaction.getTransactionId();
                transactionID.serverid = transaction.getServerid();
                out.print(sUpdateTime);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        return transactionID;
    }

    //--- GET MY ITEM VALUE -----------------------------------------------------------------------
    private String getMyItemValue(TransactionID transactionID, String sItemType, String sWebLanguage) {
        String sItemValue = "";
        Vector vItems = Item.getItems(Integer.toString(transactionID.transactionid), Integer.toString(transactionID.serverid), sItemType);
        Iterator iter = vItems.iterator();

        Item item;

        while (iter.hasNext()) {
            item = (Item) iter.next();
            sItemValue = item.getValue();//checkString(rs.getString(1));
            sItemValue = getTranNoLink("Web.Occup", sItemValue, sWebLanguage);
        }
        return sItemValue;
    }
%>

 <!-- 
 <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
-->
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        
		<tr class='admin'>
			<td colspan="2"><%=getTran(request,"web", "admission", sWebLanguage)%></td>
		</tr>
		<tr>
			<td class='admin2' colspan='2'><%writeVitalSigns(pageContext); %></td>
		</tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "masnumber", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultTextInput(session, (TransactionVO) transaction, "ITEM_TYPE_MASNUMBER", 20) %> 
            </td>
        </tr>
		<!-- 
        <tr>
            <td class="admin"><%=getTran(request,"web", "admissiontype", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_ADMISSIONTYPE_STA", "mspls.sta.admission_type", sWebLanguage, "") %>
            </td>
        </tr>
		 -->
		<tr>
            <td class="admin"><%=getTran(request,"web", "reasonforadmission", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "mspls.sta.reasonforadmission",  "ITEM_TYPE_ADMISSIONTYPE_STA", sWebLanguage, true,"","") %>
            </td>
        </tr>
		<tr>
            <td class="admin"><%=getTran(request,"web", "oedeme", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_OEDEME_STA", "mspls.sta.oedeme", sWebLanguage, "") %>
            </td>
        </tr>
		<tr>
            <td class="admin"><%=getTran(request,"web", "transferstaname", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultTextInput(session, (TransactionVO) transaction, "ITEM_TYPE_LAB_TRANSFERSTATEXT", 40) %>
			</td>
        </tr>
        <% if(SH.c(activePatient.gender).toLowerCase().equalsIgnoreCase("f") && activePatient.getAge()>=10){ %>
        <tr>
            <td class="admin"><%=getTran(request,"mspls", "pregnancyrelated", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "mspls.ssn.pregnancyrelated",  "ITEM_TYPE_PREGNANCYRELATED", sWebLanguage, true,"","") %>
            </td>
        </tr>
        <% } %>
        <tr>
            <td class="admin"><%=getTran(request,"mspls", "hivrelatedmalnutrition", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultCheckBoxes((TransactionVO)transaction, request, "mspls.sta.hivrelatedmalnutrition",  "ITEM_TYPE_HIVRELATEDMALNUTRITION", sWebLanguage, true) %>
            </td>
        </tr>
        <tr>
        	<td colspan='2'><%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%></td>
        </tr>
    </table>
    <table width="100%" class="list" cellspacing="1">
        <tr class="admin">
            <td align="center"><a href="javascript:openPopup('medical/managePrescriptionsPopup.jsp&amp;skipEmpty=1',900,400,'medication');void(0);"><%=getTran(request,"Web.Occup","medwan.healthrecord.medication",sWebLanguage)%></a></td>
        </tr>
        <tr>
            <td>
        <%
            //--- DISPLAY ACTIVE PRESCRIPTIONS (of activePatient) ---------------------------------
            // compose query
            Vector vActivePrescriptions = Prescription.findActive(activePatient.personid,activeUser.userid,"","","","","","");

            StringBuffer prescriptions = new StringBuffer();
            Vector idsVector = getActivePrescriptionsFromRs(prescriptions, vActivePrescriptions , sWebLanguage);
            int foundPrescrCount = idsVector.size();

            if(foundPrescrCount > 0){
                %>
                    <table width="100%" cellspacing="0" cellpadding="0" class="list">
                        <%-- header --%>
                        <tr class="admin">
                            <td width="22" nowrap>&nbsp;</td>
                            <td width="30%"><%=getTran(request,"Web","product",sWebLanguage)%></td>
                            <td width="15%"><%=getTran(request,"Web","begindate",sWebLanguage)%></td>
                            <td width="15%"><%=getTran(request,"Web","enddate",sWebLanguage)%></td>
                            <td width="40%"><%=getTran(request,"Web","prescriptionrule",sWebLanguage)%></td>
                        </tr>

                        <tbody class="hand"><%=prescriptions%></tbody>
                    </table>
                <%
            }
            else{
                // no records found
                %><%=getTran(request,"web","noactiveprescriptionsfound",sWebLanguage)%><br><%
            }
            %>
            </td>
        </tr>
        <tr class="admin">
            <td align="center"><%=getTran(request,"curative","medication.paperprescriptions",sWebLanguage)%> (<%=ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime())%>)</td>
        </tr>
        <%
            Vector paperprescriptions = PaperPrescription.find(activePatient.personid,"",ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime()),ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime()),"","DESC");
            if(paperprescriptions.size()>0){
                out.print("<tr><td><table width='100%'>");
                String l="";
                for(int n=0;n<paperprescriptions.size();n++){
                    if(l.length()==0){
                        l="1";
                    }
                    else{
                        l="";
                    }
                    PaperPrescription paperPrescription = (PaperPrescription)paperprescriptions.elementAt(n);
                    out.println("<tr class='list"+l+"' id='pp"+paperPrescription.getUid()+"'><td valign='top' width='90px'><img src='_img/icons/icon_delete.png' onclick='deletepaperprescription(\""+paperPrescription.getUid()+"\");'/> <b>"+ScreenHelper.stdDateFormat.format(paperPrescription.getBegin())+"</b></td><td><i>");
                    Vector products =paperPrescription.getProducts();
                    for(int i=0;i<products.size();i++){
                        out.print(products.elementAt(i)+"<br/>");
                    }
                    out.println("</i></td></tr>");
                }
                out.print("</table></td></tr>");
            }
        %>
        <tr>
            <td><a href="javascript:openPopup('medical/managePrescriptionForm.jsp&amp;skipEmpty=1',650,430,'medication');void(0);"><%=getTran(request,"web","medicationpaperprescription",sWebLanguage)%></a></td>
        </tr>
    </table>            
	<%-- BUTTONS --%>



<script>
function calculateWeightOverHeight(){
	  if(document.getElementById("ITEM_TYPE_WEIGHT").value.trim()=="" || document.getElementById("ITEM_TYPE_HEIGHT").value.trim()==""){
		  document.getElementById("ITEM_TYPE_WEIGHTOVERHEIGHT").value="";
	  }
	  else{
		  document.getElementById("ITEM_TYPE_WEIGHTOVERHEIGHT").value=(document.getElementById("ITEM_TYPE_WEIGHT").value/document.getElementById("ITEM_TYPE_HEIGHT").value).toFixed(2);
		  checkWeightForHeight(document.getElementById("ITEM_TYPE_HEIGHT").value,document.getElementById("ITEM_TYPE_WEIGHT").value,"ITEM_TYPE_WEIGHTOVERHEIGHTZ");
	  }
}

	function checkWeightForHeight(height,weight,fieldid){
	      var today = new Date();
	      var url= '<c:url value="/ikirezi/getWeightForHeight.jsp"/>?height='+height+'&weight='+weight+'&gender=<%=activePatient.gender%>&ts='+today;
	      new Ajax.Request(url,{
	          method: "POST",
	          postBody: "",
	          onSuccess: function(resp){
	              var label = eval('('+resp.responseText+')');
	    		  if(label.zindex>-999){
	    			  if(label.zindex<-3){
	    				  document.getElementById(fieldid).className="darkredtext";
	    			  }
	    			  else if(label.zindex<-2){
	    				  document.getElementById(fieldid).className="orangetext";
	    			  }
	    			  else if(label.zindex<-1){
	    				  document.getElementById(fieldid).className="yellowtext";
	    			  }
	    			  else if(label.zindex>2){
	    				  document.getElementById(fieldid).className="orangetext";
	    			  }
	    			  else if(label.zindex>1){
	    				  document.getElementById(fieldid).className="yellowtext";
	    			  }
	    			  else{
	    				  document.getElementById(fieldid).className="text";
	    			  }
	    			  document.getElementById(fieldid).value=(label.zindex*1).toFixed(1);
	    		  }
	    		  else{
	    			  document.getElementById(fieldid).value="";
  				  document.getElementById(fieldid).className="text";
	    		  }
	          },
	          onFailure: function(){
	          }
	      }
		  );
	  	}

  function checkAdmissionCriteria(){
	  if(!(document.getElementById("ITEM_TYPE_ARM_CIRCUMFERENCE").value.trim()=="") && document.getElementById("ITEM_TYPE_ARM_CIRCUMFERENCE").value*10<115){
		  document.getElementById("ITEM_TYPE_OTHERREASONFORADMISSION_STA.2").checked=true;
		  alert("OK");
	  }
	  else{
		  document.getElementById("ITEM_TYPE_OTHERREASONFORADMISSION_STA.2").checked=false;
	  }
	  updateMultiCheckbox(document.getElementById("ITEM_TYPE_OTHERREASONFORADMISSION_STA.2"),"ITEM_TYPE_OTHERREASONFORADMISSION_STA","2");
}

  function searchEncounter(){
	    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  


  function searchUser(managerUidField,managerNameField){
	  openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no&FindServiceID=<%=MedwanQuery.getInstance().getConfigString("CCBRTEyeRegistryService")%>",650,600);
    document.getElementById(diagnosisUserName).focus();
  }


  calculateWeightOverHeight();
  checkAdmissionCriteria()
</script>
    
