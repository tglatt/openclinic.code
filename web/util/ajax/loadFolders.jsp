<%@page import="be.openclinic.util.Nomenclature"%>
<%@page import="be.openclinic.archiving.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<table width='100%'>
<%
	String folder = checkString(request.getParameter("folder"));
	Nomenclature folderref = Nomenclature.get("library",folder);
	String foldername="&nbsp;<img height='16px' src='"+sCONTEXTPATH+"/_img/icons/mobile/home.png'/>/";
	if(folderref!=null){
		foldername = "<a href='javascript:setFolder(\"\")'><img height='16px' src='"+sCONTEXTPATH+"/_img/icons/mobile/home.png'/>/</a>>"+folderref.getFullyQualifiedNameLibrary(sWebLanguage);
	}
	out.println("<tr><td>"+foldername+"</td></tr>");
	//We get all childfolders for this folder
	Vector<Nomenclature> subfolders = Nomenclature.getChildren("library", folder);
	for(int n=0;n<subfolders.size();n++){
		Nomenclature nomenclature = subfolders.elementAt(n);
		Vector references = Nomenclature.getAllChildren("library", nomenclature.getId());
		Vector refs=new Vector();
		refs.add("library."+nomenclature.getId());
		for(int i=0;i<references.size();i++){
			Nomenclature ref = (Nomenclature)references.elementAt(i);
			refs.add("library."+ref.getId());
		}
		Vector<ArchiveDocument> documents = ArchiveDocument.getActiveByReferences(refs);
		out.println("<tr><td>"+(references.size()==0 && documents.size()==0?"<img style='vertical-align: middle' src='"+sCONTEXTPATH+"/_img/themes/default/menu_tee_flat.gif'/>":"<a href='javascript:setFolder(\""+nomenclature.getId()+"\")'>"+(references.size()>0?"<img style='vertical-align: middle' src='"+sCONTEXTPATH+"/_img/themes/default/menu_tee_plus.gif'/>":"<img style='vertical-align: middle' src='"+sCONTEXTPATH+"/_img/themes/default/menu_tee_flat.gif'/>")+(documents.size()>0?"<b>":""))+getTranNoLink("library",nomenclature.getId(),sWebLanguage)+(documents.size()>0?"</b>":"")+" ["+documents.size()+" "+getTran(request,"web","documents",sWebLanguage)+"]"+(references.size()==0 && documents.size()==0?"":"</a>")+"</td></tr>");
	}
	
%>
</table>