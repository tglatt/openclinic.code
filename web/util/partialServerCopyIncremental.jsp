<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="be.openclinic.system.MessageUtils"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%
	String sTables=SH.p(request,"tables"); 
	java.sql.Timestamp ts = SH.getSQLTimestamp(SH.parseDate(SH.p(request,"ts"),"yyyyMMddHHmmssSSS"));
	String from = SH.c(request.getParameter("from"),"?");
	java.util.Date requestDate = new java.util.Date();
	Connection adminConn=SH.getAdminConnection();
	Connection openclinicConn=SH.getOpenClinicConnection();
	DatabaseMetaData adminMetaData = adminConn.getMetaData();
	DatabaseMetaData openclinicMetaData = openclinicConn.getMetaData();
	Document output = DocumentHelper.createDocument();
	Element outputRoot = output.addElement("sync");
	PreparedStatement ps0 = openclinicConn.prepareStatement("select now() as ts");
	ResultSet rs0 = ps0.executeQuery();
	if(rs0.next()){
		outputRoot.addAttribute("ts", SH.formatDate(rs0.getTimestamp("ts"), "yyyyMMddHHmmssSSS"));
	}
	rs0.close();
	ps0.close();
    SAXReader reader = new SAXReader(false);
    String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"synctables.xml";
    Document document = reader.read(new URL(sDoc));
    Element root = document.getRootElement();
    Iterator<Element> tables = root.elementIterator("table");
    HashSet<String> encounters = new HashSet<String>();
    while(tables.hasNext()){
    	Element table = tables.next();
    	if(sTables.contains("*"+table.attributeValue("name")+"*")){
    		//First find the table structure
	    	ResultSet rs = null;
	    	if(table.attributeValue("database").equalsIgnoreCase("admin")){
	    		rs = adminMetaData.getColumns(SH.cs("admindbName", "ocadmin_dbo"), null, table.attributeValue("name"), null);
	    	}
	    	else if(table.attributeValue("database").equalsIgnoreCase("openclinic")){
	    		rs = openclinicMetaData.getColumns(SH.cs("openclinicdbName", "openclinic_dbo"), null, table.attributeValue("name"), null);
	    	}
	    	String columns="";
	    	Hashtable<String,String> columnTypes=new Hashtable();
	    	while(rs.next()){
	    		if(columns.length()>0){
	    			columns+=",";
	    		}
	    		String columnName=rs.getString("COLUMN_NAME");
	    		String columnType=rs.getString("TYPE_NAME");
	    		columns+=columnName;
	    		columnTypes.put(columnName,columnType);
	    	}
	    	rs.close();
	    	//Now find the table data
	    	String tsColumn=table.attributeValue("ts");
	    	String keyColumn=table.attributeValue("key");
	    	PreparedStatement ps = null;
	    	if(table.attributeValue("database").equalsIgnoreCase("admin")){
	    		ps=adminConn.prepareStatement("select "+columns+" from "+table.attributeValue("name")+" where "+tsColumn+">?");
	    	}
	    	else if(table.attributeValue("database").equalsIgnoreCase("openclinic")){
	    		ps=openclinicConn.prepareStatement("select "+columns+" from "+table.attributeValue("name")+" where "+tsColumn+">?");
	    	}
	    	ps.setTimestamp(1,ts);
	    	rs=ps.executeQuery();
	    	Element outputTable = outputRoot.addElement("table");
	    	outputTable.addAttribute("name", table.attributeValue("name"));
	    	outputTable.addAttribute("database", table.attributeValue("database"));
	    	outputTable.addAttribute("key", keyColumn);
	    	outputTable.addAttribute("ts", tsColumn);
	    	outputTable.addAttribute("columns", columns);
	    	String stypes="";
    		String[] cols = columns.split(",");
    		for(int n=0;n<cols.length;n++){
    			if(stypes.length()>0){
    				stypes+=",";
    			}
    			stypes+=columnTypes.get(cols[n]);
    		}
	    	outputTable.addAttribute("types", stypes);
	    	HashSet types = new HashSet();
	    	while(rs.next()){
	    		if(table.attributeValue("name").equalsIgnoreCase("oc_encounters")){
	    			encounters.add(rs.getInt("oc_encounter_serverid")+"."+rs.getInt("oc_encounter_objectid"));
	    		}
	    		Element row = outputTable.addElement("row");
	    		String values="";
	    		for(int n=0;n<cols.length;n++){
	    			String colName = cols[n];
	    			String colType = columnTypes.get(colName);
	    			if(values.length()>0){
	    				values+="|";
	    			}
	    			if(colType.equalsIgnoreCase("varchar") || colType.equalsIgnoreCase("char") || colType.equalsIgnoreCase("text") || colType.equalsIgnoreCase("longtext") || colType.equalsIgnoreCase("int")){
	    				values+=SH.c(rs.getString(colName)).replaceAll("\\|", "<pipe>");
	    			}
	    			else if(colType.equalsIgnoreCase("datetime")){
	    				values+=SH.formatDate(rs.getTimestamp(colName),"yyyyMMddHHmmssSSS");
	    			}
	    			else if(colType.equalsIgnoreCase("double") || colType.equalsIgnoreCase("float")){
	    				values+=rs.getDouble(colName);
	    			}
	    			else if(colType.equalsIgnoreCase("longblob")){
	    				if(rs.getBytes(colName)!=null){
	    					values+=Base64.getEncoder().encodeToString(rs.getBytes(colName));
	    				}
	    			}
	    			else if(!types.contains(colType)){
	    				SH.syslog("UNKNOWN TYPE: "+colType);
	    				types.add(colType);
	    			}
	    		}
	    		row.addCDATA(values);
	    	}
	    	rs.close();
	    	ps.close();
    	}
    }
    if(SH.p(request,"mode").equalsIgnoreCase("1") && encounters.size()>0){
    	Element outputTable = outputRoot.addElement("table");
    	outputTable.addAttribute("name", "oc_encounter_services");
    	outputTable.addAttribute("database", "openclinic");
    	outputTable.addAttribute("columns", "oc_encounter_serverid,oc_encounter_objectid,oc_encounter_serviceuid,oc_encounter_beduid,oc_encounter_serviceenddate,oc_encounter_manageruid,oc_encounter_servicebegindate");
    	outputTable.addAttribute("types", "int,int,varchar,varchar,datetime,varchar,datetime");
	    Iterator<String> iEncounters = encounters.iterator();
	    while(iEncounters.hasNext()){
	    	String encounteruid = iEncounters.next();
    		PreparedStatement ps = openclinicConn.prepareStatement("select * from oc_encounter_services where oc_encounter_serverid=? and oc_encounter_objectid=?");
    		ps.setInt(1,Integer.parseInt(encounteruid.split("\\.")[0]));
    		ps.setInt(2,Integer.parseInt(encounteruid.split("\\.")[1]));
    		ResultSet rs = ps.executeQuery();
    		while(rs.next()){
        		Element row = outputTable.addElement("row");
        		String values="";
    			values+=rs.getString("oc_encounter_serverid")+"|";
    			values+=rs.getString("oc_encounter_objectid")+"|";
    			values+=SH.c(rs.getString("oc_encounter_serviceuid")).replaceAll("\\|", "<pipe>")+"|";
    			values+=SH.c(rs.getString("oc_encounter_beduid")).replaceAll("\\|", "<pipe>")+"|";
    			values+=SH.formatDate(rs.getTimestamp("oc_encounter_serviceenddate"),"yyyyMMddHHmmssSSS")+"|";
    			values+=SH.c(rs.getString("oc_encounter_manageruid")).replaceAll("\\|", "<pipe>")+"|";
    			values+=SH.formatDate(rs.getTimestamp("oc_encounter_servicebegindate"),"yyyyMMddHHmmssSSS");
        		row.addCDATA(values);
    		}    		
    		rs.close();
    		ps.close();
	    }
    }
    adminConn.close();
    openclinicConn.close();
    out.println(MessageUtils.gzipCompressToBase64(output.asXML()));
	Pointer.deletePointers("offlinesync."+from);
	Pointer.storePointer("offlinesync."+from, SH.formatDate(requestDate,"yyyyMMddHHmmss"));
%>
