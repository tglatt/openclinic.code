<%@page import="be.mxs.common.util.diagnostics.Diagnosis"%>
<%@page import="be.mxs.common.model.vo.healthrecord.ICPCCode, java.util.Vector"%>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="be.openclinic.medical.UserDiagnosis" %>
<%@ page import="be.openclinic.medical.ServiceDiagnosis" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>


<%=sJSSCRPTACULOUS%> 

<%

	String icd11URL = MedwanQuery.getInstance().getConfigString("icd11server");

    String sReturnField = checkString(request.getParameter("returnField"));
	String sShowPatientEncounters = checkString(request.getParameter("showpatientencounters"));
	
	String sCode  = checkString(request.getParameter("Code")),
           sValue = checkString(request.getParameter("Value")),
           sLabel = checkString(request.getParameter("Label")),
           sType  = checkString(request.getParameter("Type"));
	sCode = "";
    
    String sPatientUid = checkString(request.getParameter("patientuid"));
    if(sPatientUid.length()==0 && activePatient!=null){
    	sPatientUid=activePatient.personid;
    }

    String sAuthorId=checkString(request.getParameter("AuthorUID"));
	if(sPatientUid==null){
		sPatientUid=activePatient.personid;
	}
    
    String sServiceUid = checkString(request.getParameter("serviceUid"));
    String sEncounterUid = checkString(request.getParameter("EncounterUid"));
%>
<%-- Start Floating Layer ------------------------------------------------------------------------%>


<%@page import="be.openclinic.medical.UserDiagnosis"%>


<link rel="stylesheet" href="_common/_css/icd11/icd11ect-1.5.1.css">

<style>
#ctwFlexContainer{
min-height: 600px;
}

</style>

<div>
	
	<table width="100%">
	<tr> 
		<td class="admin"><span id="searching_keys"> Cle de recherche</span> </td>
		<td class="admin2"> <input type="text" class="ctw-input" autocomplete="off" data-ctw-ino="1"> </td>
	</tr>
	
	<tr>
		<td> The selected code: <input type="text" id="paste-selectedEntity" value=""> 
                    <input type="text" id="paste-selectedLabel" value=""> 
         </td>
         
         <td>
	         <%=ScreenHelper.setFormButtonsStart()%>
	            <input class="button" type="button" name="EditAddButton" value="<%=getTranNoLink("web","add",sWebLanguage)%>" id="saveIcd11" >&nbsp;
			<%=ScreenHelper.setFormButtonsStop()%>
         </td>
	</tr>
	</table>

    <!-- input element used for typing the search  -->
    
    
   

    <!-- div element used for showing the search results -->
    <div class="ctw-window content-icd11" data-ctw-ino="1"></div>
</div>



<script type="text/javascript">

function addICD11(code ="CODE 1" , label = "LABEL CODE 1"){
    openPopup("/_common/search/diagnoseInfoIcd11.jsp&AuthorUID=<%=sAuthorId%>&ts=<%=getTs()%>&showpatientencounters=<%=sShowPatientEncounters%>&Type=ICD11&Code="+code+"&Value="+code+"&Label="+label+"&returnField=<%=sReturnField%>&returnField2=<%=sReturnField%>&patientuid=<%=sPatientUid%>",800,600);
}
var saveIcd11Button = document.getElementById("saveIcd11");


saveIcd11Button.addEventListener("click", function(e){
	e.preventDefault();
    var codeICD11 = document.getElementById("paste-selectedEntity").value;
    var label = document.getElementById("paste-selectedLabel").value;
    addICD11(codeICD11, label);
   
});


	
</script>


<script src="_common/_css/icd11/icd11ect-1.5.1.js"></script>
 
    <script>
        // Embedded Coding Tool settings object
        // please note that only the property "apiServerUrl" is required
        // the other properties are optional
        const mySettings = {
            apiServerUrl: "<%= icd11URL %>",  
            apiSecured: false ,
            popupMode: false,
            language : 'fr',
            apiSecured: false,
            
        };

        // example of an Embedded Coding Tool using the callback selectedEntityFunction 
        // for copying the code selected in an <input> element and clear the search results
        const myCallbacks = {
            selectedEntityFunction: (selectedEntity) => { 
                // paste the code into the <input>
                document.getElementById('paste-selectedEntity').value = selectedEntity.code; 
              //  console.log(selectedEntity);       
                document.getElementById('paste-selectedLabel').value = selectedEntity.title;        
                // clear the searchbox and delete the search results
               // ECT.Handler.clear("1")    
            }
        };

        // configure the ECT Handler with mySettings and myCallbacks
        ECT.Handler.configure(mySettings, myCallbacks);
    </script>    
