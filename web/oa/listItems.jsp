<%@page import="java.text.SimpleDateFormat,be.openclinic.system.SH,java.util.*"%>
<%@page import="be.mxs.common.model.vo.healthrecord.*"%>
<!-- Etape 1: cherchez le dossier médical (HealthRecordVO) pour patient ID=0 -->
<%	
	HealthRecordVO healthrecord = HealthRecordVO.getFromPersonId("0");
	//Etape 2: cherchez la liste de documents (TransactionVO) dans le dossier médical 
	//et affichez la date et le type du document
	Vector<TransactionVO> transactions = 
		TransactionVO.getTransactionsForHealthrecordId(healthrecord.getHealthRecordId());
	for(int n=0;n<transactions.size();n++){
		TransactionVO transaction = transactions.elementAt(n);
		out.println(
			new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())+": "+
			transaction.getTransactionType()+"<br/>");
		// Etape 3: pour chaque document, cherchez la liste des items (ItemVO)
		// et affichez le type et la valeur de chaque item
		Vector<ItemVO> items = new Vector(transaction.getItems());
		for(int i=0;i<items.size();i++){
			ItemVO item = items.elementAt(i);
			out.println("<li>"+item.getType()+": "+item.getValue()+"</li>");
		}
	}
%>
 