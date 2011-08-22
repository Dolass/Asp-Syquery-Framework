<!--#include file="../src/syQuery.asp" -->
<!--#include file="../src/syQuery.stream.asp" -->
<!--#include file="../src/syQuery.xmlhttp.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<script src="../../jQueryFrameWork/jQuery.1.6.2.js" ></script>
<script src="../../jQueryFrameWork/jQuery.loader.js" ></script>
<title>无标题文档</title>
</head>
<body>
<%
$.execute("stream, xmlhttp", function(stream, xmlhttp){
	var STM = $("Stream"),
		X = new xmlhttp();
	X.setUrl("http://www.baidu.com").setDataType("binary").success(function(text){
		$.echo(STM(text).bin()[0]);
	}).send().abort();
	$.echoError("<br />")
});
%>
</body>
</html>