<%@page import="be.openclinic.pharmacy.*"%>
<%@page import="org.json.*"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,java.io.*,org.dom4j.*,org.dom4j.util.*"%>
<%@include file="/includes/helper.jsp"%>
<%
	String sAction = SH.p(request,"action");
	if(sAction.equalsIgnoreCase("status")){
		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps=null;
		ResultSet rs = null;
		java.util.Date end = SH.parseDate(SH.p(request,"end"),"yyyyMMddHHmmss");
		if(end==null){
			end=new java.util.Date();
		}
		java.util.Date begin = SH.parseDate(SH.p(request,"begin"),"yyyyMMddHHmmss");
		if(begin==null){
			begin=new java.util.Date(end.getTime()-SH.getTimeDay()*7);
		}
		String[] nups = SH.p(request,"nups").split(",");
		//Create response
		JSONObject msg = new JSONObject();
		//***************************
		//HEADER
		//***************************
		msg.put("version", SH.cs("api.nups.pharmacy.version","0.1"));
		msg.put("timestamp",SH.formatDate(new java.util.Date(),"yyyyMMddHHmmss"));
		if(SH.p(request,"requestid").length()>0){
			msg.put("requestid",SH.p(request,"requestid"));
		}
		JSONObject o = new JSONObject();
		o.put("uid",SH.cs("MAYELEServerId","0"));
		o.put("label",SH.cs("MAYELEServerName","Demo Server"));
		msg.put("source",o);
		o = new JSONObject();
		o.put("begin",SH.cs("begin",SH.formatDate(begin,"yyyyMMddHHmmss")));
		o.put("end",SH.cs("begin",SH.formatDate(end,"yyyyMMddHHmmss")));
		msg.put("period",o);
		//***************************
		//PRODUCTS
		//***************************
		JSONArray products = new JSONArray();
		for(int n=0;n<nups.length;n++){
			String nupscode=nups[n];
			JSONObject product = new JSONObject();
			product.put("nups",nupscode);
			ps=conn.prepareStatement("select * from nupsref where nups=?");
			ps.setString(1,nupscode);
			rs=ps.executeQuery();
			if(rs.next()){
				product.put("label",SH.c(rs.getString("fr")).split(";")[0]);
				//***************************
				//Run through all stocks that contain the product
				//***************************
				JSONArray stocks = new JSONArray();
				Vector<Product> l_products = Product.getProductsByNomenclature(nupscode);
				for(int i=0;i<l_products.size();i++){
					Product l_product = l_products.elementAt(i);
					if(product!=null){
						Vector<ProductStock> productStocks = ProductStock.find("", l_product.getUid(), "", "", "", "", "", "", "", "", "", "", "");
						for(int s=0;s<productStocks.size();s++){
							ProductStock productStock = productStocks.elementAt(s);
							JSONObject stock = new JSONObject();
							stock.put("code",productStock.getServiceStockUid());
							stock.put("label",productStock.getServiceStock().getName());
							//***************************
							//Run through all batches in this productstock
							//***************************
							Batch.getAllBatches(productStock.getUid());
							stocks.put(stock);
						}
					}
				}
				product.put("stock",stocks);
			}
			else{
				product.put("label","Unnknow NUPS code");
			}
			products.put(product);
			rs.close();
			ps.close();
		}
		msg.put("products",products);
		out.print(msg.toString());
		if(rs!=null){
			rs.close();
		}
		if(ps!=null){
			ps.close();
		}
		conn.close();
	}
%>
