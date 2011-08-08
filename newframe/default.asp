<!--#include file="syQuery.asp" -->
<%

//var S = $("newNameSpace");
//S = S(["123", "456", "789"], {});
//
//for ( var i in S )
//{
//	$.echo(i + " : " + S[i] + "<br />");
//}

$.add("evio", function(){
	var form = function(){
		this.length = 1;
	}
	$.augment(form, {
		abc : 1
	});
	
	return form;
});

$.execute("date", function(DATE){
	$.echo(DATE.now("z"))
//	var date = new DATE();
//	for ( var i in date )
//	{
//		$.echo( i + " : " + date[i] + "<br />" );
//	}
});

%>