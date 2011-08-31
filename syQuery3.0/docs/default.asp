<!--#include file="../src/syQuery.asp" -->
<!--#include file="../src/syQuery.cache.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
</head>
<body>
<%
$.execute("data,cache", function(data, cache){
	var D = data.open("PBLog4.mdb");
	if ( D.success ){
		var C = new cache(D.object);
		var T = C.load("as",  2, "select key_Text,key_URL,key_Image From blog_Keywords");
		$.echo(T)
		D.object.Close();
		var a = "1+2";
		var b = eval(a);
		$.echo(b)
	}else{
		
	}
})
%>
</body>
</html>