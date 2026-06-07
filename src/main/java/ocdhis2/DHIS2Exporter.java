package ocdhis2;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import javax.servlet.jsp.JspWriter;
import javax.xml.bind.JAXBException;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.jfree.data.general.Dataset;

import be.mayele.Module;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.Diagnosis;
import be.openclinic.pharmacy.Batch;
import be.openclinic.pharmacy.Product;
import be.openclinic.pharmacy.ProductStock;
import be.openclinic.system.Center;
import be.openclinic.system.SH;
import net.admin.Service;

public class DHIS2Exporter {
	private Date begin=null;
	private Date end=null;
	private Document dhis2document=null;
	private Hashtable departmentmaps=loadDepartmentMaps();
	private String exportFormat;
	private StringBuffer html;
	String language="en";
	private String uids="";
	private HashSet patientrecords;
	private JspWriter jspWriter=null;
	private boolean bHasContent;
	private Hashtable pluginParameters = new Hashtable();
	private Hashtable<String,Vector> cachedDatasets = new Hashtable<String,Vector>();
	
	public boolean setPluginParameter(String key, String value) {
		if(SH.c(key).length()>0 && value!=null) {
			pluginParameters.put(key, value);
			return true;
		}
		else {
			return false;
		}
	}
	
	public void resetPluginParameters() {
		pluginParameters = new Hashtable();
	}
	
	public String getPluginParameter(String key) {
		return (String)pluginParameters.get(key);
	}
	
	public Hashtable getDepartmentmaps() {
		return departmentmaps;
	}

	public void setDepartmentmaps(Hashtable departmentmaps) {
		this.departmentmaps = departmentmaps;
	}

	public String getUids() {
		return uids;
	}

	public void setUids(String uids) {
		this.uids = uids;
	}

	public HashSet getPatientrecords() {
		return patientrecords;
	}

	public void setPatientrecords(HashSet patientrecords) {
		this.patientrecords = patientrecords;
	}

	public boolean isbHasContent() {
		return bHasContent;
	}

	public void setbHasContent(boolean bHasContent) {
		this.bHasContent = bHasContent;
	}

	public Hashtable getPluginParameters() {
		return pluginParameters;
	}

	public void setPluginParameters(Hashtable pluginParameters) {
		this.pluginParameters = pluginParameters;
	}

	public DHIS2Exporter() {
		super();
		DHIS2Helper.activeDataSet="";
	}
	
	public DHIS2Exporter(String uids) {
		super();
		DHIS2Helper.activeDataSet="";
		this.uids=uids;
	}
	
	public String getLanguage() {
		return language;
	}
	public void setLanguage(String language) {
		this.language = language;
	}
	public String getExportFormat() {
		return exportFormat;
	}
	public void setExportFormat(String exportFormat) {
		this.exportFormat = exportFormat;
	}
	public StringBuffer getHtml() {
		return html;
	}
	public void setHtml(StringBuffer html) {
		this.html = html;
	}
	public Date getBegin() {
		return begin;
	}
	public void setBegin(Date begin) {
		this.begin = begin;
	}
	public Date getEnd() {
		return end;
	}
	public void setEnd(Date end) {
		this.end = end;
	}
	public Document getDhis2document() {
		return dhis2document;
	}
	public void setDhis2document(Document dhis2document) {
		this.dhis2document = dhis2document;
	}
	
	public boolean setDhis2document(String documentname) {
        SAXReader reader = new SAXReader(false);
        Document document;
		try {
			document = reader.read(new File(documentname));
			setDhis2document(document);
		} catch (DocumentException e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public boolean inArray(String sValue,String sArray){
		return inArray(sValue,sArray,"\\|");
	}
	
	public boolean inArray(String sValue,String sArray,String separator){
		String[] items = sArray.split(separator);
		for(int n=0;n<items.length;n++){
			if(items[n].contains("{like}")) {
				if(sValue.contains(items[n].replaceAll("\\{like\\}", ""))) {
					return true;
				}
			}
			else if(items[n].contains("{notlike}")) {
				if(!sValue.contains(items[n].replaceAll("\\{notlike\\}", ""))) {
					return true;
				}
			}
			else {
				if(sValue.equals(items[n])){
					return true;
				}
			}
		}
		return false;
	}
	
	private Hashtable loadDepartmentMaps(){
		Hashtable h = new Hashtable();
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select serviceid,inscode from services");
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				String serviceid = ScreenHelper.checkString(rs.getString("serviceid")).toLowerCase();
				String inscode = ScreenHelper.checkString(rs.getString("inscode")).toLowerCase();
				if(serviceid.length()>0 && inscode.length()>0){
					Debug.println("Adding "+serviceid+" -> "+inscode);
					h.put(serviceid, inscode);
				}
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		return h;
	}
	
	public String showRecords(String dataelementuid,String optionuid,String attributeoptionuid){
		bHasContent=false;
		patientrecords = new HashSet();
		StringBuffer result = new StringBuffer("");

		Element root = dhis2document.getRootElement();
		//Step 1: make a list of all dataset types that are needed
		Vector datasetTypes = new Vector();
		Iterator iDatasets = root.elementIterator("dataset");
		while(iDatasets.hasNext()){
			Element dataset = (Element)iDatasets.next();
			if(uids.length()==0||uids.contains(dataset.attributeValue("uid"))){
				if(!datasetTypes.contains(dataset.attributeValue("type").toLowerCase())){
					datasetTypes.add(dataset.attributeValue("type").toLowerCase());
				}
			}
		}
		//Step 2: iterate through all dataset types and export all datasets for each type
		Vector encounterItems = new Vector();
		Vector lastEncounterItems = new Vector();
		Vector technicalActivityItems = new Vector();
		for(int n=0;n<datasetTypes.size();n++){
			String datasetType = (String)datasetTypes.elementAt(n);
			Debug.println("Exporting dataset type "+datasetType);
			if(datasetType.equalsIgnoreCase("encounter") && encounterItems.size()==0){
				encounterItems=loadEncounters();
				lastEncounterItems=loadLastEncounters();
			}
			else if(datasetType.equalsIgnoreCase("technicalactivity") && technicalActivityItems.size()==0){
				technicalActivityItems=loadTechnicalActivities();
			}
		}
		iDatasets = root.elementIterator("dataset");
		while(iDatasets.hasNext()){
			Element dataset = (Element)iDatasets.next();
			if(uids.length()==0||uids.contains(dataset.attributeValue("uid"))){
				if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
					Debug.println("Exporting dataset 1 "+dataset.attributeValue("uid"));
					Vector diagnosisItems=loadDiagnoses(dataset);
					exportDatasetRecord(dataset,diagnosisItems,dataelementuid,optionuid,attributeoptionuid);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
					if(ScreenHelper.checkString(dataset.attributeValue("outgoing")).equals("1")){
						exportDatasetRecord(dataset,lastEncounterItems,dataelementuid,optionuid,attributeoptionuid);
					}
					else{
						Debug.println("Exporting dataset 2 "+dataset.attributeValue("uid"));
						exportDatasetRecord(dataset,encounterItems,dataelementuid,optionuid,attributeoptionuid);
					}
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("technicalactivity")){
					Debug.println("Exporting dataset 3 "+dataset.attributeValue("uid"));
					exportDatasetRecord(dataset,technicalActivityItems,dataelementuid,optionuid,attributeoptionuid);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("item")){
					Debug.println("Exporting dataset 4 "+dataset.attributeValue("uid"));
					Vector items = loadItems(dataset);
					exportDatasetRecord(dataset,items,dataelementuid,optionuid,attributeoptionuid);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("lasttransactionitem")){
					Debug.println("Exporting dataset 5 "+dataset.attributeValue("uid"));
					Vector items=loadLastTransactionItems(dataset);
					exportDatasetRecord(dataset,items,dataelementuid,optionuid,attributeoptionuid);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("lab")){
					Debug.println("Exporting dataset 6 "+dataset.attributeValue("uid"));
					Vector items = loadLab(dataset);
					exportDatasetRecord(dataset,items,dataelementuid,optionuid,attributeoptionuid);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("pharmacy")){
					Debug.println("Exporting dataset 7 "+dataset.attributeValue("uid"));
					exportDatasetRecord(dataset,new Vector(),dataelementuid,optionuid,attributeoptionuid);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("itemplugin") || dataset.attributeValue("type").equalsIgnoreCase("plugin")){
					Debug.println("Exporting dataset 8 "+dataset.attributeValue("uid"));
					exportPluginDatasetRecord(dataset,dataelementuid,optionuid,attributeoptionuid);
				}
			}
		}
		Iterator records = patientrecords.iterator();
		while(records.hasNext()){
			String personid=(String)records.next();
			result.append(personid+";");
		}
		return result.toString();
	}
	
	public boolean export(String exportFormat){
		if(exportFormat.equalsIgnoreCase("dhis2serverdelete")){
			System.out.println("full delete of dhis2 server");
			MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "1");
			exportFormat="dhis2server";
		}
		else{
			MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "0");
		}
		DHIS2Helper.bSuccess=true;
		DHIS2Helper.sError="";
		DHIS2Helper.bColumnsDrawn=false;
		DHIS2Helper.activeAttribute="";
		DHIS2Helper.activeDataSet="";
		this.exportFormat=exportFormat;
		html=new StringBuffer();
		if(begin==null){
			System.out.println("DHIS2 export error: begin of period is missing");
			return false;
		}
		else if(end==null){
			System.out.println("DHIS2 export error: end of period is missing");
			return false;
		}
		else if(dhis2document==null){
			System.out.println("DHIS2 export error: DHIS2 configuration file is missing");
			return false;
		}
		Element root = dhis2document.getRootElement();
		//Step 1: make a list of all dataset types that are needed
		try {
			if(jspWriter!=null){
				jspWriter.print("Making list of dataset types... ");
				jspWriter.flush();
			}
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		
		Vector datasetTypes = new Vector();
		List iDatasets = root.elements("dataset");
		for(int n=0; n<iDatasets.size();n++){
			Element dataset = (Element)iDatasets.get(n);
			if(uids.length()==0||uids.contains(dataset.attributeValue("uid"))){
				if(!datasetTypes.contains(dataset.attributeValue("type").toLowerCase())){
					datasetTypes.add(dataset.attributeValue("type").toLowerCase());
				}
			}
		}
		try {
			if(jspWriter!=null){
				jspWriter.print("done<br/>Prepare exports... ");
				jspWriter.flush();
			}
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		//Step 2: iterate through all dataset types and export all datasets for each type
		Vector encounterItems = new Vector();
		Vector lastEncounterItems = new Vector();
		Vector technicalActivityItems = new Vector();
		Hashtable initialquantities = new Hashtable();
		Hashtable averageconsumptions = new Hashtable();
		Hashtable consumptions = new Hashtable();
		//Hashtable quantitieslost = new Hashtable();
		Hashtable productoperations = new Hashtable();
		for(int n=0;n<datasetTypes.size();n++){
			String datasetType = (String)datasetTypes.elementAt(n);
			Debug.println("Exporting dataset type "+datasetType);
			if(datasetType.equalsIgnoreCase("encounter")){
				encounterItems=loadEncounters();
				Debug.println("Exporting dataset type lastencounter");
				lastEncounterItems=loadLastEncounters();
			}
			else if(datasetType.equalsIgnoreCase("technicalactivity")){
				technicalActivityItems=loadTechnicalActivities();
			}
			else if(datasetType.equalsIgnoreCase("pharmacy") && initialquantities.size()==0){
				initialquantities = Product.getTotalQuantitiesAvailable(begin);
				averageconsumptions = Product.getLastYearsAverageMonthlyConsumptions(end);
				consumptions = Product.getConsumptions(begin, end);
				//quantitieslost = Product.getQuantitiesLost(begin, end, getServiceUids());
				productoperations = Product.getProductOperations(begin, end);
			}
		}
		try {
			if(jspWriter!=null){
				jspWriter.print("done<br/>");
				jspWriter.flush();
			}
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		iDatasets = root.elements("dataset");
		int nTotalSets=iDatasets.size();
		for(int n=0; n<iDatasets.size();n++){
			Element dataset = (Element)iDatasets.get(n);
			if(jspWriter!=null && (n*100/nTotalSets)>0){
				try {
					jspWriter.print("<script>document.getElementById('progressBar').style.width='"+(n*100/nTotalSets)+"%';</script>");
					jspWriter.flush();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if(uids.length()==0||uids.contains(dataset.attributeValue("uid"))){
				if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
					Debug.println("Exporting diagnosis dataset "+dataset.attributeValue("uid"));
					Vector diagnosisItems=loadDiagnoses(dataset);
					exportDataset(dataset,diagnosisItems);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
					Debug.println("Exporting encounter dataset "+dataset.attributeValue("uid"));
					if(ScreenHelper.checkString(dataset.attributeValue("outgoing")).equals("1")){
						exportDataset(dataset,lastEncounterItems);
					}
					else{
						exportDataset(dataset,encounterItems);
					}
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("technicalactivity")){
					Debug.println("Exporting technicalactivity dataset "+dataset.attributeValue("uid"));
					exportDataset(dataset,technicalActivityItems);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("item")){
					Debug.println("Exporting item dataset "+dataset.attributeValue("uid"));
					Vector items = loadItems(dataset);
					exportDataset(dataset,items);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("lasttransactionitem")){
					Debug.println("Exporting lasttransactionitem dataset "+dataset.attributeValue("uid"));
					Vector items = loadLastTransactionItems(dataset);
					exportDataset(dataset,items);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("lab")){
					Debug.println("Exporting lab dataset "+dataset.attributeValue("uid"));
					Vector items = loadLab(dataset);
					exportDataset(dataset,items);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("pharmacy")){
					Debug.println("Exporting pharmacy dataset "+dataset.attributeValue("uid"));
					exportDataset(dataset,new Vector(),initialquantities,averageconsumptions,consumptions,productoperations);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("plugin") || dataset.attributeValue("type").equalsIgnoreCase("itemplugin")){
					Debug.println("Exporting plugin dataset "+dataset.attributeValue("uid"));
					exportPluginDataset(dataset);
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("genericplugin")){
					Debug.println("Exporting dataset "+dataset.attributeValue("uid"));
					exportGenericPluginDataset(dataset);
				}
			}
		}
		if(jspWriter!=null){
			try {
				jspWriter.print("<script>document.getElementById('progressBar').style.width='100%';</script>");
				jspWriter.flush();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		if(html.toString().indexOf("table")>-1){
			html.append("</table>");
		}
		if(!bHasContent) {
			html.append("<table width='100%'><tr><td class='admin'>"+ScreenHelper.getTranNoLink("web","nodhis2data",language)+"</td></tr></table><p/>");
		}
		return DHIS2Helper.bSuccess;
	}
	
	public JspWriter getJspWriter() {
		return jspWriter;
	}

	public void setJspWriter(JspWriter jspWriter) {
		this.jspWriter = jspWriter;
	}

	private void exportGenericPluginDataset(Element dataset) {
		// We need to load the plugin items here. They have a fixed format:
		// 0: value
		// 1: category
		// 2: attribute
		// 3: dataelement code
		Vector items = new Vector();
		DHIS2Plugin plugin;
		try {
			plugin = (DHIS2Plugin)(Class.forName(dataset.attributeValue("module")).newInstance());
			if(SH.c(dataset.attributeValue("parameters")).length()>0) {
				String[] pars = dataset.attributeValue("parameters").split(";");
				for(int n=0;n<pars.length;n++) {
					setPluginParameter(pars[n].split("=")[0], pars[n].split("=")[1]);
				}
			}
			items = plugin.getResults(begin, end, dataset, pluginParameters);
		} catch (Exception e1) {
			e1.printStackTrace();
		}
		
		Element attributeOptionCombo = dataset.element("attributeOptionCombo");
		if(attributeOptionCombo!=null){
			Vector selectedItems = new Vector();
			String attributeOptionComboType=attributeOptionCombo.attributeValue("type");
			//Iterator through all attributeOptionCombo values
			Iterator iattributeOptionComboValues = attributeOptionCombo.elementIterator();
			while(iattributeOptionComboValues.hasNext()){
				selectedItems = new Vector();
				Element attributeOptionComboValue=(Element)iattributeOptionComboValues.next();
				//For the time being, only department exists as attributeOptionComboType
				if(attributeOptionComboType.equalsIgnoreCase("department")){
					String department=attributeOptionComboValue.attributeValue("value");
					Debug.println("Exporting attributeOptionType "+attributeOptionCombo.attributeValue("type")+" - "+department);
					for(int n=0;n<items.size();n++){
						boolean bAddItem=false;
						String item = (String)items.elementAt(n);
						if(department==null || department.length()==0){
							bAddItem=true;
						}
						else if(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[2].toLowerCase())).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[2].toLowerCase())))){
							bAddItem=true;
						}
						if(bAddItem){
							selectedItems.add(item);
						}
					}
				}
				else if(attributeOptionComboType.equalsIgnoreCase("genericplugin")){
					String attribute=attributeOptionComboValue.attributeValue("value");
					Debug.println("Exporting attributeOptionType "+attributeOptionCombo.attributeValue("type")+" - "+attribute);
					for(int n=0;n<items.size();n++){
						boolean bAddItem=false;
						String item = (String)items.elementAt(n);
						if(attribute==null || attribute.length()==0){
							bAddItem=true;
						}
						else if(attribute.equalsIgnoreCase(item.split(";")[2])){
							bAddItem=true;
						}
						if(bAddItem){
							selectedItems.add(item);
						}
					}
				}
				else if(attributeOptionComboType.equalsIgnoreCase("default")){
					selectedItems = items;
				}
				exportGenericPluginDataset(selectedItems,dataset,attributeOptionComboValue.attributeValue("uid"));
			}
		}
		else{
			exportGenericPluginDataset(items,dataset,"");
		}
	}
	
	private void exportPluginDataset(Element dataset) {
		// We need to load the plugin items here. They have a fixed format:
		// 0: personid
		// 1: gender
		// 2: dateofbirth
		// 3: value
		// 4: date
		// 5: service
		// 6: itemid
		Vector items = new Vector();
		DHIS2Plugin plugin;
		resetPluginParameters();
		try {
			plugin = (DHIS2Plugin)(Class.forName(dataset.attributeValue("module")).newInstance());
			if(SH.c(dataset.attributeValue("parameters")).length()>0) {
				String[] pars = dataset.attributeValue("parameters").split(";");
				for(int n=0;n<pars.length;n++) {
					setPluginParameter(pars[n].split("=")[0], pars[n].split("=")[1]);
				}
			}
			items = plugin.getItems(begin, end, dataset, pluginParameters);
		} catch (Exception e1) {
			e1.printStackTrace();
		}
		
		Element attributeOptionCombo = dataset.element("attributeOptionCombo");
		String department=null;
		if(attributeOptionCombo!=null){
			Vector selectedItems = new Vector();
			String attributeOptionComboType=attributeOptionCombo.attributeValue("type");
			//Iterator through all attributeOptionCombo values
			Iterator iattributeOptionComboValues = attributeOptionCombo.elementIterator();
			while(iattributeOptionComboValues.hasNext()){
				selectedItems = new Vector();
				Element attributeOptionComboValue=(Element)iattributeOptionComboValues.next();
				//For the time being, only department exists as attributeOptionComboType
				if(attributeOptionComboType.equalsIgnoreCase("department")){
					department=attributeOptionComboValue.attributeValue("value");
					Debug.println("Exporting attributeOptionType "+attributeOptionCombo.attributeValue("type")+" - "+department);
				}
				for(int n=0;n<items.size();n++){
					boolean bAddItem=false;
					String item = (String)items.elementAt(n);
					if(ScreenHelper.checkString(dataset.attributeValue("ondate")).equalsIgnoreCase("begin")){
						try{
							java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[4]);
							if(begindate.after(begin)){
								continue;
							}
						}
						catch(Exception e){
							continue;
						}
					}
					if(ScreenHelper.checkString(dataset.attributeValue("beforedate")).equalsIgnoreCase("begin")){
						try{
							java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[4]);
							if(!begindate.before(begin)){
								continue;
							}
						}
						catch(Exception e){
							continue;
						}
					}
					if(department==null || department.length()==0){
						bAddItem=true;
					}
					else if(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[5])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[5])))){
						bAddItem=true;
					}
					if(bAddItem){
						selectedItems.add(item);
					}
				}
				exportPluginDataset(selectedItems,dataset,attributeOptionComboValue.attributeValue("uid"));
			}
		}
		else{
			exportPluginDataset(items,dataset,"");
		}
	}
	
	private void exportDataset(Element dataset,Vector items, Hashtable initialquantities,Hashtable averageconsumptions,Hashtable consumptions,Hashtable productoperations){
		Element attributeOptionCombo = dataset.element("attributeOptionCombo");
		String department=null;
		Vector selectedItems = new Vector();
		for(int n=0;n<items.size();n++){
			String item = (String)items.elementAt(n);
			if(ScreenHelper.checkString(dataset.attributeValue("ondate")).equalsIgnoreCase("begin")){
				try{
					java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
					if(begindate.after(begin)){
						continue;
					}
				}
				catch(Exception e){
					continue;
				}
			}
			if(ScreenHelper.checkString(dataset.attributeValue("beforedate")).equalsIgnoreCase("begin")){
				try{
					java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
					if(!begindate.before(begin)){
						continue;
					}
				}
				catch(Exception e){
					continue;
				}
			}
			selectedItems.add(item);
		}
		if(dataset.attributeValue("type").equalsIgnoreCase("pharmacy")){
			exportPharmacyDataset(dataset,"",initialquantities,averageconsumptions,consumptions,productoperations);
		}
	}
		
	private void exportDataset(Element dataset,Vector items){
		Element attributeOptionCombo = dataset.element("attributeOptionCombo");
		String department=null;
		if(attributeOptionCombo!=null){
			Vector selectedItems = new Vector();
			String attributeOptionComboType=attributeOptionCombo.attributeValue("type");
			//Iterator through all attributeOptionCombo values
			Iterator iattributeOptionComboValues = attributeOptionCombo.elementIterator();
			while(iattributeOptionComboValues.hasNext()){
				selectedItems = new Vector();
				Element attributeOptionComboValue=(Element)iattributeOptionComboValues.next();
				//For the time being, only department exists as attributeOptionComboType
				if(attributeOptionComboType.equalsIgnoreCase("department")){
					department=attributeOptionComboValue.attributeValue("value");
					Debug.println("Exporting attributeOptionType "+attributeOptionCombo.attributeValue("type")+" - "+department);
				}
				for(int n=0;n<items.size();n++){
					boolean bAddItem=false;
					String item = (String)items.elementAt(n);
					if(ScreenHelper.checkString(dataset.attributeValue("ondate")).equalsIgnoreCase("begin")){
						try{
							java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
							if(begindate.after(begin)){
								continue;
							}
						}
						catch(Exception e){
							continue;
						}
					}
					if(ScreenHelper.checkString(dataset.attributeValue("beforedate")).equalsIgnoreCase("begin")){
						try{
							java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
							if(!begindate.before(begin)){
								continue;
							}
						}
						catch(Exception e){
							continue;
						}
					}
					if(department==null || department.length()==0){
						bAddItem=true;
					}
					else if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[6])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[6])))){
						bAddItem=true;
					}
					else if(dataset.attributeValue("type").equalsIgnoreCase("encounter") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
						if(SH.c(dataset.attributeValue("diagnosisrequired")).equalsIgnoreCase("1")) {
							if(Diagnosis.selectDiagnoses("", "", SH.getServerId()+"."+item.split(";")[1], "", "", "", "", "", "", "", "", "", "").size()>0) {
								bAddItem=true;
							}
						}
						else {
							bAddItem=true;
						}
					}
					else if(dataset.attributeValue("type").equalsIgnoreCase("technicalactivity") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
						bAddItem=true;
					}
					else if((dataset.attributeValue("type").equalsIgnoreCase("item")|| dataset.attributeValue("type").equalsIgnoreCase("lasttransactionitem")) && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
						bAddItem=true;
					}
					if(bAddItem){
						selectedItems.add(item);
					}
				}
				if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
					exportDiagnosisDataset(selectedItems,dataset,attributeOptionComboValue.attributeValue("uid"));
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
					exportEncounterDataset(selectedItems,dataset,attributeOptionComboValue.attributeValue("uid"));
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("technicalactivity")){
					exportTechnicalActivityDataset(selectedItems,dataset,attributeOptionComboValue.attributeValue("uid"));
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("item") || dataset.attributeValue("type").equalsIgnoreCase("lasttransactionitem") ){
					exportItemDataset(selectedItems,dataset,attributeOptionComboValue.attributeValue("uid"));
				}
				else if(dataset.attributeValue("type").equalsIgnoreCase("lab")){
					exportLabDataset(selectedItems,dataset,attributeOptionComboValue.attributeValue("uid"));
				}
			}
		}
		else{
			Vector selectedItems = new Vector();
			for(int n=0;n<items.size();n++){
				String item = (String)items.elementAt(n);
				if(ScreenHelper.checkString(dataset.attributeValue("ondate")).equalsIgnoreCase("begin")){
					try{
						java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
						if(begindate.after(begin)){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataset.attributeValue("beforedate")).equalsIgnoreCase("begin")){
					try{
						java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
						if(!begindate.before(begin)){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				selectedItems.add(item);
			}
			if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
				exportDiagnosisDataset(selectedItems,dataset,"");
			}
			else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
				exportEncounterDataset(selectedItems,dataset,"");
			}
			else if(dataset.attributeValue("type").equalsIgnoreCase("technicalactivity")){
				exportTechnicalActivityDataset(selectedItems,dataset,"");
			}
			else if(dataset.attributeValue("type").equalsIgnoreCase("item")||dataset.attributeValue("type").equalsIgnoreCase("lasttransactionitem")){
				exportItemDataset(selectedItems,dataset,"");
			}
			else if(dataset.attributeValue("type").equalsIgnoreCase("lab")){
				exportLabDataset(selectedItems,dataset,"");
			}
		}
	}
		
	private void exportDatasetRecord(Element dataset,Vector items,String dataelementuid,String optionuid,String attributeoptionuid){
		Element attributeOptionCombo = dataset.element("attributeOptionCombo");
		String department=null;
		if(attributeOptionCombo!=null){
			Vector selectedItems = new Vector();
			String attributeOptionComboType=attributeOptionCombo.attributeValue("type");
			//Iterator through all attributeOptionCombo values
			Iterator iattributeOptionComboValues = attributeOptionCombo.elementIterator();
			while(iattributeOptionComboValues.hasNext()){
				selectedItems = new Vector();
				Element attributeOptionComboValue=(Element)iattributeOptionComboValues.next();
				if(attributeoptionuid.length()==0||attributeoptionuid.equals(attributeOptionComboValue.attributeValue("uid"))){
					//For the time being, only department exists as attributeOptionComboType
					if(attributeOptionComboType.equalsIgnoreCase("department")){
						department=attributeOptionComboValue.attributeValue("value");
						Debug.println("Exporting attributeOptionType "+attributeOptionCombo.attributeValue("type")+" - "+department);
					}
					for(int n=0;n<items.size();n++){
						boolean bAddItem=false;
						String item = (String)items.elementAt(n);
						if(ScreenHelper.checkString(dataset.attributeValue("ondate")).equalsIgnoreCase("begin")){
							try{
								java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								if(begindate.after(begin)){
									continue;
								}
							}
							catch(Exception e){
								continue;
							}
						}
						if(ScreenHelper.checkString(dataset.attributeValue("beforedate")).equalsIgnoreCase("begin")){
							try{
								java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								if(!begindate.before(begin)){
									continue;
								}
							}
							catch(Exception e){
								continue;
							}
						}
						if(ScreenHelper.checkString(dataset.attributeValue("afterdate")).equalsIgnoreCase("end")){
							try{
								java.util.Date enddate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
								if(!enddate.after(end)){
									continue;
								}
							}
							catch(Exception e){
								continue;
							}
						}
						if(department==null || department.length()==0){
							bAddItem=true;
						}
						else if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[6])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[6])))){
							bAddItem=true;
						}
						else if(dataset.attributeValue("type").equalsIgnoreCase("encounter") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
							if(SH.c(dataset.attributeValue("diagnosisrequired")).equalsIgnoreCase("1")) {
								if(Diagnosis.selectDiagnoses("", "", SH.getServerId()+"."+item.split(";")[1], "", "", "", "", "", "", "", "", "", "").size()>0) {
									bAddItem=true;
								}
							}
							else {
								bAddItem=true;
							}
						}
						else if(dataset.attributeValue("type").equalsIgnoreCase("technicalactivity") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
							bAddItem=true;
						}
						else if(dataset.attributeValue("type").equalsIgnoreCase("item") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
							bAddItem=true;
						}
						else if(dataset.attributeValue("type").equalsIgnoreCase("lasttransactionitem") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
							bAddItem=true;
						}
						if(bAddItem){
							selectedItems.add(item);
						}
					}
					if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
						exportDiagnosisDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
					}
					else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
						exportEncounterDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
					}
					else if(dataset.attributeValue("type").equalsIgnoreCase("technicalactivity")){
						exportTechnicalActivityDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
					}
					else if(dataset.attributeValue("type").equalsIgnoreCase("item") || dataset.attributeValue("type").equalsIgnoreCase("lasttransactionitem")){
						exportItemDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
					}
					else if(dataset.attributeValue("type").equalsIgnoreCase("lab")){
						exportLabDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
					}
					else if(dataset.attributeValue("type").equalsIgnoreCase("itemplugin") || dataset.attributeValue("type").equalsIgnoreCase("plugin")){
						exportPluginDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
					}
				}
			}
		}
		else{
			Vector selectedItems = new Vector();
			for(int n=0;n<items.size();n++){
				String item = (String)items.elementAt(n);
				if(ScreenHelper.checkString(dataset.attributeValue("ondate")).equalsIgnoreCase("begin")){
					try{
						java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
						if(begindate.after(begin)){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataset.attributeValue("beforedate")).equalsIgnoreCase("begin")){
					try{
						java.util.Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
						if(!begindate.before(begin)){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				selectedItems.add(item);
			}
			if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
				exportDiagnosisDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
			}
			else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
				exportEncounterDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
			}
			else if(dataset.attributeValue("type").equalsIgnoreCase("technicalactivity")){
				exportTechnicalActivityDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
			}
			else if(dataset.attributeValue("type").equalsIgnoreCase("item") || dataset.attributeValue("type").equalsIgnoreCase("lasttransactionitem")){
				exportItemDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
			}
			else if(dataset.attributeValue("type").equalsIgnoreCase("lab")){
				exportLabDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
			}
			else if(dataset.attributeValue("type").equalsIgnoreCase("itemplugin") || dataset.attributeValue("type").equalsIgnoreCase("plugin")){
				exportPluginDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
			}
		}
	}
	
	private void exportPluginDatasetRecord(Element dataset,String dataelementuid,String optionuid,String attributeoptionuid){
		Vector items = new Vector();
		DHIS2Plugin plugin;
		resetPluginParameters();
		try {
			plugin = (DHIS2Plugin)(Class.forName(dataset.attributeValue("module")).newInstance());
			if(SH.c(dataset.attributeValue("parameters")).length()>0) {
				String[] pars = dataset.attributeValue("parameters").split(";");
				for(int n=0;n<pars.length;n++) {
					setPluginParameter(pars[n].split("=")[0], pars[n].split("=")[1]);
				}
			}
			items = plugin.getItems(begin, end, dataset,pluginParameters);
		} catch (Exception e1) {
			e1.printStackTrace();
		}

		Element attributeOptionCombo = dataset.element("attributeOptionCombo");
		String department=null;
		if(attributeOptionCombo!=null){
			Vector selectedItems = new Vector();
			String attributeOptionComboType=attributeOptionCombo.attributeValue("type");
			//Iterator through all attributeOptionCombo values
			Iterator iattributeOptionComboValues = attributeOptionCombo.elementIterator();
			while(iattributeOptionComboValues.hasNext()){
				selectedItems = new Vector();
				Element attributeOptionComboValue=(Element)iattributeOptionComboValues.next();
				if(attributeoptionuid.length()==0||attributeoptionuid.equals(attributeOptionComboValue.attributeValue("uid"))){
					//For the time being, only department exists as attributeOptionComboType
					if(attributeOptionComboType.equalsIgnoreCase("department")){
						department=attributeOptionComboValue.attributeValue("value");
						Debug.println("Exporting attributeOptionType "+attributeOptionCombo.attributeValue("type")+" - "+department);
					}
					for(int n=0;n<items.size();n++){
						boolean bAddItem=false;
						String item = (String)items.elementAt(n);

						if(department==null || department.length()==0){
							bAddItem=true;
						}
						else if(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[5])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[5])))){
							bAddItem=true;
						}
						if(bAddItem){
							selectedItems.add(item);
						}
					}
					exportPluginDatasetRecords(selectedItems,dataset,dataelementuid,optionuid);
				}
			}
		}
		else{
			exportPluginDatasetRecords(items,dataset,dataelementuid,optionuid);
		}
	}
	
	private void  exportDiagnosisDataset(Vector items,Element dataset, String attributeOptionComboUid){
		String gender=null;
		String origin=null;
		String outcome=null;
		String department=null;
		double minAge=-999;
		double maxAge=-999;
		//This is where we create the DataValueSet
        DataValueSet dataValueSet = new DataValueSet();
        dataValueSet.setDataSet(dataset.attributeValue("uid"));
        setPeriod(dataValueSet);
        dataValueSet.setCompleteDate(new SimpleDateFormat("yyyy-MM-dd").format(end));
        dataValueSet.setAttributeOptionCombo(attributeOptionComboUid);
        dataValueSet.setOrgUnit(dataset);

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
					gender=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") || categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					gender=categoryOptionComboValue.attributeValue("gender");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin")){
					origin=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+origin);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome")){
					outcome=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+outcome);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department")){
					department=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+department);
				}
				for(int n=0;n<items.size();n++){
					String item = (String)items.elementAt(n);
					if(ScreenHelper.checkString(dataset.attributeValue("incoming")).equals("1")){
						try{
							java.util.Date begin = null;
							if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
								begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
							}
							else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
								begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
							}
							if(begin.before(this.begin) || begin.after(this.end)){
								continue;
							}
						}
						catch (Exception e){
							e.printStackTrace();
						}
					}
					if(ScreenHelper.checkString(dataset.attributeValue("outgoing")).equals("1")){
						try{
							java.util.Date end = null;
							if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
								end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[14]);
							}
							else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
								end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
							}
							if(end.before(this.begin) || end.after(this.end)){
								continue;
							}
						}
						catch (Exception e){
							e.printStackTrace();
						}
					}
					//Check if the serviceid associated to the diagnosis is mapped onto the dhis2 department code
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
							if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
							if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
							if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin") && origin!=null && inArray(item.split(";")[15].toLowerCase(),origin.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome") && outcome!=null && inArray(item.split(";")[8].toLowerCase(),outcome.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[6])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[6])))){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
						selectedItems.add(item);
					}
				}
				exportDiagnosisDatasetSeries(selectedItems,dataset,attributeOptionComboUid,categoryOptionComboValue.attributeValue("uid"),dataValueSet);
			}
		}
		else{
			exportDiagnosisDatasetSeries(items,dataset,attributeOptionComboUid,"",dataValueSet);
		}
		if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1 || dataValueSet.getDataValues().size()>0){
			try {
				Debug.println(dataValueSet.toXMLString());
			} catch (JAXBException e) {
				e.printStackTrace();
			}
			//Send message to DHIS2 server
			if(exportFormat.equalsIgnoreCase("dhis2server")){
				DHIS2Helper.sendToServer(dataValueSet,dataset,jspWriter);
			}
			else if(exportFormat.equalsIgnoreCase("html")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "0");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				bHasContent=true;
			}
			else if(exportFormat.equalsIgnoreCase("htmlfull")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "1");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				bHasContent=true;
			}
		}
	}
	
	private void exportDiagnosisDatasetRecords(Vector items,Element dataset, String dataelementuid,String optionuid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String department=null;
		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(optionuid.length()==0||optionuid.equals(categoryOptionComboValue.attributeValue("uid"))){
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
						gender=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") || categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						gender=categoryOptionComboValue.attributeValue("gender");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin")){
						origin=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+origin);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome")){
						outcome=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+outcome);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department")){
						department=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+department);
					}
					for(int n=0;n<items.size();n++){
						String item = (String)items.elementAt(n);
						if(ScreenHelper.checkString(dataset.attributeValue("incoming")).equals("1")){
							try{
								java.util.Date begin = null;
								if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
									begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
								}
								else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
									begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								}
								if(begin.before(this.begin) || begin.after(this.end)){
									continue;
								}
							}
							catch (Exception e){
								e.printStackTrace();
							}
						}
						if(ScreenHelper.checkString(dataset.attributeValue("outgoing")).equals("1")){
							try{
								java.util.Date end = null;
								if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
									end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[14]);
								}
								else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
									end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
								}
								if(end.before(this.begin) || end.after(this.end)){
									continue;
								}
							}
							catch (Exception e){
								e.printStackTrace();
							}
						}
						//Check if the serviceid associated to the diagnosis is mapped onto the dhis2 department code
						if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2])){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
								if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2]) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
								if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
								if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin") && origin!=null && inArray(item.split(";")[11].toLowerCase(),origin.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome") && outcome!=null && inArray(item.split(";")[8].toLowerCase(),outcome.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[6])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[6])))){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
							selectedItems.add(item);
						}
					}
					exportDiagnosisDatasetSeriesRecords(selectedItems,dataset,dataelementuid);
				}
			}
		}
		else{
			exportDiagnosisDatasetSeriesRecords(items,dataset,dataelementuid);
		}
	}
	
	private void exportEncounterDataset(Vector items,Element dataset, String attributeOptionComboUid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String department=null;
		String zone=null;
		//This is where we create the DataValueSet
        DataValueSet dataValueSet = new DataValueSet();
        dataValueSet.setDataSet(dataset.attributeValue("uid"));
        setPeriod(dataValueSet);
        dataValueSet.setCompleteDate(new SimpleDateFormat("yyyy-MM-dd").format(end));
        dataValueSet.setAttributeOptionCombo(attributeOptionComboUid);
        dataValueSet.setOrgUnit(dataset);

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
					gender=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					gender=categoryOptionComboValue.attributeValue("gender");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin")){
					origin=categoryOptionComboValue.attributeValue("value");
					Debug.println("- Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+origin);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome")){
					outcome=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+outcome);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department")){
					department=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+department);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("zone")){
					zone=categoryOptionComboValue.attributeValue("value");
					Debug.println("- Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+zone);
				}
				Debug.println("Checking "+items.size()+" items...");
				for(int n=0;n<items.size();n++){
					String item = (String)items.elementAt(n);
					if(ScreenHelper.checkString(dataset.attributeValue("incoming")).equals("1")){
						try{
							java.util.Date begin = null;
							if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
								begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
							}
							else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
								begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
							}
							if(begin.before(this.begin) || begin.after(this.end)){
								continue;
							}
						}
						catch (Exception e){
							e.printStackTrace();
						}
					}
					if(ScreenHelper.checkString(dataset.attributeValue("outgoing")).equals("1")){
						try{
							java.util.Date end = null;
							if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
								end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[14]);
							}
							else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
								end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
							}
							if(end.before(this.begin) || end.after(this.end)){
								continue;
							}
						}
						catch (Exception e){
							e.printStackTrace();
						}
					}
					if(SH.c(dataset.attributeValue("hasnatreg")).equalsIgnoreCase("1") && item.split(";")[13].length()==0) {
						continue;
					}
					else if(SH.c(dataset.attributeValue("hasnatreg")).equalsIgnoreCase("0") && item.split(";")[13].length()>0) {
						continue;
					}
					if(dataset.attributeValue("type").equalsIgnoreCase("encounter") && ScreenHelper.checkString(dataset.attributeValue("mortality")).equalsIgnoreCase("true") && !item.split(";")[5].startsWith("dead")){
						continue;
					}
					if(dataset.attributeValue("type").equalsIgnoreCase("encounter") && ScreenHelper.checkString(dataset.attributeValue("missing")).equals("diagnosis")){
						Vector diagnoses = Diagnosis.selectDiagnoses("", "", MedwanQuery.getInstance().getServerId()+"."+item.split(";")[1], "", "", "", "", "", "", "", "", "icd10", "");
						if(diagnoses.size()>0) {
							continue;
						}
					}
					//Check if the serviceid associated to the encounter is mapped onto the dhis2 department code
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2])){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
							if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2]) && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
							if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
							if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin") && origin!=null && inArray(item.split(";")[7].toLowerCase(),origin.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("zone") && zone!=null && inArray(item.split(";")[10].toLowerCase(),zone.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome") && outcome!=null && inArray(item.split(";")[5].toLowerCase(),outcome.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
						selectedItems.add(item);
					}
				}
				exportEncounterDatasetSeries(selectedItems,dataset,attributeOptionComboUid,categoryOptionComboValue.attributeValue("uid"),dataValueSet);
			}
		}
		else{
			exportEncounterDatasetSeries(items,dataset,attributeOptionComboUid,"",dataValueSet);
		}
		if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1 || dataValueSet.getDataValues().size()>0){
			try {
				Debug.println(dataValueSet.toXMLString());
			} catch (JAXBException e) {
				e.printStackTrace();
			}
			//Send message to DHIS2 server
			if(exportFormat.equalsIgnoreCase("dhis2server")){
				DHIS2Helper.sendToServer(dataValueSet,dataset,jspWriter);
			}
			else if(exportFormat.equalsIgnoreCase("html")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "O");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				html.append("<p/>");
				bHasContent=true;
			}
			else if(exportFormat.equalsIgnoreCase("htmlfull")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "1");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				bHasContent=true;
			}
		}
	}
	
	private void exportTechnicalActivityDataset(Vector items,Element dataset, String attributeOptionComboUid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String department=null;
		//This is where we create the DataValueSet
        DataValueSet dataValueSet = new DataValueSet();
        dataValueSet.setDataSet(dataset.attributeValue("uid"));
        setPeriod(dataValueSet);
        dataValueSet.setCompleteDate(new SimpleDateFormat("yyyy-MM-dd").format(end));
        dataValueSet.setAttributeOptionCombo(attributeOptionComboUid);
        dataValueSet.setOrgUnit(dataset);

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
					gender=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					gender=categoryOptionComboValue.attributeValue("gender");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin")){
					origin=categoryOptionComboValue.attributeValue("value");
					Debug.println("- Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+origin);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome")){
					outcome=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+outcome);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department")){
					department=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+department);
				}
				Debug.println("Checking "+items.size()+" items...");
				for(int n=0;n<items.size();n++){
					String item = (String)items.elementAt(n);
					Debug.println("Checking item (9): "+item);
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2])){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date begindate = SH.parseDate(item.split(";")[9]);
							if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2]) && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date begindate = SH.parseDate(item.split(";")[9]);
							if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date begindate = SH.parseDate(item.split(";")[9]);
							if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin") && origin!=null && inArray(item.split(";")[7].toLowerCase(),origin.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome") && outcome!=null && inArray(item.split(";")[5].toLowerCase(),outcome.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
						selectedItems.add(item);
					}
				}
				exportTechnicalActivityDatasetSeries(selectedItems,dataset,attributeOptionComboUid,categoryOptionComboValue.attributeValue("uid"),dataValueSet);
			}
		}
		else{
			exportTechnicalActivityDatasetSeries(items,dataset,attributeOptionComboUid,"",dataValueSet);
		}
		if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1 || dataValueSet.getDataValues().size()>0){
			try {
				Debug.println(dataValueSet.toXMLString());
			} catch (JAXBException e) {
				e.printStackTrace();
			}
			//Send message to DHIS2 server
			if(exportFormat.equalsIgnoreCase("dhis2server")){
				DHIS2Helper.sendToServer(dataValueSet,dataset,jspWriter);
			}
			else if(exportFormat.equalsIgnoreCase("html")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "0");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				html.append("<p/>");
				bHasContent=true;
			}
			else if(exportFormat.equalsIgnoreCase("htmlfull")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "1");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				bHasContent=true;
			}
		}
	}
	
	private void setPeriod(DataValueSet dataValueSet) {
		if(end.getTime()-begin.getTime()==SH.getTimeDay()) {
	        dataValueSet.setPeriod(new SimpleDateFormat("yyyyMMdd").format(begin));
		}
		else if(end.getTime()-begin.getTime()<SH.getTimeDay()*32) {
	        dataValueSet.setPeriod(new SimpleDateFormat("yyyyMM").format(begin));
		}
		else if(end.getTime()-begin.getTime()<SH.getTimeDay()*95) {
			String quarter="1";
			if(Integer.parseInt(new SimpleDateFormat("MM").format(begin))>=10) {
				quarter="4";
			}
			else if(Integer.parseInt(new SimpleDateFormat("MM").format(begin))>=7) {
				quarter="3";
			}
			else if(Integer.parseInt(new SimpleDateFormat("MM").format(begin))>=4) {
				quarter="2";
			}
	        dataValueSet.setPeriod(new SimpleDateFormat("yyyy").format(begin)+"Q"+quarter);
		}
		else if(end.getTime()-begin.getTime()<SH.getTimeDay()*368) {
	        dataValueSet.setPeriod(new SimpleDateFormat("yyyy").format(begin));
		}
	}
	
	private void exportItemDataset(Vector items,Element dataset, String attributeOptionComboUid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String department=null;
		String zone=null;
		//This is where we create the DataValueSet
        DataValueSet dataValueSet = new DataValueSet();
        dataValueSet.setDataSet(dataset.attributeValue("uid"));
        setPeriod(dataValueSet);
        dataValueSet.setCompleteDate(new SimpleDateFormat("yyyy-MM-dd").format(end));
        dataValueSet.setAttributeOptionCombo(attributeOptionComboUid);
        dataValueSet.setOrgUnit(dataset);
		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
					gender=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					gender=categoryOptionComboValue.attributeValue("gender");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin")){
					origin=categoryOptionComboValue.attributeValue("value");
					Debug.println("- Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+origin);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("zone")){
					zone=categoryOptionComboValue.attributeValue("value");
					Debug.println("- Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+zone);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome")){
					outcome=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+outcome);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department")){
					department=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+department);
				}
				Debug.println("Checking "+items.size()+" items...");
				for(int n=0;n<items.size();n++){
					String item = (String)items.elementAt(n);
					Debug.println("Checking item (1): "+item);
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2])){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date itemdate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[15]);
							if(dateofbirth!=null && (itemdate.getTime()-dateofbirth.getTime())/year>=minAge && (itemdate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2]) && minAge>-999 && maxAge>-999){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date itemdate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[15]);
							double age=(itemdate.getTime()-dateofbirth.getTime())/year;
							if(age>=minAge && age<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							//e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-999){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
							Date itemdate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[15]);
							double age=(itemdate.getTime()-dateofbirth.getTime())*12/year;
							if(age>=minAge && age<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin") && origin!=null && inArray(item.split(";")[7].toLowerCase(),origin.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("zone") && zone!=null && inArray(item.split(";")[12].toLowerCase(),zone.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome") && outcome!=null && inArray(item.split(";")[5].toLowerCase(),outcome.toLowerCase())){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("transactionitemvalue")){
						ItemVO tItem = null;
						tItem=MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), categoryOptionComboValue.attributeValue("itemtype"));
						if(tItem==null || tItem.getValue()==null || tItem.getValue().length()==0){
							continue;
						}
						else{
							tItem.setValue(tItem.getValue().replaceAll(";","{semicolon}"));
							String minval=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueMin"));
							String maxval=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueMax"));
							String matchval=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValue"));
							String matchvalin=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueIn"));
							String minvalpct=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueMinPct"));
							String maxvalpct=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueMaxPct"));
							if(matchvalin.length()>0){
								try{
									if(!inArray(tItem.getValue(),matchvalin)){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(minvalpct.length()>0){
								try{
									if(Double.parseDouble(tItem.getValue())*100/Double.parseDouble(tItem.getValue())<Double.parseDouble(minvalpct)){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(maxvalpct.length()>0){
								try{
									if(Double.parseDouble(tItem.getValue())*100/Double.parseDouble(tItem.getValue())>=Double.parseDouble(maxvalpct)){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(minval.length()>0){
								try{
									if(item.split(";")[8].length()==0 || Double.parseDouble(tItem.getValue())<Double.parseDouble(minval)){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(maxval.length()>0){
								try{
									if(item.split(";")[8].length()==0 || Double.parseDouble(tItem.getValue())>Double.parseDouble(maxval)){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(matchval.length()>0){
								try{
									if(matchval.contains("{like}")) {
										if(!tItem.getValue().contains(matchval.replaceAll("\\{like\\}", ""))){
											continue;
										}
									}
									else if(!tItem.getValue().equalsIgnoreCase(matchval)){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
						}
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
						selectedItems.add(item);
					}
				}
				exportItemDatasetSeries(selectedItems,dataset,attributeOptionComboUid,categoryOptionComboValue.attributeValue("uid"),dataValueSet);
			}
		}
		else{
			exportItemDatasetSeries(items,dataset,attributeOptionComboUid,"",dataValueSet);
		}
		if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1 || dataValueSet.getDataValues().size()>0){
			try {
				Debug.println(dataValueSet.toXMLString());
			} catch (JAXBException e) {
				e.printStackTrace();
			}
			//Send message to DHIS2 server
			if(exportFormat.equalsIgnoreCase("dhis2server")){
				DHIS2Helper.sendToServer(dataValueSet,dataset,jspWriter);
			}
			else if(exportFormat.equalsIgnoreCase("html")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "0");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				html.append("<p/>");
				bHasContent=true;
			}
			else if(exportFormat.equalsIgnoreCase("htmlfull")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "1");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				bHasContent=true;
			}
		}
	}
	
	private void exportPharmacyDataset(Element dataset, String attributeOptionComboUid,Hashtable initialquantities,Hashtable averageconsumptions,Hashtable consumptions,Hashtable productoperations){
		//This is where we create the DataValueSet
        DataValueSet dataValueSet = new DataValueSet();
        dataValueSet.setDataSet(dataset.attributeValue("uid"));
        setPeriod(dataValueSet);
        dataValueSet.setCompleteDate(new SimpleDateFormat("yyyy-MM-dd").format(end));
        dataValueSet.setAttributeOptionCombo(attributeOptionComboUid);
        dataValueSet.setOrgUnit(dataset);
        
		exportPharmacyDatasetSeries(dataset,dataValueSet,initialquantities,averageconsumptions,consumptions,productoperations);

        if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1 || dataValueSet.getDataValues().size()>0){
			try {
				Debug.println(dataValueSet.toXMLString());
			} catch (JAXBException e) {
				e.printStackTrace();
			}
			//Send message to DHIS2 server
			if(exportFormat.equalsIgnoreCase("dhis2server")){
				DHIS2Helper.sendToServer(dataValueSet,dataset,jspWriter);
			}
			else if(exportFormat.equalsIgnoreCase("html")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "0");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				html.append("<p/>");
				bHasContent=true;
			}
			else if(exportFormat.equalsIgnoreCase("htmlfull")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "1");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				bHasContent=true;
			}
		}
	}

	private void exportLabDataset(Vector items,Element dataset, String attributeOptionComboUid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String invalue=null;
		//This is where we create the DataValueSet
        DataValueSet dataValueSet = new DataValueSet();
        dataValueSet.setDataSet(dataset.attributeValue("uid"));
        setPeriod(dataValueSet);
        dataValueSet.setCompleteDate(new SimpleDateFormat("yyyy-MM-dd").format(end));
        dataValueSet.setAttributeOptionCombo(attributeOptionComboUid);
        dataValueSet.setOrgUnit(dataset);

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator(); //option elements
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next(); //categoryOptionComboValue = option element
				if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
					gender=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					gender=categoryOptionComboValue.attributeValue("gender");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("invalue")){
					invalue=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+invalue);
				}
				Debug.println("Checking "+items.size()+" items...");
				for(int n=0;n<items.size();n++){
					String item = (String)items.elementAt(n);
					Debug.println("Checking item (2): "+item);
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[1])){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-999){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[7]);
							if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[1]) && minAge>-999 && maxAge>-999){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[7]);
							if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[1].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-999){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[7]);
							if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("invalue")){
						if(item.split(";").length>6 && item.split(";")[6].length()>0 && invalue.toLowerCase().contains(item.split(";")[6].toLowerCase())) {
							selectedItems.add(item);
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
						selectedItems.add(item);
					}
				}
				exportLabDatasetSeries(selectedItems,dataset,attributeOptionComboUid,categoryOptionComboValue.attributeValue("uid"),dataValueSet);
			}
		}
		else{
			exportLabDatasetSeries(items,dataset,attributeOptionComboUid,"",dataValueSet);
		}
		if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1 || dataValueSet.getDataValues().size()>0){
			try {
				Debug.println(dataValueSet.toXMLString());
			} catch (JAXBException e) {
				e.printStackTrace();
			}
			//Send message to DHIS2 server
			if(exportFormat.equalsIgnoreCase("dhis2server")){
				DHIS2Helper.sendToServer(dataValueSet,dataset,jspWriter);
			}
			else if(exportFormat.equalsIgnoreCase("html")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "0");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				html.append("<p/>");
				bHasContent=true;
			}
			else if(exportFormat.equalsIgnoreCase("htmlfull")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "1");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				bHasContent=true;
			}
		}
	}
	private void exportPluginDataset(Vector items,Element dataset, String attributeOptionComboUid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String invalue=null;
		//This is where we create the DataValueSet
        DataValueSet dataValueSet = new DataValueSet();
        dataValueSet.setDataSet(dataset.attributeValue("uid"));
        setPeriod(dataValueSet);
        dataValueSet.setCompleteDate(new SimpleDateFormat("yyyy-MM-dd").format(end));
        dataValueSet.setAttributeOptionCombo(attributeOptionComboUid);
        dataValueSet.setOrgUnit(dataset);

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator(); //option elements
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next(); //categoryOptionComboValue = option element
				if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
					gender=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
					minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
					maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
					gender=categoryOptionComboValue.attributeValue("gender");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
				}
				else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("invalue")){
					invalue=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+invalue);
				}
				Debug.println("Checking "+items.size()+" items...");
				for(int n=0;n<items.size();n++){
					String item = (String)items.elementAt(n);
					Debug.println("Checking item (3): "+item);
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[1])){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-999){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[4]);
							if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[1]) && minAge>-999 && maxAge>-999){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[4]);
							if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							//e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[1].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-999){
						long day = 24*3600*1000;
						double year = 365*day;
						try{
							Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
							Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[4]);
							if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
								selectedItems.add(item);
							}
						}
						catch(Exception e){
							e.printStackTrace();
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("invalue")){
						if(item.split(";").length>3 && item.split(";")[3].length()>0 && invalue.toLowerCase().contains(item.split(";")[3].toLowerCase())) {
							selectedItems.add(item);
						}
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
						selectedItems.add(item);
					}
				}
				Debug.println("Exporting "+selectedItems.size()+" selected Items");
				exportPluginDatasetSeries(selectedItems,dataset,attributeOptionComboUid,categoryOptionComboValue.attributeValue("uid"),dataValueSet);
			}
		}
		else{
			exportPluginDatasetSeries(items,dataset,attributeOptionComboUid,"",dataValueSet);
		}
		if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1 || dataValueSet.getDataValues().size()>0){
			try {
				Debug.println(dataValueSet.toXMLString());
			} catch (JAXBException e) {
				e.printStackTrace();
			}
			//Send message to DHIS2 server
			if(exportFormat.equalsIgnoreCase("dhis2server")){
				DHIS2Helper.sendToServer(dataValueSet,dataset,jspWriter);
			}
			else if(exportFormat.equalsIgnoreCase("html")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "0");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				html.append("<p/>");
				bHasContent=true;
			}
			else if(exportFormat.equalsIgnoreCase("htmlfull")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "1");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				bHasContent=true;
			}
		}
	}
	
	private void exportGenericPluginDataset(Vector items,Element dataset, String attributeOptionComboUid){
		String category=null;
		//This is where we create the DataValueSet
        DataValueSet dataValueSet = new DataValueSet();
        dataValueSet.setDataSet(dataset.attributeValue("uid"));
        setPeriod(dataValueSet);
        dataValueSet.setCompleteDate(new SimpleDateFormat("yyyy-MM-dd").format(end));
        dataValueSet.setAttributeOptionCombo(attributeOptionComboUid);
        dataValueSet.setOrgUnit(dataset);

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator(); //option elements
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next(); //categoryOptionComboValue = option element
				if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("genericplugin")){
					category=categoryOptionComboValue.attributeValue("value");
					Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type"));
				}
				for(int n=0;n<items.size();n++){
					String item = (String)items.elementAt(n);
					Debug.println("Checking item (4): "+item);
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("genericplugin") && category!=null && category.equalsIgnoreCase(item.split(";")[1])){
						selectedItems.add(item);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")) {
						selectedItems.add(item);
					}
				}
				exportGenericPluginDatasetSeries(selectedItems,dataset,attributeOptionComboUid,categoryOptionComboValue.attributeValue("uid"),dataValueSet);
			}
		}
		else{
			exportGenericPluginDatasetSeries(items,dataset,attributeOptionComboUid,"",dataValueSet);
		}
		if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1 || dataValueSet.getDataValues().size()>0){
			try {
				Debug.println(dataValueSet.toXMLString());
			} catch (JAXBException e) {
				e.printStackTrace();
			}
			//Send message to DHIS2 server
			if(exportFormat.equalsIgnoreCase("dhis2server")){
				DHIS2Helper.sendToServer(dataValueSet,dataset,jspWriter);
			}
			else if(exportFormat.equalsIgnoreCase("html")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "0");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				html.append("<p/>");
				bHasContent=true;
			}
			else if(exportFormat.equalsIgnoreCase("htmlfull")){
				MedwanQuery.getInstance().setConfigString("sendFullDHIS2DataSets", "1");
				html.append(DHIS2Helper.toHtml(dataValueSet,"default",language,dataset.attributeValue("label")));
				bHasContent=true;
			}
		}
	}
	
	private void exportEncounterDatasetRecords(Vector items,Element dataset, String dataelementuid,String optionuid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String department=null;
		String zone=null;

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(optionuid.length()==0||optionuid.equals(categoryOptionComboValue.attributeValue("uid"))){
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
						gender=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						gender=categoryOptionComboValue.attributeValue("gender");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin")){
						origin=categoryOptionComboValue.attributeValue("value");
						Debug.println("* Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+origin);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("zone")){
						zone=categoryOptionComboValue.attributeValue("value");
						Debug.println("* Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+zone);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome")){
						outcome=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+outcome);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department")){
						department=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+department);
					}
					Debug.println("Checking "+items.size()+" items...");
					for(int n=0;n<items.size();n++){
						String item = (String)items.elementAt(n);
						if(ScreenHelper.checkString(dataset.attributeValue("incoming")).equals("1")){
							try{
								java.util.Date begin = null;
								if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
									begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
								}
								else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
									begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								}
								if(begin.before(this.begin) || begin.after(this.end)){
									continue;
								}
							}
							catch (Exception e){
								e.printStackTrace();
							}
						}
						if(ScreenHelper.checkString(dataset.attributeValue("outgoing")).equals("1")){
							try{
								java.util.Date end = null;
								if(dataset.attributeValue("type").equalsIgnoreCase("diagnosis")){
									end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[14]);
								}
								else if(dataset.attributeValue("type").equalsIgnoreCase("encounter")){
									end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
									java.util.Date now = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[12]);
									if(!end.before(now)) {
										continue;
									}
								}
								if(end.before(this.begin) || end.after(this.end)){
									continue;
								}
							}
							catch (Exception e){
								e.printStackTrace();
							}
						}
						if(SH.c(dataset.attributeValue("hasnatreg")).equalsIgnoreCase("1") && item.split(";")[13].length()==0) {
							continue;
						}
						else if(SH.c(dataset.attributeValue("hasnatreg")).equalsIgnoreCase("0") && item.split(";")[13].length()>0) {
							continue;
						}
						if(ScreenHelper.checkString(dataset.attributeValue("missing")).equals("diagnosis")){
							if(Diagnosis.selectDiagnoses("", "", MedwanQuery.getInstance().getServerId()+"."+item.split(";")[1], "", "", "", "", "", "", "", "", "icd10", "").size()>0) {
								continue;
							}
						}
						if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2])){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2]) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
								if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin") && origin!=null && inArray(item.split(";")[7].toLowerCase(),origin.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("zone") && zone!=null && inArray(item.split(";")[10].toLowerCase(),zone.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome") && outcome!=null && inArray(item.split(";")[5].toLowerCase(),outcome.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
							selectedItems.add(item);
						}
					}
					exportEncounterDatasetSeriesRecords(selectedItems,dataset,dataelementuid);
				}
			}
		}
		else{
			exportEncounterDatasetSeriesRecords(items,dataset,dataelementuid);
		}
	}
	
	private void exportTechnicalActivityDatasetRecords(Vector items,Element dataset, String dataelementuid,String optionuid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String department=null;

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(optionuid.length()==0||optionuid.equals(categoryOptionComboValue.attributeValue("uid"))){
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
						gender=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						gender=categoryOptionComboValue.attributeValue("gender");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin")){
						origin=categoryOptionComboValue.attributeValue("value");
						Debug.println("* Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+origin);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome")){
						outcome=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+outcome);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department")){
						department=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+department);
					}
					Debug.println("Checking "+items.size()+" items...");
					for(int n=0;n<items.size();n++){
						String item = (String)items.elementAt(n);
						Debug.println("Checking item (5): "+item);
						if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2])){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = SH.parseDate(item.split(";")[9]);
								if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2]) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = SH.parseDate(item.split(";")[9]);
								if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = SH.parseDate(item.split(";")[9]);
								if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin") && origin!=null && inArray(item.split(";")[7].toLowerCase(),origin.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome") && outcome!=null && inArray(item.split(";")[5].toLowerCase(),outcome.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
							selectedItems.add(item);
						}
					}
					exportTechnicalActivityDatasetSeriesRecords(selectedItems,dataset,dataelementuid);
				}
			}
		}
		else{
			exportTechnicalActivityDatasetSeriesRecords(items,dataset,dataelementuid);
		}
	}
	
	private void exportPharmacyDatasetRecords(Element dataset, String dataelementuid,String optionuid,Hashtable initialquantities,Hashtable averageconsumptions,Hashtable consumptions,Hashtable productoperations){
		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
					//if conditions fulfilled for this categoryOptionCombo, calculate the dataElements 
				}
			}
		}
	}
	
	private void exportLabDatasetRecords(Vector items,Element dataset, String dataelementuid,String optionuid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String invalue=null;
		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(optionuid.length()==0||optionuid.equals(categoryOptionComboValue.attributeValue("uid"))){
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
						gender=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						gender=categoryOptionComboValue.attributeValue("gender");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("invalue")){
						invalue=categoryOptionComboValue.attributeValue("value");
					}
					for(int n=0;n<items.size();n++){
						String item = (String)items.elementAt(n);
						if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[1])){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[7]);
								if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[1]) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[7]);
								if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[7]);
								if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("invalue")){
							if(item.split(";").length>6 && item.split(";")[6].length()>0 && invalue.toLowerCase().contains(item.split(";")[6].toLowerCase())) {
								selectedItems.add(item);
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
							selectedItems.add(item);
						}
					}
					exportLabDatasetSeriesRecords(selectedItems,dataset,dataelementuid);
				}
			}
		}
		else{
			exportLabDatasetSeriesRecords(items,dataset,dataelementuid);
		}
	}
	
	private void exportPluginDatasetRecords(Vector items,Element dataset, String dataelementuid,String optionuid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String invalue=null;

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(optionuid.length()==0||optionuid.equals(categoryOptionComboValue.attributeValue("uid"))){
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
						gender=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						gender=categoryOptionComboValue.attributeValue("gender");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("invalue")){
						invalue=categoryOptionComboValue.attributeValue("value");
					}

					Debug.println("Checking "+items.size()+" items...");
					for(int n=0;n<items.size();n++){
						String item = (String)items.elementAt(n);
						Debug.println("Checking item (7): "+item);
						if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[1])){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[4]);
								if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[1]) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[4]);
								if((begindate.getTime()-dateofbirth.getTime())/year>=minAge && (begindate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[1].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[2]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[4]);
								if((begindate.getTime()-dateofbirth.getTime())*12/year>=minAge && (begindate.getTime()-dateofbirth.getTime())*12/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("invalue")){
							if(item.split(";").length>3 && item.split(";")[3].length()>0 && invalue.toLowerCase().contains(item.split(";")[3].toLowerCase())) {
								selectedItems.add(item);
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
							selectedItems.add(item);
						}
					}
					exportPluginDatasetSeriesRecords(selectedItems,dataset,dataelementuid);
				}
			}
		}
		else{
			exportPluginDatasetSeriesRecords(items,dataset,dataelementuid);
		}
	}
	
	private void exportItemDatasetRecords(Vector items,Element dataset, String dataelementuid,String optionuid){
		String gender=null;
		double minAge=-999;
		double maxAge=-999;
		String origin=null;
		String outcome=null;
		String department=null;
		String zone=null;

		//First we check if any categoryOptionCombo has been defined
		Element categoryOptionCombo = dataset.element("categoryOptionCombo");
		if(categoryOptionCombo!=null){
			Iterator icategoryOptionCombo = categoryOptionCombo.elementIterator();
			while(icategoryOptionCombo.hasNext()){
				Vector selectedItems = new Vector();
				Element categoryOptionComboValue = (Element)icategoryOptionCombo.next();
				if(optionuid.length()==0||optionuid.equals(categoryOptionComboValue.attributeValue("uid"))){
					if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender")){
						gender=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender")||categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths")){
						minAge=Double.parseDouble(categoryOptionComboValue.attributeValue("min"));
						maxAge=Double.parseDouble(categoryOptionComboValue.attributeValue("max"));
						gender=categoryOptionComboValue.attributeValue("gender");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+minAge+"->"+maxAge+ " | "+gender);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin")){
						origin=categoryOptionComboValue.attributeValue("value");
						Debug.println("* Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+origin);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("zone")){
						zone=categoryOptionComboValue.attributeValue("value");
						Debug.println("* Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+zone);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome")){
						outcome=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+outcome);
					}
					else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department")){
						department=categoryOptionComboValue.attributeValue("value");
						Debug.println("Exporting categoryOptionType "+categoryOptionCombo.attributeValue("type")+" - "+department);
					}
					Debug.println("Checking "+items.size()+" items...");
					for(int n=0;n<items.size();n++){
						String item = (String)items.elementAt(n);
						if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("gender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2])){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("age") && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date itemdate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[15]);
								if(dateofbirth!=null && (itemdate.getTime()-dateofbirth.getTime())/year>=minAge && (itemdate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegender") && gender!=null && gender.equalsIgnoreCase(item.split(";")[2]) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date itemdate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[15]);
								if((itemdate.getTime()-dateofbirth.getTime())/year>=minAge && (itemdate.getTime()-dateofbirth.getTime())/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("agegenderinmonths") && gender!=null && inArray(item.split(";")[2].toLowerCase(),gender.toLowerCase()) && minAge>-999 && maxAge>-1){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date itemdate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[15]);
								if((itemdate.getTime()-dateofbirth.getTime())*12/year>=minAge && (itemdate.getTime()-dateofbirth.getTime())*12/year<maxAge){
									selectedItems.add(item);
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("origin") && origin!=null && inArray(item.split(";")[7].toLowerCase(),origin.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("zone") && zone!=null && inArray(item.split(";")[12].toLowerCase(),zone.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("outcome") && outcome!=null && inArray(item.split(";")[5].toLowerCase(),outcome.toLowerCase())){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("department") && department!=null && ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])).length()>0 && department.contains(ScreenHelper.checkString((String)departmentmaps.get(item.split(";")[4])))){
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("transactionitemvalue")){
							ItemVO tItem = null;
							tItem=MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), categoryOptionComboValue.attributeValue("itemtype"));
							if(tItem==null || tItem.getValue()==null || tItem.getValue().length()==0){
								continue;
							}
							else{
								tItem.setValue(tItem.getValue().replaceAll(";", "{semicolon}"));
								String minval=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueMin"));
								String maxval=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueMax"));
								String matchval=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValue"));
								String matchvalin=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueIn"));
								String minvalpct=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueMinPct"));
								String maxvalpct=ScreenHelper.checkString(categoryOptionComboValue.attributeValue("outputItemValueMaxPct"));
								if(matchvalin.length()>0){
									try{
										if(!inArray(tItem.getValue(),matchvalin)){
											continue;
										}
									}
									catch(Exception e){
										continue;
									}
								}
								if(minvalpct.length()>0){
									try{
										if(Double.parseDouble(tItem.getValue())*100/Double.parseDouble(tItem.getValue())<Double.parseDouble(minvalpct)){
											continue;
										}
									}
									catch(Exception e){
										continue;
									}
								}
								if(maxvalpct.length()>0){
									try{
										if(Double.parseDouble(tItem.getValue())*100/Double.parseDouble(tItem.getValue())>=Double.parseDouble(maxvalpct)){
											continue;
										}
									}
									catch(Exception e){
										continue;
									}
								}
								if(minval.length()>0){
									try{
										if(item.split(";")[8].length()==0 || Double.parseDouble(tItem.getValue())<Double.parseDouble(minval)){
											continue;
										}
									}
									catch(Exception e){
										continue;
									}
								}
								if(maxval.length()>0){
									try{
										if(item.split(";")[8].length()==0 || Double.parseDouble(tItem.getValue())>Double.parseDouble(maxval)){
											continue;
										}
									}
									catch(Exception e){
										continue;
									}
								}
								if(matchval.length()>0){
									try{
										if(matchval.length()>0 && !matchval.equalsIgnoreCase(tItem.getValue())){
											continue;
										}
									}
									catch(Exception e){
										continue;
									}
								}
							}
							selectedItems.add(item);
						}
						else if(categoryOptionCombo.attributeValue("type").equalsIgnoreCase("default")){
							selectedItems.add(item);
						}
					}
					exportItemDatasetSeriesRecords(selectedItems,dataset,dataelementuid);
				}
			}
		}
		else{
			exportItemDatasetSeriesRecords(items,dataset,dataelementuid);
		}
	}
	
	private void exportEncounterDatasetSeries(Vector items,Element dataset,String attributeOptionComboUid,String categoryOptionUid, DataValueSet dataValueSet){
		boolean bMortality = ScreenHelper.checkString(dataset.attributeValue("mortality")).equalsIgnoreCase("true");
		String sEncounterType = ScreenHelper.checkString(dataset.attributeValue("encountertype"));
		String sOutcome = ScreenHelper.checkString(dataset.attributeValue("outcome"));
		String sOrigin = ScreenHelper.checkString(dataset.attributeValue("origin"));
		String sDepartmentOrgUID = ScreenHelper.checkString(dataset.attributeValue("departmentorguid"));
		HashSet authorizedServices = new HashSet();
		if(sDepartmentOrgUID.length()>0) {
			//Load all services that are compatible
			Iterator allServices = SH.getAllServices().iterator();
			while(allServices.hasNext()) {
				Service service = (Service)allServices.next();
				if(SH.c(service.getInscode()).equalsIgnoreCase(sDepartmentOrgUID)) {
					authorizedServices.add(service.getCode().toLowerCase());
				}
			}
		}
		Iterator i = dataset.element("dataelements").elementIterator("dataelement");
		while(i.hasNext()){
			Hashtable uids = new Hashtable();
			Element dataelement = (Element)i.next();
			long uidcounter=0;
			for(int n=0;n<items.size();n++){
				String item = (String)items.elementAt(n);
				if(sDepartmentOrgUID.length()>0 && !authorizedServices.contains(item.split(";")[4].toLowerCase())) {
					continue;
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("minage")).length()>0){
					long day = 24*3600*1000;
					double year = 365*day;
					try{
						Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
						Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
						double minAge = Double.parseDouble(dataelement.attributeValue("minage"));
						if(dateofbirth==null || (begindate.getTime()-dateofbirth.getTime())/year<minAge){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("maxage")).length()>0){
					long day = 24*3600*1000;
					double year = 365*day;
					try{
						Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
						Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
						double maxAge = Double.parseDouble(dataelement.attributeValue("maxage"));
						if(dateofbirth==null || (begindate.getTime()-dateofbirth.getTime())/year>=maxAge){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("minageinmonths")).length()>0){
					long day = 24*3600*1000;
					double year = 365*day;
					try{
						Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
						Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
						double minAge = Double.parseDouble(dataelement.attributeValue("minageinmonths"));
						if(dateofbirth==null || (begindate.getTime()-dateofbirth.getTime())*12/year<minAge){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("maxageinmonths")).length()>0){
					long day = 24*3600*1000;
					double year = 365*day;
					try{
						Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
						Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
						double maxAge = Double.parseDouble(dataelement.attributeValue("maxageinmonths"));
						if(dateofbirth==null || (begindate.getTime()-dateofbirth.getTime())*12/year>=maxAge){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(SH.c(dataelement.attributeValue("hasnatreg")).equalsIgnoreCase("1") && item.split(";")[13].length()==0) {
					continue;
				}
				else if(SH.c(dataelement.attributeValue("hasnatreg")).equalsIgnoreCase("0") && item.split(";")[13].length()>0) {
					continue;
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("gender")).length()>0){
					if(!inArray(item.split(";")[2].toLowerCase(),dataelement.attributeValue("gender").toLowerCase())){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("outcome")).length()>0){
					if(!inArray(item.split(";")[5].toLowerCase(),dataelement.attributeValue("outcome").toLowerCase())){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("origin")).length()>0){
					if(!inArray(item.split(";")[7].toLowerCase(),dataelement.attributeValue("origin").toLowerCase())){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataset.attributeValue("newcase")).equals("1") && !Encounter.isNewCase(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1])){
					continue;
				}
				else if(ScreenHelper.checkString(dataset.attributeValue("newcase")).equals("0") && Encounter.isNewCase(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1])){
					continue;
				}
				if(sOutcome.length()>0 && !inArray(item.split(";")[5],sOutcome.toLowerCase())){
					continue;
				}
				if(sOrigin.length()>0 && !inArray(item.split(";")[7],sOrigin.toLowerCase())){
					continue;
				}
				if(!bMortality || item.split(";")[5].startsWith("dead")){
					if(sEncounterType.length()==0 || ScreenHelper.checkString(item.split(";")[6]).equalsIgnoreCase(sEncounterType)){
						if(ScreenHelper.checkString(dataelement.attributeValue("incoming")).equals("1")){
							try{
								java.util.Date begin = begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								if(begin.before(this.begin) || begin.after(this.end)){
									continue;
								}
							}
							catch (Exception e){
								e.printStackTrace();
							}
						}
						if(SH.c(dataelement.attributeValue("etiology")).length()>0 && !dataelement.attributeValue("etiology").equalsIgnoreCase(item.split(";")[11])){
							continue;
						}
						if(ScreenHelper.checkString(dataelement.attributeValue("outgoing")).equals("1")){
							try{
								java.util.Date end =  new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
								java.util.Date now =  new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[12]);
								if(!end.before(now) ||  end.before(this.begin) || end.after(this.end)){
									continue;
								}
							}
							catch (Exception e){
								e.printStackTrace();
							}
						}
						if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("totalbeds")){
							uidcounter=getBedCountForDepartment(item.split(";")[4]);
							break;
						}
						else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("admittedatstartperiod")){
							uidcounter=getAdmittedAtStartPeriod(item.split(";")[4],begin);
							break;
						}
						else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("potentialAdmissionDays")){
							uidcounter=getBedCountForDepartment(item.split(";")[4])*ScreenHelper.nightsBetween(begin,end);
							break;
						}
						else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("admissionDays")){
							String sItemType=SH.c(dataelement.attributeValue("itemtype"));
							String sItemValue=SH.c(dataelement.attributeValue("itemvalue"));
							if(sItemValue.length()==0) {
								sItemValue="{like}%";
							}
							if(sItemType.length()>0 && sItemValue.length()>0) {
								boolean bExists=false;
								if(ScreenHelper.checkString(dataelement.attributeValue("transactiontype")).length()>0) {
									bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,dataelement.attributeValue("transactiontype"));
								}
								else {
									bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue);
								}
								if(!bExists) {
									break;
								}
							}
							try{
								java.util.Date begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								if(begin.before(this.begin)){
									begin=this.begin;
								}
								java.util.Date end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
								if(end.after(this.end)){
									end=new java.util.Date(this.end.getTime()-1000);
								}
								uidcounter+= ScreenHelper.nightsBetween(begin,end);
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("totalAdmissionDays")){
							String sItemType=SH.c(dataelement.attributeValue("itemtype"));
							String sItemValue=SH.c(dataelement.attributeValue("itemvalue"));
							if(sItemValue.length()==0) {
								sItemValue="{like}%";
							}
							if(sItemType.length()>0 && sItemValue.length()>0) {
								boolean bExists=false;
								if(ScreenHelper.checkString(dataelement.attributeValue("transactiontype")).length()>0) {
									bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,dataelement.attributeValue("transactiontype"));
								}
								else {
									bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue);
								}
								if(!bExists) {
									break;
								}
							}
							try{
								java.util.Date begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								java.util.Date end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
								if(end.after(this.end)){
									end=new java.util.Date(this.end.getTime()-1000);
								}
								uidcounter+= ScreenHelper.nightsBetween(begin,end);
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("totalAdmissionDaysPlus")){
							String sItemType=SH.c(dataelement.attributeValue("itemtype"));
							String sItemValue=SH.c(dataelement.attributeValue("itemvalue"));
							if(sItemValue.length()==0) {
								sItemValue="{like}%";
							}
							if(sItemType.length()>0 && sItemValue.length()>0) {
								boolean bExists=false;
								if(ScreenHelper.checkString(dataelement.attributeValue("transactiontype")).length()>0) {
									bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,dataelement.attributeValue("transactiontype"));
								}
								else {
									bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue);
								}
								if(!bExists) {
									break;
								}
							}
							try{
								java.util.Date begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								java.util.Date end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
								if(end.after(this.end)){
									end=new java.util.Date(this.end.getTime()-1000);
								}
								uidcounter+= ScreenHelper.nightsBetween(begin,end)+1;
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("itemCount")){
							int nNeeded=0,nMaxItems=-99;
							if(ScreenHelper.checkString(dataelement.attributeValue("itemsneeded")).length()>0){
								nNeeded=Integer.parseInt(ScreenHelper.checkString(dataelement.attributeValue("itemsneeded")));
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("maxitems")).length()>0){
								nMaxItems=Integer.parseInt(ScreenHelper.checkString(dataelement.attributeValue("maxitems")));
							}
							int nFound=0;
							Iterator iItems = dataelement.elementIterator("item");
							while(iItems.hasNext()){
								Element itemelement = (Element)iItems.next();
								String sItemType=itemelement.attributeValue("itemtype");
								String sItemValue=ScreenHelper.checkString(itemelement.attributeValue("itemvalue"));
								//Now we look for the existence of this item
								boolean bExists=false;
								if(ScreenHelper.checkString(itemelement.attributeValue("transactiontype")).length()>0) {
									if(SH.c(itemelement.attributeValue("singlematch")).equalsIgnoreCase("1")){
										bExists=MedwanQuery.getInstance().hasSingleItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"));
									}
									else {
										bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"));
									}
								}
								else {
									bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue);
								}
								if(SH.c(itemelement.attributeValue("mandatory")).equalsIgnoreCase("1") && !bExists) {
									nFound=-1;
									break;
								}
								boolean bDoBreak=false;
								if(nMaxItems<0 && nNeeded==0 && !bExists){
									nFound=-1;
									bDoBreak=true;
								}
								else if(nNeeded==0 && bExists){
									nFound++;
								}
								else if(nNeeded>0 && bExists){
									nFound++;
									if(nFound>=nNeeded && !ScreenHelper.checkString(dataelement.attributeValue("countall")).equals("1")){
										bDoBreak=true;
									}
								}
								if(nMaxItems>=0 && nFound>nMaxItems) {
									nFound=-1;
									break;
								}
								if(bDoBreak) {
									break;
								}
							}
							if(nFound>=nNeeded){
								if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("patients")){
									uids.put(item.split(";")[0],nFound);
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounters")){
									uids.put(item.split(";")[1],nFound);
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounterdate")){
									uids.put(item.split(";")[0]+"."+(item.split(";")[8]+"        ").substring(0,8),nFound); 
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("transactions")){
									uids.put(item.split(";")[11],nFound);
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("countall")).equals("1")){
									uidcounter+=nFound;
								}
								else{
									uidcounter++;
								}
							}
						}
						else{
							if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("patients")){
								uids.put(item.split(";")[0],1);
							}
							else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounters")){
								uids.put(item.split(";")[1],1);
							}
							else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounterdate")){
								uids.put(item.split(";")[0]+"."+(item.split(";")[8]+"        ").substring(0,8),1);
							}
							else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("transactions")){
								uids.put(item.split(";")[11],1);
							}
							else{
								uidcounter++;
							}
						}
					}
				}
			}
			if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("patients") || ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounterdate") || ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("itemdate") || ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounters") || ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("transactions")){
				if(ScreenHelper.checkString(dataelement.attributeValue("countall")).equals("1")){
					uidcounter=0;
					Enumeration eUids = uids.keys();
					while(eUids.hasMoreElements()){
						String key = (String)eUids.nextElement();
						uidcounter+=(Integer)uids.get(key);
					}
				}
				else{
					uidcounter=uids.size();
				}
			}
			if(MedwanQuery.getInstance().getConfigInt("cleanDHIS2DataSets",0)==0 && uidcounter>0){
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid,uidcounter+"",""));
			}
			else if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1){
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid," ",""));
			}
		}
	}
	
	private void exportTechnicalActivityDatasetSeries(Vector items,Element dataset,String attributeOptionComboUid,String categoryOptionUid, DataValueSet dataValueSet){
		boolean bMortality = ScreenHelper.checkString(dataset.attributeValue("mortality")).equalsIgnoreCase("true");
		String sEncounterType = ScreenHelper.checkString(dataset.attributeValue("encountertype"));
		String sDepartmentOrgUID = ScreenHelper.checkString(dataset.attributeValue("departmentorguid"));
		HashSet authorizedServices = new HashSet();
		if(sDepartmentOrgUID.length()>0) {
			//Load all services that are compatible
			Iterator allServices = SH.getAllServices().iterator();
			while(allServices.hasNext()) {
				Service service = (Service)allServices.next();
				if(SH.c(service.getInscode()).equalsIgnoreCase(sDepartmentOrgUID)) {
					authorizedServices.add(service.getCode().toLowerCase());
				}
			}
		}
		Iterator i = dataset.element("dataelements").elementIterator("dataelement");
		while(i.hasNext()){
			Element dataelement = (Element)i.next();
			long uidcounter=0;
			for(int n=0;n<items.size();n++){
				String item = (String)items.elementAt(n);
				if(sDepartmentOrgUID.length()>0 && !authorizedServices.contains(item.split(";")[4].toLowerCase())) {
					continue;
				}
				if(!bMortality || item.split(";")[5].startsWith("dead")){
					if(sEncounterType.length()==0 || ScreenHelper.checkString(item.split(";")[6]).equalsIgnoreCase(sEncounterType)){
						if(inArray(item.split(";")[8].toLowerCase(), dataelement.attributeValue("code").toLowerCase())){
							uidcounter++;
						}
					}
				}
			}
			if(MedwanQuery.getInstance().getConfigInt("cleanDHIS2DataSets",0)==0 && uidcounter>0){
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid,uidcounter+"",""));
			}
			else if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1){
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid," ",""));
			}
		}
	}
	
	private void exportPharmacyDatasetSeries(Element dataset, DataValueSet dataValueSet,Hashtable initialquantities,Hashtable averageconsumptions,Hashtable consumptions,Hashtable productoperations){
		Iterator i = dataset.element("dataelements").elementIterator("dataelement");
		while(i.hasNext()){
			String dataElementUid="";
			String categoryOptionComboUid="";
			Element dataelement = (Element)i.next();
			Debug.println("Searching products for DHIS2 code = "+dataelement.attributeValue("productcode"));
			Vector<Product> products = Product.getProductsByDhis2code(ScreenHelper.checkString(dataelement.attributeValue("productcode")));
			if(ScreenHelper.checkString(dataset.attributeValue("missing")).equalsIgnoreCase("1")){
				if(products.size()>0) {
					continue;
				}
				categoryOptionComboUid=ScreenHelper.checkString(dataelement.attributeValue("option"));
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),categoryOptionComboUid,"["+dataelement.attributeValue("productcode")+"]",""));
			}
			else {
				Iterator iParameters = dataelement.elementIterator("parameter");
				while(iParameters.hasNext()) {
					int value=0;
					Element parameter = (Element)iParameters.next();
					String calculate=ScreenHelper.checkString(parameter.attributeValue("calculate"));
					categoryOptionComboUid=ScreenHelper.checkString(parameter.attributeValue("option"));
					dataElementUid=ScreenHelper.checkString(parameter.attributeValue("uid"));
					long t = new java.util.Date().getTime();
					if(calculate.equalsIgnoreCase("initialstock")) {
						for(int n=0;n<products.size();n++) {
							Product product = products.elementAt(n);
							if(initialquantities.get(product.getUid())!=null) {
								value+=((Double)initialquantities.get(product.getUid())).intValue();
							}
						}
					}
					else if(calculate.equalsIgnoreCase("quantityreceived")) {
						for(int n=0;n<products.size();n++) {
							Product product = products.elementAt(n);
							Vector<ProductStock> productStocks=ProductStock.find(MedwanQuery.getInstance().getConfigString("centralPharmacyServiceStockCode"), product.getUid(), "", "", "", "", "", "", "", "", "", "", "");	
							for(int p=0;p<productStocks.size();p++) {
								ProductStock stock = productStocks.elementAt(p);
								if(stock.getServiceStock().getEnd()==null || stock.getServiceStock().getEnd().after(begin)){
									value+=stock.getTotalUnitsInForPeriod(begin, end);
								}
							}
						}
					}
					else if(calculate.equalsIgnoreCase("quantitydispensed")) {
						for(int n=0;n<products.size();n++) {
							Product product = products.elementAt(n);
							if(consumptions.get(product.getUid())!=null) {
								value+=((Double)consumptions.get(product.getUid())).intValue();
							}
						}
					}
					else if(calculate.equalsIgnoreCase("finalstockmain")) {
						for(int n=0;n<products.size();n++) {
							Product product = products.elementAt(n);
							Vector<ProductStock> productStocks=ProductStock.find(MedwanQuery.getInstance().getConfigString("centralPharmacyServiceStockCode"), product.getUid(), "", "", "", "", "", "", "", "", "", "", "");	
							for(int p=0;p<productStocks.size();p++) {
								ProductStock stock = productStocks.elementAt(p);
								if(stock.getServiceStock().getEnd()==null || stock.getServiceStock().getEnd().after(begin)){
									value+=stock.getLevel(end);
								}
							}
						}
					}
					else if(calculate.equalsIgnoreCase("finalstockdispensing")) {
						for(int n=0;n<products.size();n++) {
							Product product = products.elementAt(n);
							Vector<ProductStock> productStocks=ProductStock.find("", product.getUid(), "", "", "", "", "", "", "", "", "", "", "");	
							for(int p=0;p<productStocks.size();p++) {
								ProductStock stock = productStocks.elementAt(p);
								if((stock.getServiceStock().getEnd()==null || stock.getServiceStock().getEnd().after(begin)) && !stock.getServiceStockUid().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("centralPharmacyServiceStockCode"))) {
									value+=stock.getCorrectedLevel(end);
								}
							}
						}
					}
					else if(calculate.equalsIgnoreCase("quantityexpired")) {
						for(int n=0;n<products.size();n++) {
							Product product = products.elementAt(n);
							Vector<String> batches = Batch.getActiveExpiringBatches(product.getUid(),begin, end);
							for(int b=0;b<batches.size();b++) {
								value+=Integer.parseInt((batches.elementAt(b)).split(";")[4]);
							}
						}
					}
					else if(calculate.equalsIgnoreCase("stockoutdays")) {
						if(products.size()>0) {
							int minvalue=-1;
							for(int n=0;n<products.size();n++) {
								Product product = products.elementAt(n);
								value=product.getDaysOutOfStock(begin, end, productoperations);
								if(minvalue==-1 || value<minvalue) {
									minvalue=value;
								}
							}
							if(minvalue==-1) {
								value=0;
							}
							else {
								value=minvalue;
							}
						}
						else {
							value=new Long((end.getTime()-begin.getTime())/ScreenHelper.getTimeDay()).intValue();
						}
					}
					else if(calculate.equalsIgnoreCase("quantitytoexpire")) {
						for(int n=0;n<products.size();n++) {
							Product product = products.elementAt(n);
							Vector<String> batches = Batch.getActiveExpiringBatches(product.getUid(),end, new java.util.Date(end.getTime()+ScreenHelper.getTimeDay()*Integer.parseInt(parameter.attributeValue("delay"))));
							for(int b=0;b<batches.size();b++) {
								value+=Integer.parseInt((batches.elementAt(b)).split(";")[4]);
							}
						}
					} 
					else if(calculate.equalsIgnoreCase("averageconsumption")) {
						for(int n=0;n<products.size();n++) {
							Product product = products.elementAt(n);
							if(averageconsumptions.get(product.getUid())!=null) {
								value+=((Double)averageconsumptions.get(product.getUid())).intValue();
							}
						}
					}
					dataValueSet.getDataValues().add(new DataValue(dataElementUid,categoryOptionComboUid,value+"",""));
				}
				if(products.size()==0) {
					dataValueSet.getDataValues().add(new DataValue(dataElementUid,categoryOptionComboUid,"0",""));
				}
			}
		}
	}
	
	private void exportLabDatasetSeries(Vector items,Element dataset,String attributeOptionComboUid,String categoryOptionUid, DataValueSet dataValueSet){
		Iterator i = dataset.element("dataelements").elementIterator("dataelement");
		while(i.hasNext()){
			Element dataelement = (Element)i.next();
			HashSet uniqueexams = new HashSet();
			for(int n=0;n<items.size();n++){
				String item = (String)items.elementAt(n);
				if(SH.c(dataelement.attributeValue("invalue")).length()==0 || (item.split(";").length>6 && item.split(";")[6].length()>0 && dataelement.attributeValue("invalue").toLowerCase().contains(item.split(";")[6].toLowerCase()))) {
					if(dataelement.attributeValue("code")==null || inArray(item.split(";")[3].toLowerCase(), dataelement.attributeValue("code").toLowerCase())){
						if(SH.c(dataelement.attributeValue("itemvalue")).length()>0  && !inArray(item.split(";")[8].toLowerCase(), dataelement.attributeValue("itemvalue").toLowerCase())) {
							continue;
						}
						if(SH.c(dataelement.attributeValue("min")).length()>0) {
							try {
								if(Double.parseDouble(item.split(";")[6])<Double.parseDouble(dataelement.attributeValue("min"))) {
									continue;
								}
							}
							catch(Exception min) {
								continue;
							}
						}
						if(SH.c(dataelement.attributeValue("max")).length()>0) {
							try {
								if(Double.parseDouble(item.split(";")[6])>Double.parseDouble(dataelement.attributeValue("max"))) {
									continue;
								}
							}
							catch(Exception min) {
								continue;
							}
						}
						if(SH.c(dataelement.attributeValue("itemcomment")).length()>0){
							String itemComment = dataelement.attributeValue("itemcomment").toLowerCase();
							String s6=item.split(";")[6];
							String s9=item.split(";").length>9?item.split(";")[9]:"";
							if(itemComment.startsWith("{contains}")) {
								if(!(s6+","+s9).toLowerCase().contains(itemComment.replaceAll("\\{contains\\}", ""))) {
									continue;
								}
							}
							else if(!itemComment.equalsIgnoreCase(s6.toLowerCase()) && !itemComment.equalsIgnoreCase(s9.toLowerCase())) {
								continue;
							}
						}
						uniqueexams.add(item.split(";")[5]);
					}
				}
			}
			if(MedwanQuery.getInstance().getConfigInt("cleanDHIS2DataSets",0)==0 && uniqueexams.size()>0){
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid,uniqueexams.size()+"",""));
			}
			else if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1) {
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid," ",""));
			}
		}
	}
	
	private void exportPluginDatasetSeries(Vector items,Element dataset,String attributeOptionComboUid,String categoryOptionUid, DataValueSet dataValueSet){
		Iterator i = dataset.element("dataelements").elementIterator("dataelement");
		while(i.hasNext()){
			Element dataelement = (Element)i.next();
			HashSet results = new HashSet();
			for(int n=0;n<items.size();n++){
				String item = (String)items.elementAt(n);
				if(SH.c(dataelement.attributeValue("itemvalue")).length()==0 || inArray(item.split(";")[3].toUpperCase(),dataelement.attributeValue("itemvalue").toUpperCase())) {
					results.add(item.split(";")[6]);
				}
			}
			if(MedwanQuery.getInstance().getConfigInt("cleanDHIS2DataSets",0)==0 && results.size()>0){
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid,results.size()+"",""));
			}
			else if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1) {
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid," ",""));
			}
		}
	}
	
	private void exportGenericPluginDatasetSeries(Vector items,Element dataset,String attributeOptionComboUid,String categoryOptionUid, DataValueSet dataValueSet){
		Iterator i = dataset.element("dataelements").elementIterator("dataelement");
		while(i.hasNext()){
			Element dataelement = (Element)i.next();
			for(int n=0;n<items.size();n++){
				String item = (String)items.elementAt(n);
				if(dataelement.attributeValue("code")==null || (item.split(";").length>3 && dataelement.attributeValue("code").equalsIgnoreCase(item.split(";")[3]))) {
					int value = 0;
					try {
						value=Integer.parseInt(item.split(";")[0]);
					}
					catch(Exception e) {
						e.printStackTrace();
					}
					if(MedwanQuery.getInstance().getConfigInt("cleanDHIS2DataSets",0)==0 && value>0){
						dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid,value+"",""));
					}
					else if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1) {
						dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid," ",""));
					}
				}
			}
		}
	}
	
	private void exportItemDatasetSeries(Vector items,Element dataset,String attributeOptionComboUid,String categoryOptionUid, DataValueSet dataValueSet){
		boolean bMortality = ScreenHelper.checkString(dataset.attributeValue("mortality")).equalsIgnoreCase("true");
		String sEncounterType = ScreenHelper.checkString(dataset.attributeValue("encountertype"));
		String sDepartmentOrgUID = ScreenHelper.checkString(dataset.attributeValue("departmentorguid"));
		HashSet authorizedServices = new HashSet();
		if(sDepartmentOrgUID.length()>0) {
			//Load all services that are compatible
			Iterator allServices = SH.getAllServices().iterator();
			while(allServices.hasNext()) {
				Service service = (Service)allServices.next();
				if(SH.c(service.getInscode()).equalsIgnoreCase(sDepartmentOrgUID)) {
					authorizedServices.add(service.getCode().toLowerCase());
				}
			}
		}
		Iterator i = dataset.element("dataelements").elementIterator("dataelement");
		while(i.hasNext()){
			Hashtable uids = new Hashtable();
			Element dataelement = (Element)i.next();
			long uidcounter=0;
			for(int n=0;n<items.size();n++){
				String item = (String)items.elementAt(n);
				if(sDepartmentOrgUID.length()>0 && !authorizedServices.contains(item.split(";")[4].toLowerCase())) {
					continue;
				}
				if(ScreenHelper.checkString(dataset.attributeValue("newcase")).equals("1") && !Encounter.isNewCase(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1])){
					continue;
				}
				else if(ScreenHelper.checkString(dataset.attributeValue("newcase")).equals("0") && Encounter.isNewCase(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1])){
					continue;
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("minage")).length()>0){
					try{
						double minAge = Double.parseDouble(dataelement.attributeValue("minage"));
						long day = 24*3600*1000;
						double year = 365*day;
						Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
						Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
						if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year<minAge){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("maxage")).length()>0){
					try{
						double maxAge = Double.parseDouble(dataelement.attributeValue("maxage"));
						long day = 24*3600*1000;
						double year = 365*day;
						Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
						if(dateofbirth!=null && (begin.getTime()-dateofbirth.getTime())/year>=maxAge){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("minageinmonths")).length()>0){
					try{
						double minAge = Double.parseDouble(dataelement.attributeValue("minageinmonths"));
						long day = 24*3600*1000;
						double year = 365*day;
						Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
						if(dateofbirth!=null && (begin.getTime()-dateofbirth.getTime())*12/year<minAge){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("maxageinmonths")).length()>0){
					try{
						double maxAge = Double.parseDouble(dataelement.attributeValue("maxageinmonths"));
						long day = 24*3600*1000;
						double year = 365*day;
						Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
						if(dateofbirth!=null && (begin.getTime()-dateofbirth.getTime())*12/year>=maxAge){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("inperiod")).equalsIgnoreCase("1")){
					try{
						java.util.Date date = SH.parseDate(item.split(";")[8]);
						if(date.before(begin) || date.after(end)) {
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("gender")).length()>0){
					if(!inArray(item.split(";")[2].toLowerCase(),dataelement.attributeValue("gender").toLowerCase())){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("outcome")).length()>0){
					if(!inArray(item.split(";")[5].toLowerCase(),dataelement.attributeValue("outcome").toLowerCase())){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("origin")).length()>0){
					if(!inArray(item.split(";")[7].toLowerCase(),dataelement.attributeValue("origin").toLowerCase())){
						continue;
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("itemvaluemin")).length()>0){
					try {
						if(Double.parseDouble(item.split(";")[8])<Double.parseDouble(dataelement.attributeValue("itemvaluemin"))){
							continue;
						}
					}
					catch(Exception e) {
						e.printStackTrace();
					}
				}
				if(ScreenHelper.checkString(dataelement.attributeValue("itemvaluemax")).length()>0){
					try {
						if(Double.parseDouble(item.split(";")[8])>=Double.parseDouble(dataelement.attributeValue("itemvaluemax"))){
							continue;
						}
					}
					catch(Exception e) {
						e.printStackTrace();
					}
				}
				if(!bMortality || item.split(";")[5].startsWith("dead")){
					if(sEncounterType.length()==0 || ScreenHelper.checkString(item.split(";")[6]).equalsIgnoreCase(sEncounterType)){
						if(ScreenHelper.checkString(dataelement.attributeValue("itemvalue")).length()==0 || inArray(item.split(";")[8].toLowerCase(), dataelement.attributeValue("itemvalue").toLowerCase())){
							if(ScreenHelper.checkString(dataelement.attributeValue("itemtype")).length()==0 || inArray(item.split(";")[9].toLowerCase(), dataelement.attributeValue("itemtype").toLowerCase())){
								if(ScreenHelper.checkString(dataelement.attributeValue("outputtype")).equals("transactionItemValue")){
									String[] types=ScreenHelper.checkString(dataelement.attributeValue("outputid")).split(";");
									for(int tn=0;tn<types.length;tn++) {
										String type = types[tn];
										ItemVO tItem = MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), type);
										if(tItem==null || tItem.getValue()==null || tItem.getValue().length()==0){
											continue;
										}
										else{
											double value = 0;
											tItem.setValue(tItem.getValue().replaceAll(";", "{semicolon}"));
											String minval=ScreenHelper.checkString(dataelement.attributeValue("outputItemValueMin"));
											String maxval=ScreenHelper.checkString(dataelement.attributeValue("outputItemValueMax"));
											String matchval=ScreenHelper.checkString(dataelement.attributeValue("outputItemValue"));
											String matchvalin=ScreenHelper.checkString(dataelement.attributeValue("outputItemValueIn"));
											String matchvalcontains=ScreenHelper.checkString(dataelement.attributeValue("outputItemValueContains"));
											if(matchvalin.length()>0){
												try{
													if(!inArray(tItem.getValue(),matchvalin)){
														continue;
													}
												}
												catch(Exception e){
													continue;
												}
											}
											else if(matchvalcontains.length()>0){
												try{
													if(!tItem.getValue().contains(matchvalcontains)){
														continue;
													}
												}
												catch(Exception e){
													continue;
												}
											}
											else {
												if(matchval.length()==0){
													try{
														value=new Double(Double.parseDouble(tItem.getValue())).intValue();
													}
													catch(Exception e){
														e.printStackTrace();
													}
													if(value==0){
														continue;
													}
													if(minval.length()>0){
														try{
															if(value<Double.parseDouble(minval)){
																continue;
															}
														}
														catch(Exception e){
															continue;
														}
													}
													if(maxval.length()>0){
														try{
															if(value>Double.parseDouble(maxval)){
																continue;
															}
														}
														catch(Exception e){
															continue;
														}
													}
												}
												else if(!matchval.equalsIgnoreCase(tItem.getValue())){
													continue;
												}
											}
											if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).length()>0){
												//Evaluate conditions comparing to other items
												if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("equals;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[1]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value!=othervalue){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
												else if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("equalsorgreaterthan;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[1]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value<othervalue){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
												else if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("equalsorlessthan;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[1]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value>othervalue){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
												else if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("greaterthannotzero;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[1]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value<=othervalue || othervalue==0){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
												else if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("minusequals;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[2]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value-othervalue!=Double.parseDouble(dataelement.attributeValue("comparetoitem").split(";")[1])){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
											}
											if(ScreenHelper.checkString(dataelement.attributeValue("outputvalue")).equalsIgnoreCase("outputitemvalue")){
												value=Double.parseDouble(tItem.getValue());
											}
											else if(ScreenHelper.checkString(dataelement.attributeValue("value")).length()>0){
												value=Double.parseDouble(dataelement.attributeValue("value"));
											}
											else{
												value=1;
											}
											if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("patients")){
												uids.put(item.split(";")[0],value);
											}
											if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounterdate")){
												uids.put(item.split(";")[0]+"."+(item.split(";")[13]+"        ").substring(0,8),value);
											}
											if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("itemdate")){
												uids.put(item.split(";")[0]+"."+(item.split(";")[15]+"        ").substring(0,8),value);
											}
											else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounters")){
												uids.put(item.split(";")[1],value);
											}
											else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("transactions")){
												uids.put(item.split(";")[11],value);
											}
											else {
												uidcounter+=value;
												Debug.println("patient = "+item.split(";")[0]+" / uidcounter="+uidcounter);
											}
										}
									}
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("admissionDays")){
									try{
										java.util.Date begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
										if(begin.before(this.begin)){
											begin=this.begin;
										}
										java.util.Date end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[14]);
										if(end.after(this.end)){
											end=new java.util.Date(this.end.getTime()-1000);
										}
										uidcounter+= ScreenHelper.nightsBetween(begin,end);
									}
									catch(Exception e){
										e.printStackTrace();
									}
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("totalAdmissionDays")){
									try{
										java.util.Date begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
										java.util.Date end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[14]);
										if(end.after(this.end)){
											end=new java.util.Date(this.end.getTime()-1000);
										}
										uidcounter+= ScreenHelper.nightsBetween(begin,end);
									}
									catch(Exception e){
										e.printStackTrace();
									}
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("totalAdmissionDaysPlus")){
									try{
										java.util.Date begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[13]);
										java.util.Date end = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[14]);
										if(end.after(this.end)){
											end=new java.util.Date(this.end.getTime()-1000);
										}
										uidcounter+= ScreenHelper.nightsBetween(begin,end)+1;
									}
									catch(Exception e){
										e.printStackTrace();
									}
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("itemValue")){
									boolean bOk=true;
									Iterator iItems = dataelement.elementIterator("item");
									while(iItems.hasNext() && bOk){
										Element itemelement = (Element)iItems.next();
										if(SH.c(itemelement.attributeValue("nocount")).equalsIgnoreCase("1")){
											//Check if this element is present
											String iv = SH.c(itemelement.attributeValue("itemvalue"));
											String it = SH.c(itemelement.attributeValue("itemtype"));
											if(iv.startsWith("{notequals}")) {
												bOk=!MedwanQuery.getInstance().hasItem(it, iv.replaceAll("\\{notequals\\}",""),Integer.parseInt(item.split(";")[11]));
											}
											else {
												bOk=MedwanQuery.getInstance().hasItem(it, iv,Integer.parseInt(item.split(";")[11]));
											}
										}
									}
									if(bOk) {
										iItems = dataelement.elementIterator("item");
										while(iItems.hasNext()){
											Element itemelement = (Element)iItems.next();
											if(!SH.c(itemelement.attributeValue("nocount")).equalsIgnoreCase("1")){
												String sItemType=SH.c(itemelement.attributeValue("itemtype"));
												String itemValueId = SH.c(itemelement.attributeValue("valueid"));
												String value=MedwanQuery.getInstance().getItemValue(Integer.parseInt(item.split(";")[10]),Integer.parseInt(item.split(";")[11]), sItemType);
												String[] sItemValues=value.split(";");
												for(int z=0;z<sItemValues.length;z++) {
													if(itemValueId.length()>0 && itemValueId.equalsIgnoreCase(sItemValues[z].split("=")[0])){
														try {
															if(sItemValues[z].split("=").length>1) {
																uidcounter+=Integer.parseInt(sItemValues[z].split("=")[1]);
															}
															else {
																uidcounter++;
															}
														}
														catch(Exception e) {
															e.printStackTrace();
														}
													}
													else if(itemValueId.length()==0) {
														try {
															uidcounter+=Integer.parseInt(sItemValues[z]);
														}
														catch(Exception e) {
															uidcounter++;
															e.printStackTrace();
														}
													}
												}
											}
										}
									}
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("itemCount")){
									int nNeeded=0,nMaxItems=-99;
									if(ScreenHelper.checkString(dataelement.attributeValue("itemsneeded")).length()>0){
										nNeeded=Integer.parseInt(ScreenHelper.checkString(dataelement.attributeValue("itemsneeded")));
									}
									if(ScreenHelper.checkString(dataelement.attributeValue("maxitems")).length()>0){
										nMaxItems=Integer.parseInt(ScreenHelper.checkString(dataelement.attributeValue("maxitems")));
									}
									int nFound=0;
									Iterator iItems = dataelement.elementIterator("item");
									while(iItems.hasNext()){
										Element itemelement = (Element)iItems.next();
										String sItemType=SH.c(itemelement.attributeValue("itemtype"));
										String sItemValue=ScreenHelper.checkString(itemelement.attributeValue("itemvalue"));
										//Now we look for the existence of this item
										boolean bExists=false;
										if(ScreenHelper.checkString(itemelement.attributeValue("transactiontype")).length()>0) {
											if(SH.c(itemelement.attributeValue("singlematch")).equalsIgnoreCase("1")){
												bExists=MedwanQuery.getInstance().hasSingleItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"));
											}
											else {
												if(SH.c(itemelement.attributeValue("matchperiod")).equalsIgnoreCase("1")) {
													bExists=MedwanQuery.getInstance().hasItemPeriod(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"),begin,end);
												}
												else {
													bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"));
												}
											}
										}
										else {
											if(SH.c(itemelement.attributeValue("matchperiod")).equalsIgnoreCase("1")) {
												bExists=MedwanQuery.getInstance().hasItemPeriod(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,begin,end);
											}
											else if(SH.c(itemelement.attributeValue("sametransaction")).equalsIgnoreCase("1")) {
												for(int r=0;r<sItemType.split(";").length;r++) {
													bExists=false;
													String iv=sItemValue.split(";")[0];
													if(sItemValue.split(";").length>r) {
														iv=sItemValue.split(";")[r];
													}
													for(int q=0;q<iv.split("\\|").length && !bExists;q++) {
														if(iv.split("\\|")[q].startsWith("{notequals}")) {
															bExists=!MedwanQuery.getInstance().hasItem(sItemType.split(";")[r], iv.split("\\|")[q].replaceAll("\\{notequals\\}",""),Integer.parseInt(item.split(";")[11]));
														}
														else {
															bExists=MedwanQuery.getInstance().hasItem(sItemType.split(";")[r], iv.split("\\|")[q],Integer.parseInt(item.split(";")[11]));
														}
													}
													if(bExists && SH.c(itemelement.attributeValue("singlematch")).equalsIgnoreCase("1")) {
														break;
													}
													else if(!bExists  && !SH.c(itemelement.attributeValue("singlematch")).equalsIgnoreCase("1")) {
														break;
													}
												}
											}
											else {
												bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue);
											}
										}
										if(SH.c(itemelement.attributeValue("mandatory")).equalsIgnoreCase("1") && !bExists) {
											nFound=-1;
											break;
										}
										boolean bDoBreak=false;
										if(nMaxItems<0 && nNeeded==0 && !bExists){
											nFound=-1;
											bDoBreak=true;
										}
										else if(nNeeded==0 && bExists){
											nFound++;
										}
										else if(nNeeded>0 && bExists){
											nFound++;
											if(nFound>=nNeeded && !ScreenHelper.checkString(dataelement.attributeValue("countall")).equals("1")){
												bDoBreak=true;
											}
										}
										if(nMaxItems>=0 && nFound>nMaxItems) {
											nFound=-1;
											break;
										}
										if(bDoBreak) {
											break;
										}
									}
									if(nFound>=nNeeded){
										if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("patients")){
											uids.put(item.split(";")[0],nFound);
										}
										else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounters")){
											uids.put(item.split(";")[1],nFound);
										}
										else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounterdate")){
											uids.put(item.split(";")[0]+"."+item.split(";")[13],nFound);
										}
										else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("itemdate")){
											uids.put(item.split(";")[0]+"."+item.split(";")[15],nFound);
										}
										else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("transactions")){
											uids.put(item.split(";")[11],nFound);
										}
										else if(ScreenHelper.checkString(dataelement.attributeValue("countall")).equals("1")){
											uidcounter+=nFound;
										}
										else if(ScreenHelper.checkString(dataelement.attributeValue("countOutputValueItem")).length()>0){
											ItemVO tItem = MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("countOutputValueItem"));
											if(tItem==null || tItem.getValue()==null || tItem.getValue().length()==0){
												continue;
											}
											try {
												nFound=new Double(Double.parseDouble(tItem.getValue())).intValue();
											}
											catch(Exception r) {
												continue;
											}
											uidcounter+=nFound;
										}
										else{
											uidcounter++;
										}
									}
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("missing")).equalsIgnoreCase("1")){
									boolean bExists = false;
									Iterator iItems = dataelement.elementIterator("item");
									while(iItems.hasNext() && !bExists){
										Element missingItem = (Element)iItems.next();
										Vector vItems=MedwanQuery.getInstance().getItemsLike(MedwanQuery.getInstance().getServerId(), Integer.parseInt(item.split(";")[11]), missingItem.attributeValue("itemtype"));
										if(vItems.size()>0){									
											bExists=true;
											break;
										}
									}
									if(bExists){
										continue;
									}
									if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("patients")){
										uids.put(item.split(";")[0],1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounters")){
										uids.put(item.split(";")[1],1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounterdate")){
										uids.put(item.split(";")[0]+"."+(item.split(";")[13]+"        ").substring(0,8),1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("itemdate")){
										uids.put(item.split(";")[0]+"."+(item.split(";")[15]+"        ").substring(0,8),1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("transactions")){
										uids.put(item.split(";")[11],1);
									}
									uidcounter++;
								}
								else if(ScreenHelper.checkString(dataelement.attributeValue("combine")).equalsIgnoreCase("1")){
									boolean bOK = false;
									Iterator iItemGroups = dataelement.elementIterator("itemgroup");
									while(iItemGroups.hasNext()){
										bOK = false;
										Element itemGroup = (Element)iItemGroups.next();
										if(ScreenHelper.checkString(itemGroup.attributeValue("calculate")).equalsIgnoreCase("itemCount")){
											int nNeeded=0,nMaxItems=-99;
											if(ScreenHelper.checkString(itemGroup.attributeValue("itemsneeded")).length()>0){
												nNeeded=Integer.parseInt(ScreenHelper.checkString(itemGroup.attributeValue("itemsneeded")));
											}
											if(ScreenHelper.checkString(dataelement.attributeValue("maxitems")).length()>0){
												nMaxItems=Integer.parseInt(ScreenHelper.checkString(dataelement.attributeValue("maxitems")));
											}
											int nFound=0;
											Iterator iItems = itemGroup.elementIterator("item");
											while(iItems.hasNext()){
												Element itemelement = (Element)iItems.next();
												String sItemType=SH.c(itemelement.attributeValue("itemtype"));
												String sItemValue=ScreenHelper.checkString(itemelement.attributeValue("itemvalue"));
												//Now we look for the existence of this item
												boolean bExists=false;
												if(ScreenHelper.checkString(itemelement.attributeValue("transactiontype")).length()>0) {
													if(SH.c(itemelement.attributeValue("matchperiod")).equalsIgnoreCase("1")) {
														bExists=MedwanQuery.getInstance().hasItemPeriod(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"),begin,end);
													}
													else {
														bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"));
													}
												}
												else {
													if(SH.c(itemelement.attributeValue("matchperiod")).equalsIgnoreCase("1")) {
														bExists=MedwanQuery.getInstance().hasItemPeriod(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,begin,end);
													}
													else if(SH.c(itemelement.attributeValue("sametransaction")).equalsIgnoreCase("1")) {
														for(int r=0;r<sItemType.split(";").length;r++) {
															bExists=false;
															String iv=sItemValue.split(";")[0];
															if(sItemValue.split(";").length>r) {
																iv=sItemValue.split(";")[r];
															}
															for(int q=0;q<iv.split("\\|").length && !bExists;q++) {
																if(iv.split("\\|")[q].startsWith("{notequals}")) {
																	bExists=!MedwanQuery.getInstance().hasItem(sItemType.split(";")[r], iv.split("\\|")[q].replaceAll("\\{notequals\\}",""),Integer.parseInt(item.split(";")[11]));
																}
																else {
																	bExists=MedwanQuery.getInstance().hasItem(sItemType.split(";")[r], iv.split("\\|")[q],Integer.parseInt(item.split(";")[11]));
																}
															}
															if(bExists && SH.c(itemelement.attributeValue("singlematch")).equalsIgnoreCase("1")) {
																break;
															}
															else if(!bExists  && !SH.c(itemelement.attributeValue("singlematch")).equalsIgnoreCase("1")) {
																break;
															}
														}
													}
													else {
														bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue);
													}
												}
												if(SH.c(itemelement.attributeValue("mandatory")).equalsIgnoreCase("1") && !bExists) {
													nFound=-1;
													break;
												}
												boolean bDoBreak=false;
												if(nMaxItems<0 && nNeeded==0 && !bExists){
													nFound=-1;
													bDoBreak=true;
												}
												else if(nNeeded==0 && bExists){
													nFound++;
												}
												else if(nNeeded>0 && bExists){
													nFound++;
													if(nFound>=nNeeded && !ScreenHelper.checkString(dataelement.attributeValue("countall")).equals("1")){
														bDoBreak=true;
													}
												}
												if(nMaxItems>=0 && nFound>nMaxItems) {
													nFound=-1;
													break;
												}
												if(bDoBreak) {
													break;
												}
											}
										}
										else if(ScreenHelper.checkString(itemGroup.attributeValue("missing")).equalsIgnoreCase("1")){
											boolean bExists = false;
											Iterator iItems = dataelement.elementIterator("item");
											while(iItems.hasNext() && !bExists){
												Element missingItem = (Element)iItems.next();
												Vector vItems=MedwanQuery.getInstance().getItemsLike(MedwanQuery.getInstance().getServerId(), Integer.parseInt(item.split(";")[11]), missingItem.attributeValue("itemtype"));
												if(vItems.size()>0){									
													bExists=true;
													break;
												}
											}
											if(bExists){
												continue;
											}
										}
										if(!bOK) {
											break;
										}
									}
									if(!bOK){
										continue;
									}
									if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("patients")){
										uids.put(item.split(";")[0],1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounters")){
										uids.put(item.split(";")[1],1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounterdate")){
										uids.put(item.split(";")[0]+"."+(item.split(";")[13]+"        ").substring(0,8),1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("itemdate")){
										uids.put(item.split(";")[0]+"."+(item.split(";")[15]+"        ").substring(0,8),1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("transactions")){
										uids.put(item.split(";")[11],1);
									}
									uidcounter++;
								}
								else{
									if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("patients")){
										uids.put(item.split(";")[0],1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounters")){
										uids.put(item.split(";")[1],1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounterdate")){
										uids.put(item.split(";")[0]+"."+(item.split(";")[13]+"        ").substring(0,8),1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("itemdate")){
										uids.put(item.split(";")[0]+"."+(item.split(";")[15]+"        ").substring(0,8),1);
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("transactions")){
										uids.put(item.split(";")[11],1);
									}
									uidcounter++;
								}
							}
						}
					}
				}
			}
			if(ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("patients") || 
			   ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("encounters") ||
			   ScreenHelper.checkString(dataelement.attributeValue("unique")).equalsIgnoreCase("transactions")){
				if(ScreenHelper.checkString(dataelement.attributeValue("countall")).equals("1")){
					uidcounter=0;
					Enumeration eUids = uids.keys();
					while(eUids.hasMoreElements()){
						String key = (String)eUids.nextElement();
						uidcounter+=(Integer)uids.get(key);
					}
				}
				else{
					uidcounter=uids.size();
				}
			}
			if(MedwanQuery.getInstance().getConfigInt("cleanDHIS2DataSets",0)==0 && uidcounter>0){
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid,uidcounter+"",""));
			}
			else if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1){
				dataValueSet.getDataValues().add(new DataValue(dataelement.attributeValue("uid"),dataelement.attributeValue("categoryoptionuid")!=null?dataelement.attributeValue("categoryoptionuid"):categoryOptionUid," ",""));
			}
		}
	}
	
	private int getBedCountForDepartment(String serviceUid){
		int bedcount=0;
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select sum(totalbeds) as total from services where inscode=(select inscode from services where serviceid=?)");
			ps.setString(1, serviceUid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				bedcount=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return bedcount;
	}
	
	private int getAdmittedAtStartPeriod(String serviceUid,java.util.Date start){
		int count=0;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select count(*) total from oc_encounters e,oc_encounter_services s where e.oc_encounter_objectid=s.oc_encounter_objectid and e.oc_encounter_type='admission' and s.oc_encounter_servicebegindate<? and (s.oc_encounter_serviceenddate is null or s.oc_encounter_serviceenddate>?) and s.oc_encounter_serviceuid in (select serviceid from servicesview where inscode=(select inscode from servicesview where serviceid=?))");
			ps.setTimestamp(1, SH.getSQLTimestamp(start));
			ps.setTimestamp(2, SH.getSQLTimestamp(start));
			ps.setString(3, serviceUid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				count=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return count;
	}
	
	private void exportEncounterDatasetSeriesRecords(Vector items,Element dataset,String dataelementuid){
		int uidcounter=0;
		boolean bMortality = ScreenHelper.checkString(dataset.attributeValue("mortality")).equalsIgnoreCase("true");
		String sEncounterType = ScreenHelper.checkString(dataset.attributeValue("encountertype"));
		String sOutcome = ScreenHelper.checkString(dataset.attributeValue("outcome")); 
		String sOrigin = ScreenHelper.checkString(dataset.attributeValue("origin")); 
		String sDepartmentOrgUID = ScreenHelper.checkString(dataset.attributeValue("departmentorguid"));
		HashSet authorizedServices = new HashSet();
		if(sDepartmentOrgUID.length()>0) {
			//Load all services that are compatible
			Iterator allServices = SH.getAllServices().iterator();
			while(allServices.hasNext()) {
				Service service = (Service)allServices.next();
				if(SH.c(service.getInscode()).equalsIgnoreCase(sDepartmentOrgUID)) {
					authorizedServices.add(service.getCode().toLowerCase());
				}
			}
		}
		for(int n=0;n<items.size();n++){
			String item = (String)items.elementAt(n);
			if(sDepartmentOrgUID.length()>0 && !authorizedServices.contains(item.split(";")[4].toLowerCase())) {
				continue;
			}
			if(ScreenHelper.checkString(dataset.attributeValue("newcase")).equals("1") && !Encounter.isNewCase(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1])){
				continue;
			}
			else if(ScreenHelper.checkString(dataset.attributeValue("newcase")).equals("0") && Encounter.isNewCase(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1])){
				continue;
			}
			if(sOutcome.length()>0 && !inArray(item.split(";")[5].toLowerCase(), sOutcome.toLowerCase())){
				continue;
			}
			if(sOrigin.length()>0 && !inArray(item.split(";")[7].toLowerCase(), sOrigin.toLowerCase())){
				continue;
			}
			if(!bMortality || item.split(";")[5].startsWith("dead")){
				if(sEncounterType.length()==0 || ScreenHelper.checkString(item.split(";")[6]).equalsIgnoreCase(sEncounterType)){
					Iterator i = dataset.element("dataelements").elementIterator("dataelement");
					while(i.hasNext()){
						Element dataelement = (Element)i.next();
						if(ScreenHelper.checkString(dataelement.attributeValue("minage")).length()>0){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								Date begindate = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								double minAge = Double.parseDouble(dataelement.attributeValue("minage"));
								if(dateofbirth==null || (begindate.getTime()-dateofbirth.getTime())/year<minAge){
									continue;
								}
							}
							catch(Exception e){
								continue;
							}
						}
						if(ScreenHelper.checkString(dataelement.attributeValue("maxage")).length()>0){
							long day = 24*3600*1000;
							double year = 365*day;
							try{
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								double maxAge = Double.parseDouble(dataelement.attributeValue("maxage"));
								if(dateofbirth==null || (begin.getTime()-dateofbirth.getTime())/year>=maxAge){
									continue;
								}
							}
							catch(Exception e){
								continue;
							}
						}
						if(ScreenHelper.checkString(dataelement.attributeValue("minageinmonths")).length()>0){
							try{
								double minAge = Double.parseDouble(dataelement.attributeValue("minageinmonths"));
								long day = 24*3600*1000;
								double year = 365*day;
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								if(dateofbirth!=null && (begin.getTime()-dateofbirth.getTime())*12/year<minAge){
									continue;
								}
							}
							catch(Exception e){
								continue;
							}
						}
						if(ScreenHelper.checkString(dataelement.attributeValue("maxageinmonths")).length()>0){
							try{
								double maxAge = Double.parseDouble(dataelement.attributeValue("maxageinmonths"));
								long day = 24*3600*1000;
								double year = 365*day;
								Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
								if(dateofbirth!=null && (begin.getTime()-dateofbirth.getTime())*12/year>=maxAge){
									continue;
								}
							}
							catch(Exception e){
								continue;
							}
						}
						if(SH.c(dataelement.attributeValue("hasnatreg")).equalsIgnoreCase("1") && item.split(";")[13].length()==0) {
							continue;
						}
						else if(SH.c(dataelement.attributeValue("hasnatreg")).equalsIgnoreCase("0") && item.split(";")[13].length()>0) {
							continue;
						}
						if(ScreenHelper.checkString(dataelement.attributeValue("gender")).length()>0){
							if(!inArray(item.split(";")[2].toLowerCase(),dataelement.attributeValue("gender").toLowerCase())){
								continue;
							}
						}
						if(ScreenHelper.checkString(dataelement.attributeValue("incoming")).equals("1")){
							try{
								java.util.Date begin = begin = new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[8]);
								if(begin.before(this.begin) || begin.after(this.end)){
									continue;
								}
							}
							catch (Exception e){
								e.printStackTrace();
							}
						}
						if(ScreenHelper.checkString(dataelement.attributeValue("outgoing")).equals("1")){
							try{
								java.util.Date end =  new SimpleDateFormat("yyyyMMddHHmm").parse(item.split(";")[9]);
								if(end.before(this.begin) || end.after(this.end)){
									continue;
								}
							}
							catch (Exception e){
								e.printStackTrace();
							}
						}
						if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("itemCount")){
							int nNeeded=0,nMaxItems=-99;
							if(ScreenHelper.checkString(dataelement.attributeValue("itemsneeded")).length()>0){
								nNeeded=Integer.parseInt(ScreenHelper.checkString(dataelement.attributeValue("itemsneeded")));
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("maxitems")).length()>0){
								nMaxItems=Integer.parseInt(ScreenHelper.checkString(dataelement.attributeValue("maxitems")));
							}
							int nFound=0;
							Iterator iItems = dataelement.elementIterator("item");
							while(iItems.hasNext()){
								Element itemelement = (Element)iItems.next();
								String sItemType=SH.c(itemelement.attributeValue("itemtype"));
								String sItemValue=ScreenHelper.checkString(itemelement.attributeValue("itemvalue"));
								//Now we look for the existence of this item
								boolean bExists=false;
								if(ScreenHelper.checkString(itemelement.attributeValue("transactiontype")).length()>0) {
									bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"));
								}
								else {
									bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue);
								}
								if(SH.c(itemelement.attributeValue("mandatory")).equalsIgnoreCase("1") && !bExists) {
									nFound=-1;
									break;
								}
								boolean bDoBreak=false;
								if(nMaxItems<0 && nNeeded==0 && !bExists){
									nFound=-1;
									bDoBreak=true;
								}
								else if(nNeeded==0 && bExists){
									nFound++;
								}
								else if(nNeeded>0 && bExists){
									nFound++;
									if(nFound>=nNeeded && !ScreenHelper.checkString(dataelement.attributeValue("countall")).equals("1")){
										bDoBreak=true;
									}
								}
								if(nMaxItems>=0 && nFound>nMaxItems) {
									nFound=-1;
									break;
								}
								if(bDoBreak) {
									break;
								}
							}
							if(nFound<nNeeded){
								continue;
							}
						}
						if(dataelement.attributeValue("uid").equals(dataelementuid)){
							patientrecords.add(item.split(";")[0]);
						}
					}
				}
			}
		}
	}
	
	private void exportTechnicalActivityDatasetSeriesRecords(Vector items,Element dataset,String dataelementuid){
		int uidcounter=0;
		boolean bMortality = ScreenHelper.checkString(dataset.attributeValue("mortality")).equalsIgnoreCase("true");
		String sEncounterType = ScreenHelper.checkString(dataset.attributeValue("encountertype"));
		String sDepartmentOrgUID = ScreenHelper.checkString(dataset.attributeValue("departmentorguid"));
		HashSet authorizedServices = new HashSet();
		if(sDepartmentOrgUID.length()>0) {
			//Load all services that are compatible
			Iterator allServices = SH.getAllServices().iterator();
			while(allServices.hasNext()) {
				Service service = (Service)allServices.next();
				if(SH.c(service.getInscode()).equalsIgnoreCase(sDepartmentOrgUID)) {
					authorizedServices.add(service.getCode().toLowerCase());
				}
			}
		}
		for(int n=0;n<items.size();n++){
			String item = (String)items.elementAt(n);
			if(sDepartmentOrgUID.length()>0 && !authorizedServices.contains(item.split(";")[4].toLowerCase())) {
				continue;
			}
			if(!bMortality || item.split(";")[5].startsWith("dead")){
				if(sEncounterType.length()==0 || ScreenHelper.checkString(item.split(";")[6]).equalsIgnoreCase(sEncounterType)){
					Iterator i = dataset.element("dataelements").elementIterator("dataelement");
					while(i.hasNext()){
						Element dataelement = (Element)i.next();
						if(dataelement.attributeValue("uid").equals(dataelementuid)){
							if(!inArray(item.split(";")[8].toLowerCase(), dataelement.attributeValue("code").toLowerCase())){
								continue;
							}
							patientrecords.add(item.split(";")[0]);
						}
					}
				}
			}
		}
	}
	
	private void exportLabDatasetSeriesRecords(Vector items,Element dataset,String dataelementuid){
		int uidcounter=0;
		for(int n=0;n<items.size();n++){
			String item = (String)items.elementAt(n);
			Iterator i = dataset.element("dataelements").elementIterator("dataelement");
			while(i.hasNext()){
				Element dataelement = (Element)i.next();
				if(dataelement.attributeValue("uid").equals(dataelementuid)){
					if(SH.c(dataelement.attributeValue("code")).length()>0 && !inArray(item.split(";")[3].toLowerCase(), dataelement.attributeValue("code").toLowerCase())){
						continue;
					}
					if(SH.c(dataelement.attributeValue("itemvalue")).length()>0  && !inArray(item.split(";")[8].toLowerCase(), dataelement.attributeValue("itemvalue").toLowerCase())) {
						continue;
					}
					if(SH.c(dataelement.attributeValue("min")).length()>0) {
						try {
							if(Double.parseDouble(item.split(";")[6])<Double.parseDouble(dataelement.attributeValue("min"))) {
								continue;
							}
						}
						catch(Exception min) {
							continue;
						}
					}
					if(SH.c(dataelement.attributeValue("max")).length()>0) {
						try {
							if(Double.parseDouble(item.split(";")[6])>Double.parseDouble(dataelement.attributeValue("max"))) {
								continue;
							}
						}
						catch(Exception min) {
							continue;
						}
					}
					if(SH.c(dataelement.attributeValue("itemcomment")).length()>0){
						String itemComment = dataelement.attributeValue("itemcomment").toLowerCase();
						String s6=item.split(";")[6];
						String s9=item.split(";").length<=9?"":item.split(";")[9];
						if(itemComment.startsWith("{contains}")) {
							if(!(s6+","+s9).toLowerCase().contains(itemComment.replaceAll("\\{contains\\}", ""))) {
								continue;
							}
						}
						else if(!itemComment.equalsIgnoreCase(s6.toLowerCase()) && !itemComment.equalsIgnoreCase(s9.toLowerCase())) {
							continue;
						}
					}
					patientrecords.add(item.split(";")[0]);
				}
			}
		}
	}
	
	private void exportPluginDatasetSeriesRecords(Vector items,Element dataset,String dataelementuid){
		int uidcounter=0;
		for(int n=0;n<items.size();n++){
			String item = (String)items.elementAt(n);
			Iterator i = dataset.element("dataelements").elementIterator("dataelement");
			while(i.hasNext()){
				Element dataelement = (Element)i.next();
				if(dataelement.attributeValue("uid").equals(dataelementuid)){
					if(SH.c(dataelement.attributeValue("itemvalue")).length()==0 || inArray(item.split(";")[3].toUpperCase(),dataelement.attributeValue("itemvalue").toUpperCase())) {
						SH.syslog("Adding patient record "+item.split(";")[0]);
						patientrecords.add(item.split(";")[0]);
					}
				}
			}
		}
		SH.syslog("item size 4 = "+patientrecords.size());
	}
	
	private void exportItemDatasetSeriesRecords(Vector items,Element dataset,String dataelementuid){
		int uidcounter=0;
		boolean bMortality = ScreenHelper.checkString(dataset.attributeValue("mortality")).equalsIgnoreCase("true");
		String sEncounterType = ScreenHelper.checkString(dataset.attributeValue("encountertype"));
		String sDepartmentOrgUID = ScreenHelper.checkString(dataset.attributeValue("departmentorguid"));
		HashSet authorizedServices = new HashSet();
		if(sDepartmentOrgUID.length()>0) {
			//Load all services that are compatible
			Iterator allServices = SH.getAllServices().iterator();
			while(allServices.hasNext()) {
				Service service = (Service)allServices.next();
				if(SH.c(service.getInscode()).equalsIgnoreCase(sDepartmentOrgUID)) {
					authorizedServices.add(service.getCode().toLowerCase());
				}
			}
		}
		for(int n=0;n<items.size();n++){
			String item = (String)items.elementAt(n);
			if(sDepartmentOrgUID.length()>0 && !authorizedServices.contains(item.split(";")[4].toLowerCase())) {
				continue;
			}
			if(ScreenHelper.checkString(dataset.attributeValue("newcase")).equals("1") && !Encounter.isNewCase(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1])){
				continue;
			}
			else if(ScreenHelper.checkString(dataset.attributeValue("newcase")).equals("0") && Encounter.isNewCase(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1])){
				continue;
			}
			if(!bMortality || item.split(";")[5].startsWith("dead")){
				if(sEncounterType.length()==0 || ScreenHelper.checkString(item.split(";")[6]).equalsIgnoreCase(sEncounterType)){
					Iterator i = dataset.element("dataelements").elementIterator("dataelement");
					while(i.hasNext()){
						Element dataelement = (Element)i.next();
						if(dataelement.attributeValue("uid").equals(dataelementuid)){
							if(ScreenHelper.checkString(dataelement.attributeValue("minage")).length()>0){
								try{
									double minAge = Double.parseDouble(dataelement.attributeValue("minage"));
									long day = 24*3600*1000;
									double year = 365*day;
									Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
									Date begindate = ScreenHelper.parseDate(item.split(";")[13],"yyyyMMddHHmm");
									if(dateofbirth!=null && (begindate.getTime()-dateofbirth.getTime())/year<minAge){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("maxage")).length()>0){
								try{
									double maxAge = Double.parseDouble(dataelement.attributeValue("maxage"));
									long day = 24*3600*1000;
									double year = 365*day;
									Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
									if(dateofbirth!=null && (begin.getTime()-dateofbirth.getTime())/year>=maxAge){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("minageinmonths")).length()>0){
								try{
									double minAge = Double.parseDouble(dataelement.attributeValue("minageinmonths"));
									long day = 24*3600*1000;
									double year = 365*day;
									Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
									if(dateofbirth!=null && (begin.getTime()-dateofbirth.getTime())*12/year<minAge){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("maxageinmonths")).length()>0){
								try{
									double maxAge = Double.parseDouble(dataelement.attributeValue("maxageinmonths"));
									long day = 24*3600*1000;
									double year = 365*day;
									Date dateofbirth = ScreenHelper.parseDate(item.split(";")[3]);
									if(dateofbirth!=null && (begin.getTime()-dateofbirth.getTime())*12/year>=maxAge){
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("inperiod")).equalsIgnoreCase("1")){
								try{
									java.util.Date date = SH.parseDate(item.split(";")[8]);
									if(date.before(begin) || date.after(end)) {
										continue;
									}
								}
								catch(Exception e){
									continue;
								}
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("gender")).length()>0){
								if(!inArray(item.split(";")[2].toLowerCase(),dataelement.attributeValue("gender").toLowerCase())){
									continue;
								}
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("itemtype")).length()>0 && !inArray(item.split(";")[9].toLowerCase(), dataelement.attributeValue("itemtype").toLowerCase())){
								continue;
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("outcome")).length()>0 && !inArray(item.split(";")[5].toLowerCase(), dataelement.attributeValue("outcome").toLowerCase())){
								continue;
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("origin")).length()>0 && !inArray(item.split(";")[7].toLowerCase(), dataelement.attributeValue("origin").toLowerCase())){
								continue;
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("itemvalue")).length()>0 && !inArray(item.split(";")[8].toLowerCase(), dataelement.attributeValue("itemvalue").toLowerCase())){
								continue;
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("itemvaluemin")).length()>0){
								try {
									if(Double.parseDouble(item.split(";")[8])<Double.parseDouble(dataelement.attributeValue("itemvaluemin"))){
										continue;
									}
								}
								catch(Exception e) {
									e.printStackTrace();
								}
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("itemvaluemax")).length()>0){
								try {
									if(Double.parseDouble(item.split(";")[8])>=Double.parseDouble(dataelement.attributeValue("itemvaluemax"))){
										continue;
									}
								}
								catch(Exception e) {
									e.printStackTrace();
								}
							}
							if(ScreenHelper.checkString(dataelement.attributeValue("outputtype")).equals("transactionItemValue")){
								String[] types=ScreenHelper.checkString(dataelement.attributeValue("outputid")).split(";");
								boolean bOk=false;
								for(int tn=0;tn<types.length && !bOk;tn++) {
									String type = types[tn];
									ItemVO tItem = MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), type);
									if(tItem==null || tItem.getValue()==null || tItem.getValue().length()==0){
										continue;
									}
									else {
										tItem.setValue(tItem.getValue().replaceAll(";", "{semicolon}"));
									}
									if(ScreenHelper.checkString(dataelement.attributeValue("outputItemValue")).length()>0){
										String matchval=ScreenHelper.checkString(dataelement.attributeValue("outputItemValue")).replaceAll("\\{sem\\}", ";");
										if(matchval.contains("{like}")) {
											if(!tItem.getValue().contains(matchval.replaceAll("\\{like\\}", ""))){
												continue;
											}
										}
										else if(!tItem.getValue().equalsIgnoreCase(matchval)){
											continue;
										}
									}
									else if(ScreenHelper.checkString(dataelement.attributeValue("outputItemValueIn")).length()>0){
										String matchvalin=ScreenHelper.checkString(dataelement.attributeValue("outputItemValueIn"));
										if(matchvalin.length()>0){
											try{
												if(!inArray(tItem.getValue(),matchvalin)){
													continue;
												}
											}
											catch(Exception e){
												continue;
											}
										}
									}
									else{
										double value = 0;
										if(ScreenHelper.checkString(dataelement.attributeValue("value")).length()>0){
											value=new Double(Double.parseDouble(ScreenHelper.checkString(dataelement.attributeValue("value")))).intValue();
										}
										else{
											try{
												value=new Double(Double.parseDouble(tItem.getValue())).intValue();
											}
											catch(Exception e){
												e.printStackTrace();
											}
											if(value==0){
												continue;
											}
											String minval=ScreenHelper.checkString(dataelement.attributeValue("outputItemValueMin"));
											String maxval=ScreenHelper.checkString(dataelement.attributeValue("outputItemValueMax"));
											String matchval=ScreenHelper.checkString(dataelement.attributeValue("outputItemValue"));
											if(minval.length()>0){
												try{
													if(value<Double.parseDouble(minval)){
														continue;
													}
												}
												catch(Exception e){
													continue;
												}
											}
											if(maxval.length()>0){
												try{
													if(value>Double.parseDouble(maxval)){
														continue;
													}
												}
												catch(Exception e){
													continue;
												}
											}
											if(matchval.length()>0){
												try{
													if(value!=Double.parseDouble(matchval)){
														continue;
													}
												}
												catch(Exception e){
													continue;
												}
											}
											if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).length()>0){
												//Evaluate conditions comparing to other items
												if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("equals;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[1]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value!=othervalue){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
												else if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("equalsorgreaterthan;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[1]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value<othervalue){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
												else if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("equalsorlessthan;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[1]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value>othervalue){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
												else if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("greaterthannotzero;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[1]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value<=othervalue || othervalue==0){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
												else if(ScreenHelper.checkString(dataelement.attributeValue("comparetoitem")).startsWith("minusequals;")){
													try{
														value=Double.parseDouble(tItem.getValue());
														ItemVO otheritem =MedwanQuery.getInstance().getItem(Integer.parseInt(item.split(";")[10]), Integer.parseInt(item.split(";")[11]), dataelement.attributeValue("comparetoitem").split(";")[2]);
														if(otheritem!=null){
															double othervalue=Double.parseDouble(otheritem.getValue());
															if(value-othervalue!=Double.parseDouble(dataelement.attributeValue("comparetoitem").split(";")[1])){
																continue;
															}
														}
														else{
															continue;
														}
													}
													catch(Exception r){
														r.printStackTrace();
														continue;
													}
												}
											}
										}
									}
									bOk=true;
								}
								if(!bOk) {
									continue;
								}
							}
							else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("itemvalue")){
								boolean bOk=true;
								Iterator iItems = dataelement.elementIterator("item");
								while(iItems.hasNext() && bOk){
									Element itemelement = (Element)iItems.next();
									if(SH.c(itemelement.attributeValue("nocount")).equalsIgnoreCase("1")){
										//Check if this element is present
										String iv = SH.c(itemelement.attributeValue("itemvalue"));
										String it = SH.c(itemelement.attributeValue("itemtype"));
										if(iv.startsWith("{notequals}")) {
											bOk=!MedwanQuery.getInstance().hasItem(it, iv.replaceAll("\\{notequals\\}",""),Integer.parseInt(item.split(";")[11]));
										}
										else {
											bOk=MedwanQuery.getInstance().hasItem(it, iv,Integer.parseInt(item.split(";")[11]));
										}
									}
								}
								if(bOk) {
									iItems = dataelement.elementIterator("item");
									while(iItems.hasNext()){
										Element itemelement = (Element)iItems.next();
										if(!SH.c(itemelement.attributeValue("nocount")).equalsIgnoreCase("1")){
											String sItemType=SH.c(itemelement.attributeValue("itemtype"));
											String itemValueId = SH.c(itemelement.attributeValue("valueid"));
											String value=MedwanQuery.getInstance().getItemValue(Integer.parseInt(item.split(";")[10]),Integer.parseInt(item.split(";")[11]), sItemType);
											String[] sItemValues=value.split(";");
											bOk=false;
											for(int z=0;z<sItemValues.length;z++) {
												if(itemValueId.length()>0 && itemValueId.equalsIgnoreCase(sItemValues[z].split("=")[0])){
													try {
														if(sItemValues[z].split("=").length>1) {
															if(Integer.parseInt(sItemValues[z].split("=")[1])>0) {
																bOk=true;
																break;
															}
														}
													}
													catch(Exception e) {
														e.printStackTrace();
													}
												}
												else if(itemValueId.length()==0) {
													try {
														if(Integer.parseInt(sItemValues[z])>0) {
															bOk=true;
															break;
														};
													}
													catch(Exception e) {
														uidcounter++;
														e.printStackTrace();
													}
												}
											}
											if(bOk) {
												break;
											}
										}
									}
									if(!bOk) {
										continue;
									}
								}
							}
							else if(ScreenHelper.checkString(dataelement.attributeValue("calculate")).equalsIgnoreCase("itemCount")){
								int nNeeded=0,nMaxItems=-99;
								if(ScreenHelper.checkString(dataelement.attributeValue("itemsneeded")).length()>0){
									nNeeded=Integer.parseInt(ScreenHelper.checkString(dataelement.attributeValue("itemsneeded")));
								}
								if(ScreenHelper.checkString(dataelement.attributeValue("maxitems")).length()>0){
									nMaxItems=Integer.parseInt(ScreenHelper.checkString(dataelement.attributeValue("maxitems")));
								}
								int nFound=0;
								Iterator iItems = dataelement.elementIterator("item");
								while(iItems.hasNext()){
									Element itemelement = (Element)iItems.next();
									String sItemType=SH.c(itemelement.attributeValue("itemtype"));
									String sItemValue=ScreenHelper.checkString(itemelement.attributeValue("itemvalue"));
									//Now we look for the existence of this item
									boolean bExists=false;
									if(ScreenHelper.checkString(itemelement.attributeValue("transactiontype")).length()>0) {
										if(SH.c(itemelement.attributeValue("singlematch")).equalsIgnoreCase("1")){
											bExists=MedwanQuery.getInstance().hasSingleItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"));
										}
										else {
											if(SH.c(itemelement.attributeValue("matchperiod")).equalsIgnoreCase("1")) {
												bExists=MedwanQuery.getInstance().hasItemPeriod(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"),begin,end);
											}
											else {
												bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,itemelement.attributeValue("transactiontype"));
											}
										}
									}
									else {
										if(SH.c(itemelement.attributeValue("matchperiod")).equalsIgnoreCase("1")) {
											bExists=MedwanQuery.getInstance().hasItemPeriod(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue,begin,end);
										}
										else if(SH.c(itemelement.attributeValue("sametransaction")).equalsIgnoreCase("1")) {
											for(int r=0;r<sItemType.split(";").length;r++) {
												bExists=false;
												String iv=sItemValue.split(";")[0];
												if(sItemValue.split(";").length>r) {
													iv=sItemValue.split(";")[r];
												}
												for(int q=0;q<iv.split("\\|").length && !bExists;q++) {
													if(iv.split("\\|")[q].startsWith("{notequals}")) {
														bExists=!MedwanQuery.getInstance().hasItem(sItemType.split(";")[r], iv.split("\\|")[q].replaceAll("\\{notequals\\}",""),Integer.parseInt(item.split(";")[11]));
													}
													else {
														bExists=MedwanQuery.getInstance().hasItem(sItemType.split(";")[r], iv.split("\\|")[q],Integer.parseInt(item.split(";")[11]));
													}
												}
												if(bExists && SH.c(itemelement.attributeValue("singlematch")).equalsIgnoreCase("1")) {
													break;
												}
												else if(!bExists  && !SH.c(itemelement.attributeValue("singlematch")).equalsIgnoreCase("1")) {
													break;
												}
											}
										}
										else {
											bExists=MedwanQuery.getInstance().hasItem(MedwanQuery.getInstance().getConfigString("serverId")+"."+item.split(";")[1], sItemType, sItemValue);
										}
									}
									if(SH.c(itemelement.attributeValue("mandatory")).equalsIgnoreCase("1") && !bExists) {
										nFound=-1;
										break;
									}
									boolean bDoBreak=false;
									if(nMaxItems<0 && nNeeded==0 && !bExists){
										nFound=-1;
										bDoBreak=true;
									}
									else if(nNeeded==0 && bExists){
										nFound++;
									}
									else if(nNeeded>0 && bExists){
										nFound++;
										if(nFound>=nNeeded && !ScreenHelper.checkString(dataelement.attributeValue("countall")).equals("1")){
											bDoBreak=true;
										}
									}
									if(nMaxItems>=0 && nFound>nMaxItems) {
										nFound=-1;
										break;
									}
									if(bDoBreak) {
										break;
									}
								}
								if(nFound<nNeeded){
									continue;
								}
							}
							else if(ScreenHelper.checkString(dataelement.attributeValue("missing")).equalsIgnoreCase("1")){
								boolean bExists = false;
								Iterator iItems = dataelement.elementIterator("item");
								while(iItems.hasNext() && !bExists){
									Element missingItem = (Element)iItems.next();
									Vector vItems=MedwanQuery.getInstance().getItemsLike(MedwanQuery.getInstance().getServerId(), Integer.parseInt(item.split(";")[11]), missingItem.attributeValue("itemtype"));
									if(vItems.size()>0){									
										bExists=true;
										break;
									}
								}
								if(bExists){
									continue;
								}
							}
							patientrecords.add(item.split(";")[0]);
						}
					}
				}
			}
		}
	}
	
	private void exportDiagnosisDatasetSeries(Vector items,Element dataset,String attributeOptionComboUid,String categoryOptionUid, DataValueSet dataValueSet){
		//Set diagnosis specific attributes
		//We already have the attributeOptionCombo uid and categoryOptionCombo uid
		//We only have to calculate the values now, based on the extra attributes
		//Now we must also match the code of each diagnosis on a dataelement code from the dataset
		Hashtable targetcodes = new Hashtable();
		Hashtable targetflags = new Hashtable();
		Hashtable uidcounters = new Hashtable();
		Iterator i = dataset.element("dataelements").elementIterator("dataelement");
		while(i.hasNext()){
			Element dataelement = (Element)i.next();
			for(int n=0;n<dataelement.attributeValue("code").toLowerCase().split(",").length;n++){
				targetcodes.put(dataelement.attributeValue("code").toLowerCase().split(",")[n], dataelement.attributeValue("uid"));
				if(SH.c(dataelement.attributeValue("flags")).length()>0) {
					targetflags.put(dataelement.attributeValue("uid"),dataelement.attributeValue("flags"));
				}
			}
			if(MedwanQuery.getInstance().getConfigInt("sendFullDHIS2DataSets",0)==1){
				uidcounters.put(dataelement.attributeValue("uid"), new Double(0));
			}
		}
		boolean bMortality = ScreenHelper.checkString(dataset.attributeValue("mortality")).equalsIgnoreCase("true");
		boolean bNewcase = ScreenHelper.checkString(dataset.attributeValue("newcase")).equalsIgnoreCase("true");
		String sTransaction = ScreenHelper.checkString(dataset.attributeValue("transaction"));
		String sEncounterType = ScreenHelper.checkString(dataset.attributeValue("encountertype"));
		String sDepartmentOrgUID = ScreenHelper.checkString(dataset.attributeValue("departmentorguid"));
		String sItemTypes = ScreenHelper.checkString(dataset.attributeValue("itemtype"));
		String sItemValues = ScreenHelper.checkString(dataset.attributeValue("itemvalue"));
		HashSet authorizedServices = new HashSet();
		if(sDepartmentOrgUID.length()>0) {
			//Load all services that are compatible
			Iterator allServices = SH.getAllServices().iterator();
			while(allServices.hasNext()) {
				Service service = (Service)allServices.next();
				if(SH.c(service.getInscode()).equalsIgnoreCase(sDepartmentOrgUID)) {
					authorizedServices.add(service.getCode().toLowerCase());
				}
			}
		}

		HashSet encounterdiagnoses = new HashSet();
		HashSet patientdiagnoses = new HashSet();

		//We must calculate the total diagnosis weights of all diagnoses
		String classification = ScreenHelper.checkString(dataset.attributeValue("classification")).toLowerCase();
		Hashtable encounterbod = new Hashtable();
		for(int n=0;n<items.size();n++){
			String item = (String)items.elementAt(n);

			if(sDepartmentOrgUID.length()>0 && !authorizedServices.contains(item.split(";")[6].toLowerCase())) {
				continue;
			}
			if(classification==null || classification.equalsIgnoreCase(item.split(";")[4])){
				if(encounterdiagnoses.contains(item.split(";")[1]+"."+item.split(";")[5])){
					continue;
				}
				else{
					encounterdiagnoses.add(item.split(";")[1]+"."+item.split(";")[5]);
				}
				if(!bMortality || item.split(";")[8].startsWith("dead")){
					if(bMortality){
						if(patientdiagnoses.contains(item.split(";")[0]+"."+item.split(";")[5])){
							continue;
						}
						else{
							patientdiagnoses.add(item.split(";")[0]+"."+item.split(";")[5]);
						}
					}
					if(!bNewcase || item.split(";")[9].equalsIgnoreCase("1")){
						if(sEncounterType.length()==0 || ScreenHelper.checkString(item.split(";")[11]).equalsIgnoreCase(sEncounterType)){
							if(sTransaction.length()==0 || MedwanQuery.getInstance().getTransactionType(ScreenHelper.checkString(item.split(";")[12])).equalsIgnoreCase(sTransaction)){
								if(encounterbod.get(item.split(";")[1])==null){
									encounterbod.put(item.split(";")[1], Integer.parseInt(item.split(";")[10]));
								}
								else{
									encounterbod.put(item.split(";")[1],((Integer)encounterbod.get(item.split(";")[1]))+Integer.parseInt(item.split(";")[10]));
								}
							}
						}
					}
				}
			}
		}
		encounterdiagnoses = new HashSet();
		patientdiagnoses = new HashSet();
		for(int n=0;n<items.size();n++){
			String item = (String)items.elementAt(n);
			boolean bOK=true;
			if(sItemTypes.length()>0) {
				//Check if itemtypes are available with matching values
				for(int it=0;it<sItemTypes.split(";").length;it++) {
					String sItemType=sItemTypes.split(";")[it];
					String sItemValue="";
					if(sItemValues.split(";").length>it) {
						sItemValue=sItemValues.split(";")[it];
					}
					if(sItemValue.startsWith("{notequals}")) {
						bOK=!MedwanQuery.getInstance().hasItem(item.split(";")[1],sItemType, sItemValue.replaceAll("\\{notequals\\}",""));
					}
					else {
						bOK=MedwanQuery.getInstance().hasItem(item.split(";")[1],sItemType, sItemValue.replaceAll("\\{notequals\\}",""));
					}
					if(!bOK) {
						break;
					}
				}
			}
			if(!bOK) {
				continue;
			}
			if(classification==null || classification.equalsIgnoreCase(item.split(";")[4])){
				if(encounterdiagnoses.contains(item.split(";")[1]+"."+item.split(";")[5])){
					continue;
				}
				else{
					encounterdiagnoses.add(item.split(";")[1]+"."+item.split(";")[5]);
				}
				if(!bMortality || item.split(";")[8].startsWith("dead")){
					if(bMortality){
						if(patientdiagnoses.contains(item.split(";")[0]+"."+item.split(";")[5])){
							continue;
						}
						else{
							patientdiagnoses.add(item.split(";")[0]+"."+item.split(";")[5]);
						}
					}
					if(!bNewcase || item.split(";")[9].equalsIgnoreCase("1")){
						if(sEncounterType.length()==0 || ScreenHelper.checkString(item.split(";")[11]).equalsIgnoreCase(sEncounterType)){
							if(sTransaction.length()==0 || MedwanQuery.getInstance().getTransactionType(ScreenHelper.checkString(item.split(";")[12])).equalsIgnoreCase(sTransaction)){
								//First find a matching targetcode
								String code = item.split(";")[5].toLowerCase();
								String match=null;
								while(code.length()>0){
									match = (String)targetcodes.get(code);
									if(match !=null) {
										String flagsToVerify = SH.c((String)targetflags.get(SH.c((String)targetcodes.get(code))));
										for(int f=0;f<flagsToVerify.split(",").length;f++) {
											String sFlag = flagsToVerify.split(",")[f];
											if(!item.split(";")[7].contains(sFlag)) {
												match=null;
												break;
											}
										}
									}
									if(match!=null || code.length()==1){
										break;
									}
									code=code.substring(0,code.length()-1);	
								}
								if(match==null){
									match=(String)targetcodes.get("other");
								}
								if(match!=null){
									double value=1;
									if(bMortality){
										//******************************************
										//Mortality is distributed over all diagnoses according to their weight
										//******************************************
										double diagnosisweight=Double.parseDouble(item.split(";")[10]);
										double encounterweight=new Double((Integer)encounterbod.get(item.split(";")[1]));
										value=diagnosisweight/encounterweight;
									}
									if(uidcounters.get(match)==null){
										uidcounters.put(match, value);
									}
									else{
										uidcounters.put(match,(Double)uidcounters.get(match)+value);
									}
								}
							}
						}
					}
				}
			}
		}
		i = uidcounters.keySet().iterator();
		while(i.hasNext()){
			String uid=(String)i.next();
			if(MedwanQuery.getInstance().getConfigInt("cleanDHIS2DataSets",0)==0 && (Double)uidcounters.get(uid)>0){
				dataValueSet.getDataValues().add(new DataValue(uid,categoryOptionUid,new Double(Math.ceil((Double)uidcounters.get(uid))).intValue()+"",""));
			}
			else{
				dataValueSet.getDataValues().add(new DataValue(uid,categoryOptionUid," ",""));
			}
		}
	}
	
	private void exportDiagnosisDatasetSeriesRecords(Vector items,Element dataset,String dataelementuid){
		//Set diagnosis specific attributes
		//We already have the attributeOptionCombo uid and categoryOptionCombo uid
		//We only have to calculate the values now, based on the extra attributes
		//Now we must also match the code of each diagnosis on a dataelement code from the dataset
		Iterator i = dataset.element("dataelements").elementIterator("dataelement");
		while(i.hasNext()){
			Element dataelement = (Element)i.next();
			if(dataelement.attributeValue("uid").equals(dataelementuid)){
				Hashtable targetcodes = new Hashtable();
				Hashtable targetflags = new Hashtable();
				Iterator id = dataset.element("dataelements").elementIterator("dataelement");
				while(id.hasNext()){
					Element de = (Element)id.next();
					if(de.attributeValue("uid").equals(dataelementuid)){
						for(int n=0;n<de.attributeValue("code").toLowerCase().split(",").length;n++){
							targetcodes.put(de.attributeValue("code").toLowerCase().split(",")[n], de.attributeValue("uid"));
							if(SH.c(de.attributeValue("flags")).length()>0) {
								targetflags.put(de.attributeValue("uid"),de.attributeValue("flags"));
							}
						}
					}	
				}
				boolean bMortality = ScreenHelper.checkString(dataset.attributeValue("mortality")).equalsIgnoreCase("true");
				boolean bNewcase = ScreenHelper.checkString(dataset.attributeValue("newcase")).equalsIgnoreCase("true");
				String sTransaction = ScreenHelper.checkString(dataset.attributeValue("transaction"));
				String sEncounterType = ScreenHelper.checkString(dataset.attributeValue("encountertype"));
				String classification = ScreenHelper.checkString(dataset.attributeValue("classification")).toLowerCase();
				String sDepartmentOrgUID = ScreenHelper.checkString(dataset.attributeValue("departmentorguid"));
				String sItemTypes = ScreenHelper.checkString(dataset.attributeValue("itemtype"));
				String sItemValues = ScreenHelper.checkString(dataset.attributeValue("itemvalue"));
				HashSet authorizedServices = new HashSet();
				if(sDepartmentOrgUID.length()>0) {
					//Load all services that are compatible
					Iterator allServices = SH.getAllServices().iterator();
					while(allServices.hasNext()) {
						Service service = (Service)allServices.next();
						if(SH.c(service.getInscode()).equalsIgnoreCase(sDepartmentOrgUID)) {
							authorizedServices.add(service.getCode().toLowerCase());
						}
					}
				}
				for(int n=0;n<items.size();n++){
					String item = (String)items.elementAt(n);
					if(sItemTypes.length()>0) {
						//Check if itemtypes are available with matching values
						boolean bOK=false;
						for(int it=0;it<sItemTypes.split(";").length;it++) {
							String sItemType=sItemTypes.split(";")[it];
							String sItemValue="";
							if(sItemValues.split(";").length>it) {
								sItemValue=sItemValues.split(";")[it];
							}
							if(sItemValue.startsWith("{notequals}")) {
								bOK=!MedwanQuery.getInstance().hasItem(item.split(";")[1],sItemType, sItemValue.replaceAll("\\{notequals\\}",""));
							}
							else {
								bOK=MedwanQuery.getInstance().hasItem(item.split(";")[1],sItemType, sItemValue.replaceAll("\\{notequals\\}",""));
							}
							if(!bOK) {
								continue;
							}
						}
						if(!bOK) {
							continue;
						}
					}
					if(sDepartmentOrgUID.length()>0 && !authorizedServices.contains(item.split(";")[6].toLowerCase())) {
						continue;
					}
					if(classification==null || classification.equalsIgnoreCase(item.split(";")[4])){
						if(!bMortality || item.split(";")[8].startsWith("dead")){
							if(!bNewcase || item.split(";")[9].equalsIgnoreCase("1")){
								if(sEncounterType.length()==0 || ScreenHelper.checkString(item.split(";")[11]).equalsIgnoreCase(sEncounterType)){
									if(sTransaction.length()==0 || MedwanQuery.getInstance().getTransactionType(ScreenHelper.checkString(item.split(";")[12])).equalsIgnoreCase(sTransaction)){
										//First find a matching targetcode
										String code = item.split(";")[5].toLowerCase();
										String match=null;
										while(code.length()>0){
											match = (String)targetcodes.get(code);
											if(match!=null){
												String flagsToVerify = SH.c((String)targetflags.get(SH.c((String)targetcodes.get(code))));
												for(int f=0;f<flagsToVerify.split(",").length;f++) {
													String sFlag = flagsToVerify.split(",")[f];
													if(!item.split(";")[7].contains(sFlag)) {
														match=null;
														break;
													}
												}
											}
											if(match!=null || code.length()==1){
												break;
											}
											code=code.substring(0,code.length()-1);	
										}
										if(match!=null){
											patientrecords.add(item.split(";")[0]);
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	private Vector loadDiagnoses(Element dataset){
		Vector items = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			String sSql = 	"select personid,oc_encounter_begindate,oc_encounter_enddate,oc_diagnosis_encounteruid,gender,dateofbirth,oc_diagnosis_codetype,oc_diagnosis_code,oc_diagnosis_serviceuid,oc_diagnosis_flags,oc_encounter_outcome,oc_diagnosis_nc,oc_diagnosis_gravity,oc_encounter_type,oc_diagnosis_referenceuid,oc_encounter_origin"
					+ " from adminview a,oc_encounters b,oc_diagnoses c"
					+ " where"
					+ " a.personid=b.oc_encounter_patientuid and"
					+ " b.oc_encounter_serverid"+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+"b.oc_encounter_objectid=c.oc_diagnosis_encounteruid and"
					+ " (oc_diagnosis_updatetime>=? and oc_diagnosis_updatetime<?)";
			String sExtra="";
			if(SH.c(dataset.attributeValue("transactiontype")).length()>0){
				sExtra+=" t.transactionType in (";
				for(int n=0;n<ScreenHelper.checkString(dataset.attributeValue("transactiontype")).split(",").length;n++) {
					if(n>0) {
						sExtra+=",";
					}
					sExtra+="'"+ScreenHelper.checkString(dataset.attributeValue("transactiontype")).split(",")[n]+"'";
				}
				sExtra+=") and";
				sSql = 	"select personid,oc_encounter_begindate,oc_encounter_enddate,oc_diagnosis_encounteruid,gender,dateofbirth,oc_diagnosis_codetype,oc_diagnosis_code,oc_diagnosis_serviceuid,oc_diagnosis_flags,oc_encounter_outcome,oc_diagnosis_nc,oc_diagnosis_gravity,oc_encounter_type,oc_diagnosis_referenceuid"
						+ " from adminview a,oc_encounters b,oc_diagnoses c, transactions t"
						+ " where"
						+ sExtra
						+ " t.transactionId=replace(oc_diagnosis_referenceuid,'"+SH.getServerId()+".','') and"
						+ " a.personid=b.oc_encounter_patientuid and"
						+ " b.oc_encounter_serverid"+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+"b.oc_encounter_objectid=c.oc_diagnosis_encounteruid and"
						+ " (oc_diagnosis_updatetime>=? and oc_diagnosis_updatetime<?)";			
			}

			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, new java.sql.Date(begin.getTime()));
			ps.setDate(2, new java.sql.Date(end.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				int gravity = Integer.parseInt(rs.getString("oc_diagnosis_gravity"));
				if(gravity==0){
					gravity=1;
				}
				try{
					String item = rs.getString("personid")+";" //0
							+rs.getString("oc_diagnosis_encounteruid")+";" //1
							+rs.getString("gender")+";" //2
							+ScreenHelper.formatDate(rs.getDate("dateofbirth"))+";" //3
							+rs.getString("oc_diagnosis_codetype")+";" //4
							+rs.getString("oc_diagnosis_code")+";" //5
							+(rs.getString("oc_diagnosis_serviceuid")+";").toLowerCase() //6
							+rs.getString("oc_diagnosis_flags")+";" //7
							+rs.getString("oc_encounter_outcome")+";" //8
							+rs.getString("oc_diagnosis_nc")+";" //9
							+gravity+";" //10
							+rs.getString("oc_encounter_type")+";" //11
							+rs.getString("oc_diagnosis_referenceuid")+";" //12
							+new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("oc_encounter_begindate"))+";" //13
							+(rs.getTimestamp("oc_encounter_enddate")==null?new SimpleDateFormat("yyyyMMddHHmm").format(new java.util.Date()):new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("oc_encounter_enddate")))+";" //14
							+rs.getString("oc_encounter_origin")+";"; //15
					Debug.println(item);
					items.add(item);
				}
				catch(Exception o){
					o.printStackTrace();
				}
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		return items;
	}

	private Vector loadEncounters(){
		Vector items = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			//First load empty encounters
			HashSet emptyEncounters = new HashSet();
			String sSql =    "SELECT * FROM oc_encounters e,healthrecord h"
					+ " WHERE"
					+ " e.oc_encounter_patientuid=h.personid AND"
					+ "	NOT EXISTS (SELECT * FROM transactions t,items i where"
					+ "		h.healthRecordId=t.healthrecordid AND"
					+ "		t.transactionid=i.transactionid AND"
					+ "		t.serverid=i.serverid AND"
					+ "		i.value='1.'||e.oc_encounter_objectid) AND"
					+ "	(oc_encounter_enddate>=? and oc_encounter_begindate<?)";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, new java.sql.Date(begin.getTime()));
			ps.setDate(2, new java.sql.Date(end.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				emptyEncounters.add(rs.getString("oc_encounter_serverid")+"."+rs.getString("oc_encounter_objectid"));
			}
			rs.close();
			ps.close();
			
			java.util.Date now = null;
			sSql =   "select now() now";
			ps = conn.prepareStatement(sSql);
			rs = ps.executeQuery();
			if(rs.next()) {
				now = rs.getTimestamp("now");
			}
			rs.close();
			ps.close();

			sSql = 	"select personid,gender,dateofbirth,oc_encounter_begindate,oc_encounter_enddate,oc_encounter_outcome,natreg,"
							+ " oc_encounter_type,oc_encounter_origin,oc_encounter_serverid,oc_encounter_objectid,oc_encounter_serviceuid,oc_encounter_situation,oc_encounter_etiology"
							+ " from adminview a,oc_encounters_view b"
							+ " where"
							+ " a.personid=b.oc_encounter_patientuid and"
							+ " a.dateofbirth>'1900-01-01' and"
							+ " (oc_encounter_enddate>=? and oc_encounter_begindate<?)";
			
			ps = conn.prepareStatement(sSql);
			ps.setDate(1, new java.sql.Date(begin.getTime()));
			ps.setDate(2, new java.sql.Date(end.getTime()));
			rs = ps.executeQuery();
			while(rs.next()){
				String item = rs.getString("personid")+";" //0
						+rs.getString("oc_encounter_objectid")+";" //1
						+rs.getString("gender")+";" //2
						+ScreenHelper.formatDate(rs.getDate("dateofbirth"))+";" //3
						+(rs.getString("oc_encounter_serviceuid")+";").toLowerCase() //4
						+rs.getString("oc_encounter_outcome")+";" //5
						+rs.getString("oc_encounter_type")+";" //6
						+rs.getString("oc_encounter_origin")+";" //7
						+new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("oc_encounter_begindate"))+";" //8
						+new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("oc_encounter_enddate"))+";" //9
						+rs.getString("oc_encounter_situation")+";" //10
						+rs.getString("oc_encounter_etiology")+";" //11
						+new SimpleDateFormat("yyyyMMddHHmm").format(now)+";" //12
						+SH.c(rs.getString("natreg"))+";" //13
						+"x;";
				Debug.println(item);
				items.add(item);
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		return items;
	}
	
	private Vector loadLastEncounters(){
		Vector items = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			java.util.Date now = null;
			String sSql =   "select now() now";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				now = rs.getTimestamp("now");
			}
			rs.close();
			ps.close();
			sSql = 	"select personid,gender,dateofbirth,oc_encounter_begindate,oc_encounter_enddate,oc_encounter_startdate,oc_encounter_outcome,natreg,"
							+ " oc_encounter_type,oc_encounter_origin,oc_encounter_objectid,oc_encounter_serviceuid,oc_encounter_situation,oc_encounter_etiology"
							+ " from adminview a, (select * from oc_encounters_view a where oc_encounter_enddate>=? and oc_encounter_begindate<? and "
							+ " oc_encounter_begindate = (select max(oc_encounter_servicebegindate) from"
							+ " oc_encounter_services where oc_encounter_serverid=a.oc_encounter_serverid and oc_encounter_objectid=a.oc_encounter_objectid)"
							+ " ) b"
							+ " where"
							+ " a.personid=b.oc_encounter_patientuid and"
							+ " a.dateofbirth>'1900-01-01'";
			ps = conn.prepareStatement(sSql);
			ps.setDate(1, new java.sql.Date(begin.getTime()));
			ps.setDate(2, new java.sql.Date(end.getTime()));
			rs = ps.executeQuery();
			while(rs.next()){
				String item = rs.getString("personid")+";" //0
						+rs.getString("oc_encounter_objectid")+";" //1
						+rs.getString("gender")+";" //2
						+ScreenHelper.formatDate(rs.getDate("dateofbirth"))+";" //3
						+(rs.getString("oc_encounter_serviceuid")+";").toLowerCase() //4
						+rs.getString("oc_encounter_outcome")+";" //5
						+rs.getString("oc_encounter_type")+";" //6
						+rs.getString("oc_encounter_origin")+";" //7
						+new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("oc_encounter_startdate"))+";" //8
						+new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("oc_encounter_enddate"))+";" //9
						+rs.getString("oc_encounter_situation")+";" //10
						+rs.getString("oc_encounter_etiology")+";" //11
						+new SimpleDateFormat("yyyyMMddHHmm").format(now)+";" //12
						+SH.c(rs.getString("natreg"))+";" //13
						+"x;";
				Debug.println(item);
				items.add(item);
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		return items;
	}
	
	private Vector loadTechnicalActivities(){
		Vector items = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			String sSql = 	"select personid,gender,dateofbirth,oc_encounter_begindate,oc_encounter_enddate,oc_encounter_outcome,"
							+ "oc_encounter_type,oc_encounter_origin,oc_encounter_objectid,oc_debet_serviceuid,oc_prestation_dhis2code"
							+ " from adminview a,oc_encounters b,oc_debets c,oc_prestations d"
							+ " where"
							+ " a.personid=b.oc_encounter_patientuid and"
							+ " b.oc_encounter_objectid=replace(oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"
							+ " (oc_debet_date>=? and oc_debet_date<?) and"
							+ " oc_prestation_objectid=replace(oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"
							+ " oc_prestation_dhis2code is not null and"
							+ " oc_prestation_dhis2code<>''";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, new java.sql.Date(begin.getTime()));
			ps.setDate(2, new java.sql.Date(end.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				String item = rs.getString("personid")+";"							//0
						+rs.getString("oc_encounter_objectid")+";"					//1
						+rs.getString("gender")+";"									//2
						+ScreenHelper.formatDate(rs.getDate("dateofbirth"))+";"		//3
						+(rs.getString("oc_debet_serviceuid")+";").toLowerCase()	//4
						+rs.getString("oc_encounter_outcome")+";"					//5
						+rs.getString("oc_encounter_type")+";"						//6
						+rs.getString("oc_encounter_origin")+";"					//7
						+rs.getString("oc_prestation_dhis2code")+";"				//8
						+SH.formatDate(rs.getDate("oc_encounter_begindate"))+";"	//9
						;				
				Debug.println(item);
				items.add(item);
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		return items;
	}
	
	private String getItemsDatasetSignature(Element dataset) {
		String s = "items$"+SH.c(dataset.attributeValue("itemValueMin"));
		s += "$"+SH.c(dataset.attributeValue("itemValueMax"));
		s += "$"+SH.c(dataset.attributeValue("itemValue"));
		s += "$"+SH.c(dataset.attributeValue("unique"));
		s += "$"+SH.c(dataset.attributeValue("transactiontype"));
		s += "$"+SH.c(dataset.attributeValue("itemtype"));
		s += "$"+SH.c(dataset.attributeValue("exacttransactiontype"));
		s += "$"+SH.c(dataset.attributeValue("exactitemtype"));
		s += "$"+SH.c(dataset.attributeValue("incoming"));
		s += "$"+SH.c(dataset.attributeValue("outgoing"));
		s += "$"+SH.c(dataset.attributeValue("encountertype"));
		return s;
	}
	
	private Vector loadItems(Element dataset){
		String datasetUid = getItemsDatasetSignature(dataset);
		if(cachedDatasets.get(datasetUid)!=null && SH.c(dataset.attributeValue("nocache"),"0").equalsIgnoreCase("0")) {
			return cachedDatasets.get(datasetUid);
		}
		String minval=ScreenHelper.checkString(dataset.attributeValue("itemValueMin"));
		String maxval=ScreenHelper.checkString(dataset.attributeValue("itemValueMax"));
		String matchval=ScreenHelper.checkString(dataset.attributeValue("itemValue"));
		String unique=ScreenHelper.checkString(dataset.attributeValue("unique"));
		HashSet uniques = new HashSet();
		Vector items = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			String sExtra="";
			if(ScreenHelper.checkString(dataset.attributeValue("transactiontype")).split(",").length>1){
				sExtra+=" d.transactionType in (";
				for(int n=0;n<ScreenHelper.checkString(dataset.attributeValue("transactiontype")).split(",").length;n++) {
					if(n>0) {
						sExtra+=",";
					}
					sExtra+="'"+ScreenHelper.checkString(dataset.attributeValue("transactiontype")).split(",")[n]+"'";
				}
				sExtra+=") and";
			}
			if(ScreenHelper.checkString(dataset.attributeValue("itemtype")).split(",").length>1){
				sExtra+=" e.type in (";
				for(int n=0;n<ScreenHelper.checkString(dataset.attributeValue("itemtype")).split(",").length;n++) {
					if(n>0) {
						sExtra+=",";
					}
					sExtra+="'"+ScreenHelper.checkString(dataset.attributeValue("itemtype")).split(",")[n]+"'";
				}
				sExtra+=") and";
			}

			String sSql = 	"select a.personid,gender,dateofbirth,oc_encounter_begindate,oc_encounter_enddate,oc_encounter_outcome,"
							+ " oc_encounter_type,oc_encounter_origin,oc_encounter_objectid,"
							+ " (select max(oc_encounter_serviceuid) from oc_encounters_view where "
							+ "   oc_encounter_serverid=b.oc_encounter_serverid and "
							+ "   oc_encounter_objectid=b.oc_encounter_objectid and "
							+ "   convert(oc_encounter_startdate,date)<=convert(d.updatetime,date) and "
							+ "   convert(oc_encounter_enddate,date)>=convert(d.updatetime,date)) as oc_encounter_serviceuid,"
							+ " e.value,e.type,e.date,e.serverid,"
							+ " e.transactionid,oc_encounter_situation,oc_encounter_begindate,oc_encounter_enddate"
							+ " from adminview a,oc_encounters b,healthrecord c,transactions d, items e, items f"
							+ " where"
							+ " a.personid=b.oc_encounter_patientuid and"
							+ " (d.updatetime>=? and d.updatetime<?) and"
							+ " c.personid=b.oc_encounter_patientuid and"
							+ " c.healthrecordid=d.healthrecordid and"
							+ " d.transactiontype like ? and"
							+ sExtra
							+ " e.serverid=d.serverid and"
							+ " e.transactionid=d.transactionid and"
							+ " e.type like ? and"
							+ " f.serverid=d.serverid and"
							+ " f.transactionid=d.transactionid and"
							+ " f.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID' and"
							+ " b.oc_encounter_objectid=replace(f.value,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')";
			//Debug.println(sSql);
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, new java.sql.Date(begin.getTime()));
			ps.setDate(2, new java.sql.Date(end.getTime()));
			if(ScreenHelper.checkString(dataset.attributeValue("exacttransactiontype")).equalsIgnoreCase("1")){
				ps.setString(3, ScreenHelper.checkString(dataset.attributeValue("transactiontype")));
			}
			else if(ScreenHelper.checkString(dataset.attributeValue("transactiontype")).split(",").length==1){
				ps.setString(3, ScreenHelper.checkString(dataset.attributeValue("transactiontype"))+"%");
			}
			else {
				ps.setString(3, "%");
			}
			if(ScreenHelper.checkString(dataset.attributeValue("exactitemtype")).equalsIgnoreCase("1")){
				ps.setString(4, ScreenHelper.checkString(dataset.attributeValue("itemtype")));
			}
			else if(ScreenHelper.checkString(dataset.attributeValue("itemtype")).split(",").length==1){
				ps.setString(4, ScreenHelper.checkString(dataset.attributeValue("itemtype"))+"%");
			}
			else {
				ps.setString(4, "%");
			}
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				if(unique.length()>0) {
					String uid=null;
					if(unique.equalsIgnoreCase("encounters")) {
						uid=rs.getString("oc_encounter_objectid");
					}
					else if(unique.equalsIgnoreCase("transactions")) {
						uid=rs.getString("transactionid");
					}
					else if(unique.equalsIgnoreCase("patients")) {
						uid=rs.getString("personid");
					}
					if(uid!=null) {
						if(uniques.contains(uid)) {
							continue;
						}
						else {
							uniques.add(uid);
						}
					}
				}
				java.util.Date dBegin=rs.getTimestamp("oc_encounter_begindate");
				java.util.Date dEnd=rs.getTimestamp("oc_encounter_enddate")==null?new java.util.Date(end.getTime()+SH.getTimeDay()):rs.getTimestamp("oc_encounter_enddate");
				java.util.Date dDate=rs.getTimestamp("date");
				if(SH.c(dataset.attributeValue("incoming")).equalsIgnoreCase("1") && (dBegin.before(begin) || dBegin.after(end))){
					continue;
				}
				if(SH.c(dataset.attributeValue("outgoing")).equalsIgnoreCase("1") && (dEnd.before(begin) || dEnd.after(end))){
					continue;
				}
				if(SH.c(dataset.attributeValue("encountertype")).length()>0 && !dataset.attributeValue("encountertype").equalsIgnoreCase(rs.getString("oc_encounter_type"))){
					continue;
				}
				String item = rs.getString("personid")+";" //0
						+rs.getString("oc_encounter_objectid")+";" //1
						+rs.getString("gender")+";" //2
						+ScreenHelper.formatDate(rs.getDate("dateofbirth"))+";" //3
						+(rs.getString("oc_encounter_serviceuid")+";").toLowerCase() //4
						+rs.getString("oc_encounter_outcome")+";" //5
						+rs.getString("oc_encounter_type")+";" //6
						+rs.getString("oc_encounter_origin")+";" //7
						+rs.getString("value").replaceAll(";", "{semicolon}")+";" //8
						+rs.getString("type")+";" //9
						+rs.getString("serverid")+";" //10
						+rs.getString("transactionid")+";" //11
						+rs.getString("oc_encounter_situation")+";" //12
						+new SimpleDateFormat("yyyyMMddHHmm").format(dBegin)+";" //13
						+new SimpleDateFormat("yyyyMMddHHmm").format(dEnd)+";" //14
						+new SimpleDateFormat("yyyyMMddHHmm").format(dDate)+";" //15
						;
				//Debug.println("===========> "+item);
				if(minval.length()>0){
					try{
						if(item.split(";")[8].length()==0 || Double.parseDouble(item.split(";")[8])<Double.parseDouble(minval)){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(maxval.length()>0){
					try{
						if(item.split(";")[8].length()==0 || Double.parseDouble(item.split(";")[8])>Double.parseDouble(maxval)){
							continue;
						}
					}
					catch(Exception e){
						continue;
					}
				}
				if(matchval.startsWith("{like}")) {
					if(!item.split(";")[8].contains(matchval.replaceAll("\\{like\\}", ""))) {
						continue;
					}
				}
				else if(matchval.startsWith("{notlike}")) {
					if(item.split(";")[8].contains(matchval.replaceAll("\\{notlike\\}", ""))) {
						continue;
					}
				}
				else if(matchval.startsWith("{in}")) {
					if(!matchval.replaceAll("\\{in\\}", "").contains(item.split(";")[8])) {
						continue;
					}
				}
				else if(matchval.length()>0 && !matchval.contains(item.split(";")[8])){
					continue;
				}
				items.add(item);
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		cachedDatasets.put(datasetUid,items);
		return items;
	}
	
	private String getLastTransactionItemsDatasetSignature(Element dataset) {
		String s = "lasttransactionitems$"+SH.c(dataset.attributeValue("itemValueMin"));
		s += "$"+SH.c(dataset.attributeValue("itemValueMax"));
		s += "$"+SH.c(dataset.attributeValue("itemValue"));
		s += "$"+SH.c(dataset.attributeValue("transactionolderthandays"));
		s += "$"+SH.c(dataset.attributeValue("considertransactiontypes"));
		s += "$"+SH.c(dataset.attributeValue("accepttransactiontypes"));
		s += "$"+SH.c(dataset.attributeValue("exacttransactiontype"));
		s += "$"+SH.c(dataset.attributeValue("exactitemtype"));
		s += "$"+SH.c(dataset.attributeValue("itemtype"));
		return s;
	}

	private Vector loadLastTransactionItems(Element dataset){
		String datasetUid = getLastTransactionItemsDatasetSignature(dataset);
		if(cachedDatasets.get(datasetUid)!=null) {
			return cachedDatasets.get(datasetUid);
		}
		String minval=ScreenHelper.checkString(dataset.attributeValue("itemValueMin"));
		String maxval=ScreenHelper.checkString(dataset.attributeValue("itemValueMax"));
		String matchval=ScreenHelper.checkString(dataset.attributeValue("itemValue"));
		String transactionolderthandays = ScreenHelper.checkString(dataset.attributeValue("transactionolderthandays"));
		java.util.Date dTransactionsValidBefore=end;
		if(transactionolderthandays.length()>0) {
			dTransactionsValidBefore=new java.util.Date(dTransactionsValidBefore.getTime()-Integer.parseInt(transactionolderthandays)*ScreenHelper.getTimeDay());
		}
		Vector items = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
            String et = "'unknown'";
            String[] etypes = ScreenHelper.checkString(dataset.attributeValue("considertransactiontypes")).split(";");
            for(int n=0;n<etypes.length;n++) {
            	if(etypes[n].length()>0) {
            		et+=",'"+etypes[n]+"'";
            	}
            }
            String rt = "'unknown'";
            String[] rtypes = ScreenHelper.checkString(dataset.attributeValue("accepttransactiontypes")).split(";");
            for(int n=0;n<rtypes.length;n++) {
            	if(rtypes[n].length()>0) {
            		rt+=",'"+rtypes[n]+"'";
            	}
            }
			String sSql = 	"select a.personid,gender,dateofbirth,oc_encounter_begindate,oc_encounter_enddate,'dead' as oc_encounter_outcome,"
							+ " oc_encounter_type,oc_encounter_origin,oc_encounter_objectid,(select max(oc_encounter_serviceuid) from oc_encounters_view where oc_encounter_serverid=b.oc_encounter_serverid and oc_encounter_objectid=b.oc_encounter_objectid and convert(oc_encounter_startdate,date)<=convert(d.updatetime,date) and convert(oc_encounter_enddate,date)>=convert(d.updatetime,date)) as oc_encounter_serviceuid,e.value,e.type,e.serverid,"
							+ " e.transactionid,oc_encounter_situation,oc_encounter_begindate,oc_encounter_enddate,d.updatetime"
							+ " from adminview a,oc_encounters b,healthrecord c, items e, items f, ("
							+ " select t.serverid,t.transactionid,t.updatetime,t.healthrecordid from transactions t,("
							+ " select max(transactionid) transactionid,healthrecordid from transactions where updatetime<? and transactiontype in ("+et+")"
							+ " group by healthrecordid) q"
							+ " where t.transactionid=q.transactionid and t.healthrecordid=q.healthrecordid and transactiontype in ("+rt+")"
							+ " ) d"
							+ " where"
							+ " a.personid=b.oc_encounter_patientuid and"
							+ " c.personid=b.oc_encounter_patientuid and"
							+ " c.healthrecordid=d.healthrecordid and"
							+ " e.serverid=d.serverid and"
							+ " e.transactionid=d.transactionid and"
							+ " e.type like ? and"
							+ " f.serverid=d.serverid and"
							+ " f.transactionid=d.transactionid and"
							+ " f.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID' and"
							+ " b.oc_encounter_objectid=replace(f.value,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, new java.sql.Date(end.getTime()));
			if(ScreenHelper.checkString(dataset.attributeValue("exactitemtype")).equalsIgnoreCase("1")){
				ps.setString(2, ScreenHelper.checkString(dataset.attributeValue("itemtype")));
			}
			else{
				ps.setString(2, ScreenHelper.checkString(dataset.attributeValue("itemtype"))+"%");
			}
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				if(!rs.getTimestamp("updatetime").after(dTransactionsValidBefore)) {
					String item = rs.getString("personid")+";"
							+rs.getString("oc_encounter_objectid")+";"
							+rs.getString("gender")+";"
							+ScreenHelper.formatDate(rs.getDate("dateofbirth"))+";"
							+(rs.getString("oc_encounter_serviceuid")+";").toLowerCase()
							+rs.getString("oc_encounter_outcome")+";"
							+rs.getString("oc_encounter_type")+";"
							+rs.getString("oc_encounter_origin")+";"
							+rs.getString("value").replaceAll(";", "{semicolon}")+";"
							+rs.getString("type")+";"
							+rs.getString("serverid")+";"
							+rs.getString("transactionid")+";"
							+rs.getString("oc_encounter_situation")+";"
							+new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("oc_encounter_begindate"))+";"
							+new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("oc_encounter_enddate")==null?new java.util.Date(end.getTime()+SH.getTimeDay()):rs.getTimestamp("oc_encounter_enddate"))+";";
					Debug.println(item);
					if(minval.length()>0){
						try{
							if(item.split(";")[8].length()==0 || Double.parseDouble(item.split(";")[8])<Double.parseDouble(minval)){
								continue;
							}
						}
						catch(Exception e){
							continue;
						}
					}
					if(maxval.length()>0){
						try{
							if(item.split(";")[8].length()==0 || Double.parseDouble(item.split(";")[8])>Double.parseDouble(maxval)){
								continue;
							}
						}
						catch(Exception e){
							continue;
						}
					}
					if(matchval.length()>0 && !matchval.equalsIgnoreCase(item.split(";")[8])){
						continue;
					}
					items.add(item);
				}
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		cachedDatasets.put(datasetUid,items);
		return items;
	}
	
	private String getLabDatasetSignature(Element dataset) {
		String s = "lab$"+SH.c(dataset.attributeValue("abnormal"));
		s += "$"+SH.c(dataset.attributeValue("normal"));
		s += "$"+SH.c(dataset.attributeValue("encountertype"));
		return s;
	}

	private Vector loadLab(Element dataset){
		String datasetUid = getLabDatasetSignature(dataset);
		if(cachedDatasets.get(datasetUid)!=null) {
			return cachedDatasets.get(datasetUid);
		}
		String abnormal=ScreenHelper.checkString(dataset.attributeValue("abnormal"));
		String normal=ScreenHelper.checkString(dataset.attributeValue("normal"));
		String encountertype=ScreenHelper.checkString(dataset.attributeValue("encountertype"));
		String itemType=ScreenHelper.checkString(dataset.attributeValue("itemtype"));
		Vector items = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			String sSql = 	"select a.personid,gender,dateofbirth,c.dhis2code,b.serverid,b.transactionid,b.resultvalue,b.resultdate,b.resultcomment"
							+ " from adminview a,requestedlabanalyses b,labanalysis c"
							+ " where"
							+ " a.personid=b.patientid and"
							+ " b.finalvalidator is not null and"
							+ " (b.resultdate>=? and b.resultdate<?) and"
							+ " b.analysiscode=c.labcode and"
							+ " c.dhis2code is not null and"
							+ " c.dhis2code <> ''";
			if(itemType.length()>0) {
				sSql = 	"select a.personid,gender,dateofbirth,c.dhis2code,b.serverid,b.transactionid,b.resultvalue,b.resultdate,b.resultcomment,(select value from items i where i.transactionid=b.transactionid and i.type='"+itemType+"') itemvalue"
						+ " from adminview a,requestedlabanalyses b,labanalysis c"
						+ " where"
						+ " a.personid=b.patientid and"
						+ " b.finalvalidator is not null and"
						+ " (b.resultdate>=? and b.resultdate<?) and"
						+ " b.analysiscode=c.labcode and"
						+ " c.dhis2code is not null and"
						+ " c.dhis2code <> ''";
			}
			else if(encountertype.length()>0) {
				sSql = 	"select a.personid,gender,dateofbirth,c.dhis2code,b.serverid,b.transactionid,b.resultvalue,b.resultdate,b.resultcomment"
						+ " from adminview a,requestedlabanalyses b,labanalysis c, oc_encounters d"
						+ " where"
						+ " a.personid=b.patientid and"
						+ " d.OC_ENCOUNTER_PATIENTUID=b.patientid AND"
						+ " d.OC_ENCOUNTER_BEGINDATE<=b.resultdate AND"
						+ " d.oc_encounter_type='"+encountertype+"' and"
						+ " (d.oc_encounter_enddate IS NULL OR date_add(d.oc_encounter_enddate,interval 1 day)>b.resultdate) and"
						+ " b.finalvalidator is not null and"
						+ " (b.resultdate>=? and b.resultdate<?) and"
						+ " b.analysiscode=c.labcode and"
						+ " c.dhis2code is not null and"
						+ " c.dhis2code <> ''";
			}
			if(abnormal.equals("1")){
				sSql+=	" and ((c.editor like 'numeric%' and (b.resultvalue*1<b.resultrefmin*1 or b.resultvalue>b.resultrefmax*1))"
						+ " or b.resultvalue=c.alertvalue)";
			}
			else if(normal.equals("1")){
				sSql+=	" and (c.editor like 'numeric%' and b.resultvalue*1>=b.resultrefmin*1 and b.resultvalue<=b.resultrefmax*1"
						+ " and b.resultvalue<>c.alertvalue)";
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, new java.sql.Date(begin.getTime()));
			ps.setDate(2, new java.sql.Date(end.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				String item = rs.getString("personid")+";" //0
						+rs.getString("gender")+";" //1
						+ScreenHelper.formatDate(rs.getDate("dateofbirth"))+";" //2
						+rs.getString("dhis2code")+";" //3
						+rs.getString("serverid")+";" //4
						+rs.getString("transactionid")+";" //5
						+rs.getString("resultvalue")+";" //6
						+new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("resultdate"))+";" //7
						+(itemType.length()>0?SH.c(rs.getString("itemvalue")).length()>0?rs.getString("itemvalue"):"medwan.common.null":"medwan.common.null")+";" //8
						+SH.c(rs.getString("resultcomment"))+";";  //9
				items.add(item);
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		if(!(SH.c(dataset.attributeValue("nocache")).equalsIgnoreCase("1"))) {
			cachedDatasets.put(datasetUid,items);
		}
		return items;
	}
}
