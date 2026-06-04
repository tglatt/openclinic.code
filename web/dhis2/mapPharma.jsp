<%@page import="java.io.PrintWriter"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	SAXReader reader = new SAXReader(false);
	Document document = reader.read(new File("c:/tmp/pharma/old.xml"));
	Element root = document.getRootElement();
	Hashtable<String,String> uids = new Hashtable();
	Iterator<Element> datasets = root.elementIterator("dataset");
	while(datasets.hasNext()){
		Element dataset = datasets.next();
		Element dataelements = dataset.element("dataelements");
		if(dataelements!=null){
			Iterator<Element> iDataelements = dataelements.elementIterator("dataelement");
			while(iDataelements.hasNext()){
				Element dataelement = iDataelements.next();
				Iterator<Element> parameters = dataelement.elementIterator("parameter");
				if(parameters.hasNext()){
					Element parameter = parameters.next();
					uids.put(parameter.attributeValue("uid"),dataelement.attributeValue("productcode"));
				}
			}
		}
	}
	Document newdocument = reader.read(new File("c:/tmp/pharma/new.xml"));
	root = newdocument.getRootElement();
	datasets = root.elementIterator("dataset");
	while(datasets.hasNext()){
		Element dataset = datasets.next();
		Element dataelements = dataset.element("dataelements");
		if(dataelements!=null){
			Iterator<Element> iDataelements = dataelements.elementIterator("dataelement");
			while(iDataelements.hasNext()){
				Element dataelement = iDataelements.next();
				Iterator<Element> parameters = dataelement.elementIterator("parameter");
				if(parameters.hasNext()){
					Element parameter = parameters.next();
					if(uids.get(parameter.attributeValue("uid"))!=null){
						dataelement.setAttributeValue("productcode", uids.get(parameter.attributeValue("uid")));
					}
				}
			}
		}
	}
	org.apache.commons.io.FileUtils.writeStringToFile(new File("c:/tmp/pharma/new.corrected.xml"), newdocument.asXML(), java.nio.charset.Charset.forName("UTF-8"));

%>