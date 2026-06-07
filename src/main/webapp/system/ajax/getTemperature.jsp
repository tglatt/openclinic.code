<%@page import="java.io.*"
%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String cpuTemp = "?";
	FileReader fr = new FileReader(SH.cs("temperatureFile","/tmp/temperature"));
	BufferedReader br = new BufferedReader(fr);
	String line = br.readLine();
		if(SH.cs("ostype","orangepi").equalsIgnoreCase("orangepi")){
			while(line!=null){
				if(line.startsWith("littlecore")){
					br.readLine();
					line=br.readLine();
					if(line.startsWith("temp") && line.split("\\:").length>1){
						cpuTemp=line.split("\\:")[1].split("\\(")[0].replaceAll("\\+","").replaceAll("°","").replaceAll("F","").replaceAll("C","").trim();
						break;
					}
				}
				line=br.readLine();
			}
		}
		else if(SH.cs("ostype","orangepi").equalsIgnoreCase("probox")){
			while(line!=null){
				if(line.startsWith("coretemp-isa")){
					br.readLine();
					line=br.readLine();
					if(line.startsWith("Package") && line.split("\\:").length>1){
						cpuTemp=line.split("\\:")[1].split("\\(")[0].replaceAll("\\+","").replaceAll("°","").replaceAll("F","").replaceAll("C","").trim();
						break;
					}
				}
				line=br.readLine();
			}
		}
%>
{
	"cpu":"<%=cpuTemp %>"
}