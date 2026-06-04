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
	String accessright="anesthesia.monitoring";
%>
<%=checkPermission(accessright,"select",activeUser)%>
<%=sJSCHARTJS%>
<%=sJSEXCANVAS%>
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
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <%=ScreenHelper.writeDefaultHiddenInput((TransactionVO)transaction, "ITEM_TYPE_CONTEXT_DEPARTMENT") %>
    <%=ScreenHelper.writeDefaultHiddenInput((TransactionVO)transaction, "ITEM_TYPE_CONTEXT_CONTEXT") %>
    
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <table class="list" width="100%" cellspacing="1" cellpadding='0'>
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" colspan="4">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
        	<td colspan='1' width='20%' style='vertical-align: top'>
        		<table id='measurementEntry' width='100%'>
        			<tr>
        				<td>
        					<table width='100%'>
        						<tr>
			        				<td class='admin2' id='clock'><input class='button' type='button' value='<%=getTranNoLink("anesthesia","start",sWebLanguage) %>' name='startButton' id='startButton' onclick='start()'/></td>
        						</tr>
        					</table>
        				</td>
        			</tr>
        			<tr id='setMeasurements' style='display: none'>
        				<td>
        					<table width='100%'>
        						<tr class='admin'><td colspan='2'><%=getTran(request,"anesthesia","register.value",sWebLanguage) %></td></tr>
        						<tr>
        							<td class='admin'><%=getTran(request,"anesthesia","stage",sWebLanguage) %></td>
        							<td class='admin2'>
        								<select class='text' id='stage'><%=SH.writeSelect(request, "anesthesia.stage", "", sWebLanguage) %></select>
        							</td>
        						</tr>
        						<tr>
        							<td class='admin'><%=getTran(request,"anesthesia","BP",sWebLanguage) %></td>
        							<td class='admin2'>
        								<input type='text' id='bp.s' size='3'/>/<input type='text' id='bp.d' size='3'/> mmHg
									</td>
        						</tr>
        						<tr>
        							<td class='admin'><%=getTran(request,"anesthesia","HF",sWebLanguage) %></td>
        							<td class='admin2'><input type='text' id='hf' size='3'/> /min</td>
        						</tr>
        						<tr>
        							<td class='admin'><%=getTran(request,"anesthesia","RF",sWebLanguage) %></td>
        							<td class='admin2'><input type='text' id='rf' size='3'/> /min</td>
        						</tr>
        						<tr>
        							<td class='admin'><%=getTran(request,"anesthesia","sao2",sWebLanguage) %></td>
        							<td class='admin2'><input type='text' id='sao2' size='3'/> %</td>
        						</tr>
        						<tr>
        							<td class='admin'><%=getTran(request,"anesthesia","temp",sWebLanguage) %></td>
        							<td class='admin2'><input type='text' id='temp' size='3'/> °C</td>
        						</tr>
        						<tr>
        							<td class='admin'><%=getTran(request,"anesthesia","drug",sWebLanguage) %></td>
        							<td class='admin2'><input type='text' id='drug' size='20'/></td>
        						</tr>
        						<tr>
        							<td class='admin'><%=getTran(request,"anesthesia","event",sWebLanguage) %></td>
        							<td class='admin2'><input type='text' id='event' size='20'/></td>
        						</tr>
        						<tr>
        							<td class='admin2' colspan='2'><center><input type='button' class='button' value='<%=getTranNoLink("web","add",sWebLanguage)%>' onclick='addData()'/></center></td>
        						</tr>
        					</table>
        				</td>
        			</tr>
        		</table>
        	</td>
        	<td colspan='3'>
        		<table id='monitor' width='100%'>
        			<tr>
				    	<td>
							<div style="border: 0px solid black" id="divdiag1"><canvas height='200px' width='600px' id='diag1'></canvas></div>
						</td>
        			</tr>
        			<tr>
				    	<td>
							<div style="border: 0px solid black"><canvas height='200px' width='600px' id='diag2'></canvas></div>
						</td>
        			</tr>
        		</table>
        	</td>
        </tr>
    </table>
    <%=SH.writeDefaultHiddenInput((TransactionVO)transaction, "ITEM_TYPE_MONITORINGDATA") %>
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,accessright,sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>  
  var inittime=0;
  var measurements="";
  
//Define a plugin to provide data labels
  Chart.plugins.register({
      afterDatasetsDraw: function(chart, easing) {
          // To only draw at the end of animation, check for easing === 1
          var ctx = chart.ctx;

          chart.data.datasets.forEach(function (dataset, i) {
              var meta = chart.getDatasetMeta(i);
              if (dataset.showLabels && !meta.hidden) {
                  meta.data.forEach(function(element, index) {
                      // Draw the text in black, with the specified font
                      ctx.fillStyle = 'rgb(0, 0, 0)';

                      var fontSize = 8;
                      var fontStyle = 'normal';
                      var fontFamily = 'Arial';
                      ctx.font = Chart.helpers.fontString(fontSize, fontStyle, fontFamily);

                      // Just naively convert to string for now
                      var dataString = dataset.data[index].y+'';
                      if(!(dataset.data[index].z==undefined)){
                   		dataString = dataset.data[index].z+'';
                      }

                      // Make sure alignment settings are correct
                      ctx.textAlign = 'center';
                      ctx.textBaseline = 'middle';

                      var padding = 5;
                      var position = element.tooltipPosition();
                      ctx.fillText(dataString, position.x, position.y - (fontSize / 2) - padding);
                  });
              }
          });
      }
  });

  var chart1,chart2;
  var second = 1000;
  var minute = 60*second;
  var hour = 60*minute;
  var day = 24*hour;
  var timeFormat = 'h';


  function updateGraphs(){
	var ds= [
	     	{
		     	label: '<%=getTranNoLink("web","systolic",sWebLanguage)%>',
		 		borderColor: 'red',
		 		backgroundColor: 'rgba(0,0,0,0)',
		 		fill: false,
		 		pointRadius: 3,
		 		borderWidth: 1,
                pointStyle: 'cross',
		 		data: []
		 	},
	    	{
		     	label: '<%=getTranNoLink("web","diastolic",sWebLanguage)%>',
		 		borderColor: 'blue',
		 		backgroundColor: 'rgba(0,0,0,0)',
		 		fill: false,
		 		pointRadius: 3,
		 		borderWidth: 1,
                pointStyle: 'cross',
		     	data: []
		 	},
	    	{
		     	label: '<%=getTranNoLink("web","temperature",sWebLanguage)%>',
		 		borderColor: 'green',
		 		backgroundColor: 'rgba(0,0,0,0)',
		 		fill: false,
		 		pointRadius: 3,
		 		borderWidth: 1,
                pointStyle: 'star',
		     	data: []
		 	},
	    	{
		     	label: '<%=getTranNoLink("web","heartrate",sWebLanguage)%>',
		 		borderColor: 'grey',
		 		backgroundColor: 'rgba(0,0,0,0)',
		 		fill: false,
		 		pointRadius: 1,
		 		borderWidth: 2,
		 		borderDash: [2,2],
		     	data: []
		 	},
        	{
               	label: '<%=getTranNoLink("web","drugs",sWebLanguage)%>',
         		showLabels: true,
         		translate: true,
         		borderColor: 'darkgreen',
         		backgroundColor: 'lightgreen',
         		fill: false,
                showLine: false,
                pointStyle: 'triangle',
                radius: 5,
                displayticks: false,
               	data: []
           	},
        	{
               	label: '<%=getTranNoLink("web","events",sWebLanguage)%>',
         		showLabels: true,
         		translate: true,
         		borderColor: 'darkred',
         		backgroundColor: 'lightblue',
         		fill: false,
                showLine: false,
                pointStyle: 'rect',
                radius: 5,
                displayticks: false,
               	data: []
           	},
	];
	chart1=drawGraph(chart1,'diag1',20,200,10,35,41,1,[],ds);
	
	var ds2= [
     	{
	     	label: '<%=getTranNoLink("web","respiratoryrate",sWebLanguage)%>',
	 		borderColor: 'red',
	 		backgroundColor: 'rgba(0,0,0,0)',
	 		fill: false,
	 		pointRadius: 1,
	 		borderWidth: 1,
	     	data: []
	 	},
    	{
	     	label: '<%=getTranNoLink("web","sao2",sWebLanguage)%>',
	 		borderColor: 'blue',
	 		backgroundColor: 'rgba(0,0,0,0)',
	 		fill: false,
	 		pointRadius: 1,
	 		borderWidth: 1,
	     	data: []
	 	},
	];
	chart2=drawGraph2(chart2,'diag2',0,100,10,0,50,5,[],ds2);
  }
  
  function setAnnotation(){
		var startdate = new Date();
		var preStarted=false;
		var postStarted=false;
		var pre,pre2;
		var post,post2;
		if(document.getElementById("ITEM_TYPE_MONITORINGDATA").value.length>0){
			sort("ITEM_TYPE_MONITORINGDATA");
			var array = document.getElementById("ITEM_TYPE_MONITORINGDATA").value.split("|");
			startdate = new Date(array[0].split(";")[0]*1);
			for(n=0;n<array.length;n++){
			    if(array[n].length>0 && array[n].split(";").length>9){
					var oDate = new Date(array[n].split(";")[0]*1);
					var oType = array[n].split(";")[9];
					if(oType == 1){
						preStarted=true;
					}
					else if(oType == 3){
						postStarted=true;
					}
					if(!pre && preStarted && oType>1){
				  	    var newData={
						  	x: oDate,
						 	y: 190,
						    z: "<%=getTranNoLink("web","anesthesia",sWebLanguage)%>",
						};
				  	    chart1.config.data.datasets[5].data.push(newData);
				  	    pre = {
								id: "pre",
				                type: 'box',
				                drawTime: 'beforeDatasetsDraw',
				                xScaleID: 'x-axis-0',
				                yScaleID: 'y-axis-0',
				                xMin: startdate,
				                xMax: oDate,
				                yMin: chart1.scales["y-axis-0"].min,
				                yMax: chart1.scales["y-axis-0"].max,
				                backgroundColor: 'rgba(255, 0, 0, 0.1)'
				            };
						pre2 = {
								id: "pre2",
				                type: 'box',
				                drawTime: 'beforeDatasetsDraw',
				                xScaleID: 'x-axis-0',
				                yScaleID: 'y-axis-0',
				                xMin: startdate,
				                xMax: oDate,
				                yMin: chart2.scales["y-axis-0"].min,
				                yMax: chart2.scales["y-axis-0"].max,
				                backgroundColor: 'rgba(255, 0, 0, 0.1)'
				            };
					}
					if(!post && postStarted){
				  	    var newData={
							x: oDate,
							y: 190,
							z: "<%=getTranNoLink("web","postanesthesia",sWebLanguage)%>",
						};
				  	    chart1.config.data.datasets[5].data.push(newData);
						post = {
								id: "post",
				                type: 'box',
				                drawTime: 'beforeDatasetsDraw',
				                xScaleID: 'x-axis-0',
				                yScaleID: 'y-axis-0',
				                xMin: oDate,
				                xMax: chart1.scales["x-axis-0"].max,
				                yMin: chart1.scales["y-axis-0"].min,
				                yMax: chart1.scales["y-axis-0"].max,
				                backgroundColor: 'rgba(0, 255, 0, 0.2)'
				            };
						post2 = {
								id: "post2",
				                type: 'box',
				                drawTime: 'beforeDatasetsDraw',
				                xScaleID: 'x-axis-0',
				                yScaleID: 'y-axis-0',
				                xMin: oDate,
				                xMax: chart2.scales["x-axis-0"].max,
				                yMin: chart2.scales["y-axis-0"].min,
				                yMax: chart2.scales["y-axis-0"].max,
				                backgroundColor: 'rgba(0, 255, 0, 0.2)'
				            };
					}
			    }
			}
		}
		if(!pre){
			pre = {
					id: "pre",
	                type: 'box',
	                drawTime: 'beforeDatasetsDraw',
	                xScaleID: 'x-axis-0',
	                yScaleID: 'y-axis-0',
	                xMin: startdate,
	                xMax: Date.now(),
	                yMin: chart1.scales["y-axis-0"].min,
	                yMax: chart1.scales["y-axis-0"].max,
	                backgroundColor: 'rgba(255, 0, 0, 0.1)'
	            };
			pre2 = {
					id: "pre2",
	                type: 'box',
	                drawTime: 'beforeDatasetsDraw',
	                xScaleID: 'x-axis-0',
	                yScaleID: 'y-axis-0',
	                xMin: startdate,
	                xMax: Date.now(),
	                yMin: chart2.scales["y-axis-0"].min,
	                yMax: chart2.scales["y-axis-0"].max,
	                backgroundColor: 'rgba(255, 0, 0, 0.1)'
	            };
		}
		if(!post){
			post={};
			post2={};
		}
	    var annotation = {
	            drawTime: "beforeDatasetsDraw",
	            events: ['dblclick'],
	            annotations: [pre,post]
	        };
	    var annotation2 = {
	            drawTime: "beforeDatasetsDraw",
	            events: ['dblclick'],
	            annotations: [pre2,post2]
	        };
	    chart1.options.annotation = annotation;
	    chart1.update();
	    chart2.options.annotation = annotation2;
	    chart2.update();
  }

  function drawGraph(cChart,canvasid,cMin,cMax,cStep,cMin2,cMax2,cStep2,cAnnotations,dataset){
		var startdate = new Date();
		if(document.getElementById("ITEM_TYPE_MONITORINGDATA").value.length>0){
			sort("ITEM_TYPE_MONITORINGDATA");
			var array = document.getElementById("ITEM_TYPE_MONITORINGDATA").value.split("|");
			startdate = new Date(array[0].split(";")[0]*1);
		}
		var ctx=document.getElementById(canvasid).getContext("2d");
		Chart.defaults.global.defaultFontSize=10;
		maxdate=new Date(new Date(startdate.getFullYear(),startdate.getMonth(),startdate.getDate(),startdate.getHours()).getTime()+6*hour);
		mindate=new Date(startdate.getFullYear(),startdate.getMonth(),startdate.getDate(),startdate.getHours());
		maxdate2=new Date(new Date(startdate.getFullYear(),startdate.getMonth(),startdate.getDate()).getTime()+6*hour);
		mindate2=new Date(startdate.getFullYear(),startdate.getMonth(),startdate.getDate());
		//Chart.defaults.global.legend.onClick=function(){};
		cChart = new Chart(ctx, {
		    type: 'line',
		    data: {
		    	datasets: dataset
	    	},
		    options: {	
		        elements: {
		            line: {
		                tension: 0
		            }
		        },
		    	legend: {
		            display: true
		        },
		        scales: {
		        	yAxes: [{
		        		ticks: {
			        		min: cMin,
			        		max: cMax,	
			        		stepSize: cStep,
		        		}
		        	},
		        	{
		        		ticks: {
				   			display: true,
			   		        autoSkip: false,
			        		min: cMin2,
			        		max: cMax2,	
			        		stepSize: cStep2,
			   		        maxTicksLimit: 1,
		        		}
		        	},],
			       	xAxes: [{
			   			type: "time",
			   			display: true,
			   			ticks: {
			   		        autoSkip: false,
			   		        maxTicksLimit: 100
			   		    },
			   			time: {
			   				format: timeFormat,
			   				min: mindate,
			   				max: maxdate,
			   				unit: 'minute',
			   				stepSize: 10,
			   		        displayFormats: {
			   		            'millisecond': 'HH',
			   		            'second': 'HH',
			   		            'minute': 'HH:mm	',
			   		            'hour': 'HH',
			   		            'day': 'HH',
			   		            'week': 'HH',
			   		            'month': 'HH',
			   		            'quarter': 'HH',
			   		            'year': 'HH',
			   		         }					
			   			},
			   		},
				],
			},
			annotation: {
			   	annotations: cAnnotations,
			    drawTime: "afterDraw" // (default)
			},
			  tooltips: {
			      enabled: true,
			      mode: 'single',
			      callbacks: {
			          label: function(tooltipItems, data) {
			        	  if(tooltipItems.datasetIndex ==2){
			        		  return 35+(tooltipItems.yLabel-20)*(41-35)/(200-20);
			        	  }
			        	  else if(tooltipItems.datasetIndex ==4){
			        		  return data.datasets[4].data[tooltipItems.index].z;
			        	  }
			        	  else if(tooltipItems.datasetIndex ==5){
			        		  return data.datasets[5].data[tooltipItems.index].z;
			        	  }
			        	  else{
			        		  return tooltipItems.yLabel;
			        	  }
			      	  }
			  	  }
		      },
			},
	  	  });
		  return cChart;
	  }
	  
  function drawGraph2(cChart,canvasid,cMin,cMax,cStep,cMin2,cMax2,cStep2,cAnnotations,dataset){
		var startdate = new Date();
		if(document.getElementById("ITEM_TYPE_MONITORINGDATA").value.length>0){
			sort("ITEM_TYPE_MONITORINGDATA");
			var array = document.getElementById("ITEM_TYPE_MONITORINGDATA").value.split("|");
			startdate = new Date(array[0].split(";")[0]*1);
		}
		var ctx=document.getElementById(canvasid).getContext("2d");
		Chart.defaults.global.defaultFontSize=10;
		maxdate=new Date(new Date(startdate.getFullYear(),startdate.getMonth(),startdate.getDate(),startdate.getHours()).getTime()+6*hour);
		mindate=new Date(startdate.getFullYear(),startdate.getMonth(),startdate.getDate(),startdate.getHours());
		maxdate2=new Date(new Date(startdate.getFullYear(),startdate.getMonth(),startdate.getDate()).getTime()+6*hour);
		mindate2=new Date(startdate.getFullYear(),startdate.getMonth(),startdate.getDate());
		//Chart.defaults.global.legend.onClick=function(){};
		cChart = new Chart(ctx, {
		    type: 'line',
		    labels: ['0','1','2','3','4','5','6'],
		    data: {
		    	datasets: dataset
	    	},
		    options: {	
		        elements: {
		            line: {
		                tension: 0
		            }
		        },
		    	legend: {
		            display: true
		        },
		        scales: {
		        	yAxes: [{
		        		ticks: {
			        		min: cMin,
			        		max: cMax,	
			        		stepSize: cStep,
		        		}
		        	},
		        	{
		        		ticks: {
				   			display: true,
			   		        autoSkip: false,
			        		min: cMin2,
			        		max: cMax2,	
			        		stepSize: cStep2,
			   		        maxTicksLimit: 1,
		        		}
		        	},],
			       	xAxes: [{
			   			type: "time",
			   			display: true,
			   			ticks: {
			   		        autoSkip: false,
			   		        maxTicksLimit: 100
			   		    },
			   			time: {
			   				format: timeFormat,
			   				min: mindate,
			   				max: maxdate,
			   				unit: 'minute',
			   				stepSize: 10,
			   		        displayFormats: {
			   		            'millisecond': 'HH',
			   		            'second': 'HH',
			   		            'minute': 'HH:mm	',
			   		            'hour': 'HH',
			   		            'day': 'HH',
			   		            'week': 'HH',
			   		            'month': 'HH',
			   		            'quarter': 'HH',
			   		            'year': 'HH',
			   		         }					
			   			},
			   		},
				],
			},
			annotation: {
			   	annotations: cAnnotations,
			    drawTime: "afterDraw" // (default)
			},
			  tooltips: {
			      enabled: true,
			      mode: 'single',
			      callbacks: {
			          label: function(tooltipItems, data) {
			        	  if(tooltipItems.datasetIndex ==0){
			        		  return tooltipItems.yLabel/2;
			        	  }
			        	  else{
			        		  return tooltipItems.yLabel;
			        	  }
			      	  }
			  	  }
		      },
			},
	  	  });
		  return cChart;
	  }
	  
  function start(){
	  document.getElementById('setMeasurements').style.display='';
	  setClock();
	  window.setInterval("setClock()",1000);
  }
  
  function setClock(){
	  checkUpdateable();
	  var date = new Date();
	  var minutes=date.getMinutes();
	  if(minutes<10){
		  minutes="0"+minutes;
	  }
	  var seconds=date.getSeconds();
	  if(seconds<10){
		  seconds="0"+seconds;
	  }
	  var time = date.getHours()+":"+minutes+":"+seconds;
	  document.getElementById('clock').innerHTML='<font style="color: blue;font-size: 12px;font-weight: bolder">'+time+'</font>';
  }
	
  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  
  if( document.getElementById('encounteruid').value=="" <%=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERRAL_SOURCESITE").length()==0 && request.getParameter("nobuttons")==null?"":" && 1==0"%>){
  	alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
  	searchEncounter();
  }	

  function searchUser(managerUidField,managerNameField){
	  openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no&FindServiceID=<%=MedwanQuery.getInstance().getConfigString("CCBRTEyeRegistryService")%>",650,600);
    document.getElementById(diagnosisUserName).focus();
  }

  function submitForm(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO,activeUser,"document.transactionForm.submit();"));
    %>
  }
  
  function addData(){
	  if(document.getElementById("ITEM_TYPE_MONITORINGDATA").value.length>0){
		  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+="|";
	  }
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=Date.now()+";";
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=document.getElementById("bp.s").value.replace(",",".")+";";
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=document.getElementById("bp.d").value.replace(",",".")+";";
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=document.getElementById("temp").value.replace(",",".")+";";
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=document.getElementById("hf").value.replace(",",".")+";";
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=document.getElementById("rf").value.replace(",",".")+";";
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=document.getElementById("sao2").value.replace(",",".")+";";
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=document.getElementById("drug").value.replace(",",".")+";";
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=document.getElementById("event").value.replace(",",".")+";";
	  document.getElementById("ITEM_TYPE_MONITORINGDATA").value+=document.getElementById("stage").value+";";
	  sort("ITEM_TYPE_MONITORINGDATA");
	  updateCharts();
	  document.getElementById("bp.s").value="";
	  document.getElementById("bp.d").value="";
	  document.getElementById("temp").value="";
	  document.getElementById("hf").value="";
	  document.getElementById("rf").value="";
	  document.getElementById("sao2").value="";
	  document.getElementById("drug").value="";
	  document.getElementById("event").value="";
  }
  
  function updateCharts(){
	  //Chart 1
	  chart1.config.data.datasets[0].pointBackgroundColor=[];
	  chart1.config.data.datasets[0].data = [];
	  chart1.config.data.datasets[1].pointBackgroundColor=[];
	  chart1.config.data.datasets[1].data = [];
	  chart1.config.data.datasets[2].pointBackgroundColor=[];
	  chart1.config.data.datasets[2].data = [];
	  chart1.config.data.datasets[3].pointBackgroundColor=[];
	  chart1.config.data.datasets[3].data = [];
	  //Chart 2
	  chart2.config.data.datasets[0].pointBackgroundColor=[];
	  chart2.config.data.datasets[0].data = [];
	  chart2.config.data.datasets[1].pointBackgroundColor=[];
	  chart2.config.data.datasets[1].data = [];
	  var drugcounter=20;
	  var array = document.getElementById("ITEM_TYPE_MONITORINGDATA").value.split("|");
	  for(n=0;n<array.length;n++){
		  if(array[n].length>0){
			  var oDate = new Date(array[n].split(";")[0]*1);
			  //Systolic blood pressure
			  var oSYS = array[n].split(";")[1]*1;
			  if(oSYS>0){
			  	  var newData={
			  	  	  x: oDate,
				  	  y: oSYS,
			  	  };
			  	  chart1.config.data.datasets[0].data.push(newData);
        	  	  chart1.config.data.datasets[0].pointBackgroundColor.push('black');
			  }
			  //Diastolic blood pressure
			  var oDIA = array[n].split(";")[2]*1;
			  if(oDIA>0){
			  	  var newData={
			  	  	  x: oDate,
				  	  y: oDIA,
			  	  };
			  	  chart1.config.data.datasets[1].data.push(newData);
        	  	  chart1.config.data.datasets[1].pointBackgroundColor.push('black');
			  }
			  //Temperature
			  var oTEMP = array[n].split(";")[3]*1;
			  if(oTEMP>0){
				  oTEMP=20+(oTEMP-35)*(200-20)/(41-35);
			  	  var newData={
			  	  	  x: oDate,
				  	  y: oTEMP,
			  	  };
			  	  chart1.config.data.datasets[2].data.push(newData);
        	  	  chart1.config.data.datasets[2].pointBackgroundColor.push('black');
			  }
			  //Heartrate
			  var oHF = array[n].split(";")[4]*1;
			  if(oHF>0){
			  	  var newData={
			  	  	  x: oDate,
				  	  y: oHF,
			  	  };
			  	  chart1.config.data.datasets[3].data.push(newData);
        	  	  chart1.config.data.datasets[3].pointBackgroundColor.push('black');
			  }
			  //Respiratory rate
			  var oRF = array[n].split(";")[5]*1;
			  if(oRF>0){
			  	  var newData={
			  	  	  x: oDate,
				  	  y: oRF*2,
			  	  };
			  	  chart2.config.data.datasets[0].data.push(newData);
        	  	  chart2.config.data.datasets[0].pointBackgroundColor.push('black');
			  }
			  //SaO2
			  var oSAO2 = array[n].split(";")[6]*1;
			  if(oSAO2>0){
			  	  var newData={
			  	  	  x: oDate,
				  	  y: oSAO2,
			  	  };
			  	  chart2.config.data.datasets[1].data.push(newData);
        	  	  chart2.config.data.datasets[1].pointBackgroundColor.push('black');
			  }
			  //Drugs
			  var oDrug = array[n].split(";")[7];
			  if(oDrug.length>0){
			  	  var newData={
			  	  	  x: oDate,
				  	  y: drugcounter,
				  	  z: oDrug,
			  	  };
			  	  drugcounter+=20;
			  	  if(drugcounter>100){
			  		  drugcounter=20;
			  	  }
			  	  chart1.config.data.datasets[4].data.push(newData);
			  }
			  //Events
			  var oEvent = array[n].split(";")[8];
			  if(oEvent.length>0){
			  	  var newData={
			  	  	  x: oDate,
				  	  y: drugcounter,
				  	  z: oEvent,
			  	  };
			  	  drugcounter+=20;
			  	  if(drugcounter>100){
			  		  drugcounter=20;
			  	  }
			  	  chart1.config.data.datasets[5].data.push(newData);
			  }
			  //Pre-post anesthesie
			  if(array[n].split(";").length>9){
				  document.getElementById('stage').value=array[n].split(";")[9];
			  }
		  }
	  }
	  setAnnotation();
  }
  
  function sort(id){
  	  var array = document.getElementById(id).value.split("|");
	  array.sort();
	  document.getElementById(id).value=array.join("|");
  }
  
  function checkUpdateable(){
	  if(document.getElementById("ITEM_TYPE_MONITORINGDATA").value.length>0){
		  var array = document.getElementById("ITEM_TYPE_MONITORINGDATA").value.split("|");
		  if(Date.now()-array[0].split(";")[0]*1>6*3600*1000){
			  if(document.getElementById("startButton")){
				  document.getElementById("startButton").disabled=true;
				  document.getElementById("startButton").style="text-decoration: line-through;";
			  }
			  document.getElementById('setMeasurements').style.display='none';
		  }
		  else{
			  if(document.getElementById("startButton")){
				  document.getElementById("startButton").disabled=false;
				  document.getElementById("startButton").style="text-decoration: ;";
			  }
		  }
	  }
	  else{
		  if(document.getElementById("startButton")){
			  document.getElementById("startButton").disabled=false;
			  document.getElementById("startButton").style="text-decoration: ;";
		  }
	  }
  }
  
  window.setTimeout("updateGraphs();updateCharts();checkUpdateable();",500);

</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        