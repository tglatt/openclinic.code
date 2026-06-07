<%@page import="java.io.PrintWriter"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String fn="mcnt";
	Document newDoc = DocumentHelper.createDocument();
	Element newRoot = newDoc.addElement("document");
	SAXReader reader = new SAXReader(false);
	Document document = reader.read(new File("c:/tmp/pharma/"+fn+".xml"));
	Element root = document.getRootElement();
	Element informaltable = root.element("informaltable");
	Element group = informaltable.element("tgroup");
	Element body = group.element("tbody");
	Iterator<Element> rows = body.elementIterator("row");
	int counter=1;
	while(rows.hasNext()){
		Element row = rows.next();
		Iterator<Element> entries = row.elementIterator("entry");
		String productName = entries.next().elementText("para").trim()+" "+entries.next().elementText("para").trim()+" "+entries.next().elementText("para").trim();
		Element dataelement = newRoot.addElement("dataelement");
		dataelement.setAttributeValue("label", productName.replaceAll("  ","").trim());
		dataelement.setAttributeValue("productcode", "7."+counter++);
		dataelement.setAttributeValue("nolink", "1");
		String s = entries.next().element("para").element("anchor").attributeValue("id").replaceAll("-dataelement", "");
		Element parameter = dataelement.addElement("parameter");
		parameter.setAttributeValue("option", "GKkUPluq2QJ");
		parameter.setAttributeValue("calculate", "initialstock");
		parameter.setAttributeValue("uid", s);
		s = entries.next().element("para").element("anchor").attributeValue("id").replaceAll("-dataelement", "");
		parameter = dataelement.addElement("parameter");
		parameter.setAttributeValue("option", "GKkUPluq2QJ;1");
		parameter.setAttributeValue("calculate", "quantityreceived");
		parameter.setAttributeValue("uid", s);
		s = entries.next().element("para").element("anchor").attributeValue("id").replaceAll("-dataelement", "");
		parameter = dataelement.addElement("parameter");
		parameter.setAttributeValue("option", "GKkUPluq2QJ;2");
		parameter.setAttributeValue("calculate", "quantitydispensed");
		parameter.setAttributeValue("uid", s);
		entries.next();
		entries.next();
		s = entries.next().element("para").element("anchor").attributeValue("id").replaceAll("-dataelement", "");
		parameter = dataelement.addElement("parameter");
		parameter.setAttributeValue("option", "mk30dGof9Is");
		parameter.setAttributeValue("calculate", "finalstockmain");
		parameter.setAttributeValue("uid", s);
		s = entries.next().element("para").element("anchor").attributeValue("id").replaceAll("-dataelement", "");
		parameter = dataelement.addElement("parameter");
		parameter.setAttributeValue("option", "lFDhwNnXSle");
		parameter.setAttributeValue("calculate", "finalstockdispensing");
		parameter.setAttributeValue("uid", s+";1");
		s = entries.next().element("para").element("anchor").attributeValue("id").replaceAll("-dataelement", "");
		parameter = dataelement.addElement("parameter");
		parameter.setAttributeValue("option", "GKkUPluq2QJ;3");
		parameter.setAttributeValue("calculate", "quantityexpired");
		parameter.setAttributeValue("uid", s);
		s = entries.next().element("para").element("anchor").attributeValue("id").replaceAll("-dataelement", "");
		parameter = dataelement.addElement("parameter");
		parameter.setAttributeValue("option", "GKkUPluq2QJ;4");
		parameter.setAttributeValue("calculate", "quantitytoexpire");
		parameter.setAttributeValue("delay", "90");
		parameter.setAttributeValue("uid", s);
		s = entries.next().element("para").element("anchor").attributeValue("id").replaceAll("-dataelement", "");
		parameter = dataelement.addElement("parameter");
		parameter.setAttributeValue("option", "GKkUPluq2QJ;5");
		parameter.setAttributeValue("calculate", "stockoutdays");
		parameter.setAttributeValue("uid", s);
		s = entries.next().element("para").element("anchor").attributeValue("id").replaceAll("-dataelement", "");
		parameter = dataelement.addElement("parameter");
		parameter.setAttributeValue("option", "GKkUPluq2QJ;6");
		parameter.setAttributeValue("calculate", " averageconsumption");
		parameter.setAttributeValue("uid", s);
	}
	org.apache.commons.io.FileUtils.writeStringToFile(new File("c:/tmp/pharma/"+fn+".new.xml"), newDoc.asXML(), java.nio.charset.Charset.forName("UTF-8"));
%>