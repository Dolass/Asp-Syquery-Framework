<!--#include file="../src/syQuery.asp" -->
<!--#include file="../src/syQuery.fso.asp" -->
<%
$.execute("fso", function(F){
	F("111").name("555", true)
});
%>
