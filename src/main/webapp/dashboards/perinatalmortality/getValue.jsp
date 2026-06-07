<%@include file="/includes/validateUser.jsp"%>
<%
	String sTimeUnit = SH.p(request,"timeunit");
	String title = getTranNoLink("web","totalmortality",sWebLanguage);
	String title2 = getTranNoLink("web","perinatalmortality",sWebLanguage);
	String period="";

	String dates="",values="",values2="";
	Connection conn = SH.getOpenClinicConnection();
	if(sTimeUnit.equalsIgnoreCase("day")){
		SortedMap mortality = new TreeMap(), perinatalmortality = new TreeMap();
		String sSql = 	"select * from oc_encounters where oc_encounter_outcome like 'dead%' and oc_encounter_enddate>=? and oc_encounter_enddate<?";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
		ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String date = new SimpleDateFormat("yyyy-MM-dd").format(rs.getDate("oc_encounter_enddate"));
			if(mortality.get(date)==null){
				mortality.put(date,1);
			}
			else{
				mortality.put(date,(Integer)mortality.get(date)+1);
			}
			//Check if this is intrahospital maternal death
			PreparedStatement ps2 = conn.prepareStatement("select * from transactions t,items i where t.healthrecordid=? and t.transactionid=i.transactionid and (i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERINATALDEATH' and i.value='1')");
			ps2.setInt(1,MedwanQuery.getInstance().getHealthRecordIdFromPersonId(rs.getInt("oc_encounter_patientuid")));
			ResultSet rs2 = ps2.executeQuery();
			if(rs2.next()){
				if(perinatalmortality.get(date)==null){
					perinatalmortality.put(date,1);
				}
				else{
					perinatalmortality.put(date,(Integer)perinatalmortality.get(date)+1);
				}
			}
			rs2.close();
			ps2.close();
		}
		Iterator iMortality = mortality.keySet().iterator();
		while(iMortality.hasNext()){
			String date = (String)iMortality.next();
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+date+"'";
			values+= mortality.get(date)+"";
			values2+= perinatalmortality.get(date)==null?"0":perinatalmortality.get(date)+"";
		}
		rs.close();
		ps.close();
		period =" 30 "+getTranNoLink("web","days",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("month")){
		SortedMap mortality = new TreeMap(), perinatalmortality = new TreeMap();
		String sSql = 	"select * from oc_encounters where oc_encounter_outcome like 'dead%' and oc_encounter_enddate>=? and oc_encounter_enddate<?";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
		ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String date = new SimpleDateFormat("yyyy-MM-01").format(rs.getDate("oc_encounter_enddate"));
			if(mortality.get(date)==null){
				mortality.put(date,1);
			}
			else{
				mortality.put(date,(Integer)mortality.get(date)+1);
			}
			//Check if this is intrahospital maternal death
			PreparedStatement ps2 = conn.prepareStatement("select * from transactions t,items i where t.healthrecordid=? and t.transactionid=i.transactionid and (i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MATERNALDEATH' and i.value='1')");
			ps2.setInt(1,MedwanQuery.getInstance().getHealthRecordIdFromPersonId(rs.getInt("oc_encounter_patientuid")));
			ResultSet rs2 = ps2.executeQuery();
			if(rs2.next()){
				if(perinatalmortality.get(date)==null){
					perinatalmortality.put(date,1);
				}
				else{
					perinatalmortality.put(date,(Integer)perinatalmortality.get(date)+1);
				}
			}
			rs2.close();
			ps2.close();
		}
		Iterator iMortality = mortality.keySet().iterator();
		while(iMortality.hasNext()){
			String date = (String)iMortality.next();
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+date+"'";
			values+= mortality.get(date)+"";
			values2+= perinatalmortality.get(date)==null?"0":perinatalmortality.get(date)+"";
		}
		rs.close();
		ps.close();
		period =" 12 "+getTranNoLink("web","months",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("year")){
		SortedMap mortality = new TreeMap(), perinatalmortality = new TreeMap();
		String sSql = 	"select * from oc_encounters where oc_encounter_outcome like 'dead%' and oc_encounter_enddate>=? and oc_encounter_enddate<?";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
		ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String date = new SimpleDateFormat("yyyy-01-01").format(rs.getDate("oc_encounter_enddate"));
			if(mortality.get(date)==null){
				mortality.put(date,1);
			}
			else{
				mortality.put(date,(Integer)mortality.get(date)+1);
			}
			//Check if this is intrahospital maternal death
			PreparedStatement ps2 = conn.prepareStatement("select * from transactions t,items i where t.healthrecordid=? and t.transactionid=i.transactionid and (i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MATERNALDEATH' and i.value='1')");
			ps2.setInt(1,MedwanQuery.getInstance().getHealthRecordIdFromPersonId(rs.getInt("oc_encounter_patientuid")));
			ResultSet rs2 = ps2.executeQuery();
			if(rs2.next()){
				if(perinatalmortality.get(date)==null){
					perinatalmortality.put(date,1);
				}
				else{
					perinatalmortality.put(date,(Integer)perinatalmortality.get(date)+1);
				}
			}
			rs2.close();
			ps2.close();
		}
		Iterator iMortality = mortality.keySet().iterator();
		while(iMortality.hasNext()){
			String date = (String)iMortality.next();
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+date+"'";
			values+= mortality.get(date)+"";
			values2+= perinatalmortality.get(date)==null?"0":perinatalmortality.get(date)+"";
		}
		rs.close();
		ps.close();
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
		},
		{
			data: [<%=values2 %>],
			borderColor: 'blue',
			label: '<%=title2+period %>',
			borderWidth: 1,
			pointRadius: 1
		}]
	}
}