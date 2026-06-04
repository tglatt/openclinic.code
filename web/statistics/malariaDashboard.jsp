<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=sJSCHARTJS %>
<%=sJSSORTTABLE%>
<%
	String sBegin = SH.formatDate(SH.getPreviousMonthBegin());
	String sEnd = SH.formatDate(SH.getPreviousMonthEnd());
%>

<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'><td colspan='2'><%=getTran(request,"malaria","dashboard",sWebLanguage) %></td></tr>
		<tr>
		    <td class="admin"><%=getTran(request,"web","site",sWebLanguage)%></td>
		    <td class="admin2">
		    	<select name='site' id='site' class='text'>
		    		<%=SH.writeSelect(request, "malariastats.site", "", sWebLanguage) %>
		    	</select>
		    </td>                        
		</tr>
		<tr>
		    <td class="admin"><%=getTran(request,"web","period",sWebLanguage)%></td>
		    <td class='admin2'>
		    	<%= SH.writeDateField("dashboardBegin", "transactionForm", sBegin, true, false, sWebLanguage, sCONTEXTPATH)%>
		    	<%= SH.writeDateField("dashboardEnd", "transactionForm", sEnd, true, false, sWebLanguage, sCONTEXTPATH)%>
		    	<input type='button' onclick='doAnalyze()' name='submitButton' class='button' value='<%=getTranNoLink("web","analyze",sWebLanguage) %>'/>
		    	<input type='button' onclick='doDownload()' name='submitButton' class='button' value='<%=getTranNoLink("web","download",sWebLanguage) %>'/>
		    </td>
		</tr>
	</table>
	<div id='divDashboard'></div>
</form>

<script>
	var aSimpleMalariaFever = toArray("3,5,,3,6");
	
	function toArray(s){
		const array = [];
		for(n=0;n<s.split(",").length;n++){
			if(s.split(",")[n].length>0){
				array[n] = s.split(",")[n]*1;
			}
		}
		return array;
	}
	
	function doAnalyze(){
	    document.getElementById('divDashboard').innerHTML = "<img height='14px' src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
	    var params = "site="+document.getElementById("site").value+"&begin="+document.getElementById("dashboardBegin").value+"&end="+document.getElementById("dashboardEnd").value;
	    var url = "<%=sCONTEXTPATH%>/statistics/ajax/generateMalariaDashboard.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			document.getElementById('divDashboard').innerHTML=resp.responseText;
			drawCharts();
			sortables_init();
		}
		});
	}
	
	function doDownload(){
	    var params = "site="+document.getElementById("site").value+"&begin="+document.getElementById("dashboardBegin").value+"&end="+document.getElementById("dashboardEnd").value;
		window.open("<%=sCONTEXTPATH%>/statistics/ajax/downloadMalariaDashboard.jsp?"+params);		
	}

	function drawPieChart(ctx,data){
		var myPieChart = new Chart(ctx,{
		    type: 'pie',
		    data: data,
		    options: Chart.defaults.doughnut
		});
	}

	function drawBarChart(ctx,data){
		var myBarChart = new Chart(ctx,{
		    type: 'bar',
		    data: data,
		    options: {
		    	scales: {
		    		y: {
		    			beginAtZero: true,
		    		}
		    	},
		    }
		});
	}

	function drawLineChart(ctx,data){
		var myLineChart = new Chart(ctx,{
		    type: 'line',
		    data: data,
		    options: {
		        responsive: true,
		        plugins: {
		          legend: {
		            position: 'top',
		          },
		          title: {
		            display: true,
		          }
		        },
				scales: {
					x: {
						ticks: {
							autoSkip: false,
						}
					}
				}
		      },
		});
	}

	function drawCharts(){
		var ctx = document.getElementById("allCasesChart");
		var data = {
			    datasets: [{
			    	label: 'Fever classes',
			        data: [document.getElementById('feverNoMalaria').innerHTML*1, document.getElementById('feverSimpleMalaria').innerHTML*1,document.getElementById('feverSevereMalaria').innerHTML*1,document.getElementById('feverOtherMalaria').innerHTML*1],
		            backgroundColor: [
		                'rgba(255, 206, 86, 0.5)',
		                'rgba(75, 192, 192, 0.5)',
		                'rgba(255, 99, 132, 0.5)',
		                'rgba(255, 159, 64, 0.5)'
		            ],
		            borderColor: [
		                'rgba(255, 206, 86, 1)',
		                'rgba(75, 192, 192, 1)',
		                'rgba(255,99,132,1)',
		                'rgba(255, 159, 64,1)'
		            ],
		            borderWidth: 1
	            }],

			    // These labels appear in the legend and in the tooltips when hovering different arcs
			    labels: [
			        '<%=getTranNoLink("malariastats","fevernomalaria",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","simplemalaria",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","severemalaria",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","othermalaria",sWebLanguage)%>'
			    ]
			};
		drawPieChart(ctx,data);

		var ctx = document.getElementById("malariaFeverChart");
		var data = {
			    datasets: [{
			        data: [document.getElementById('feverSimpleMalaria').innerHTML*1, document.getElementById('noFeverSimpleMalaria').innerHTML*1,document.getElementById('feverSevereMalaria').innerHTML*1,document.getElementById('noFeverSevereMalaria').innerHTML*1],
		            backgroundColor: [
		                'rgba(255, 206, 86, 0.5)',
		                'rgba(75, 192, 192, 0.5)',
		                'rgba(255, 99, 132, 0.5)',
		                'rgba(255, 159, 64, 0.5)'
		            ],
		            borderColor: [
		                'rgba(255, 206, 86, 1)',
		                'rgba(75, 192, 192, 1)',
		                'rgba(255,99,132,1)',
		                'rgba(255, 159, 64,1)'
		            ],
		            borderWidth: 1
	            }],

			    // These labels appear in the legend and in the tooltips when hovering different arcs
			    labels: [
			        '<%=getTranNoLink("malariastats","feversimplemalaria",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","nofeversimplemalaria",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","feverseveremalaria",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","nofeverseveremalaria",sWebLanguage)%>'
			    ]
			};
		drawPieChart(ctx,data);

		var ctx = document.getElementById("malariaFeverLine");
		var data = {
				labels: ['<38','38','38.5','39','39.5','>=40'],
			    datasets: [{
			    	label: '<%=getTranNoLink("malariastats","simplemalaria",sWebLanguage)%>%',
			        data: toArray(document.getElementById("simpleMalariaTemperatures").value),
		            borderColor: 'rgba(75, 192, 192, 1)',
		            backgroundColor: 'rgba(75, 192, 192, 0.5)' ,
		            fill: false,
		            spanGaps: true,
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","severemalaria",sWebLanguage)%>%',
			        data: toArray(document.getElementById("severeMalariaTemperatures").value),
		            borderColor: 'rgba(255,99,132,1)',
		            backgroundColor: 'rgba(255, 99, 132, 0.5)' ,
		            fill: false,
		            spanGaps: true,
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","fevernomalaria",sWebLanguage)%>%',
			        data: toArray(document.getElementById("feverNoMalariaTemperatures").value),
		            borderColor: 'rgba(255, 206, 86, 1)',
		            backgroundColor: 'rgba(255, 206, 86, 0.5)' ,
		            fill: false,
		            spanGaps: true,
		            borderWidth: 1,
	            }
			    ]
			};
		drawLineChart(ctx,data);
		
		var ctx = document.getElementById("malariaTestBar");
		var data = {
				labels: ['TDR+','TDR-','TDR?','GE+','GE-','GE?'],
			    datasets: [{
			    	label: '<%=getTranNoLink("malariastats","simplemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("simpleMalariaTests").value),
		            backgroundColor: 'rgba(75, 192, 192, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","severemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("severeMalariaTests").value),
		            backgroundColor: 'rgba(255, 99, 132, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","fever",sWebLanguage)%>',
			        data: toArray(document.getElementById("feverNoMalariaTests").value),
		            backgroundColor: 'rgba(255, 206, 86, 0.5)',
		            borderWidth: 1,
	            },
			    ]
			};
		drawBarChart(ctx,data);
		
		var ctx = document.getElementById("malariaTestBarPct");
		var data = {
				labels: ['TDR+','TDR-','TDR?','GE+','GE-','GE?'],
			    datasets: [{
			    	label: '<%=getTranNoLink("malariastats","simplemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("simpleMalariaTestsPct").value),
		            backgroundColor: 'rgba(75, 192, 192, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","severemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("severeMalariaTestsPct").value),
		            backgroundColor: 'rgba(255, 99, 132, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","fever",sWebLanguage)%>',
			        data: toArray(document.getElementById("feverNoMalariaTestsPct").value),
		            backgroundColor: 'rgba(255, 206, 86, 0.5)',
		            borderWidth: 1,
	            },
			    ]
			};
		drawBarChart(ctx,data);

		var ctx = document.getElementById("malariaSeveritySignsChart");
		var data = {
				labels: ['Prostration','Convulsions','Conscience','Dyspnée','Ictère','Hématurie','Pâleur','Oligurie','Insuf.rénale','Hypoglycémie','Choc','Parasites+++','Autre'],
			    datasets: [{
			    	label: '<%=getTranNoLink("malariastats","simplemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("simpleMalariaSeveritySigns").value),
		            backgroundColor: 'rgba(75, 192, 192, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","severemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("severeMalariaSeveritySigns").value),
		            backgroundColor: 'rgba(255, 99, 132, 0.5)',
		            borderWidth: 1,
	            },
			    ]
			};
		drawBarChart(ctx,data);

		var ctx = document.getElementById("malariaOtherSignsChart");
		var data = {
				labels: ['Fièvre','Céphalées','Goût amer','Artromyalgies','Vomissements','Autre'],
			    datasets: [{
			    	label: '<%=getTranNoLink("malariastats","simplemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("simpleMalariaOtherSigns").value),
		            backgroundColor: 'rgba(75, 192, 192, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","severemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("severeMalariaOtherSigns").value),
		            backgroundColor: 'rgba(255, 99, 132, 0.5)',
		            borderWidth: 1,
	            },
			    ]
			};
		drawBarChart(ctx,data);

		var ctx = document.getElementById("malariaTreatmentsChart");
		var data = {
				labels: ['Artémis./pipér.','Quin/clinda','Quin co','Quin inj','Artémet./Luméf.','Artésun. inj.'],
			    datasets: [{
			    	label: '<%=getTranNoLink("malariastats","simplemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("simpleMalariaTreatments").value),
		            backgroundColor: 'rgba(75, 192, 192, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","severemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("severeMalariaTreatments").value),
		            backgroundColor: 'rgba(255, 99, 132, 0.5)',
		            borderWidth: 1,
	            },
			    ]
			};
		drawBarChart(ctx,data);

		var ctx = document.getElementById("malariaComplicationsTreatmentsChart");
		var data = {
				labels: ['Glucose','Ringer','Antipyrétique','Transfusion','Anticonvulsif','Oxygène'],
			    datasets: [{
			    	label: '<%=getTranNoLink("malariastats","simplemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("simpleMalariaComplicationsTreatments").value),
		            backgroundColor: 'rgba(75, 192, 192, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","severemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("severeMalariaComplicationsTreatments").value),
		            backgroundColor: 'rgba(255, 99, 132, 0.5)',
		            borderWidth: 1,
	            },
			    ]
			};
		drawBarChart(ctx,data);

		var ctx = document.getElementById("malariaEncountersChart");
		var data = {
			    datasets: [{
			        data: toArray(document.getElementById('malariaEncounters').value),
		            backgroundColor: [
		                'rgba(255, 206, 86, 0.5)',
		                'rgba(75, 192, 192, 0.5)',
		                'rgba(255, 99, 132, 0.5)',
		                'rgba(255, 159, 64, 0.5)'
		            ],
		            borderColor: [
		                'rgba(255, 206, 86, 1)',
		                'rgba(75, 192, 192, 1)',
		                'rgba(255,99,132,1)',
		                'rgba(255, 159, 64,1)'
		            ],
		            borderWidth: 1
	            }],

			    // These labels appear in the legend and in the tooltips when hovering different arcs
			    labels: [
			        '<%=getTranNoLink("malariastats","simplevisit",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","simpleadmission",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","severevisit",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","severeadmission",sWebLanguage)%>'
			    ]
			};
		drawPieChart(ctx,data);

		var ctx = document.getElementById("malariaGendersChart");
		var data = {
			    datasets: [{
			        data: toArray(document.getElementById('malariaGenders').value),
		            backgroundColor: [
		                'rgba(255, 206, 86, 0.5)',
		                'rgba(75, 192, 192, 0.5)',
		                'rgba(255, 99, 132, 0.5)',
		                'rgba(255, 159, 64, 0.5)'
		            ],
		            borderColor: [
		                'rgba(255, 206, 86, 1)',
		                'rgba(75, 192, 192, 1)',
		                'rgba(255,99,132,1)',
		                'rgba(255, 159, 64,1)'
		            ],
		            borderWidth: 1
	            }],

			    // These labels appear in the legend and in the tooltips when hovering different arcs
			    labels: [
			        '<%=getTranNoLink("malariastats","malesimple",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","malesevere",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","femalesimple",sWebLanguage)%>',
			        '<%=getTranNoLink("malariastats","femalesevere",sWebLanguage)%>'
			    ]
			};
		drawPieChart(ctx,data);

		var ctx = document.getElementById("malariaAgeChart");
		var data = {
				labels: ['0-5','5-15','15-25','15-40','40+'],
			    datasets: [{
			    	label: '<%=getTranNoLink("malariastats","simplemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("simpleMalariaAge").value),
		            backgroundColor: 'rgba(75, 192, 192, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","severemalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("severeMalariaAge").value),
		            backgroundColor: 'rgba(255, 99, 132, 0.5)',
		            borderWidth: 1,
	            },
	            {
			    	label: '<%=getTranNoLink("malariastats","fevernomalaria",sWebLanguage)%>',
			        data: toArray(document.getElementById("feverNoMalariaAge").value),
		            backgroundColor: 'rgba(255, 159, 64, 0.5)',
		            borderWidth: 1,
	            },
			    ]
			};
		drawBarChart(ctx,data);
	}
	
</script>