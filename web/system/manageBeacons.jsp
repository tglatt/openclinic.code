<%@page import="java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../assets/includes/commonFunctions.jsp"%>
<%=checkPermission(out,"beacons","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>
<%=sJSEMAIL%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** assets/manageBeacons.jsp **********************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>            

<form name="SearchForm" id="SearchForm" method="POST">
    <%=writeTableHeader("web","beacons",sWebLanguage,"")%>
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- search ID --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","id",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="searchId" name="searchId" size="20" maxLength="50" value="">
            </td>
        </tr>   
        
        <%-- search ALIAS --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","alias",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="searchAlias" name="searchAlias" size="20" maxLength="50" value="">
            </td>
        </tr>   
        
        <%-- search TYPE --%>                
        <tr>
            <td class="admin"><%=getTran(request,"web","type",sWebLanguage)%></td>
            <td class="admin2">
	            <select class='text' id="searchType" name="searchType">
	            	<option/>
	            	<%= SH.writeSelect(request, "bleResourceType", "", sWebLanguage) %>
	            </select>
            </td>
        </tr>
                    
        <%-- search BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSearch" id="buttonSearch" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="searchBeacons();">&nbsp;
                <input class="button" type="button" name="buttonClear" id="buttonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
            </td>
        </tr>
    </table>
</form>

<script>
  SearchForm.searchId.focus();

  <%-- SEARCH BEACONS --%>
  function searchBeacons(){
    document.getElementById("divBeacons").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Searching";            
    var url = "<c:url value='/system/ajax/getBeacons.jsp'/>?ts="+new Date().getTime();
    var params="id="+SearchForm.searchId.value+
    "&alias="+SearchForm.searchAlias.value+
    "&type="+SearchForm.searchType.value;
    new Ajax.Request(url,{
      method: "GET",
      parameters: params,
      onSuccess: function(resp){
        $("divBeacons").innerHTML = resp.responseText;
        sortables_init();
      },
      onFailure: function(resp){
        $("divBeacon").innerHTML = "Error in 'system/ajax/getBeacons.jsp' : "+resp.responseText.trim();
      }
    });
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    document.getElementById("searchId").value = "";
    document.getElementById("searchType").value = "";
    
    document.getElementById("searchId").focus();
    resizeAllTextareas(8);
  }
</script>

<div id="divBeacons" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- id --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","id",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="id" name="id" size="50" maxLength="50" value="">
                &nbsp;&nbsp;&nbsp;<%=getTran(request,"web","detecton",sWebLanguage) %>:&nbsp;
                <select id='reader' name='reader' class='text'>
					<option/>
					<%
						String activeBLEReader = SH.c((String)session.getAttribute("activeBLEReader"));
						Connection conn = SH.getOpenClinicConnection();
						PreparedStatement ps = conn.prepareStatement("select distinct oc_beacon_id,oc_beacon_comment,oc_beacon_alias from oc_beacons where oc_beacon_resourcetype='reader' order by oc_beacon_alias");
						ResultSet rs = ps.executeQuery();
						while(rs.next()){
							out.println("<option "+(activeBLEReader.equalsIgnoreCase(rs.getString("oc_beacon_id"))?"selected":"")+" value='"+rs.getString("oc_beacon_id")+"'>"+rs.getString("oc_beacon_alias")+" - "+rs.getString("oc_beacon_comment")+"</option>");
						}
						rs.close();
						ps.close();
						conn.close();
					%>
				</select>
                <input type='button' class='button' name='detectBeaconsButton' value='<%=getTranNoLink("web","search",sWebLanguage) %>' onclick='detectBeacons();'/>
                <span id='rssiInfo' style='font-size: 12px;font-weight: bolder; color: red'></span>
            </td>
        </tr>
        
        <%-- alias --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","alias",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="alias" name="alias" size="50" maxLength="50" value="">
                &nbsp;
                <input type='button' class='button' id='unlinkButton' value='<%=getTranNoLink("web","unlink",sWebLanguage) %>' onclick='unlinkBLETag(document.getElementById("alias").value);'/>
            </td>
        </tr>   
             
        <%-- resourcetype --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","reftype",sWebLanguage)%></td>
            <td class="admin2">
	            <select class='text' id="resourcetype" name="resourcetype">
	            	<option/>
	            	<%= SH.writeSelect(request, "bleResourceType", "", sWebLanguage) %>
	            </select>
            </td>
        </tr>
             
        <%-- resourceid --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","refid",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="resourceid" name="resourceid" size="50" maxLength="50" value="">
            </td>
        </tr>
             
        <%-- city --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","comment",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="comment" name="comment" size="50" maxLength="255" value="">
            </td>
        </tr>  
             
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveBeacon();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteBeacon();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newBeacon();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    
    <div id="divBeacon" style="padding-top:10px;"></div>
</form>
    
<script>
	function refresh(){
		displayBeacon(document.getElementById("id").value);
		searchBeacons();
	}
	function detectBeacons(){
		document.getElementById("rssiInfo").innerHTML="";
		if(document.getElementById("reader").value.length>0){
		    document.getElementById("divBeacon").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";            
		    var url = "<c:url value='/patienttracking/ajax/getClosestBeacon.jsp'/>?ts="+new Date().getTime();
		    new Ajax.Request(url,{
		      method: "GET",
		      parameters: "readerid="+document.getElementById("reader").value,
		      onSuccess: function(resp){
		          var data = eval("("+resp.responseText+")");
		          if(data.rssi*1<0){
			          $("id").value = data.id.unhtmlEntities();
			          $("alias").value = data.alias.unhtmlEntities();
			          $("resourcetype").value = data.resourcetype.unhtmlEntities();
			          $("resourceid").value = data.resourceid.unhtmlEntities();
			          $("comment").value = data.comment;
			          document.getElementById("rssiInfo").innerHTML="&nbsp;&nbsp;"+data.rssi+" dB";
		          }
		          document.getElementById("divBeacon").innerHTML="";
		      },
		      onFailure: function(resp){
		        $("divBeacon").innerHTML = "Error in '/patienttracking/ajax/getBeaconRecordings.jsp' : "+resp.responseText.trim();
		      }
		    });
		}
	}
	
  function openPatientRecord(id){
	  window.location.href='<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp&PersonID='+id;
  }


	<%-- SAVE BEACON --%>
  function saveBeacon(){
    <%-- check required fields --%>
	document.getElementById("rssiInfo").innerHTML="";
    if(requiredFieldsProvided()){
      document.getElementById("divBeacon").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Saving";  
      disableButtons();
      
      var sParams = "id="+EditForm.id.value+
                    "&alias="+EditForm.alias.value+
                    "&resourcetype="+EditForm.resourcetype.value+
                    "&resourceid="+EditForm.resourceid.value+
                    "&comment="+EditForm.comment.value;

      var url = "<c:url value='/system/ajax/saveBeacon.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,{
        method: "POST",
        postBody: sParams,                   
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          $("divBeacon").innerHTML = data.message;

          searchBeacons();
          newBeacon();
          enableButtons();
        },
        onFailure: function(resp){
          $("divBeacon").innerHTML = "Error in 'sysem/ajax/saveBeacon.jsp' : "+resp.responseText.trim();
        }
      });
    }
    else{
      alertDialog("web.manage","dataMissing");
      <%-- focus empty field --%>
      if(document.getElementById("id").value.length==0) document.getElementById("id").focus();          
    }
  }
  
  <%-- REQUIRED FIELDS PROVIDED --%>
  function requiredFieldsProvided(){
    return document.getElementById("id").value.length > 0;
  }
  
  <%-- LOAD BEACON --%>
  function loadBeacons(){
	document.getElementById("rssiInfo").innerHTML="";
    document.getElementById("divBeacons").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";            
    var url = "<c:url value='/system/ajax/getBeacons.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "",
      onSuccess: function(resp){
        $("divBeacons").innerHTML = resp.responseText;
        sortables_init();
      },
      onFailure: function(resp){
        $("divBeacon").innerHTML = "Error in 'system/ajax/getBeacons.jsp' : "+resp.responseText.trim();
      }
    });
  }

  <%-- DISPLAY BEACON --%>
  function displayBeacon(beaconId){
    var url = "<c:url value='/system/ajax/getBeacon.jsp'/>?ts="+new Date().getTime();
	document.getElementById("rssiInfo").innerHTML="";

    new Ajax.Request(url,{
      method: "GET",
      parameters: "beaconId="+beaconId,
      onSuccess: function(resp){
        var data = eval("("+resp.responseText+")");
          
        $("id").value = data.id.unhtmlEntities();
        $("alias").value = data.alias.unhtmlEntities();
        $("resourcetype").value = data.resourcetype.unhtmlEntities();
        $("resourceid").value = data.resourceid.unhtmlEntities();
        $("comment").value = data.comment;
         
        document.getElementById("divBeacon").innerHTML = ""; 
        resizeAllTextareas(8);

        <%-- display hidden buttons --%>
        document.getElementById("buttonDelete").style.visibility = "visible";
        document.getElementById("buttonNew").style.visibility = "visible";
      },
      onFailure: function(resp){
        $("divBeacon").innerHTML = "Error in 'system/ajax/getBeacon.jsp' : "+resp.responseText.trim();
      }
    });
  }
  
  <%-- DELETE BEACON --%>
  function deleteBeacon(){ 
      if(yesnoDeleteDialog()){
      disableButtons();
      
      var url = "<c:url value='/system/ajax/deleteBeacon.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,{
        method: "GET",
        parameters: "beaconId="+document.getElementById("id").value,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          $("divBeacon").innerHTML = data.message;

          newBeacon();
          searchBeacons();
          enableButtons();
        },
        onFailure: function(resp){
          $("divBeacon").innerHTML = "Error in 'system/ajax/deleteBeacon.jsp' : "+resp.responseText.trim();
        }  
      });
    }
  }

  <%-- NEW BEACON --%>
  function newBeacon(){                   
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("id").value = "";
    $("alias").value = "";
    $("resourcetype").value = "";
    $("resourceid").value = "";
    $("comment").value = "";
    $("id").focus();
    resizeAllTextareas(8);
  }
  
  <%-- DISABLE BUTTONS --%>
  function disableButtons(){
    document.getElementById("buttonSave").disabled = true;
    document.getElementById("buttonDelete").disabled = true;
    document.getElementById("buttonNew").disabled = true;
  }
  
  <%-- ENABLE BUTTONS --%>
  function enableButtons(){
    document.getElementById("buttonSave").disabled = false;
    document.getElementById("buttonDelete").disabled = false;
    document.getElementById("buttonNew").disabled = false;
  }
            
  resizeAllTextareas(8);
</script>
<%=sJSBUTTONS%>
