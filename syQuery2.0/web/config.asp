<!--#include file="public/lib/syQuery-min.asp" -->
<!--#include file="public/lib/syQuery.framework-min.asp" -->
<%
// 创建新的运行实例
var API = new syQuery(), 
	// 缓存前缀
	cacheMark = "evio_" , 
	// 缓存列表
	cachelist = {
		module : {
			area : ["id", "mo_name", "mo_msg", "mo_mark", "mo_fo", "mo_start", "mo_istitle", "mo_root", "mo_setuptime", "mo_active", "mo_author", "mo_url"],
			sql : function(){ return "Select "+ this.area.join(",") +" From [module]"; },
			key : cacheMark + "module"
		}
	},
	
	cache = {
		module : {
			area : cachelist.module.area,
			sql : cachelist.module.sql(),
			key : cachelist.module.key,
			isfile : true,
			isapp : true,
			isdb : true
		}
	};

// 增加数据库创建模块
API.add("db_open", function(){
	// 你可以配置新的数据项
	return $.open("private/database/API.mdb");
});

API.add("db-close", function(db){
	// 关闭数据库连接
	db.Close();
	db = null;
});

%>