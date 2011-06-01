<%
/**
 * 加载器原型
 * author : evio
 * date : 2011/05/23
 */
;var syQuery = function( fn )
{
	this.data = { event : {}, keep : {} }
	
	var _init;
	
	if ( fn != undefined && $.isFunction(fn) )
	{
		_init = fn;
	}
	
	if ( _init != undefined ) _init();
}

/**
 * 为加载器扩展方法
 */
$.mix( syQuery, {
	/**
	 * 通用正则
	 */
	regExpress : {
		includeExp : /\<\!\-\-\#include\sfile\=\"(.+?)\"\s?\-\->/g,
		includeFileExp : /file\=\"(.+)\"/,
		includeContentForLeftExp : /^[\r\t\s\n]+/,
		includeContentForRightExp : /[\r\t\s\n]+$/
	},
	/**
	 * 框架版本号
	 */
	version : "2.0",
	/**
	 * 框架唯一标识
	 */
	mark : "F9A7KH02DA4",
	/**
	 * 框架所在目录
	 */
	path : "",
	/**
	 * 捕获文件
	 */
	catchFile : function(f, stream){
		// 兼容对象。如果不存在FSO对象，则自动创建该对象。
		// note f 为单文件路径
		if ( stream == undefined ) stream = $.stream();
		
		// 文件内容
		var len = f.split("/"), localFo = len.slice(0, -1).join("/");
		var context = $.load(f, stream, 2);
		
		return syQuery.catchContent(context, stream, localFo);
	},
	
	catchContent : function(context, stream, localFo){
		var l = 0, r = 0, text = "", p = "", e, t, tempText;
		if ( syQuery.regExpress.includeExp.test(context) ){
			while ( l > -1 ){
				l = context.indexOf("<" + "!--#include");
				if ( l > -1 ){
					text += context.substring(0, l);
					context = context.substring(l + 12);
					r = context.indexOf("-->");
					p = context.substring(0, r);
					e = $.trim(p.replace(" file=\"", "").replace("\"", ""));
					t = localFo + "/" + e;
					context = context.substring(r + 3);
					tempText = syQuery.catchFile(t, stream);
					text += syQuery.catchContent(tempText, stream, t.split("/").slice(0, -1).join("/"));
				}else{
					text += context;
					context = "";
				}
			}
			return text;
		}else{
			return context;
		}
	},
	
	filterContent : function(context){
		context = context.replace(syQuery.regExpress.includeContentForLeftExp, "").replace(syQuery.regExpress.includeContentForRightExp, "");
		function textformat(t){
			if ( t.length > 0 ){
				return ";Response.Write(\"" + t.replace(/\\/g, "\\\\").replace(/\"/g, "\\\"").replace(/\r/g, "\\r").replace(/\n/g, "\\n").replace(/\s/g, " ").replace(/\t/g, "\\t") + "\");";
			}else{
				return "";
			}
		}
		var conSplit = context.split("<" + "%"), r = 0, text = "", temp;
		for ( var i = 0 ; i < conSplit.length ; i++ )
		{
			r = conSplit[i].indexOf("%" + ">");
			if ( r > -1 ){
				temp = textformat(conSplit[i].substring(r + 2));
				text += (/^\=/.test(conSplit[i]) ? ";Response.Write(" + conSplit[i].substring(1, r) + ");" : conSplit[i].substring(0, r)) + temp;
			}else{
				text += textformat(conSplit[i]);
			}
		}
		return text;
	},
	
	/**
	 * include 动态加载文件
	 * param {string | array} f 文件名或者文件名组成的数组
	 * return null 
	 * support stream
	 */
	include : function( f ){
		if ( $.isArray(f) ){
			for ( var i = 0 ; i < f.length ; i++ )
			{
				syQuery.include(f[i]);
			}
		}else{
			eval(syQuery.filterContent(syQuery.catchFile(f)));
		}
	},
	
	augment : function(/*r, s1, s2, ..., ov, wl*/){
		var args = arguments, len = args.length - 2,
			r = args[0], ov = args[len], wl = args[len + 1],
			i = 1;

		if (!$.isArray(wl)) {
			ov = wl;
			wl = undefined;
			len++;
		}
		if (!$.isBoolean(ov)) {
			ov = undefined;
			len++;
		}

		for (; i < len; i++) {
			$.mix(r.prototype, args[i].prototype || args[i], ov, wl);
		}

		return r;
	},
	
	add : function(name, fn, config){
		// 设置一个静态的Function方法。
		syQuery[ name ] = function(){}
		
		if ( config != undefined ){
			fn( syQuery[name], config() );
		}else{
			fn( syQuery[name] );
		}	
	}
} );

(function(){
	var root = Server.MapPath("/"), local = Server.MapPath(".");
	// 循环获得路径
	function getLocalPath(){
		if ( root != local ){
			return (function(){
				var j = local.replace(new RegExp("^" + root.replace(/\\/g, "\\\\")), "").substring(1).split("\\").length, temp = "";
				for ( var i = 0 ; i < j ; i++ )
				{
					temp += "../";
				}
				return temp;
			})();
		}else{
			return "";
		}
	}
	
	syQuery.root = getLocalPath(); // 本框架相当于于网站根目录的上级位置集合字符串。
	
})();

syQuery.augment(syQuery, {
	
	add : function(name, fn){
		this.data.event[name] = fn;
	},
	
	use : function(name, config){		
		if ( config == undefined ) config = [];
		if ( !$.isArray(config) ) config = [config];
		
		if ( this.data.event[name] == undefined ) return;
		
		return this.data.event[name].apply(undefined, config);
	},
	
	run : function(fn, condition){
		var _this = this;
		/**
		 * condition 附加调用模块参数方法 name 模块名  [arguments] 参数组成的数组，用于传递。
		 * 		< { name1 : [arguments1], name2 : [arguments2] ... } >
		 */
		if ( condition != undefined )
		{
			for ( var c in condition )
			{
				_this.data.keep[c] = _this.use(c, condition[c] || []) || null;
			}
		}
		
		fn.call(_this.data.keep, _this);
		
	}
});

/**
 * 加载CACHE模块
 * 注意点： <object id="pjblog" runat="server" scope="Application" progid="Scripting.Dictionary"></object> 放置在global.asa文件中
 * 以上模块用于对数组对象，OBJECT对象的内存存储。同化VB的Application。
 * 使用方法：
 * 		var A = new syQuery.application();
 *			A.flag : 关键，这个是在global.asa中声明的Object的ID名。如果想使用别的ID名，请修改global.asa中相应的数值后使用 A.flag = "new ID"来声明。
 *			A.set : <[json | string], [anyObject]> 设置缓存的方法。
 *			A.get : <[string]> 获取缓存数据的方法。
 *	---------------------------------------------------------------------------------------------------------------------------
 *			A.load : <object> 获取特殊数据缓存的方法。
 *			A.write : <object> 写入缓存的方法。
 					object 数据格式如下 ：
						{
							area : "A, B, C, D, E, F",
							sql : "Select "+ this.area +" From [table] where ...",
							key : "[application name]",
							isfile : true | false,
							isapp : true | false,
							isdb : true | false,
							path : ""
						}
 * 注意 ： load 和 write 方法都是争对二维数组来说的，也就是对$.rows方法后的数据来说的。其他数据无效。
 * 			如果需要缓存其他数据，请直接使用 set 和 get 方法来缓存。
 */
syQuery.add("application", function(A){
	// 为 application 扩展方法
	syQuery.augment(A, {
		
		flag : "pjblog",
		root : "cache", // 这个是个相对于运行文件所在地址去寻找缓存文件夹位置的地址， 最后不能以"\"结束。
		conn : null,
		
		// 设置内存缓存的方法
		set : function(key, value){
			var flag = this.flag;
			
			if ( value == undefined ){
				if ( $.isJson(key) ){
					Application.Lock(); 
					for ( var i in key )
					{
						Application.StaticObjects(flag).Item(i) = key[i]; 
					}
					Application.UnLock();
				}
			}else{
				Application.Lock(); 
				Application.StaticObjects(flag).Item(key) = value; 
				Application.UnLock();
			}
			
		},
		
		// 获取内存缓存的方法
		get : function(key){ return Application.StaticObjects(this.flag).Item(key) || null; },
		
		// App 文件 数据库 三者之间互相转换的关系之获取缓存
		load : function(object){
			
			var _arr = [], i = 0, value;
			if ( object.isapp ) _arr.push("app");
			if ( object.isfile ) _arr.push("file");
			if ( object.isdb ) _arr.push("db");
			if ( object.path == undefined ) object.path = object.key + ".cache";
			
			while ( _arr[i] != undefined )
			{
				value = this["_load_" + _arr[i]](object);
				if ( value == null ){
					i++;
				}else{
					if ( i > 0 ){
						for ( var j = 0 ; j < i ; j++ ){
							if ( _arr[j] != "db" ){
								this["_write_" + _arr[j]](object, value);
							}
						}
					}
					i = 10; // 保证跳出循环
					return value;
				}
			}
			
			return [];
		},
		
		// App 文件 数据库 三者之间互相转换的关系之写入缓存
		write : function(object){
			if ( object.path == undefined ) object.path = object.key + ".cache";
			
			var _arr = [], value = null, _file = false;
			
			if ( object.isdb ) {
				value = this._load_db(object);
			}else if ( object.isfile ){
				value = this._load_file(object);
				_file = true;
			}
			
			if ( value != null ){
				if ( object.isapp ){
					if (_app == true) this._write_app(object, value);
				}
				if ( object.isfile ){
					if ( _file != true ) this._write_file(object, value);
				}
			}
		},
		
		// 私有方法 获取APP数据	
		_load_app : function(object){
			var t = this.get(object.key);
			if ( t != null && $.isObject(t) && t.length ){
				return $.toArray(t);
			}else{
				return null;
			}
		},
		
		// 私有方法 获取文件数据
		_load_file : function(object){
			if ( $(this.root + "/" + object.path, $.fso()).exsit() ){
				return $.parseJSON($(this.root + "/" + object.path, $.stream()).load(2).get(0) || "") || null;
			}else{
				return null;
			}
		},
		
		// 私有方法 获取数据库数据
		_load_db : function(object){
			var row = null;
			$({
				sql : object.sql,
				type : 1,
				callback : function(rs){
					try{
						row = $.rows(rs);
					}catch(e){}
				}
			}).select(this.conn);
			
			return row;
		},
		
		// 私有方法 写入App数据
		_write_app : function(object, arr){
			this.set(object.key, arr);
		},
		
		// 私有方法 写入文件数据
		_write_file : function(object, arr){
			var temp1 = [];
			for ( var i = 0 ; i < arr.length ; i++ )
			{
				var items = arr[i];
				items = $.map(items, function(i, k){
					return encodeURIComponent(k);
				});
				items = "[" + items.join(",") + "]";
				temp1.push(items);
			}
			temp1 = "[" + temp1.join(",") + "]";
			$.echo(this.root + "/" + object.path)
			$(temp1, $.stream()).save(this.root + "/" + object.path, 2);
		}
		
	});
});

/**
 * 文件打包类
 * 对文件进行base64编码后打包在一个xml文件中
 * 方法 pack unpack
 */
syQuery.add("package", function(P, J){
	// 为该类扩展方法
	syQuery.augment(P, {
	
		// PACK 打包文件的方法
		pack : function(which, toWhere, options){
		/**
		 * which 打包文件夹（打包后此文件夹不包含在内）
		 * toWhere 打包后文件存放地址
		 * options 配置参数
					- repFolder 文件夹替换方法
					- repFile   文件替换方法
					- packFolder 文件夹正在打包时的方法
					- packFile 文件正在打包时的方法
					- success 打包成功后执行的方法
					- error 打包失败后执行的方法
					
		 */
			var packageXml = '<?xml version="1.0"?><package xmlns:dt="urn:schemas-microsoft-com:datatypes"><count><foldercount></foldercount><filecount></filecount></count><content><folders></folders><files></files></content></package>',
				allFolders = this.allFolder(which), 
				xml = $.xml(packageXml), 
				root = xml[0],
				object = xml[1],
				self = this;
				
			if ( allFolders.length > 0 )
			{
				if ( root != null )
				{
					try{
						// 处理文件夹
						$(root, object).find("count foldercount").text(allFolders.length); // 添加数量
						
						// 循环写入文件
						$.arrEach(allFolders, function(i, k){
							k = k.replace(/\.\.\//g, "");
							$(root, object).find("content folders").append("item").html( options!= undefined && options.repFolder != undefined && $.isFunction(options.repFolder) ? options.repFolder(k + "") : k + "");
							if ( options!= undefined && options.packFolder != undefined && $.isFunction(options.packFolder) ) options.packFolder(k);
						});
						
						// 处理文件
						$(allFolders, J.fso).collect("f", true).each(function(i, k){
							var text = self._t2b($(k, $.stream()).load(1).get(0));
							k = k.replace(/\.\.\//g, "");
							var element = $(root, object).find("content files").append("item").html(text + "").attrs({
								path : (options!= undefined && options.repFile != undefined && $.isFunction(options.repFile) ? options.repFile(k + "") : k + ""),
								filename : ( k.split("/").slice(-1).join("") )
							});
							if ( options!= undefined && options.packFile != undefined && $.isFunction(options.packFile) ) options.packFile(k);
						});
						
						$(root, object).saveXML(toWhere);
						
						if ( options!= undefined && options.success != undefined && $.isFunction(options.success) ) options.success(toWhere);
						
					}catch(e){
						if ( options!= undefined && options.error != undefined && $.isFunction(options.error) ) options.error(e.message);
					}
				}
			}
			
		},
		
		// 解包文件的方法
		unpack : function(which, toWhere, options){
		/**
		 * which 解包文件地址
		 * toWhere 解包文件夹地址
		 * options 配置参数
					- repFolder 文件夹替换方法
					- repFile   文件替换方法
					- packFolder 文件夹正在打包时的方法
					- packFile 文件正在打包时的方法
					- success 打包成功后执行的方法
					- error 打包失败后执行的方法
					
		 */
			var xml = $.xml(which),
				root = xml[0],
				object = xml[1],
				self = this;
				
			if ( root != null )
			{
				try{
					// 批量创建文件夹
					var fo = $(root, object).find("content folders item").map(function(i, k){
						var text = toWhere + "/" + $(k, object).text();
						if ( options!= undefined && options.packFolder != undefined && $.isFunction(options.packFolder) ) options.packFolder(text);
						if ( options!= undefined && options.repFolder != undefined && $.isFunction(options.repFolder) ) text = options.repFolder(text);
						return text;
					}).toArray();
					
					$(fo, J.fso).create();
					
					// 批量创建文件
					var fi = $(root, object).find("content files item").each(function(i, k){
						var path = toWhere + "/" + $(k, object).attr("path"), filename = $(k, object).attr("filename"), text = self._b2t($(k, object).text());
						if ( options!= undefined && options.repFile != undefined && $.isFunction(options.repFile) ) path = options.repFile(path);
						$.save(text, path, $.stream(), 1);
						if ( options!= undefined && options.packFile != undefined && $.isFunction(options.packFile) ) options.packFile(path, filename);
					});
					
					if ( options!= undefined && options.success != undefined && $.isFunction(options.success) ) options.success(toWhere);
				}catch(e){
					if ( options!= undefined && options.error != undefined && $.isFunction(options.error) ) options.error(e.message);
				}
			}
			
		},
		
		allFolder : function(which){
			var fso = J.fso, Arr = [],
				first = $(which, fso).collect("o", true), self = this;
			
			Arr = self._addArray(Arr, first.toArray());
			
			if ( first.size() > 0 ){
				Arr = self._addArray(Arr, first.map(function(i, k){
					return self.allFolder(k);
				}).toArray());
			}
			return Arr;
		},
		
		// 以下2个方法是对二进制和BASE64的转换
		_t2b : function(t){
			if ( t == null ) return "";
			var temp = J.xml.createElement("file");
			temp.dataType = "bin.base64";
			temp.nodeTypedValue = t;
			return temp.text;
		},
		
		_b2t : function(b){
			var temp = J.xml.createElement("file");
			temp.dataType = "bin.base64";
			temp.text = b;
			return temp.nodeTypedValue;
		},
		
		_addArray : function(tar, sour){
			for ( var i = 0 ; i < sour.length ; i++ )
			{
				tar.push(sour[i]);
			}
			return tar;
		}
	});
}, function(){

	var xml, fso = $.fso();
	try{ xml = $.active("Microsoft.XMLDOM"); }catch(e){ xml = $.active("Msxml2.DOMDocument.5.0"); }
	
	return {
		xml : xml,
		fso : fso
	}
});

syQuery.add("page", function(P){
	
});
%>