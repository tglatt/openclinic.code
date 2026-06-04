<%@include file="/includes/validateUser.jsp"%>
<%
	String sTimeUnit = SH.p(request,"timeunit");
	String title = getTranNoLink("web","lengthofstay",sWebLanguage);
	String period="";

	String dates="",values="";
	Connection conn = SH.getOpenClinicConnection();
	if(sTimeUnit.equalsIgnoreCase("month")){
		SortedMap los = new TreeMap();
		String sSql = "select * from oc_encounters where oc_encounter_enddate>=? and oc_encounter_enddate<? and oc_encounter_type='admission'";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
		ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String date = new SimpleDateFormat("yyyy-MM-01").format(rs.getDate("oc_encounter_enddate"));
			if(los.get(date)==null){
				los.put(date,new Vector());
			}
			try{
				((Vector)los.get(date)).add(new Double((rs.getDate("oc_encounter_enddate").getTime()-rs.getDate("oc_encounter_begindate").getTime()))/new Double(SH.getTimeDay()));
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		Iterator iLOS = los.keySet().iterator();
		while(iLOS.hasNext()){
			String date = (String)iLOS.next();
			if(dates.length()>0){
				dates+=",";
				values+=",";
			}
			dates+= "'"+date+"'";
			double totalvalue=0;
			Vector vValues = (Vector)los.get(date);
			for(int n=0;n<vValues.size();n++){
				totalvalue+=(Double)vValues.elementAt(n);
			}
			values+= totalvalue/vValues.size()+"";
		}
		rs.close();
		ps.close();
		period =" 12 "+getTranNoLink("web","months",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("year")){
		java.util.Date activeDateEnd=SH.parseDate("01/01/"+(Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))+1));
		java.util.Date activeDateBegin=SH.parseDate("01/01/"+(Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))));
		for(int y=0;y<10;y++){
			SortedMap los = new TreeMap();
			String sSql = "select * from oc_encounters where oc_encounter_enddate>=? and oc_encounter_enddate<? and oc_encounter_type='admission'";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1,new java.sql.Date(activeDateBegin.getTime()));
			ps.setTimestamp(2,new java.sql.Timestamp(activeDateEnd.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				String date = new SimpleDateFormat("yyyy-01-01").format(activeDateBegin);
				if(los.get(date)==null){
					los.put(date,new Vector());
				}
				try{
					((Vector)los.get(date)).add(new Double((rs.getDate("oc_encounter_enddate").getTime()-rs.getDate("oc_encounter_begindate").getTime()))/new Double(SH.getTimeDay()));
				}
				catch(Exception e){
					e.printStackTrace();
				}
			}
			Iterator iLOS = los.keySet().iterator();
			while(iLOS.hasNext()){
				String date = (String)iLOS.next();
				if(dates.length()>0){
					dates+=",";
					values+=",";
				}
				dates+= "'"+date+"'";
				double totalvalue=0;
				Vector vValues = (Vector)los.get(date);
				for(int n=0;n<vValues.size();n++){
					totalvalue+=(Double)vValues.elementAt(n);
				}
				values+= totalvalue/vValues.size()+"";
			}
			
			rs.close();
			ps.close();
			activeDateEnd=activeDateBegin;
			activeDateBegin=SH.parseDate("01/01/"+(Integer.parseInt(new SimpleDateFormat("yyyy").format(activeDateEnd))-1));
		}
		period =" 10 "+getTranNoLink("web","years",sWebLanguage);
	}
	conn.close();
%>
{
	data: {
		labels: [<%=dates %>],
		datasets: [{
			data: [<%=values %>],
			borderColor: 'red',
			label: '<%=title+period %>',
			borderWidth: 1,
			pointRadius: 1
		}]
	}
}