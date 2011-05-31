<%
/**
 * Project Name : "Adodb.RecordSet" ActivexObject
 * Project Author : evio
 * CreateTime : 2011-04-14
 * Project Version : 2.0
 */
;(function(){
	
	$.extend({
		
		// 返回connection对象
		conn : function(){
			return $.active($.config.ActivexObject.conn);
		},
		
		/**
		 * 打开数据库的方法
		 * option <string | json> 配置信息
		 * obj <object> connection对象
		 * 返回值 : <boolean> true | false
		 */
		open : function(options, obj){
			if ( options == undefined ) {
				$.setError("未定义错误");
				return { success : false, object : null }
			}
			if ( obj == undefined || !$.isObject(obj) ){
				obj = $.conn();
			}
			var setting = {
				method	 : "access", // 数据库模式
				userName : "",	// 用户名
				userPass : "",	// 密码
				serverNs : "",	// 服务器地址或者Access文件路径
				baseName : ""	// 服务器名字
			}, parentBasePath = function(i){
				var s = ""; 
				for (var o = 0 ; o < i ; o++)
				{ 
					s += "../";
				} 
				return s;
			}, SQL = function(setting, i){
				return setting.method === "access" ?
						"provider=Microsoft.jet.oledb.4.0;data source=" + Server.MapPath(parentBasePath(i) + setting.serverNs) 
						:
						"PROVIDER=MSDASQL;DRIVER={SQL Server};SERVER=" + setting.serverNs + ";DATABASE=" + setting.baseName + ";UID=" + setting.userName + ";PWD=" + setting.userPass + ";";
			}, tryToOpen = function(obj, defaults, j){
				if ( num >= 10 ){ 
					$.setError("未找到指定的Access数据库文件");
					return { success : false, object : null } 
				}
				try{ 
					tempSQL = SQL(defaults, j);
					obj.Open(tempSQL);
					return { success : true, object : obj }
				}catch(ex){ 
					num++; 
					return tryToOpen(obj, defaults, ++j);
				}
			}, num = 0;
			
			// extend the options
			if ( $.isString(options) ){ setting.serverNs = options; }else if ( $.isJson(options) ){ setting = $.extend( setting, options ); }
			
			// try to open conn
			try{ return tryToOpen(obj, setting, 0); }catch(e){ 
				$.setError(e.message);
				return { success : false, object : null } 
			}
		},
		recloy : {
			sysLoop : function(rs, fn){
				rs.MoveFirst();
				while ( !rs.Eof )
				{
					fn.call(rs);
				}
			}
		},
		msProtect : function( c, options ){
			// options.success
			// options.failure
			if ( options != undefined ){
				c.BeginTrans();
				try{
					if ( $.isFunction( options.success ) ) options.success();
					c.CommitTrans();
				}catch(e){
					if ( $.isFunction( options.failure ) ) options.failure(e);
					c.RollbackTrans();
				}
			}
		},
		
		record : function( options ){
			/**
			 * options 配置
			 * 		# rs 			<object> 	recordset对象
			 *		# conn			<object>	数据库连接对象
			 *		# hook			<json>		批量数据
			 *			- sql 		<string> 	语句
			 *			- type 		<number> 	操作类型
			 *			- callback	<function> 	回调方法
			 *		# complete 		<function>	所有操作完成后回调方法
			 *		# protect		<boolean>	是否使用事务处理机制
			 *		# onError  		<function>	错误的回调方法(仅使用与事务处理模式)
			 */
			 
			if ( options == undefined ) 		return $.active($.config.ActivexObject.record);
			if ( !$.isJson(options) ) 			return null;
			if ( options.conn == undefined ) 	return null;
			if ( options.rs == undefined ) 		options.rs = $.active($.config.ActivexObject.record);
			if ( options.hook == undefined )	return options.rs;
			if ( $.isJson(options.hook) )		options.hook = [options.hook];
			if ( !$.isArray(options.hook) ) 	return options.rs;
			
			// 内置循环核心方法
			var mainContent = function()
			{
				for ( var i = 0 ; i < options.hook.length ; i++ )
				{
					var j = options.hook[i];
					if ( j.sql == undefined ) continue ;
					if ( j.type == undefined ) continue ;

					options.rs.Open(j.sql, options.conn, 1, j.type);
					
					if ( $.isFunction(j.callback) )
					{
						if ( j.callback.call( $.recloy, options.rs, options.conn ) == false ) continue ;
					}
					
					options.rs.Close();
				}
			}
			
			// 保护模式
			if ( options.protect == true ) {
				$.msProtect(options.conn, {
					success : mainContent, 
					failure : options.onError
				});
			}else{
				mainContent();
			};
			
			// 完成模式
			if ( $.isFunction(options.complete) ) options.complete();
		},
		
		rows : function(obj){
			// obj --> rs
			var tansArray = function( arr, fieldslen ){
				var len = arr.length / fieldslen, data=[], sp; 
				for( var i = 0; i < len ; i++ ) { 
					data[i] = new Array(); 
					sp = i * fieldslen; 
					for( var j = 0 ; j < fieldslen ; j++ ) { data[i][j] = arr[sp + j] ; } 
				}
				return data; 
			};
			var tempArr = [];
			try{ tempArr = obj.GetRows().toArray(); }catch(e){}
			return tansArray( tempArr, obj.Fields.Count );	  
		}
	});
	
	$.fn.extend({
		select : function( conn, rs )
		{
			var Arr = $.map(this, function( i, k ){
				if ( !$.isJson(k) ) return null;
				if ( k.type == undefined ) k.type = 3;
				return k;
			});
			if ( Arr.length > 0 )
			{
				$.record({ rs : rs, conn : conn, hook : Arr});
			}
		},
		/**
		 * k <json> 配置数据
		 *		- table 		<string>		表名
		 *		- method		<string>		执行方法名
		 *		- data			<data>			数据
		 *		- pKey			<string>		主键
		 *		- pKeyValue		<anyobject>		主键值
		 *		- callback		<function>		回调方法
		 */
		record : function( conn, options, rs ){
			var Arr = $.map(this, function( i, k ){
				if ( k != undefined ){
					var temp_json = {}
					
					if ( k.method === "update" || k.method === "delete" )
					{
						temp_json.sql = "Select * From " + k.table + " Where " + k.pKey + "=" + k.pKeyValue; 
						temp_json.type = 3;
					}else{
						temp_json.sql = "Select * From " + k.table;
						temp_json.type = 2;
					}
					
					temp_json.callback = function( r, c ){
						if ( k.method === "insert" ) { r.AddNew(); }
						var t, d;
						if ( $.isFunction( k.callback ) ){
							t = k.callback.call(r, c);
						}
						if ( t == false ) return;
						d = k.data;
						if ( k.method === "delete" ){
							r.Delete();
						}else{
							if ( $.isJson(d) ) d = [d];
							for ( var i = 0 ; i < d.length ; i++ )
							{
								r(d[i].key) = d[i].text;
							}
							r.Update();
						}
					}
					
					return temp_json;
				}else{
					return null;
				}
			});

			var p = { rs : rs, conn : conn, hook : Arr }
			if ( options != undefined ){
				if ( options.complete != undefined ) p.complete = options.complete;
				if ( options.protect != undefined ) p.protect = options.protect;
				if ( options.onError != undefined ) p.onError = options.onError;
			}
			$.record(p);
		},
		
		insert : function(conn, table, pKey, callback){
			var data = this.toArray(), dataJson = {
				table : table,
				method : "insert",
				data : data,
				pKey : pKey
			};
			if ( callback != undefined ) dataJson.callback = callback;
			$(dataJson).record(conn);
		},
		
		update : function(conn, table, pKey, pKeyValue, callback){
			var data = this.toArray(), dataJson = {
				table : table,
				method : "update",
				data : data,
				pKey : pKey,
				pKeyValue : pKeyValue
			};
			if ( callback != undefined ) dataJson.callback = callback;
			$(dataJson).record(conn);
		},
		
		scrap : function(conn, table, pKey, pKeyValue, callback){
			var data = this.toArray(), dataJson = {
				table : table,
				method : "delete",
				data : data,
				pKey : pKey,
				pKeyValue : pKeyValue
			};
			if ( callback != undefined ) dataJson.callback = callback;
			$(dataJson).record(conn);
		}
	});
})();
%>