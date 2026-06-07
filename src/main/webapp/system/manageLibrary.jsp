<%@page import="java.io.*,org.apache.commons.io.*"%>
<%@page import="be.openclinic.archiving.ArchiveDocument,be.openclinic.system.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
                
<%=checkPermission(out,"system.management","select",activeUser)%>
<%=sJSPROTOTYPE %>

<%
	Hashtable hParameters = SH.getMultipartFormParameters(request);
	String sFolderName = SH.c((String)hParameters.get("folderName"));
	String sFolderCode = SH.c((String)hParameters.get("folderCode"));
    FormFile formFile = (FormFile)hParameters.get("docFile");


	String SCANDIR_BASE = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_basePath","/var/tomcat/webapps/openclinic/scan");
    String sFolderStore = SCANDIR_BASE+"/"+MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirFrom","from");
    String sDocumentStore = SCANDIR_BASE+"/"+MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo","to");

    if(formFile!=null){
	    String sFileName = formFile.getFilename();
        if(sFileName.trim().length()>0 && SH.isAcceptableUploadFileExtension(sFileName)){
            try{
                //We creëren een nieuw archiving document
             	String sSql = "INSERT INTO arch_documents (arch_document_serverid, arch_document_objectid, arch_document_udi,"+
              	"  arch_document_title, arch_document_description, arch_document_author, arch_document_destination, arch_document_category,arch_document_date, arch_document_reference,"+
	  	        "  arch_document_updatetime, arch_document_updateid,arch_document_tran_serverid)"+
                " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,-1)";		
                Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = conn.prepareStatement(sSql);
                ps.setInt(1,MedwanQuery.getInstance().getConfigInt("serverId",1));
                int objectId=MedwanQuery.getInstance().getOpenclinicCounter("ARCH_DOCUMENTS");
                String sUDI=ArchiveDocument.generateUDI(objectId);
                ps.setInt(2,objectId);
                ps.setString(3,sUDI);
                ps.setString(4,(String)hParameters.get("docTitle"));
                ps.setString(5,(String)hParameters.get("docDescription"));
                ps.setString(6,(String)hParameters.get("docAuthor"));
                ps.setString(7,(String)hParameters.get("docVersion"));
                ps.setString(8,"library");
                ps.setTimestamp(9, new Timestamp(new java.util.Date().getTime()));
                ps.setString(10,"library."+sFolderCode);
                ps.setTimestamp(11, new Timestamp(new java.util.Date().getTime()));
				ps.setString(12,activeUser.userid);
				ps.execute();
				ps.close();
				conn.close();
				String sUid=sUDI+"."+FilenameUtils.getExtension(sFileName);
				formFile.store(SH.getScanDirectoryFromPath()+"/"+sUid);
	        }
	        catch(Exception e){
	        	Debug.printStackTrace(e);
	        }
        }
    }    
%>

<form name='transactionForm' method='post' enctype='multipart/form-data'>
	<table width='100%'>
		<tr class='admin'><td colspan='2'><%=getTran(request,"web.manage","managelibrary",sWebLanguage) %></td></tr>
		<tr style='vertical-align: middle'>
			<td class='admin' width='1%' nowrap><%=getTran(request,"web","folder",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
                <input class="text" type="text" name="folderName" id="folderName" READONLY size="<%=sTextWidth%>" title="<%=sFolderName%>" value="<%=sFolderName%>">
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchFolder('folderCode','folderName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.folderCode.value='';transactionForm.folderName.value='';loadDocuments();">
                <input type="hidden" name="folderCode" id="folderCode" value="<%=sFolderCode%>" onchange='loadDocuments();'>&nbsp;
				<input type='button' class='button' name='newDocumentButton' value='<%=getTranNoLink("web","newdocument",sWebLanguage) %>' onclick='newDocument();'/>
				<input type='button' class='button' name='newButton' value='<%=getTranNoLink("web","newsubfolder",sWebLanguage) %>' onclick='newFolder();'/>
				<input type='button' class='button' name='editButton' value='<%=getTran(request,"web","edit",sWebLanguage) %>' onclick='edit("");'/>
			</td>
		</tr>
	</table>
	<div id='divDocuments'></div>
</form>
<IFRAME style="display:none" id='hf2'  name="hidden-form"></IFRAME>

<script>
	function edit(){
	    openPopup("/system/manageLibraryFolder.jsp&ts=<%=getTs()%>&folderCodeInit="+document.getElementById("folderCode").value+"&folderNameInit="+document.getElementById("folderName").value+"&returnFolderCode=folderCode&returnFolderName=folderName&returnFunction=loadDocuments()&PopupWidth=500");
	}
	
	function newFolder(){
	    openPopup("/system/manageLibraryFolder.jsp&ts=<%=getTs()%>&action=new&parentFolderCode="+document.getElementById("folderCode").value+"&parentFolderName="+document.getElementById("folderName").value+"&returnFolderCode=folderCode&returnFolderName=folderName&returnFunction=loadDocuments()&PopupWidth=500");
	}
	
	function searchFolder(folderCode,folderName){
	    openPopup("/_common/search/searchNomenclatureGeneral.jsp&ts=<%=getTs()%>&Mode=manage&FindType=library&VarCode="+folderCode+"&VarText="+folderName);
	}
	
	function loadDocuments(noloader){
		if(!noloader){
			document.getElementById('divDocuments').innerHTML = "&nbsp;&nbsp;<img style='vertical-align: middle' height='10px' src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
		}
	    var params = "folderCode="+document.getElementById("folderCode").value;
		var url = "<%=sCONTEXTPATH%>/util/ajax/loadLibraryDocuments.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			if(document.getElementById('divDocuments').innerHTML!=resp.responseText){
				document.getElementById('divDocuments').innerHTML=resp.responseText;
			}
			if(resp.responseText.indexOf('ajax-loader')>-1){
				window.setTimeout('loadDocuments(true)',2000);
			}
		}
		});
	}
	
	function deleteDocument(serverid,objectid){
		if(window.confirm('<%=getTranNoLink("web","areyousure",sWebLanguage)%>')){
		    var params = "serverid="+serverid+"&objectid="+objectid;
			var url = "<%=sCONTEXTPATH%>/util/ajax/deleteDocument.jsp";
			new Ajax.Request(url,{
			method: "POST",
			parameters: params,
			onSuccess: function(resp){
				loadDocuments();
			}
			});
		}
	}
	
	function newDocument(){
	    document.getElementById('divDocuments').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
	    var params = "folderCode="+document.getElementById("folderCode").value;
	    var url = "<%=sCONTEXTPATH%>/util/ajax/newDocumentTemplate.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			document.getElementById('divDocuments').innerHTML=resp.responseText;
		}
		});
	}
	
	function editDocument(documentid){
	    document.getElementById('divDocuments').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
	    var params = "documentid="+documentid;
	    var url = "<%=sCONTEXTPATH%>/util/ajax/editDocumentTemplate.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			document.getElementById('divDocuments').innerHTML=resp.responseText;
		}
		});
	}
	
	function getFile(filename){
		var url = "<c:url value='util/getDocument.jsp?document='/><%=sDocumentStore%>/"+filename;
		window.open(url,"hidden-form");
	}
	
	loadDocuments();
</script>