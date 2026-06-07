<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSGAUGE %>
<%
	String prefix="abo";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=writeDashboardText(prefix+"text","<img height='14px' src='"+sCONTEXTPATH+"/_img/themes/default/ajax-loader.gif'/>",22) %><br>
		</td>
	</tr>
</table>

<script>
	window.setTimeout('<%=prefix%>getValue()',1000);
	function <%=prefix%>getValue(){
  		//*****************************************
  		//Pass parameters here
  		//*****************************************
	    var params = "";
	    var url = '<c:url value="/dashboards/"/><%=prefix%>/getValue.jsp?ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      	method: "GET",
	      	parameters: params,
	      	onSuccess: function(resp){
	      		//*****************************************
	      		//Do something with the obtained value here
	      		//*****************************************
	            var result = eval('('+resp.responseText+')');
	            <%=prefix%>text.innerHTML=	"<center><table width='100%'>"+
	            							"<tr><td style='text-align: right;font-size: 14px'>A+&nbsp;</td><td style='font-size: 14px'>"+result.apos+" ("+(result.apos*100/result.total).toFixed(1)+"%)</td></tr>"+
	            							"<tr><td style='text-align: right;font-size: 14px''>A-&nbsp;</td><td style='font-size: 14px'>"+result.aneg+" ("+(result.aneg*100/result.total).toFixed(1)+"%)</td></tr>"+
	            							"<tr><td style='text-align: right;font-size: 14px''>B+&nbsp;</td><td style='font-size: 14px'>"+result.bpos+" ("+(result.bpos*100/result.total).toFixed(1)+"%)</td></tr>"+
	            							"<tr><td style='text-align: right;font-size: 14px''>B-&nbsp;</td><td style='font-size: 14px'>"+result.bneg+" ("+(result.bneg*100/result.total).toFixed(1)+"%)</td></tr>"+
	            							"<tr><td style='text-align: right;font-size: 14px''>AB+&nbsp;</td><td style='font-size: 14px'>"+result.abpos+" ("+(result.abpos*100/result.total).toFixed(1)+"%)</td></tr>"+
	            							"<tr><td style='text-align: right;font-size: 14px''>AB-&nbsp;</td><td style='font-size: 14px'>"+result.abneg+" ("+(result.abneg*100/result.total).toFixed(1)+"%)</td></tr>"+
	            							"<tr><td style='text-align: right;font-size: 14px''>O+&nbsp;</td><td style='font-size: 14px'>"+result.opos+" ("+(result.opos*100/result.total).toFixed(1)+"%)</td></tr>"+
	            							"<tr><td style='text-align: right;font-size: 14px''>O-&nbsp;</td><td style='font-size: 14px'>"+result.oneg+" ("+(result.oneg*100/result.total).toFixed(1)+"%)</td></tr>"+
	            							"</table></center>";
	      	}
	    });
	}
	
</script>