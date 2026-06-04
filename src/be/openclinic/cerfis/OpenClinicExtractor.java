package be.openclinic.cerfis;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.system.SH;

public abstract class OpenClinicExtractor {
	StringBuffer data = new StringBuffer();
	Date begin,end;
	
	public StringBuffer getData() {
		return data;
	}

	public void setData(StringBuffer data) {
		this.data = data;
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

	
	public void store() throws IOException {
		String filename=SH.cs("tempDirectory","/tmp")+"/"+SH.formatDate(begin,"yyyy.mm.dd")+"-"+SH.formatDate(end,"yyyy.mm.dd")+"_hypertension_"+System.currentTimeMillis()+".csv";
		BufferedWriter bw = new BufferedWriter(new FileWriter(filename));
		bw.write(data.toString());
		bw.flush();
		bw.close();
	}
	
	public void post(HttpServletResponse response) throws IOException {
	    response.setContentType("application/octet-stream");
	    response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicStatistic" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + ".csv\"");
	    ServletOutputStream os = response.getOutputStream();
	    byte[] b = data.toString().getBytes("ISO-8859-1");
	    for (int n=0;n<b.length;n++) {
	        os.write(b[n]);
	    }
	    os.flush();
	    os.close();
	}
	
	public OpenClinicExtractor(Date begin, Date end) {
		this.begin=begin;
		this.end=end;
	}
}
