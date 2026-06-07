<%@ page import="be.openclinic.medical.PaperPrescription,
				 be.openclinic.medical.Prescription,
				 be.openclinic.pharmacy.Product" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%!
	private Product getProduct(String sProductUid) {
	    // search for product in products-table
	    Product product = Product.get(sProductUid);
	
	    if (product != null && product.getName() == null) {
	        // search for product in product-history-table
	        product = product.getProductFromHistory(sProductUid);
	    }
	
	    return product;
	}
	
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
%>
<%            
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
