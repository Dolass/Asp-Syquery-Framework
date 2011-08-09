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

$.execute("date, session, cookie", function(D, S, C){

	var Cookie = new C();
	Cookie.init("key").set("123").keep("day(3)");

//	for ( var i in l )
//	{
//		$.echo( i + " : " + Cookie[i] + "<br />" );
//	}
});

%>
<script>
document.write(unescape(document.cookie))
</script>