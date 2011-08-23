<!--#include file="../src/syQuery.asp" -->
<!--#include file="../src/syQuery.xml.asp" -->
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
$.execute("xml", function(xml){
var o1 = '<?xml version="1.0" encoding="utf-8"?><webRoot t2="a"><element_1><element_2><element_3>test</element_3></element_2></element_1></webRoot>';
var o2 = "test.xml";
var o3 = "dafdsfasdjkfhjksdhfjashd";

var root = xml.load(o2);

if ( root ){
	root.getElementsByTagName("element_2").parent().each(function(i, k){
		$.echo(k.tagName)
	});
//	root.saveXML("1.xml");
//	$.echo("ok")
}else{
	//$.echoError("<br />")
}

});
%>
</body>
</html>