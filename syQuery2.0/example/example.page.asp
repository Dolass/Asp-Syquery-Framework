<!--#include file="../build/syQuery-min.asp" -->
<!--#include file="../src/syQuery.framework.asp" -->
<%
Server.ScriptTimeout = 10;
Response.Buffer = true;
;(function(){
	var c = $.open("syblog.mdb");
	if ( c.success ){
		
		var page = new syQuery.page();
		var time1 = syQuery.timer();
		page.init({
			table : "syblog_picture",
			area : ["picture_id", "picture_name", "picture_mark"], // 字段集合
			key : "picture_id", // 主键
			absolutePage : 11, // 当前页
			pagesize : 100, // 每条记录条数
			where : null, // 条件
			order : null, //排序
			conn : c.object,
			callback : function(rs){
				//1131329
				$.echo(rs(1).value + "[" + rs(0).value + "]" + "<br />")
			}
		});

//		var arr = ["evio1", "evio2", "evio3", "evio4", "evio5", "evio6"];
//		page.init(arr, 5, 1, function(t, i){
//			$.echo( t + " : " + i + "<br />" )
//		})

//		var x = page.pagebar(101, 2, 10, 51), l = x.start, r = x.end;
//		$.echo(l)
//		while ( l <= r )
//		{
//			$.echo( l + "<br />");
//			l++
//		}
		var time2 = syQuery.timer();
		$.echo("运行时长：" + (time2 - time1) + "MS");
		c.object.Close();
		c.object = null;
	}else{
		$.echo($.getError());
	}
})();
%>