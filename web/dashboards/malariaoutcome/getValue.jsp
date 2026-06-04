<%@include file="/includes/validateUser.jsp"%>
<%
	Hashtable<String,String> outcomes = new Hashtable<String,String>();
	String labels = "'"+getTranNoLink("gfmalaria.evolution2","1",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","2",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","3",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","4",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","5",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","6",sWebLanguage)+"'";
	Vector<TransactionVO> transactions = MedwanQuery.getInstance().getTransactionsByTypeBetween("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GF_MALARIA_DISCHARGE", SH.getDateAdd(SH.getToday(), -SH.getTimeDay()*30), SH.getTomorrow());
	for(int n=0;n<transactions.size();n++){
		TransactionVO transaction = transactions.elementAt(n);
		String outcome=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVOLUTION");
		if(outcome.length()>0){
			outcomes.put(transaction.getEncounter().getUid(),outcome);
		}
	}
	int[] counts = {0,0,0,0,0,0};
	Iterator<String> encounteruids = outcomes.keySet().iterator();
	while(encounteruids.hasNext()){
		String id=encounteruids.next();
		counts[Integer.parseInt(outcomes.get(id))-1]++;
	}
	String values = counts[0]+","+counts[1]+","+counts[2]+","+counts[3]+","+counts[4]+","+counts[5];
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
      			'black',
      			'lightgreen',
      			'lightgrey'
      		],
      		hoverOffset: 4
		}]
	}
}