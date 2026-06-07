<%@page import="be.openclinic.system.SH"%>
<%@page import="java.util.Vector"%>
<%@page import="be.openclinic.pharmacy.Product"%>

<b>Liste de produits contenant PARACETAMOL:</b>
<table border="1">
<%
	Vector<Product> products = Product.find("paracetamol", "", "", "", "", "", "", "", "", "");
	for(int n=0;n<products.size();n++){
		Product product = products.elementAt(n);
		out.println("<tr>");
		out.println("<td>"+product.getName()+"</td>");
		out.println("<td>"+SH.getTranNoLink("product.unit",product.getUnit(),"fr")+"</td>");
		out.println("</tr>");
	}
%>
</table>