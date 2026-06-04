<%@page import="java.io.*"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="be.openclinic.system.SystemInfo"%>
<%@include file="/includes/helper.jsp"%>
<%
	String Seconds_Behind_Master="";
	if(SH.cs("replicationServer","").length()>0){	
		Connection conn = null;
		PreparedStatement ps=null;
		ResultSet rs=null;
		try{
			Class.forName(SH.cs("replicationDatabaseDriver","com.mysql.jdbc.Driver"));			
			conn =  DriverManager.getConnection("jdbc:mysql://"+SH.cs("replicationServer","")+":"
																		  +SH.cs("replicationPort","3306")+"/openclinic_dbo?user="
																		  +SH.cs("replicationUser","root")+"&password="
																		  +SH.cs("replicationPassword","")
																		  +SH.cs("replicationConnectionParameters",""));
			ps = conn.prepareStatement("show slave status");
			rs = ps.executeQuery();
			if(rs.next()){
				Seconds_Behind_Master=SH.c(rs.getString("Seconds_Behind_Master"));
				try{
					if(Double.parseDouble(Seconds_Behind_Master)>1000000){
						Seconds_Behind_Master="-1";
					}
				}
				catch(Exception i){
					
				}
			}
		}
		catch(Exception e){
		}
		if(conn!=null){
			SH.close(conn, ps, rs);
		}
	}
	String sTemperature = "-1";
	if(SH.cs("cpuTempSensorFile","").length()>0){
		BufferedReader br = new BufferedReader(new FileReader(SH.cs("cpuTempSensorFile","")));
		String line="";
		while((line=br.readLine())!=null){
			if(line.toLowerCase().startsWith("package id 0:")){
				sTemperature=br.readLine().split(":")[1].trim();
			}
		}
		
	}
%>
{
	"memoryload": "<%=SystemInfo.getUsedMemory()/(1024*1024)%>",
	"maxmemory": "<%=SystemInfo.getMaximumMemory()/(1024*1024)%>",
	"usersload": "<%=SystemInfo.getActiveUserCount()%>",
	"cpuload": "<%=new DecimalFormat("#0.00").format(SystemInfo.getSystemLoadAverage())%>",
	"replicationload": "<%=Seconds_Behind_Master%>",
	"temperature": "<%=new DecimalFormat("#0").format(Double.parseDouble(sTemperature))%>",
	"end"		: ""
}