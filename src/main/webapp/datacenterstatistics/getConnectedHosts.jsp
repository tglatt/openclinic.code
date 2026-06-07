<%@page import="java.net.NetworkInterface"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="be.openclinic.system.SystemInfo"%>
<%@include file="/includes/helper.jsp"%>
<%@page import="be.mxs.common.util.system.*"%>
<%!
	private long ipvalue(String s){
		long l = 0;
		try{
			l=Integer.parseInt(s.split("\\.")[0])*256*256*256+
			  Integer.parseInt(s.split("\\.")[1])*256*256+
			  Integer.parseInt(s.split("\\.")[2])*256+
			  Integer.parseInt(s.split("\\.")[3]);
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return l;
	}
%>
<%
	String vpnDomain = checkString(request.getParameter("vpnDomain"));
	String viewAll = checkString(request.getParameter("viewAll"));
	String deleteuid = checkString(request.getParameter("deleteuid"));
	if(deleteuid.length()>0){
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps = conn.prepareStatement("delete from dc_monitorparameters where dc_monitorparameter_serveruid=? and dc_monitorparameter_parameter='systeminfo'");
		ps.setString(1,deleteuid.split("=")[0]);
		ps.execute();
		ps.close();
		conn.close();
	}
%>
<%= sCSSNORMAL %>
<%
	if(request.getParameter("submitButton")!=null && SH.c(request.getParameter("accesskey")).length()>0){
		session.removeAttribute("accesskey");
		if(SH.cs("vpnlogin."+request.getParameter("accesskey"),"").length()>0){
			session.setAttribute("accesskey",request.getParameter("accesskey"));
		}
	}
	String accesskey = SH.c((String)session.getAttribute("accesskey"));
	if(accesskey.length()==0){
%>
<form name='transactionForm' method='post'>
	<br/><br/><br/><br/><br/><br/><center><img width='150px' src='<%=sCONTEXTPATH%>/_img/openclinic_logo.jpg'/></center><br/>
	<center>Access key: <input type='password' class='text' name='accesskey' value=''/> <input type='submit' name='submitButton' value='Login'/></center>

</form>
<%		
	}
	else{
%>

<form name='transactionForm' id='transactionForm' method='post'>
	<input type='hidden' name='sortcolumn' id='sortcolumn' value='<%=SH.p(request,"sortcolumn")%>'/>
	<input type='hidden' name='deleteuid' id='deleteuid'/>
	<input type='hidden' name='vpnDomain' id='vpnDomain' value='<%=vpnDomain %>'/>
	<table width="100%">
		<tr class='admin'>
			<td colspan='8'>
				<a href='javascript:document.getElementById("vpnDomain").value="";window.location.href="<%=sCONTEXTPATH %>/datacenterstatistics/getConnectedHosts.jsp?vpnDomain=";'>root</a>
				<%
					String domain="";
					if(vpnDomain.length()>0){
						for(int n=0;n<vpnDomain.split("\\.").length;n++){
							domain+=vpnDomain.split("\\.")[n];
							%>
								. <a href='javascript:document.getElementById("vpnDomain").value="<%=domain %>";window.location.href="<%=sCONTEXTPATH %>/datacenterstatistics/getConnectedHosts.jsp?vpnDomain=<%=domain%>";'><%=vpnDomain.split("\\.")[n] %></a>
							<%
							domain+=".";
						}
					}
				%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input onchange='transactionForm.submit();' type='checkbox' name='viewAll' id='viewAll' value='1' <%=viewAll.equalsIgnoreCase("1")?"checked":"" %>/>View all
			</td>
			<%
				int reloadinterval=30;
				if(SH.p(request,"reloadinterval").length()>0){
					try{
						reloadinterval=Integer.parseInt(SH.p(request,"reloadinterval"));
					}
					catch(Exception e){
						e.printStackTrace();
					}
				}
				else if(session.getAttribute("reloadinterval")!=null){
					reloadinterval=(Integer)session.getAttribute("reloadinterval");
				}
				session.setAttribute("reloadinterval",reloadinterval);
			%>
			<td colspan='1'>
				Reload every
				<select class='text' name='reloadinterval' onchange='transactionForm.submit()'>
					<option value='5' <%=reloadinterval==5?"selected":"" %>>5 seconds</option>
					<option value='30' <%=reloadinterval==30?"selected":"" %>>30 seconds</option>
					<option value='60' <%=reloadinterval==60?"selected":"" %>>1 minute</option>
					<option value='300' <%=reloadinterval==300?"selected":"" %>>5 minutes</option>
					<option value='1800' <%=reloadinterval==1800?"selected":"" %>>30 minutes</option>
					<option value='0' <%=reloadinterval==0?"selected":"" %>>Never</option>
				</select>
			</td>
		</tr>
	<%
		SortedMap servers = new TreeMap();
		Enumeration networkInterfaces = NetworkInterface.getNetworkInterfaces();
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		String sSql = "select distinct * from dc_monitorparameters where dc_monitorparameter_parameter='systeminfo' and dc_monitorparameter_value like ? and (1=0";
		for(int n=0;n<SH.cs("vpnlogin."+accesskey,"").split(",").length;n++){
			if(SH.cs("vpnlogin."+accesskey,"").split(",")[n].trim().length()>0){
				sSql += " or dc_monitorparameter_value like ?";
			}
		}
		sSql+=") order by dc_monitorparameter_value";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setString(1,vpnDomain+"%");
		int pars = 0;
		for(int n=0;n<SH.cs("vpnlogin."+accesskey,"").split(",").length;n++){
			if(SH.cs("vpnlogin."+accesskey,"").split(",")[n].trim().length()>0){
				ps.setString(2+pars,SH.cs("vpnlogin."+accesskey,"").split(",")[n].trim()+"%");
				pars++;
			}
		}
		ResultSet rs = ps.executeQuery();
		boolean bInit=false;
		HashSet hosts = new HashSet(), names = new HashSet();
		int counter=0, totalusers=0;
		while(rs.next()){
			long timenow=new java.util.Date().getTime();
			long timecontact = rs.getTimestamp("dc_monitorparameter_updatetime").getTime();
			long diff = timenow-timecontact;
			String key=SH.padLeft(diff+"","0",20)+";"+new SimpleDateFormat("yyyyMMddHHmmss").format(rs.getTimestamp("dc_monitorparameter_updatetime"))+";"+rs.getString("dc_monitorparameter_serveruid");
			servers.put(key,SH.c(rs.getString("dc_monitorparameter_value")));
		}
		rs.close();
		ps.close();
		Iterator it = servers.keySet().iterator();
		while(it.hasNext()){
			String key = (String)it.next();
			SystemInfo systemInfo = SystemInfo.parse((String)servers.get(key));
			if(key.split(";").length<4){
				continue;
			}
			String uid = key.split(";")[2]+";"+key.split(";")[3];
			if(hosts.contains(uid)){
				continue;
			}
			String name = systemInfo.getVPNIpAddress(networkInterfaces)+"."+systemInfo.getVpnName();
			if(names.contains(name)){
				continue;
			}
			totalusers+=systemInfo.getUsersConnected();
			hosts.add(uid);
			names.add(name);
		}
		hosts = new HashSet();
		names = new HashSet();
		if(totalusers<MedwanQuery.getInstance().getConfigInt("minusers."+vpnDomain,99999999)){
			MedwanQuery.getInstance().setConfigString("minusers."+vpnDomain,totalusers+"");
		}
		if(totalusers>MedwanQuery.getInstance().getConfigInt("maxusers."+vpnDomain,0)){
			MedwanQuery.getInstance().setConfigString("maxusers."+vpnDomain,totalusers+"");
		}
		SortedMap sortedservers = new TreeMap();
		String sortcolumn=SH.p(request,"sortcolumn");
		if(sortcolumn.length()>0){
			it = servers.keySet().iterator();
			while(it.hasNext()){
				String key = (String)it.next();
				Object o = servers.get(key);
				SystemInfo systemInfo = SystemInfo.parse((String)servers.get(key));
				if(sortcolumn.equalsIgnoreCase("vpnname")){
					key=systemInfo.getVpnName()+";"+key.split(";")[1]+";"+key.split(";")[2]+";"+key.split(";")[3];
				}
				else if(sortcolumn.equalsIgnoreCase("vpndomain")){
					key=systemInfo.getVpnDomain()+"."+systemInfo.getVpnName()+";"+key.split(";")[1]+";"+key.split(";")[2]+";"+key.split(";")[3];
				}
				else if(sortcolumn.equalsIgnoreCase("vpnaddress")){
					key=ipvalue(systemInfo.getVpnAddress())+";"+key.split(";")[1]+";"+key.split(";")[2]+";"+key.split(";")[3];
				}
				else if(sortcolumn.equalsIgnoreCase("uptime")){
					key=SH.padLeft(systemInfo.getUpTime()+"","0",20)+";"+key.split(";")[1]+";"+key.split(";")[2]+";"+key.split(";")[3];
				}
				else if(sortcolumn.equalsIgnoreCase("diskspace")){
					key=SH.padLeft(systemInfo.getDiskSpace()+"","0",20)+";"+key.split(";")[1]+";"+key.split(";")[2]+";"+key.split(";")[3];
				}
				else if(sortcolumn.equalsIgnoreCase("users")){
					key=SH.padLeft(systemInfo.getUsersConnected()+"","0",20)+";"+key.split(";")[1]+";"+key.split(";")[2]+";"+key.split(";")[3];
				}
				sortedservers.put(key,o);
			}
			servers=sortedservers;
		}
		it = servers.keySet().iterator();
		while(it.hasNext()){
			String key = (String)it.next();
			SystemInfo systemInfo = SystemInfo.parse((String)servers.get(key));
			if(key.split(";").length<4){
				continue;
			}
			String uid = key.split(";")[2]+";"+key.split(";")[3];
			if(hosts.contains(uid)){
				continue;
			}
			String name = systemInfo.getVPNIpAddress(networkInterfaces)+"."+systemInfo.getVpnName();
			if(names.contains(name)){
				continue;
			}

			if(viewAll.equalsIgnoreCase("1") || systemInfo.getVpnDomain().equalsIgnoreCase(vpnDomain)){
				if(!bInit){
					%>
					<tr>
						<td class='admin'>#</td>
						<td class='admin' id='colvpndomain'><a href='javascript:sort("vpndomain");'>VPN Domain</a></td>
						<td class='admin' id='colvpnname'><a href='javascript:sort("vpnname");'>VPN Name</a></td>
						<td class='admin' id='colvpnaddress'><a href='javascript:sort("vpnaddress");'>VPN Address</a></td>
						<td class='admin' id='coluptime'><a href='javascript:sort("uptime");'>Uptime</a></td>
						<td class='admin' id='coldiskspace'><a href='javascript:sort("diskspace");'>Diskspace</a></td>
						<td class='admin'>Version</td>
						<td class='admin' id='colusers' title='Range = <%=MedwanQuery.getInstance().getConfigInt("minusers."+vpnDomain,0)%> - <%=MedwanQuery.getInstance().getConfigInt("maxusers."+vpnDomain,0)%>'><font color='red'><%=totalusers %></font> <a href='javascript:sort("users");'>Users</a></td>
						<td class='admin' id='collastseen'><a href='javascript:sort("");'>Last seen</a></td>
					</tr>
					<%
					bInit=true;
				}

				//Host
				long delay = (new java.util.Date().getTime()-new SimpleDateFormat("yyyyMMddHHmmss").parse(key.split(";")[1]).getTime())/1000;
				String cls = "admingreen";
				if(delay>18000){
					cls="adminredcontrast";
				}
				else if(delay>1800){
					cls="adminyellow";
				}

				String version="",version2="",diskspace="";
				PreparedStatement ps2 = conn.prepareStatement("select * from dc_monitorservers where dc_monitorserver_serveruid=?");
				ps2.setString(1,uid);
				ResultSet rs2 = ps2.executeQuery();
				if(rs2.next()){
					version=rs2.getString("dc_monitorserver_softwareversion");
					try{
						version2=Integer.parseInt(version)/1000000+"."+Integer.parseInt(version.substring(version.length()-6,version.length()-3))+"."+Integer.parseInt(version.substring(version.length()-3));
						if(Integer.parseInt(version)<5170005){
							version2+=" <img height='14px' title='This version has security vulnerabilities. Please upgrade to at least version 5.170.5.' src='"+sCONTEXTPATH+"/_img/icons/icon_blinkwarning.gif'/>";
						}
					}
					catch(Exception e){
						e.printStackTrace();
					}
				}
				long ndiskspace=systemInfo.getDiskSpace()/(1024*1024);
				diskspace=new DecimalFormat("#,###.###").format(ndiskspace)+" Mb";
				if(ndiskspace<1000){
					diskspace+=" <img height='14px' title='Low diskspace' src='"+sCONTEXTPATH+"/_img/icons/icon_blinkwarning.gif'/>";
				}
	
				rs2.close();
				ps2.close();
				counter++;
				%>
				<tr>
					<td class='<%=cls%>'><span title='<%=uid%>'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' height='14px' onclick='deleteserver("<%=uid+"="+HTMLEntities.htmlentities(systemInfo.getVpnName())%>")'/><%=counter %></span></td>
					<td class='<%=cls%>'><%=systemInfo.getVpnDomain() %></td>
					<td class='<%=cls%>'><%=HTMLEntities.htmlentities(systemInfo.getVpnName()) %></td>
					<td class='<%=cls%>'><a href='javascript:window.open("http://<%=systemInfo.getVpnAddress()+":"+systemInfo.getVpnPort() %>/openclinic");'><%=systemInfo.getVpnAddress()+":"+systemInfo.getVpnPort() %></a></td>
					<td class='<%=cls%>'><%=systemInfo.getUpTimeFormatted() %></td>
					<td class='<%=cls%>'><%=diskspace %></td>
					<td class='<%=cls%>' nowrap><%=version2 %></td>
					<td class='<%=cls%>'><%=systemInfo.getUsersConnected() %></td>
					<td class='<%=cls%>'><%=new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new SimpleDateFormat("yyyyMMddHHmmss").parse(key.split(";")[1]))+" ("+SystemInfo.getUpTimeFormatted(delay)+")" %></td>
				</tr>
				<%
				hosts.add(key.split(";")[2]);
				names.add(name);
			}
		}
		bInit=false;
		HashSet domains = new HashSet();
		it = servers.keySet().iterator();
		while(it.hasNext()){
			String key = (String)it.next();
			SystemInfo systemInfo = SystemInfo.parse((String)servers.get(key));
			if(domains.contains(systemInfo.getVpnDomain().replace(domain, "").split("\\.")[0])){
				continue;
			}
			if(!systemInfo.getVpnDomain().equalsIgnoreCase(vpnDomain)){
				if(!bInit){
					%>
					<tr>
						<td colspan='9'>
							<hr/>
						</td>
					</tr>
					<tr>
						<td class='admin' colspan='9'>Sub domains</td>
					</tr>
					<%
					bInit=true;
				}
				//Domain
				%>
				<tr>
					<td class='admin' colspan='9'>
						<a href='javascript:document.getElementById("vpnDomain").value="<%=domain+systemInfo.getVpnDomain().replace(domain, "").split("\\.")[0] %>";window.location.href="<%=sCONTEXTPATH %>/datacenterstatistics/getConnectedHosts.jsp?vpnDomain=<%=domain+systemInfo.getVpnDomain().replace(domain, "").split("\\.")[0]%>";'><%=systemInfo.getVpnDomain().replace(domain, "").split("\\.")[0] %></a>
					</td>
				</tr>
				<%
				domains.add(systemInfo.getVpnDomain().replace(domain, "").split("\\.")[0]);
			}
		}
		if(sortcolumn.length()==0){
			sortcolumn="lastseen";
		}
		%>
		<script>document.getElementById("col<%=sortcolumn%>").innerHTML=document.getElementById("col<%=sortcolumn%>").innerHTML+" <img style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/themes/default/bottom.jpg'/>";</script>
		<%
		conn.close();
	%>
	</table>
</form>
<script>
	function sort(column){
		document.getElementById("sortcolumn").value=column;
		transactionForm.submit();
	}
	function deleteserver(uid){
		document.getElementById('deleteuid').value=uid;
		document.getElementById('transactionForm').submit();
	}
	<%if(reloadinterval>0){%>
		window.setTimeout("window.location.reload()",<%=reloadinterval*1000 %>);
	<%}%>
</script>
<%
	}
%>