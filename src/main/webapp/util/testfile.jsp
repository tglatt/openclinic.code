<%@page import="java.nio.file.*"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="org.dom4j.*,org.dom4j.io.*"%>
<%@page import="java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
String filePath = "C:/tmp/test.txt";

StringBuilder sb = new StringBuilder();
try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(filePath), "UTF8"))) {

 String cLine;
 while ((cLine = br.readLine()) != null) {
  sb.append(cLine).append("\n");
 }
} catch (IOException e) {
 e.printStackTrace();
}

for(int n=0;n<sb.toString().getBytes().length;n++){
	System.out.println(n+": "+sb.toString().getBytes()[n]);
}
%>