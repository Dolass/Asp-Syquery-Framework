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

$.execute("evio", function(H){
	var t = $("test");
	
	
	var x = '{ "a" : 1, "b" : 2 }';
	x = $.parseJSON(x);
	$.echo(x.b);
	
});

%>