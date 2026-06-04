<%@page import="java.io.*"%>
<%@page import="org.eclipse.paho.client.mqttv3.*,org.eclipse.paho.client.mqttv3.persist.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream("/tmp/ppg/simulatordata.ppg1"), "UTF8"));
	BufferedReader br2 = new BufferedReader(new InputStreamReader(new FileInputStream("/tmp/ppg/simulatordata.ppg2"), "UTF8"));
	BufferedWriter bw = new BufferedWriter(new FileWriter("/tmp/ppg/simulatordata.combined"));
    String cLine;
    while ((cLine = br.readLine()) != null) {
    	bw.write(cLine+"\n");
    	if((cLine = br2.readLine()) != null){
        	bw.write(cLine+"\n");
    	}
    }
    bw.flush();
    bw.close();
%>