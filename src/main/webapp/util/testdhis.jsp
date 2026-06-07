<%@page import="java.nio.file.Files"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="org.dom4j.*,org.dom4j.io.*"%>
<%@page import="java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	String normalize(String s){
		if(s==null){
			return "";
		}

		String sReturn = s.replaceAll("é","e");
		sReturn = sReturn.replaceAll("É","E");
		sReturn = sReturn.replaceAll("è","e");
		sReturn = sReturn.replaceAll("ê","e");
		sReturn = sReturn.replaceAll("ë","e");
		sReturn = sReturn.replaceAll("È","E");
		sReturn = sReturn.replaceAll("ô","o");
		sReturn = sReturn.replaceAll("û","u");
		sReturn = sReturn.replaceAll("à","a");
		sReturn = sReturn.replaceAll("á","a");
		sReturn = sReturn.replaceAll("â","a");
		sReturn = sReturn.replaceAll("Â","A");
		sReturn = sReturn.replaceAll("ç","c");
		sReturn = sReturn.replaceAll("ü","u");
		sReturn = sReturn.replaceAll("´"," ");
		sReturn = sReturn.replaceAll("`"," ");
		sReturn = sReturn.replaceAll("µ","u");
		sReturn = sReturn.replaceAll("°","");
		
		byte[] bytes = sReturn.getBytes();
		for(int n=0;n<bytes.length;n++){
			if(bytes[n]==-110 || bytes[n]==-85 || bytes[n]==-69 || bytes[n]==-96){
				bytes[n]=32;
			}
			if(bytes[n]==-116){
				bytes[n]='e';
			}
			if(bytes[n]==-128){
				bytes[n]='E';
			}
			if(bytes[n]==-100){
				bytes[n]='o';
			}
			if(bytes[n]==-123){
				bytes[n]='.';
			}
		}
		
		return new String(bytes);
	}
	
	void EliminateSharing(Element element){
		Iterator<Element> i = element.elementIterator();
		while(i.hasNext()){
			Element e = i.next();
			if(e.getName().equalsIgnoreCase("sharing") || e.getName().equalsIgnoreCase("indicators") || e.getName().equalsIgnoreCase("indicatorTypes") || e.getName().equalsIgnoreCase("organisationUnits") || e.getName().equalsIgnoreCase("legendSets")){
				element.remove(e);
			}
			else if(e.getName().equalsIgnoreCase("createdBy")){
				Element cb = DocumentHelper.createElement("createdBy");
				Element dn = cb.addElement("displayName");
				dn.setText("admin");
				Element nm = cb.addElement("name");
				nm.setText("admin");
				Element id = cb.addElement("id");
				id.setText("M5zQapPyTZI");
				Element un = cb.addElement("username");
				un.setText("admin");
				element.remove(e);
				element.add(cb);
			}
			else if(e.getName().equalsIgnoreCase("lastUpdatedBy")){
				Element cb = DocumentHelper.createElement("lastUpdatedBy");
				Element dn = cb.addElement("displayName");
				dn.setText("admin");
				Element nm = cb.addElement("name");
				nm.setText("admin");
				Element id = cb.addElement("id");
				id.setText("M5zQapPyTZI");
				Element un = cb.addElement("username");
				un.setText("admin");
				element.remove(e);
				element.add(cb);
			}
			else{
				e.setText(normalize(e.getText()));
				Iterator<Attribute> ia = e.attributeIterator();
				while(ia.hasNext()){
					Attribute a = ia.next();
					if(a.getValue().equalsIgnoreCase("default")){
						a.setValue("newdefault");
					}
					else{
						a.setValue(normalize(a.getValue()));
					}
				}
				EliminateSharing(e);
			}
		}
	}
%>
<%
	SAXReader reader = new SAXReader(false);
	String filePath = "C:/tmp/test.in.xml";
	
	StringBuilder sb = new StringBuilder();
	try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(filePath), "UTF8"))) {
 		String cLine;
		while ((cLine = br.readLine()) != null) {
  			sb.append(cLine).append("\n");
 		}
	} catch (IOException e) {
		e.printStackTrace();
	}	
	Writer ow = new BufferedWriter(new OutputStreamWriter(new FileOutputStream("c:/tmp/test.in.copy.xml"), "UTF-8"));
	try {
	    ow.write(sb.toString());
	} finally {
	    ow.close();
	}
	Document document = reader.read(new File("c:/tmp/test.in.copy.xml"));
	Element root = document.getRootElement();
	EliminateSharing(root);
	XMLWriter writer = new XMLWriter( new FileWriter("c:/tmp/test.out.xml"));
    writer.write( document );
    writer.flush();
    writer.close();
%>