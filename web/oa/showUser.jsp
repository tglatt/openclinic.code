Solution exercice 1:
================================
<%@page import="net.admin.*"%>
<%
	User user = User.get(4);
%>

Nom: <%= user.person.lastname %><br/>
Prénom: <%= user.person.firstname %><br/>

================================

Exercice 2: vérifiez si le mot de passe de l'utilisateur avec 
ID 4 est "openclinic" dans oa/validateUser.jsp
	
Exercice 3: vérifiez si l'utilisateur avec ID 4 est un 
administrateur système	 (valeur du paramètre "sa") dans 
oa/checkSA.jsp
