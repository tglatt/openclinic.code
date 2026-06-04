package be.openclinic.system;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.text.RandomStringGenerator;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URL;
import java.net.UnknownHostException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.GregorianCalendar;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.util.DummyTransactionFactory;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.knowledge.SPT;
import net.admin.AdminPerson;
import net.admin.User;

public class SH extends ScreenHelper {
	
	public static String getScanDirectoryFromPath() {
		String SCANDIR_BASE = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_basePath","/var/tomcat/webapps/openclinic/scan");
	    return SCANDIR_BASE+"/"+MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirFrom","from");
	}
	
	public static boolean writeTextFile(String name, String content) {
		try {
			PrintWriter out = new PrintWriter(name);
			out.println(content);
			out.flush();
			out.close();
			return true;
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return false;
	}
	
    public static boolean isValidUrl(String urlString) {
        try {
            new URL(urlString).toURI();
            return true;
        } catch (Exception e) {
            return false;
        }
    }

	public static boolean loadDumpFile(String database, String fileName,String encoding) {
		try{
			Connection conn;
			if(database.equals("openclinic")) {
				conn = SH.getOpenClinicConnection();
			}
			else if(database.equals("ocadmin")) {
				conn = SH.getAdminConnection();
			}
			else if(database.equals("ocstats")) {
				conn = SH.getStatsConnection();
			}
			else {
				return false;
			}
			FileInputStream fis = new FileInputStream(fileName);
			InputStreamReader isr = new InputStreamReader(fis,"utf-8");
			BufferedReader br = new BufferedReader(isr);
			Statement statement = conn.createStatement();
			String line,instruction="";
			while((line = br.readLine()) != null){
				if(line.length()>0 && !line.startsWith("--") && !line.startsWith("/*")){
					instruction+=line+" ";
					if(line.endsWith(";")){
						statement.execute(instruction);
						instruction="";
					}
				}
			}
			br.close();
			statement.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public static java.util.Date dateAdd(java.util.Date date, long time) {
		return new java.util.Date(date.getTime()+time);
	}
	
	public static java.util.Date dateAdd(long time) {
		return new java.util.Date(new java.util.Date().getTime()+time);
	}
	
	public static boolean isSemaphore(String id) {
		boolean bSemaphore=false;
		Connection conn = SH.getOpenClinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from oc_semaphores where oc_semaphore_id=?");
			ps.setString(1, id);
			ResultSet rs = ps.executeQuery();
			bSemaphore=rs.next();
			rs.close();
			ps.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		try {
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return bSemaphore;
	};

	public static String getTimeBetween(java.util.Date begin,java.util.Date end) {
		return getTimeBetween(begin, end, "en");
	}
	
	public static String getTimeBetween(java.util.Date begin,java.util.Date end, String language) {
		if(begin==null || end==null) {
			return "";
		}
		long milliseconds=end.getTime()-begin.getTime();
		int seconds = (int) (milliseconds / 1000) % 60 ;
		int minutes = (int) ((milliseconds / (1000*60)) % 60);
		int hours   = (int) ((milliseconds / (1000*60*60)) % 24);
		int days   = (int) ((milliseconds / (1000*60*60*24)));
		String s = "";
		if(days>0) {
			s=days+getTranNoLink("time","d",language)+" "+hours+getTranNoLink("time","h",language)+" "+minutes+getTranNoLink("time","m",language)+" "+seconds+getTranNoLink("time","s",language);
		}
		else if(hours>0) {
			s=hours+getTranNoLink("time","h",language)+" "+minutes+getTranNoLink("time","m",language)+" "+seconds+getTranNoLink("time","s",language);
		}
		else if(minutes>0) {
			s=minutes+getTranNoLink("time","m",language)+" "+seconds+getTranNoLink("time","s",language);
		}
		else {
			s=seconds+getTranNoLink("time","s",language);
		}
		return s;
	}
	
	public static void updateRecentItemValue(TransactionVO transaction, String itemtype, long timespan) {
		String pf = "be.mxs.common.model.vo.healthrecord.IConstants.";
		ItemVO item = transaction.getItem(pf+itemtype);
		if(item!=null && (item.getValue()).length()==0) {
			item.setValue(MedwanQuery.getInstance().getLastItemValueAfterWithHealthrecordId(transaction.getHealthrecordId(), pf+itemtype, new java.util.Date(new java.util.Date().getTime()-timespan)));
		}
	}
	public static void updateRecentItemValue(TransactionVO transaction, String sourceitemtype, String targetitemtype, long timespan) {
		String pf = "be.mxs.common.model.vo.healthrecord.IConstants.";
		ItemVO item = transaction.getItem(pf+targetitemtype);
		if(item!=null && (item.getValue()).length()==0) {
			item.setValue(MedwanQuery.getInstance().getLastItemValueAfterWithHealthrecordId(transaction.getHealthrecordId(), pf+sourceitemtype, new java.util.Date(new java.util.Date().getTime()-timespan)));
		}
	}
	public static void clearSemaphores(long timeoutinmillis) {
		Connection conn = SH.getOpenClinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("delete from oc_semaphores where oc_semaphore_date<=?");
			ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()-timeoutinmillis));
			ps.execute();
			ps.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		try {
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	public static void setSemaphore(String id) {
		Connection conn = SH.getOpenClinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("insert into oc_semaphores(oc_semaphore_id,oc_semaphore_date) values(?,?)");
			ps.setString(1, id);
			ps.setTimestamp(2, new java.sql.Timestamp(new java.util.Date().getTime()));
			ps.execute();
			ps.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		try {
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	public static String getScanDirectoryToPath() {
		String SCANDIR_BASE = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_basePath","/var/tomcat/webapps/openclinic/scan");
	    return SCANDIR_BASE+"/"+MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo","to");
	}
	
    public static String xe(String s){
    	return HTMLEntities.xmlencode(ScreenHelper.checkString(s));
    }
    
    public static double getPriceToDouble(String sPrice) {
    	double d=0;
    	try {
    		if(sPrice.contains(".") && sPrice.contains(",") && sPrice.indexOf(",")<sPrice.indexOf(".")) {
    			// comma is a thousands separator
    			sPrice=sPrice.replaceAll(",", "");
    		}
    		else if(sPrice.contains(".") && sPrice.contains(",") && sPrice.indexOf(",")>sPrice.indexOf(".")) {
    			// point is a thousands separator
    			sPrice=sPrice.replaceAll("\\.", "");
    		}
			sPrice=sPrice.replaceAll(" ", "");
			sPrice=sPrice.replaceAll(",", "\\.");
			d=Double.parseDouble(sPrice);
    	}
    	catch(Exception e) {
    		e.printStackTrace();
    	}
    	return d;
    }

    public static Hashtable getMultipartFormParameters(HttpServletRequest request) {
		Hashtable parameters = new Hashtable();
		if(ServletFileUpload.isMultipartContent(request)) {
		    FileItemFactory factory = new DiskFileItemFactory();
		    ServletFileUpload upload = new ServletFileUpload(factory);
		    List items = null;
		    try {
		        items = upload.parseRequest(request);
	        } catch (FileUploadException e) {
	             e.printStackTrace();
	        }
		    Iterator itr = items.iterator();
		    while (itr.hasNext()) {
		        FileItem item = (FileItem) itr.next();
		        if (item.isFormField()) {
		        	parameters.put(item.getFieldName(), item.getString());
		        } else {
		        	try {
		        		FormFile formFile =new FormFile();
		        		formFile.document=item.get();
		        		formFile.filename=FilenameUtils.getName(item.getName()); 
		        		parameters.put(item.getFieldName(), formFile);
		            } catch (Exception e) {
		                 e.printStackTrace();
		            }
		      	}
		    }    	
		}
		else {
			Enumeration epars = request.getParameterNames();
			while(epars.hasMoreElements()) {
				String parname = (String)epars.nextElement();
				parameters.put(parname, request.getParameter(parname));
			}
		}
		return parameters;
	}
	
	public static java.sql.Timestamp ts(java.util.Date date){
		if(date==null) {
			return null;
		}
		return new java.sql.Timestamp(date.getTime());
	}
	
	public static String c(String s) {
		return checkString(s);
	}
	
	public static String getNUPSDomainOptions(User user,String domain) {
		String s = "";
		if(user.getAccessRightNoSA("nups.procedures.select")) {
			s+="<option "+(domain.equals("PROC")?"selected":"")+">PROC</option>";
		}
		if(user.getAccessRightNoSA("nups.consultation.select")) {
			s+="<option "+(domain.equals("EVAL")?"selected":"")+">EVAL</option>";
		}
		if(user.getAccessRightNoSA("nups.drugs.select")) {
			s+="<option "+(domain.equals("MED")?"selected":"")+">MED</option>";
		}
		if(user.getAccessRightNoSA("nups.prostheses.select")) {
			s+="<option "+(domain.equals("PROT")?"selected":"")+">PROT</option>";
		}
		if(user.getAccessRightNoSA("nups.consumables.select")) {
			s+="<option "+(domain.equals("CONS")?"selected":"")+">CONS</option>";
		}
		if(user.getAccessRightNoSA("nups.transport.select")) {
			s+="<option "+(domain.equals("TRAN")?"selected":"")+">TRAN</option>";
		}
		if(user.getAccessRightNoSA("nups.lodging.select")) {
			s+="<option "+(domain.equals("LOG")?"selected":"")+">LOG</option>";
		}
		if(user.getAccessRightNoSA("nups.lab.select")) {
			s+="<option "+(domain.equals("LAB")?"selected":"")+">LAB</option>";
		}
		if(user.getAccessRightNoSA("nups.imaging.select")) {
			s+="<option "+(domain.equals("IMG")?"selected":"")+">IMG</option>";
		}
		if(user.getAccessRightNoSA("nups.radiotherapy.select")) {
			s+="<option "+(domain.equals("RXT")?"selected":"")+">RXT</option>";
		}
		if(user.getAccessRightNoSA("nups.physiotherapy.select")) {
			s+="<option "+(domain.equals("PHY")?"selected":"")+">PHY</option>";
		}
		if(user.getAccessRightNoSA("nups.mentalhealth.select")) {
			s+="<option "+(domain.equals("MENT")?"selected":"")+">MENT</option>";
		}
		if(user.getAccessRightNoSA("nups.other.select")) {
			s+="<option ></option>";
		}
		return s;
	}
	public static String getAvailableNUPSSections(User user) {
		String s="'-1'";
		if(user.getAccessRightNoSA("nups.procedures.select")) {
			s+=",'1.0','1.01','1.02','1.03','1.04','1.05','1.06','1.07','1.08','1.09','1.10','1.11','1.12','1.13'";
		}
		if(user.getAccessRightNoSA("nups.consultation.select")) {
			s+=",'2.0'";
		}
		if(user.getAccessRightNoSA("nups.drugs.select")) {
			s+=",'3.0'";
		}
		if(user.getAccessRightNoSA("nups.prostheses.select")) {
			s+=",'4.0'";
		}
		if(user.getAccessRightNoSA("nups.consumables.select")) {
			s+=",'5.0'";
		}
		if(user.getAccessRightNoSA("nups.transport.select")) {
			s+=",'6.0'";
		}
		if(user.getAccessRightNoSA("nups.lodging.select")) {
			s+=",'7.0'";
		}
		if(user.getAccessRightNoSA("nups.lab.select")) {
			s+=",'8.0'";
		}
		if(user.getAccessRightNoSA("nups.imaging.select")) {
			s+=",'9.0'";
		}
		if(user.getAccessRightNoSA("nups.radiotherapy.select")) {
			s+=",'10.0'";
		}
		if(user.getAccessRightNoSA("nups.physiotherapy.select")) {
			s+=",'11.0'";
		}
		if(user.getAccessRightNoSA("nups.mentalhealth.select")) {
			s+=",'12.0'";
		}
		if(user.getAccessRightNoSA("nups.other.select")) {
			s+=",'99.0'";
		}
		return s;
	}
	public static String getNUPSSectionOptions(User user,String sectioncode,String sWebLanguage) {
		String s="";
		if(user.getAccessRightNoSA("nups.procedures.select")) {
			s+="<option value='1.00' "+(sectioncode.equals("1")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.00",sWebLanguage)+"</option>";
			s+="<option value='1.01' "+(sectioncode.equals("1.01")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.01",sWebLanguage)+"</option>";
			s+="<option value='1.02' "+(sectioncode.equals("1.02")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.02",sWebLanguage)+"</option>";
			s+="<option value='1.03' "+(sectioncode.equals("1.03")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.03",sWebLanguage)+"</option>";
			s+="<option value='1.04' "+(sectioncode.equals("1.04")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.04",sWebLanguage)+"</option>";
			s+="<option value='1.05' "+(sectioncode.equals("1.05")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.05",sWebLanguage)+"</option>";
			s+="<option value='1.06' "+(sectioncode.equals("1.06")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.06",sWebLanguage)+"</option>";
			s+="<option value='1.07' "+(sectioncode.equals("1.07")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.07",sWebLanguage)+"</option>";
			s+="<option value='1.08' "+(sectioncode.equals("1.08")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.08",sWebLanguage)+"</option>";
			s+="<option value='1.09' "+(sectioncode.equals("1.09")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.09",sWebLanguage)+"</option>";
			s+="<option value='1.1' "+(sectioncode.equals("1.1")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.1",sWebLanguage)+"</option>";
			s+="<option value='1.11' "+(sectioncode.equals("1.11")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.11",sWebLanguage)+"</option>";
			s+="<option value='1.12' "+(sectioncode.equals("1.12")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.12",sWebLanguage)+"</option>";
			s+="<option value='1.13' "+(sectioncode.equals("1.13")?"selected":"")+">"+SH.getTranNoLink("nups.section","1.13",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.consultation.select")) {
			s+="<option value='2' "+(sectioncode.equals("2")||sectioncode.equals("2.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","2.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.drugs.select")) {
			s+="<option value='3' "+(sectioncode.equals("3")||sectioncode.equals("3.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","3.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.prostheses.select")) {
			s+="<option value='4' "+(sectioncode.equals("4")||sectioncode.equals("4.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","4.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.consumables.select")) {
			s+="<option value='5' "+(sectioncode.equals("5")||sectioncode.equals("5.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","5.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.transport.select")) {
			s+="<option value='6' "+(sectioncode.equals("6")||sectioncode.equals("6.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","6.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.lodging.select")) {
			s+="<option value='7' "+(sectioncode.equals("7")||sectioncode.equals("7.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","7.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.lab.select")) {
			s+="<option value='8' "+(sectioncode.equals("8")||sectioncode.equals("8.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","8.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.imaging.select")) {
			s+="<option value='9' "+(sectioncode.equals("9")||sectioncode.equals("9.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","9.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.radiotherapy.select")) {
			s+="<option value='10' "+(sectioncode.equals("10")||sectioncode.equals("10.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","10.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.physiotherapy.select")) {
			s+="<option value='11' "+(sectioncode.equals("11")||sectioncode.equals("11.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","11.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.mentalhealth.select")) {
			s+="<option value='12' "+(sectioncode.equals("12")||sectioncode.equals("12.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","12.0",sWebLanguage)+"</option>";
		}
		if(user.getAccessRightNoSA("nups.other.select")) {
			s+="<option value='99' "+(sectioncode.equals("99")||sectioncode.equals("13.0")?"selected":"")+">"+SH.getTranNoLink("nups.section","99.0",sWebLanguage)+"</option>";
		}
		return s;
	}
	
	public static void populateTransactionWithLastItemValues(TransactionVO tran,String personid) {
    	if(tran.isNew()){
    		TransactionVO lastTran = MedwanQuery.getInstance().getLastTransactionByType(Integer.parseInt(personid), tran.getTransactionType());
            new DummyTransactionFactory().populateTransactionItemValues(tran,lastTran);
    	}
	}
	
	public static HttpResponse getAuthenticated(String url, String userName, String password) throws Exception {
		HttpClient client = HttpClients.createDefault();
		HttpGet req = new HttpGet(url);
		String aut = Base64.getEncoder().encodeToString((userName+":"+password).getBytes("utf-8"));
		req.setHeader("Authorization", "Basic "+aut);
		return client.execute(req);
	}

	public static JSONArray getJsonArray(HttpResponse resp) throws Exception {
		HttpEntity entity = resp.getEntity();
		JSONArray array = new JSONArray(EntityUtils.toString(entity)); 
		return array;
	}

	public static void syslog(Object s) {
		System.out.println(new SimpleDateFormat("mm:ss:SSS").format(new java.util.Date())+" ||SYSLOG|| "+s);
	}
	
	public static int sumIntegerValuesForTokenStartingWithKey(Hashtable<String,Integer> h, String token) {
		int sum = 0;
		Enumeration<String> e = h.keys();
		while(e.hasMoreElements()) {
			String k = e.nextElement();
			if(token.toLowerCase().startsWith(k.toLowerCase())) {
				sum+=h.get(k);
			}
		}
		return sum;
	}
	
	public static int sumIntegerValuesForKeyLike(Hashtable<String,Integer> h, String s) {
		int sum = 0;
		Enumeration<String> e = h.keys();
		while(e.hasMoreElements()) {
			String k = e.nextElement();
			if(k.toLowerCase().startsWith(s.toLowerCase())) {
				sum+=h.get(k);
			}
		}
		return sum;
	}
	
	public static boolean hasParentKey(Hashtable h, String key) {
		if(h.get(key)!=null) return true;
		Enumeration<String> e = h.keys();
		while(e.hasMoreElements()) {
			String k = e.nextElement();
			if(key.toLowerCase().startsWith(k.toLowerCase())) {
				return true;
			}
		}
		return false;
	}
	
	public static String getParentValue(Hashtable h, String key) {
		if(h.get(key)!=null) return (String)h.get(key);
		Enumeration<String> e = h.keys();
		while(e.hasMoreElements()) {
			String k = e.nextElement();
			if(key.toLowerCase().startsWith(k.toLowerCase())) {
				return (String)h.get(k);
			}
		}
		return null;
	}
	
	public static double sumDoubleValuesForTokenStartingWithKey(Hashtable<String,Double> h, String token) {
		double sum = 0;
		Enumeration<String> e = h.keys();
		while(e.hasMoreElements()) {
			String k = e.nextElement();
			if(token.toLowerCase().startsWith(k.toLowerCase())) {
				sum+=h.get(k);
			}
		}
		return sum;
	}
	
	public static double sumDoubleValuesForKeyLike(Hashtable<String,Double> h, String s) {
		double sum = 0;
		Enumeration<String> e = h.keys();
		while(e.hasMoreElements()) {
			String k = e.nextElement();
			if(k.toLowerCase().startsWith(s.toLowerCase())) {
				sum+=h.get(k);
			}
		}
		return sum;
	}
	
	public static String c(StringBuffer s) {
		return checkString(s);
	}
	
	public static String c(Object s, String defaultValue) {
		return checkString(s,defaultValue);
	}
	
	public static String c(String s, String defaultValue) {
		return checkString(s,defaultValue);
	}
	
	public static String sid() {
		return SH.getConfigString("serverid");
	}
	
	public static String cx(String s) {
		return convertToXml(c(s));
	}
	
	public static String convertToXml(String s) {
		return s.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "glt;").replaceAll("\"", "&quot;").replaceAll("'", "&apos;");
	}
	
	public static String c(java.util.Date d) {
		return formatDate(d,SH.fullDateFormatSS);
	}
	
	public static String p(HttpServletRequest request, String parameter) {
		return c(request.getParameter(parameter));
	}
	
	public static String p(HttpServletRequest request, String parameter, String defaultValue) {
		return c(request.getParameter(parameter)).length()==0?defaultValue:c(request.getParameter(parameter));
	}
	
    public static int ci(String key, int defaultValue) {
    	return MedwanQuery.getInstance().getConfigInt(key,defaultValue);
    }

    public static long cl(String key, long defaultValue) {
    	return MedwanQuery.getInstance().getConfigLong(key,defaultValue);
    }

    public static int getDayMinutes(java.util.Date date) {
    	Calendar calendar = GregorianCalendar.getInstance();
    	calendar.setTime(date);
    	return calendar.get(Calendar.HOUR_OF_DAY)*60+calendar.get(Calendar.MINUTE);
    }
    
    public static double cd(String key, double defaultValue) {
    	try {
    		return new Double(MedwanQuery.getInstance().getConfigString(key,defaultValue+""));
    	}
    	catch(Exception e) {
    		return defaultValue;
    	}
    }

    public static String cs(String key, String defaultValue) {
    	return MedwanQuery.getInstance().getConfigString(key,defaultValue);
    }
    
    public static String getRandomPassword() {
		char [][] pairs = {{'a','z'},{'0','9'}};
    	return new RandomStringGenerator.Builder().withinRange(pairs).build().generate(SH.ci("mpiGeneratedPatientPasswordLength", 8));
    }

    public static String getRandomPassword(int length) {
		char [][] pairs = {{'a','z'},{'0','9'}};
    	return new RandomStringGenerator.Builder().withinRange(pairs).build().generate(length);
    }

    public static Connection getOpenClinicConnection() {
    	return MedwanQuery.getInstance().getOpenclinicConnection();
    }
    
    public static Connection getAdminConnection() {
    	return MedwanQuery.getInstance().getAdminConnection();
    }
    
    public static Connection getStatsConnection() {
    	return MedwanQuery.getInstance().getStatsConnection();
    }
    
    public static int getServerId() {
    	return MedwanQuery.getInstance().getConfigInt("serverId",1);
    }
    
    public static String formatDouble(double d) {
    	return new DecimalFormat("#0.00",new DecimalFormatSymbols(Locale.getDefault())).format(d);
    }
    
    public static boolean hasSPTDataToPost() {
    	return SPT.hasSPTDataToPost();
    }
    
    public static boolean isHostReachable(String host) {
    	try {
			return InetAddress.getByName(host).isReachable(5000);
		} catch (Exception e) {
			return false;
		}
    }
    
    public static boolean isServerListening(String host, int port)
    {
        Socket s = null;
        try
        {
            s = new Socket(host, port);
        }
        catch (Exception e)
        {
            return false;
        }
        finally
        {
            if(s != null) {
                try {
                	s.close();
                }
                catch(Exception e){}
            }
        }
        return true;
    }
    public static long getServerResponseDelay(String host, int port, int timeout){
    	long duration = new java.util.Date().getTime();
        Socket s = null;
        try{
        	s = new Socket();
        	s.connect(new InetSocketAddress(host, port), timeout);
            return new java.util.Date().getTime()-duration;
        }
        catch (Exception e){
            return -1;
        }
        finally{
            if(s != null){
	            try{
	            	s.close();
	            }
	            catch(Exception e){}
            }
        }
    }
    
    public static void close(Connection conn, PreparedStatement ps, ResultSet rs) {
    	try {
    		if(rs!=null) rs.close();
    	}
    	catch(Exception e) {
    		e.printStackTrace();
    	}
    	close(conn,ps);
    }
    
    public static void close(Connection conn, PreparedStatement ps) {
    	try {
    		if(ps!=null) ps.close();
    	}
    	catch(Exception e) {
    		e.printStackTrace();
    	}
    	finally {
    		try {
    			if(conn!=null) {
    				conn.close();
    			}
			} catch (SQLException e) {
				e.printStackTrace();
			}
    	}
    }
    
    public static String cdm() {
    	return cdm("");
    }
    
    public static String cdm(String alternateIds) {
    	return getClinicalDataMandatory(alternateIds);
    }
    
    public static String getClinicalDataMandatory(String alternateIds) {
    	return "data-mandatory='"+SH.ci("enforceCompleteClinicalDataEntry",0)+"'"+(alternateIds.length()==0?"":" data-alternateids='"+alternateIds+"'");
    }
    
    public static String dmf() {
    	return dmf("");
    }
    
    public static String dmf(String alternateIds) {
    	return getDataMandatoryForced(alternateIds);
    }
    
    public static String getDataMandatoryForced(String alternateIds) {
    	return "data-mandatory='1'"+(alternateIds.length()==0?"":" data-alternateids='"+alternateIds+"'");
    }
    
    public static void loadRecentItems(TransactionVO transaction,AdminPerson activePatient) {
    	if(transaction.isNew()){
    		transaction.setHealthrecordId(MedwanQuery.getInstance().getHealthRecordIdFromPersonId(Integer.parseInt(activePatient.personid)));
    		if(MedwanQuery.getInstance().getConfigInt("loadRecentVitalSignsInRMHConsultation",0)==1) {
	    		transaction.preloadRecentVitalSigns();
    		}
    	}
    }
}
