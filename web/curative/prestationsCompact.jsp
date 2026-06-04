<%@page import="be.openclinic.finance.PatientInvoice"%>
<%@page import="be.openclinic.finance.Insurance"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSPROTOTYPE %>
<%=sJSSCRPTACULOUS %>
<form name='prestationForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='2'>
				<%=getTran(request,"web","prestations",sWebLanguage) %>
				<i id='activeinsurer'><%=Insurance.getDefaultInsuranceForPatient(activePatient.personid)==null?"":"["+Insurance.getDefaultInsuranceForPatient(activePatient.personid).getInsurar().getName()+"]" %></i>
			</td>
		</tr>
		<tr id='prestationsheader'>
			<td class='admin'><%=getTran(request,"web","prestation",sWebLanguage) %></td>
			<td class='admin2'>
				<input type='hidden' name='prestationid' id='prestationid'/>
				<input type='text' class='text' size='4' name='prestationquantity' id='prestationquantity' value='1'/>
				x <input type='text' class='text' size='50' name='prestationname' id='prestationname'  onkeyup='if(this.value.length>0 && enterEvent(event,13)){myautocompleter.activate();}'/>
				<div id="autocomplete_prestation" class="autocompletiondiv"></div>
			</td>
		</tr>
		<tr>
			<td class='admin2' colspan='2'><div id='prestationlist'></div></td>
		</tr>
		<%
			Vector i = PatientInvoice.searchInvoices("", "", activePatient.personid, "");
			Vector invoices=new Vector();
			for(int n=0;n<i.size();n++){
				PatientInvoice invoice = (PatientInvoice)i.elementAt(n);
				if(invoice.getBalance()==0 || invoice.getDate().before(new java.util.Date(new java.util.Date().getTime()-SH.ci("loadOpenInvoicesInFastEncounterNotOlderThanDays",7)*SH.getTimeDay()))){
					continue;
				}
				invoices.add(invoice);
			}
			if(invoices.size()>0){
		%>
				<tr>
					<td class='admin'><%=getTran(request,"web","loadinvoice",sWebLanguage) %></td>
					<td class='admin2'>
						<select class='text' type='text' name='invid' id='invid' onchange='findInvoice()'>
							<option/>
							<%
								for(int n=0;n<invoices.size();n++){
									PatientInvoice invoice = (PatientInvoice)invoices.elementAt(n);
									if(invoice.getBalance()==0 || invoice.getDate().before(new java.util.Date(new java.util.Date().getTime()-SH.ci("loadOpenInvoicesInFastEncounterNotOlderThanDays",7)*SH.getTimeDay()))){
										continue;
									}
									out.println("<option value='"+invoice.getUid()+"'>"+SH.formatDate(invoice.getDate())+" - "+invoice.getUid()+" ("+invoice.getBalance()+" "+SH.cs("currency","EUR")+")</option>");
								}
							%>
						</select>
						<img id='showinvoice' style='vertical-align: middle;display: none' height='20px' src='<%=sCONTEXTPATH %>/_img/icons/mobile/show.png' onclick='showInvoice()'/>
					</td>
				</tr>
		<%
			}
		%>
	</table>
</form>

<script>
	var prestationlist='';

	var myautocompleter = new Ajax.Autocompleter('prestationname','autocomplete_prestation','curative/ajax/getPrestations.jsp?encountertype='+document.getElementById("EditEncounterType").value+'&',{
		  minChars:1,
		  method:'post',
		  afterUpdateElement:afterAutoComplete,
		  callback:composeCallbackURL
		});
	
	function setMyAutoCompleter(){
		var myautocompleter = new Ajax.Autocompleter('prestationname','autocomplete_prestation','curative/ajax/getPrestations.jsp?encountertype='+document.getElementById("EditEncounterType").value+'&',{
			  minChars:1,
			  method:'post',
			  afterUpdateElement:afterAutoComplete,
			  callback:composeCallbackURL
			});
	}
		
	function afterAutoComplete(field,item){
		var regex = new RegExp('[-0123456789.;\,]*-idcache','i');
		var nomimage = regex.exec(item.innerHTML);
		var id = nomimage[0].replace('-idcache','');
		document.getElementById("prestationid").value = id;
		document.getElementById("prestationname").value=document.getElementById("prestationname").value.substring(0,document.getElementById("prestationname").value.indexOf(id));
		doAdd();
	}
		
	function composeCallbackURL(field,item){
		document.getElementById("prestationid").value="";
		var url = "";
		if(field.id=="prestationname"){
			url = "prestation="+field.value;
		}
		if(document.getElementById('defaultExtraInsurar') && document.getElementById('defaultExtraInsurar').checked){
			url += "&defaultExtraInsurar=1";
		}
		return url;
	}
	
	function doDelete(id){
		if(prestationlist.indexOf(id+'~')>-1){
			var prestations = prestationlist.split('|');
			for(n=0;n<prestations.length;n++){
				if(prestations[n].indexOf(id+"~")>-1){
					prestationlist=prestationlist.replace(prestations[n],'');
				}
			}
			showPrestationList();
		}		
	}
	
	function doAdd(){
		var id = document.getElementById('prestationid').value.split(";")[0];
		var cost = document.getElementById('prestationid').value.split(";")[1];
		var name = document.getElementById('prestationname').value;
		var quantity = document.getElementById('prestationquantity').value;
		if(quantity*1>0){
			if(prestationlist.indexOf(id+'~')<0){
				//Prestation doesn't exist yet, add it
				prestationlist+=id+"~"+name+"~"+quantity+"~"+cost+"|";
			}
			else{
				var prestations = prestationlist.split('|');
				for(n=0;n<prestations.length;n++){
					if(prestations[n].indexOf(id+"~")>-1){
						prestationlist=prestationlist.replace(prestations[n],prestations[n].split("~")[0]+"~"+prestations[n].split("~")[1]+"~"+(prestations[n].split("~")[2]*1+quantity*1)+"~"+prestations[n].split("~")[3]);
					}
				}
			}
			showPrestationList();
			if(document.getElementById("EditEncounterService").value.length==0){
				//Try to update the service from the prestation
				updateService(id);
			}
		}
	}
	
	function updateService(id){
	    var params = "id="+id;
	    var url= '<c:url value="/curative/ajax/getPrestationService.jsp"/>?ts='+new Date();
	    new Ajax.Request(url,{
		  method: "POST",
	      parameters: params,
	      onSuccess: function(resp){
              var label = eval('('+resp.responseText+')');
              if(label.serviceid.length>0){
            	  document.getElementById("EditEncounterService").value=label.serviceid;
            	  document.getElementById("EditEncounterServiceName").value=label.servicename;
            	  document.getElementById("EditEncounterType").value=label.encountertype;
            	  document.getElementById("EditEncounterOrigin").value='residence';
              }
	      },
		  onFailure: function(){
		    alert('error');
	      }
	    });
	}
	
	function findInvoice(){
		if(document.getElementById('invid').value==''){
      	  document.getElementById('invoiceuid').value='';
    	  document.getElementById('amount').value="0";
    	  document.getElementById('amounttext').innerHTML="0.0";
    	  document.getElementById("reference").value='';
    	  document.getElementById('prestationsheader').style.display='';
    	  document.getElementById('prestationlist').innerHTML='';
    	  prestationlist='';
    	  document.getElementById('activeinsurer').innerHTML='<%=Insurance.getDefaultInsuranceForPatient(activePatient.personid)==null?"":"["+Insurance.getDefaultInsuranceForPatient(activePatient.personid).getInsurar().getName()+"]" %>';
		  document.getElementById('showinvoice').style.display='none';
		  loadEncounter();
		}
		else{
   		    document.getElementById('showinvoice').style.display='';
		    var params = "id="+document.getElementById('invid').value;
		    var url= '<c:url value="/curative/ajax/getInvoice.jsp"/>?ts='+new Date();
		    new Ajax.Request(url,{
			  method: "POST",
		      parameters: params,
		      onSuccess: function(resp){
	              var invoice = eval('('+resp.responseText+')');
	              if(invoice.invoiceuid.length>0){
	            	  document.getElementById('invoiceuid').value=invoice.invoiceuid;
	            	  document.getElementById('amount').value=invoice.amount.replace(',','.');
	            	  document.getElementById('amounttext').innerHTML=invoice.amount.replace(',','.');
	            	  document.getElementById("EditEncounterService").value=invoice.serviceid;
	            	  document.getElementById("EditEncounterServiceName").value=invoice.servicename;
	            	  document.getElementById("EditEncounterType").value=invoice.encountertype;
	            	  document.getElementById("EditEncounterManager").value=invoice.encountermanager;
	            	  document.getElementById("EditEncounterManagerName").value=invoice.encountermanagername;
	            	  document.getElementById("EditEncounterOrigin").value=invoice.encounterorigin;
	            	  document.getElementById("EditEncounterSituation").value=invoice.encountersituation;
	            	  document.getElementById("reference").value=invoice.reference;
	            	  document.getElementById("activeinsurer").innerHTML="["+invoice.activeinsurer+"]";
	            	  document.getElementById('prestationsheader').style.display='none';
	            	  document.getElementById('prestationlist').innerHTML='';
	            	  prestationlist='';
	              }
		      },
			  onFailure: function(){
			    alert('error');
		      }
		    });
		}
	}
	function showPrestationList(keepEncounter){
		var cost=0;
		var html = "<table width='100%'>";
		var prestations = prestationlist.split('|');
		var bHasPrestations=false;
		for(n=0;n<prestations.length;n++){
			var components=prestations[n].split("~");
			if(components.length>2){
				bHasPrestations=true;
				html+="<tr><td width='1%'><img onclick='doDelete(\""+components[0]+"\")' src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png'/></td><td>"+components[1]+"</td><td>&nbsp;x&nbsp;"+components[2]+"</td></tr>";
				cost+=components[2]*components[3].replace(',','.');
			}
		}
		html+="</table>";
		if(bHasPrestations){
			document.getElementById('amount').value=cost.toFixed(2);
			document.getElementById('amounttext').innerHTML=cost.toFixed(2);
		}
		else if(!keepEncounter){
			document.getElementById('amount').value="0";
			document.getElementById('amounttext').innerHTML="0.00";
      	    document.getElementById("EditEncounterService").value="";
    	    document.getElementById("EditEncounterServiceName").value="";
    	    document.getElementById("EditEncounterType").value="";
		}

		document.getElementById("prestationlist").innerHTML=html;
		document.getElementById('prestationid').value='';
		document.getElementById('prestationname').value='';
		document.getElementById('prestationquantity').value='1';
		document.getElementById('prestationname').focus();
	}
	
	function showInvoice(){
		openPopup('/financial/patientInvoiceEdit.jsp&showpatientname=1&nosave=1&FindPatientInvoiceUID='+document.getElementById('invoiceuid').value);
	}
</script>