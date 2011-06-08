<!--#include file="../../config.asp" -->
<!--#include file="../../public/system/module.class.asp" -->
<%
API.run(function(){
	var module = new syQuery.module(),
		_cache = new syQuery.application(),
		_fo = $.query("fo") || "";
		
	if ( _fo.length == 0 ){
		$.echo($.makeJson({ success : false, message : "缺少参数，无法安装。" }));
		return;
	}
		
	module.root = "../../";	
	_cache.root = "../../private/cache";
	
	var xmlConfig = module.open(_fo),
		connConfig = this["db_open"];
		
	if ( xmlConfig.success ){
		if ( connConfig.success ){
			if ( connConfig.object.Execute("select count(*) From [module] where [mo_mark]='" + xmlConfig.mark + "'")(0) > 0 )
			{
				$.echo($.makeJson({ success : false, message : "插件已安装，无需再次安装。" }));
			}
			else
			{
				module.inData(xmlConfig, connConfig.object, function(){
					_cache.conn = connConfig.object;
					_cache.write(cache.module);
				});
				module.move(_fo);
				$.echo($.makeJson({ success : true, message : "插件安装成功。" }));
			}
			API.use("db-close", [connConfig.object]);
		}else{
			$.echo($.makeJson({ success : false, message : $.getError() }));
		}
	}else{
		$.echo($.makeJson({ success : false, message : xmlConfig.message }));
	}
	
},{ "db_open" : [] });
%>