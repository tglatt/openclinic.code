<%!
	public String writeDashboardGauge(String id,int width, double minval, double maxval,String footer){
		StringBuffer sb = new StringBuffer();
		return sb.toString();
	}
%>
<%=writeDashboardGauge("clinicalcoveragegauge",200,0,100,"% Couverture clinique")%>