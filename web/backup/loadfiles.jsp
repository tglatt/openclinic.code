<%@page import="java.text.*"%>
<%@include file="/includes/helper.jsp"%>
<%@page import="be.mxs.common.util.system.*,java.nio.file.*,java.nio.file.attribute.*"%>

<table width='100%'>
<%!
	public static String humanReadableByteCountBin(long bytes) {
	    long absB = bytes == Long.MIN_VALUE ? Long.MAX_VALUE : Math.abs(bytes);
	    if (absB < 1024) {
	        return bytes + " B";
	    }
	    long value = absB;
	    CharacterIterator ci = new StringCharacterIterator("KMGTPE");
	    for (int i = 40; i >= 0 && absB > 0xfffccccccccccccL >> i; i -= 10) {
	        value >>= 10;
	        ci.next();
	    }
	    value *= Long.signum(bytes);
	    return String.format("%.1f %ciB", value / 1024.0, ci.current());
	}
%>
<%
	SortedMap map = new TreeMap();
	File[] files = new File(SH.p(request,"folder")).listFiles();
	SortedMap<Long,File> sortedFiles = new TreeMap();
	for(int n=0;n<files.length;n++){
		sortedFiles.put(Files.readAttributes(files[n].toPath(),BasicFileAttributes.class).creationTime().toMillis(), files[n]);
	}
	Iterator iFiles = sortedFiles.keySet().iterator();
	int counter=0;
	while(iFiles.hasNext()){
		files[counter]=sortedFiles.get(iFiles.next());
		counter++;
	}		
	String sProject =SH.p(request,"project");
	long previousSize=0,beforepreviousSize=0;
	Hashtable<String,Long> previousSizes = new Hashtable<String,Long>();
	Hashtable<String,Long> beforePreviousSizes = new Hashtable<String,Long>();
	for(int n=0;n<files.length;n++){
		File file = files[n];
		if(file.getName().startsWith(".")){
			continue;
		}
		Path path = file.toPath();
		BasicFileAttributes fatr = Files.readAttributes(path,BasicFileAttributes.class);
		String tooOld="";
		if(n==files.length-1 && new java.util.Date().getTime()-fatr.creationTime().toMillis()>SH.getTimeHour()*28){
			tooOld=" <img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif'/>";
		}
		String s = 	"<tr>"+
				"	<td class='admin' width='1%' nowrap>"+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(fatr.creationTime().toMillis())+tooOld+"&nbsp;</td>"+
				"	<td class='admin2'><a style='font-size: 12px' href='"+SH.cs("backupFilesURL","http://localhost/openclinic/backup/files/")+sProject+"/"+file.getName()+"'>"+file.getName()+"</a></td>"+
				"	<td class='admin2' id='backup_"+n+"'><b>"+humanReadableByteCountBin(fatr.size())+"</b><br/><font style='font-size: 8px'>"+new DecimalFormat("#,000").format(fatr.size())+" bytes</font></td>"+
				"	<td class='admin2'>"+(file.getName().toLowerCase().contains("inc")?"Incremental backup":"<font style='font-size: 12px;font-weight: bolder;color: red'>Full backup</font>")+"</td>"+
				"</tr>";
		if(!file.getName().toLowerCase().contains("inc") && previousSizes.get(file.getName().split("\\_")[0])!=null && beforePreviousSizes.get(file.getName().split("\\_")[0])!=null && fatr.size()<previousSizes.get(file.getName().split("\\_")[0])-1024 && fatr.size()<beforePreviousSizes.get(file.getName().split("\\_")[0])-1024){
			s = 	"<tr>"+
					"	<td class='admin' width='1%' nowrap>"+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(fatr.creationTime().toMillis())+tooOld+"&nbsp;</td>"+
					"	<td class='admin2'><a style='font-size: 12px' href='"+SH.cs("backupFilesURL","http://localhost/openclinic/backup/files/")+sProject+"/"+file.getName()+"'>"+file.getName()+"</a></td>"+
					"	<td class='adminred' id='backup_"+n+"'><b style='color: white'>"+humanReadableByteCountBin(fatr.size())+"</b><br/><font style='font-size: 8px'>"+new DecimalFormat("#,000").format(fatr.size())+" bytes</font></td>"+
					"	<td class='admin2'>"+(file.getName().toLowerCase().contains("inc")?"Incremental backup":"<font style='font-size: 12px;font-weight: bolder;color: red'>Incomplete full backup?</font>")+"</td>"+
					"</tr>";
		}
		map.put(-fatr.creationTime().toMillis(), s);
		beforepreviousSize=previousSize;
		previousSize=fatr.size();
		if(previousSizes.get(file.getName().split("\\_")[0])!=null){
				beforePreviousSizes.put(file.getName().split("\\_")[0],previousSizes.get(file.getName().split("\\_")[0]));
		}
		previousSizes.put(file.getName().split("\\_")[0],previousSize);
	}
	Iterator i = map.keySet().iterator();
	while(i.hasNext()){
		out.print(map.get(i.next()));
	}

%>
</table>