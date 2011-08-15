<%
/**
 * @Project Name : 数据库操作类
 * @Project Info : 略
 */
$.add("data", function(){
	// 创建数据库操作对象实例
	var data = $("data"),
		core = function(object){
			this.length = 0;
			this.object = object || null;
		};
	
	// 次级对象扩展
	$.augment(core, {
		each : function(callback){
			var _Core = this[0], 
				i = 0;
				
			_Core.MoveFirst();
			while ( !_Core.Eof )
			{
				callback(i, _Core);
				_Core.MoveNext();
				i++;
			}
			
			return this;
		}
	});
	
	// 原型扩展
	$.mix(data, {
		open : function(options, object){
			if ( object == undefined ) object = new ActiveXObject($.config.ActivexObject.conn);
			var setting = {
					method	 : "access", // 数据库模式
					userName : "",	// 用户名
					userPass : "",	// 密码
					serverNs : "",	// 服务器地址或者Access文件路径
					baseName : ""	// 服务器名字
			};
			
			if ( $.isString(options) ){ 
				setting.serverNs = options; 
			}else if ( $.isJson(options) ){ 
				setting = $.extend( setting, options ); 
			}

			var	json = tryOpen(object, setting, 0);
			
			return {
				success : json.success,
				object : json.object
			}
		},
		
		close : function(object){
			try{
				object.Close();
				object = null;
			}catch(e){ object = null; }
		},
		
		select : function(sql, callback, conn, rs, moden, type){
			var _this 	= 	this, retValue;
				moden 	= 	moden 	== 	undefined ? 1 : moden;
				type 	= 	type 	== 	undefined ? 1 : type;
				rs 		= 	rs 		== 	undefined ? new ActiveXObject($.config.ActivexObject.record) : rs;
				conn 	= 	conn 	== 	undefined ? new ActiveXObject($.config.ActivexObject.conn) : conn;
			
			if ( $.isArray(sql) ){
				sql.each(function(i, k){
					return _this.select(k, callback, rs, conn, moden, type);
				});
			}else{
				rs.Open(sql, conn, moden, type);
				retValue = callback.call([rs].toQuery(new core()), rs, conn);
				rs.Close();
				return retValue;
			}
		}
	});
	
	$.fn.extend({
		
	});
	
	function rootDefault(i){
		var _nice = "";
		for ( var j = 0 ; j < i ; j++ ){ _nice += "../";}
		return _nice;
	}
	
	function SQLSTR(setting, i){
		return setting.method === "access" ?
		"provider=Microsoft.jet.oledb.4.0;data source=" + Server.MapPath(rootDefault(i) + setting.serverNs) :
		"PROVIDER=MSDASQL;DRIVER={SQL Server};SERVER=" + setting.serverNs + ";DATABASE=" + setting.baseName + ";UID=" + setting.userName + ";PWD=" + setting.userPass + ";";
	}
	
	function tryOpen(obj, defaults, j){
		if ( j >= 10 ){ return { success : false, object : null } }
		try{
			obj.Open(SQLSTR(defaults, j));
			return { success : true, object : obj }
		}catch(ex){
			return tryOpen(obj, defaults, ++j);
		}
	}
	
	return data;
});
%>