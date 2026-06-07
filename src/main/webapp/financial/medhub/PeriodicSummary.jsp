<%@ page import="be.mxs.common.util.system.*,be.openclinic.finance.*,java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
  <table width="100%"><tr class='admin'>
  <td colspan='2'>
       <%=getTran(request,"web","periodicsummary",sWebLanguage)%>
  </td>
 </tr>
 </table>
 <form name="EditForm" id="EditForm" method="POST">
<table width="100%">
   <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web.occup","medwan.common.date",sWebLanguage)%></td>
            <td class="admin2" width="80"><%=getTran(request,"Web","Begin",sWebLanguage)%></td>
            <td class="admin2" width="150"><%=writeDateField("FindDateBegin","EditForm",SH.formatDate(new java.util.Date()),sWebLanguage)%></td>
            <td class="admin2" width="80"><%=getTran(request,"Web","end",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindDateEnd","EditForm",SH.formatDate(new java.util.Date()),sWebLanguage)%></td>
        </tr>
        
       
        
           <tr id="Service">
	            <td class="admin" width="<%=sTDAdminWidth%>" ><%=getTran(request,"web","service",sWebLanguage)%></td>
	            <td class='admin2' colspan='4'>
	                <input type="hidden" name="EditEncounterService" id="EditEncounterService" value="" onchange="EditEncounterForm.EditEncounterBed.value='';EditEncounterForm.EditEncounterBedName.value='';setBedButton();setTransfer();changeService();">
	                <input class="text" type="text" name="EditEncounterServiceName" id="EditEncounterServiceName" readonly size="<%=sTextWidth%>" value="" >
	                
	                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"web","select",sWebLanguage)%>" onclick="searchService('EditEncounterService','EditEncounterServiceName');">
	                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"web","clear",sWebLanguage)%>" onclick="EditForm.EditEncounterService.value='';EditForm.EditEncounterServiceName.value='';">
	            </td>  
	        </tr>  
	        
	        
	    <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" ><%=getTran(request,"web","company",sWebLanguage)%></td>
          <td class="admin2" colspan='4'>
            <input type="hidden" name="EditNumber" id="EditNumber" value="">
            <input type="hidden" name="EditInsurarUID" id="EditInsurarUID" value="">
            <input type="text" class="text" readonly name="EditInsurarText" value="" size="100">
			<img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsurar();">
			<img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="doClearInsurar()">
           
        </td>
        </tr>
        
         <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" ><%=getTran(request,"web","Module",sWebLanguage)%></td>
          <td class="admin2" colspan='4'>
               <select class="text" id="SelectModule" name="SelectModule">
                   <%
	              		if(SH.ci("enableOBR",0)==1){out.println("<option>OBR</option>");} 
	              		if(SH.ci("enableMedHub",0)==1){out.println("<option>MedHub</option>");} 
                   	%>
                </select>
          </td>
        </tr>  
        
           <tr>
            <td class="admin">Status</td>
            <td class="admin2" colspan="4">
            <select class="text" id="SelectStatus" name="SelectStatus">
            <option value="1">Toutes les factures</option>
            <option value="2">Annulee</option>
            <option value="3">Ouverte</option>
            <option value="4">Fermee</option>
            <option value="5">Validee</option>
            <option value="6">Non Validee</option>
            <option value="7">Envoyee</option>
            <option value="8">Avec erreur</option>
            <option value="9">Sans signature du responsable</option>
            </select>
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="loadPeriodicSummary()">&nbsp;
            </td>
        </tr>
                
</table> 
 </form>
  <table width="100%" class="list" cellspacing="0" style="border:none;">
            <tr class="admin">
            
                <td width="20%" style="text-align: left;"><%=HTMLEntities.htmlentities(getTran(request,"web","invoices",sWebLanguage))%></td>
                <td width="20%" style="text-align: left;"><%=HTMLEntities.htmlentities(getTran(request,"web","Nombre",sWebLanguage))%></td>
                <td width="20%" style="text-align: left;"><%=HTMLEntities.htmlentities(getTran(request,"web","amount",sWebLanguage))%>&nbsp;&nbsp;</td>
                <td width="20%" style="text-align: left;"><%=HTMLEntities.htmlentities(getTran(request,"web","details",sWebLanguage))%>&nbsp;&nbsp;</td>
                <td width="20%" style="text-align: left;"><%=HTMLEntities.htmlentities(getTran(request,"web","synthese",sWebLanguage))%>&nbsp;&nbsp;</td>
                     
       </tr>
       </table>
<div id='result' name='result'>
</div>
<script>


function MedhubInvoicesDetails(invoicestatus){

	var status_facture = document.getElementById('SelectStatus').value;
	var max_selection = 10;
	var begin_select = 0;
	var end_select = 0;
	invoicestatus = status_facture;
	//alert(invoicestatus);
    var URL = "&FindDateBegin="
    +document.getElementById('FindDateBegin').value
    +"&FindDateEnd="+document.getElementById('FindDateEnd').value
    +"&EditEncounterService="+document.getElementById('EditEncounterService').value
    +"&insurarUid="+document.getElementById('EditInsurarUID').value
    +"&module="+document.getElementById('SelectModule').value
    
    +"&max_selection="+max_selection
    +"&begin_select="+begin_select
    +"&end_select="+end_select
    
    +"&invoicestatus="+invoicestatus+"&ts=<%=getTs()%>";
    
    
    window.open("<c:url value='/financial/medhub/util/resume.jsp?'/>" + URL);
    
    
    
  }

function searchService(serviceUidField,serviceNameField){
	
    var sNeedsBeds = "";
  
     sNeedsBeds = "&needsvisits=0";
        
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarSelectDefaultStay=true&VarCode="+serviceUidField+"&VarText="+serviceNameField+sNeedsBeds);
    document.getElementById(serviceNameField).focus();
  }
  
 function searchInsurar(){
	  openPopup("/_common/search/searchInsurar.jsp&ts=<%=getTs()%>&ReturnFieldInsurarUid=EditInsurarUID&ReturnFieldInsurarName=EditInsurarText&doFunction=changeInsurar(0)&excludePatientSelfIsurarUID=true&PopupHeight=500&PopupWith=500");
	}

function doClearInsurar(){
	  EditForm.EditInsurarUID.value = "";
	  EditForm.EditInsurarText.value = "";
	}
  
function doClearService(){
	  EditForm.EditInsurarUID.value = "";
	  EditForm.EditInsurarText.value = "";
	}
  function loadPeriodicSummary(){
	  if(document.getElementById('FindDateBegin').value!="" && 
			  document.getElementById('FindDateEnd').value!=""){
	        $("result").innerHTML = "<br><br><br><div id='ajaxLoader' style='display:block;text-align:center;'>"+
	                                    "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..</div>";
	        var params ="";                          
	            params = "FindDateBegin="+document.getElementById('FindDateBegin').value+
	                     "&FindDateEnd="+document.getElementById('FindDateEnd').value+
	                     "&EditEncounterService="+document.getElementById('EditEncounterService').value+
	                     "&module="+document.getElementById('SelectModule').value+
	                     "&selectstatus="+document.getElementById('SelectStatus').value+
	                     "&insurarUid="+document.getElementById('EditInsurarUID').value;
	            //alert(params);
	            //$("result").innerHTML = params;
	        var url= "<c:url value='/financial/medhub/getPeriodicSummary.jsp'/>?ts="+new Date();
	        new Ajax.Request(url,{
	          method: "GET",
	          parameters: params,
	          onSuccess: function(resp){
	            $("result").innerHTML = resp.responseText; 
	          }
	   });
	  }else{
		alert("Indiquez la date de debut et la date de fin de la periode!");  
	  }
  }
  
  
    function printSummary(){
    	//alert("Go");
	var url = "<c:url value='/financial/medhub/createSammary.jsp'/>"+
	          "?FindDateBegin="+document.getElementById('FindDateBegin').value+
	          "&FindDateEnd="+document.getElementById('FindDateEnd').value+
	          "&EditEncounterService="+document.getElementById('EditEncounterService').value+
	          "&module="+document.getElementById('SelectModule').value+
	          "&selectstatus="+document.getElementById('SelectStatus').value+
	          "&insurarUid="+document.getElementById('EditInsurarUID').value+
	          "&ts=<%=getTs()%>";
	          //alert(url);
	  window.open(url,"Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=1200,menubar=no").moveTo((screen.width-800)/2,(screen.height-1200)/2);
     }
  
 
</script>

