<!--#include file="../src/syQuery.asp" -->
<!--#include file="../src/syQuery.data.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
</head>
<body>
<ul>
<%
$.execute("data,cache", function(data, cache){
	var D = data.open("PBLog4.mdb");
	if ( D.success ){
		data.select("select key_Text,key_URL,key_Image From blog_Keywords", function(){
			var args = this.page(18, 1, function(rs, i){
				//$.echo(rs("key_Text").value +  i +"<br />");
			}, this);
			args.push(function(i, b, t, s, c){
				$.echo("<li>" + i + "</li>");
			});
			
			this.pageBar.apply(this, args);
		}, D.object)
	}else{
		
	}
})
%>
</ul>
</body>
</html>