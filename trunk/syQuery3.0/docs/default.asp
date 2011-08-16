<!--#include file="../src/syQuery.asp" -->
<!--#include file="../src/syQuery.data.asp" -->
<%
$.execute("data", function(D){
	var x = D.open("PBLog4.mdb");
	if ( x.success ){
		var conn = x.object;
		var t = D.insert({
			"key_Text" : "123",
			"key_URL" : "http://syblog.net",
			"key_Image" : "111111"
		}, "blog_Keywords", function(r, c){
			return r("key_ID").value;
		}, conn);
		$.echo(t);
	}
	D.close(x.object);
});
%>
