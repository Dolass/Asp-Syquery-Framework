<!--#include file="../src/syQuery.asp" -->
<!--#include file="../src/syQuery.data.asp" -->
<%
$.execute("data", function(D){
	var x = D.open("PBLog4.mdb");
	if ( x.success ){
		var conn = x.object;
		D.select("select * from blog_Keywords", function(R, C){
			this.each(function(i, r){
				$.echo(r("key_Text").value + "<br />");
			});
		}, conn);
	}
	D.close(x.object);
});
%>
