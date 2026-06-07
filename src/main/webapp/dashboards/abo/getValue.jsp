<%@include file="/includes/validateUser.jsp"%>
<%
	int apos=0,aneg=0,bpos=0,bneg=0,abpos=0,abneg=0,opos=0,oneg=0;
	Connection conn = SH.getOpenclinicConnection();
	String sSql="SELECT COUNT(*) total,a.resultvalue abo,b.resultvalue rh FROM requestedlabanalyses a,requestedlabanalyses b WHERE"+
			" a.transactionid=b.transactionid AND"+
			" a.analysiscode='ABO' AND"+
			" b.analysiscode='Rh' AND"+
			" a.resultvalue<>'' AND"+
			" b.resultvalue<>''"+
			" GROUP BY a.resultvalue,b.resultvalue";
	PreparedStatement ps = conn.prepareStatement(sSql);
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		if(rs.getString("abo").equalsIgnoreCase("A") && rs.getString("rh").equalsIgnoreCase("+")){
			apos=rs.getInt("total");
		}
		else if(rs.getString("abo").equalsIgnoreCase("A") && rs.getString("rh").equalsIgnoreCase("-")){
			aneg=rs.getInt("total");
		}
		else if(rs.getString("abo").equalsIgnoreCase("B") && rs.getString("rh").equalsIgnoreCase("+")){
			bpos=rs.getInt("total");
		}
		else if(rs.getString("abo").equalsIgnoreCase("B") && rs.getString("rh").equalsIgnoreCase("-")){
			bneg=rs.getInt("total");
		}
		else if(rs.getString("abo").equalsIgnoreCase("AB") && rs.getString("rh").equalsIgnoreCase("+")){
			abpos=rs.getInt("total");
		}
		else if(rs.getString("abo").equalsIgnoreCase("AB") && rs.getString("rh").equalsIgnoreCase("-")){
			abneg=rs.getInt("total");
		}
		else if(rs.getString("abo").equalsIgnoreCase("O") && rs.getString("rh").equalsIgnoreCase("+")){
			opos=rs.getInt("total");
		}
		else if(rs.getString("abo").equalsIgnoreCase("O") && rs.getString("rh").equalsIgnoreCase("-")){
			oneg=rs.getInt("total");
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>
{
	"total": <%=apos+aneg+bpos+bneg+abpos+abneg+opos+oneg %>,
	"apos": <%=apos %>,
	"aneg": <%=aneg %>,
	"bpos": <%=bpos %>,
	"bneg": <%=bneg %>,
	"abpos": <%=abpos %>,
	"abneg": <%=abneg %>,
	"opos": <%=opos %>,
	"oneg": <%=oneg %>
}