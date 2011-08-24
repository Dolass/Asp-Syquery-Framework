<!--#include file="../src/syQuery.asp" -->
<!--#include file="../src/syQuery.upload.asp" -->
<!--#include file="../src/syQuery.fso.asp" -->
<%
$.execute("upload", function(upload){
	var U = new upload();
	U.uploadType.push("txt");
	U.uploadType.push("js");
	var O = U.upload({
		onError :function(e){
			$.echo("upload error : " + e.message)
		}
	});
	
	for ( var i in O ){
		$.echo("<li>" + i + " : " + O[i].size + " : " + O[i].fileSavePath +"</li>");
	}
})
%>