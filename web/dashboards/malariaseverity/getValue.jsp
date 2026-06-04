<%@include file="/includes/validateUser.jsp"%>
<%
	Hashtable<String,String> diagnoses = new Hashtable<String,String>();
	String labels = "'"+getTranNoLink("gfmalaria","simple",sWebLanguage)+"','"+getTranNoLink("gfmalaria","severe",sWebLanguage)+"','"+getTranNoLink("gfmalaria","other",sWebLanguage)+"','?'";
	Vector<TransactionVO> transactions = MedwanQuery.getInstance().getTransactionsByTypeBetween("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GF_MALARIA_ADMISSION", SH.getDateAdd(SH.getToday(), -SH.getTimeDay()*30), SH.getTomorrow());
	for(int n=0;n<transactions.size();n++){
		TransactionVO transaction = transactions.elementAt(n);
		String diag=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRESUMEDDIAGNOSIS");
		if(diag.length()>0){
			diagnoses.put(transaction.getEncounter().getUid(),diag);
		}
		else if(diagnoses.get(transaction.getEncounter().getUid())==null){
			diagnoses.put(transaction.getEncounter().getUid(),"99;");
		}
	}
	transactions = MedwanQuery.getInstance().getTransactionsByTypeBetween("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GF_MALARIA_DISCHARGE", SH.getDateAdd(SH.getToday(), -SH.getTimeDay()*30), SH.getTomorrow());
	for(int n=0;n<transactions.size();n++){
		TransactionVO transaction = transactions.elementAt(n);
		String diag=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FINALDIAGNOSIS");
		if(diag.length()>0){
			if(diag.length()>0){
				diagnoses.put(transaction.getEncounter().getUid(),diag);
			}
			else if(diagnoses.get(transaction.getEncounter().getUid())==null){
				diagnoses.put(transaction.getEncounter().getUid(),"99;");
			}
		}
	}
	int simple=0,severe=0,other=0,unknown=0;
	Iterator<String> encounteruids = diagnoses.keySet().iterator();
	while(encounteruids.hasNext()){
		String id=encounteruids.next();
		if(diagnoses.get(id).equalsIgnoreCase("1;")){
			simple++;
		}
		else if(diagnoses.get(id).equalsIgnoreCase("2;")){
			severe++;
		}
		else if(diagnoses.get(id).equalsIgnoreCase("3;")){
			other++;
		}
		else if(diagnoses.get(id).equalsIgnoreCase("99;")){
			unknown++;
		}
	}
	String values = simple+","+severe+","+other+","+unknown;
%>
{
	data: {
		labels: [<%=labels %>],
		datasets: [{
			data: [<%=values %>],
			backgroundColor: [
      			'rgb(54, 162, 235)',
				'rgb(255, 99, 132)',
      			'rgb(255, 205, 86)',
      			'lightgrey'
      		],
      		hoverOffset: 4
		}]
	}
}