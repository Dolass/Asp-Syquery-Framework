<!--#include file="../build/syQuery-min.asp" -->
<!--#include file="../src/syQuery.data.asp" -->
<%
$.execute("data", function(D){
	var x = D.open("PBLog4.mdb");
	$.echo(x.success);
});
%>
