<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String comment = SH.p(request,"comment");
	String code = SH.p(request,"code");
	String domain = SH.p(request,"domain");
	String presentation = SH.p(request,"presentation");
	SH.syslog("domain="+domain);
	String fr="",en="",es="",pt="",sdci="",sdose="",slabel="";
	if(domain.equalsIgnoreCase("MED")){
		if(SH.p(request,"title-fr").length()==0){
			for(int n=1;n<50;n++){
				if(SH.p(request,"dci"+n).length()>0){
					if(sdci.length()>0){
						sdci+="|";
						sdose+="|";
						slabel+=" / ";
					}
					sdci+=SH.p(request,"dci"+n);
					sdose+=SH.p(request,"dose"+n);
					slabel+=SH.p(request,"dci"+n)+" "+SH.p(request,"dose"+n);
				}
			}
			SH.syslog(presentation+"="+getTranNoLink("nups.presentation",presentation,"fr"));
			fr=slabel.toUpperCase()+" ["+getTranNoLink("nups.presentation",presentation,"fr").toUpperCase()+"] "+(comment.length()>0?" - "+comment.toUpperCase():"");
			en=slabel.toUpperCase()+" ["+getTranNoLink("nups.presentation",presentation,"en").toUpperCase()+"] "+(comment.length()>0?" - "+comment.toUpperCase():"");
			es=slabel.toUpperCase()+" ["+getTranNoLink("nups.presentation",presentation,"es").toUpperCase()+"] "+(comment.length()>0?" - "+comment.toUpperCase():"");
			pt=slabel.toUpperCase()+" ["+getTranNoLink("nups.presentation",presentation,"pt").toUpperCase()+"] "+(comment.length()>0?" - "+comment.toUpperCase():"");
		}
		else{
			fr=SH.p(request,"title-fr");
			en=SH.p(request,"title-en");
			es=SH.p(request,"title-es");
			pt=SH.p(request,"title-pt");
			Connection conn = SH.getOpenclinicConnection();
			PreparedStatement ps = conn.prepareStatement("select * from nupsref where nups=?");
			ps.setString(1,code.split("\\.")[0]);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				String s = rs.getString("fr");
				if(s.split(";").length>1){
					sdci=s.split(";")[1];
				}
				if(s.split(";").length>3){
					sdose=s.split(";")[3];
				}
			}
			rs.close();
			ps.close();
			conn.close();
		}
	}
%>
{
	"fr":"<%=fr+";"+sdci+";"+presentation+";"+sdose+";"+comment %>",
	"en":"<%=en+";"+sdci+";"+presentation+";"+sdose+";"+comment %>",
	"es":"<%=es+";"+sdci+";"+presentation+";"+sdose+";"+comment %>",
	"pt":"<%=pt+";"+sdci+";"+presentation+";"+sdose+";"+comment %>"
}