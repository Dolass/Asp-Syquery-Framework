<!--#include file="../src/sizzle.asp" -->
<%
Response.Charset = "UTF-8";
sizzle.use("/demo/c", function(e){
	var t = Array.prototype;
	for ( var i in t ){
		fn.write("<br />" + i);
	}
	
	new Date().format("y-m-d h:i:s").write();

})
%>