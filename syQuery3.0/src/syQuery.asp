<%@LANGUAGE="JAVASCRIPT" CODEPAGE="65001"%>
<%
/**
 *	@ function source module
 *	@ param selector 	<object> data object
 *	@ param context  	<object> limited context
 *	@ param QueryRoot 	<object> 
 *	@ return <syQuery object>
 */
var $ = (function(){
	/**
	  *	@ function source module
 	  *	@ param selector 	<object> data object
 	  *	@ param context  	<object> limited context
 	  *	@ param QueryRoot 	<object> 
 	  *	@ return <syQuery object>
	 */
	var limitedKey = ["config", "ready", "error", "root", "charset", "createQuery", "merge", "mix", "augment", "type", "echo", "fn", "die", "isFunction", "isString", "isArray", "isObject", "isBoolean", "isNumber", "isDate", "isJson", "isQuery", "include", "add", "use", "execute", "query", "querys", "posts", "post", "Enumerator", "parseJSON", "getIP"];
	var _Query = function( key, object, fn ){
		if ( _Query.isString( key ) ){
			if ( limitedKey.indexOf(key) == -1 )
			{
				// create syQuery object
				_Query[key] = function( selector, context ){
					context = object ? object : context;
					return new _Query.fn.init( selector, context, fn );
				};
				limitedKey.push(key);
				// return the created object
				return _Query[key];
			}else{
				// add to error eqment
				_Query.error.push("syQuery error : $['" + key + "'] exsit.");
			}
		}else if ( _Query.isFunction( key ) ) {
			// add to ready eqment
			_Query.ready.push( key );
		}
	}
	push = Array.prototype.push;
	
	_Query.addKey = function(key){
		if ( limitedKey.indexOf( key ) === -1 ) limitedKey.push( key );
	}
	
	/**
	  *	@ json for syQuery module setting
	 */
	_Query.config = {
		ActivexObject : {
			conn : "ADODB.CONNECTION",
			record : "ADODB.RECORDSET",
			fso : "Scripting.FileSystemObject",
			stream : "Adodb" + "." + "Stream",
			xmlhttp : "Microsoft.XMLHTTP",
			xml : "Microsoft.XMLDOM",
			winhttp : "WinHttp.WinHttpRequest.5.1"
		}
	}; // 框架设置
	_Query.ready = []; // 框架全局运行绑定代码列表
	_Query.error = []; // 框架全局错误绑定代码列表
	_Query.root = ""; // 框架运行物理地址相对于根地址偏移的位置
	_Query.charset = "utf-8"; // 框架编码
	_Query.plugin = "syQuery3.0/build"; // 相对于网站跟目录的地址，不带/ （只填文件夹）
	_Query.module = {}; //系统已加载的模块
	_Query.sysFile = "syQuery.{name}-min.asp";
	
	// syQuery 对象构造函数
	_Query.fn = _Query.prototype = {
		init : function( selector, context, fn ){
			var ret = _Query.createQuery( selector, this, context );
			if ( fn != undefined ) {
				var callback = fn.call(ret);
				if ( callback ) return callback;
			};
			return ret;
		}, // 初始化方法
		constructor : _Query, // 原型构造
		syQuery : "3.0", // 版本号
		length : 0, // 内容数量
		object : null, // 指针对象
		size : function(){ return this.length; }, // 内容长度
		/**
		 * 改变syQuery对象中的object属性，并返回该对象
		 * @ param object <object> 新对象
		 * @ return <syQuery>
		 */
		shift : function( object ){
			this.object = object || null;
			return this;
		}
	}
	
	_Query.createQuery = function( selector, ret, context ){

		if ( selector == undefined ) return ret;
		if ( this.isArray(selector) ){
			// 数组转化为syQuery对象
			return selector.toQuery( ret, context );
		}else if ( this.isObject(selector) ){
			var isBinary, isObjectArr ;
			try{ selector.constructor; isBinary = false; }catch(e){ isBinary = true; }
			try{ isObjectArr = this.isNumber( selector.length ); }catch(e){ isObjectArr = false; }

			if ( isBinary === true || isObjectArr === true ){
				// 使用数组方法来转化为syQuery对象
				return Array.prototype.toQuery.call(selector, ret, context);
			}else{
				push.call(ret, selector);
				ret.object = context || null;
				return ret;
			}
		}else{
			push.call(ret, selector);
			ret.object = context || null;
			return ret;
		}
		
	}
	
	/**
	  *	@ function <object for extend>
 	  *	@ param source 	<object> source object
 	  *	@ param target  <object> target object
 	  *	@ param over	<object> allow to cover
	  *	@ param args	<object> cover limited
 	  *	@ return <object>
	 */
	_Query.mix = function( source, target, over, args ){
		
		if ( !source || !target ) return source;
		if ( over == undefined ) over = true;
		var len, i, p;
		
		if ( args && ( len = args.length ) )
		{
			for ( i = 0 ; i < len ; i++ )
			{
				p = args[i];
				if ( p in target )
				{
					_mix( p, source, target, over );
				}
			}
		}else{
			 for ( p in target ) {
				_mix( p, source, target, over );
			 }
		}
		
		return source;
	}
	
	_Query.extend = _Query.fn.extend = function( source, target, args )
	{
		var _source = source || {}, _target = target || {}, _args = args || [];
		if ( !target && !args )
		{
			_source = this;
			_target = source;
		}
		return _Query.mix( _source, _target, true, _args );
	}
	
	/**
	  *	@ function <new function for extend>
 	  *	@ param r 	<object> target object
 	  *	@ param s(n)  <item's params>
 	  *	@ param ov	<object> allow to cover
	  *	@ param wl	<object> cover limited
 	  *	@ return <object>
	 */
	_Query.augment = function(/*r, s1, s2, ..., ov, wl*/){
		var args = arguments, len = args.length - 2,
			r = args[0], ov = args[len], wl = args[len + 1],
			i = 1;

		if ( this.type(wl) != "array") {
			ov = wl;
			wl = undefined;
			len++;
		}
		if (this.type(ov) != "boolean") {
			ov = undefined;
			len++;
		}

		for (; i < len; i++) {
			this.mix(r.prototype, args[i].prototype || args[i], ov, wl);
		}

		return r;
	}
	
	/**
	 * 获取数据类型具体方法
	 */
	_Query.type = function( D ){
		return Object.prototype.toString.apply( D ).split(" ")[1].toLowerCase().replace("]", "");
	}
	
	/**
	 * 输出内容的方法
	 * 参数：S, callback, args
	 * S : 数据 , callback : 回调方法 , args : 附加参数
	 * 返回值 ： 无
	 */
	_Query.echo = function( S, callback, args )
	{
		if ( callback == undefined )
		{
			Response.Write( S );
			return;
		}
		if ( args == undefined )
		{
			Response.Write( callback.call( S ) );
			return;
		}
		Response.Write( callback.apply( S, args ) );
	}
	
	/**
	 * 终止输出的方法
	 * @param 继承自$.echo方法
	 * @return 无
	 */
	_Query.die = function(){
		this.echo.apply(undefined, arguments);
		Response.End();
	}
	
	var _mix = function( p, r, s, ov ){
		if (ov || !(p in r)) {
			r[p] = s[p];
		}
	};
	
	_Query.fn.init.prototype = _Query.fn;
	return _Query;
	
})();

/**
 * String prototype method
 * useing String.medthod <function>
 * return <String>
 */
$.augment( String, {
	// 普通去除两端空格
	trim : function(){
		return this.replace(/^\s+/, "").replace(/\s+$/, "");
	},
	// 字符串防SQL注入
	sql : function(){
		var _str = this;
		[
			[/(w)(here)/ig, "$1h&#101;re"],
			[/(s)(elect)/ig, "$1el&#101;ct"],
			[/(i)(nsert)/ig, "$1ns&#101;rt"],
			[/(c)(reate)/ig, "$1r&#101;ate"],
			[/(d)(rop)/ig, "$1ro&#112;"],
			[/(a)(lter)/ig, "$1lt&#101;r"],
			[/(d)(elete)/ig, "$1el&#101;te"],
			[/(u)(pdate)/ig, "$1p&#100;ate"],
			[/(\s)(or)/ig, "$1o&#114;"],
			[/(java)(script)/ig, "$1scri&#112;t"],
			[/(j)(script)/ig, "$1scri&#112;t"],
			[/(vb)(script)/ig, "$1scri&#112;t"],
			[/(expression)/ig, "e&#173;pression"],
			[/(c)(ookie)/ig, "&#99;ookie"],
			[/(Object)/ig, "&#79;bject"],
			[/(script)/ig, "scri&#112;t"]
		].each(function(i, k){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	},
	
	_sql : function(){
		var _str = this;
		[
			[/(w)(h&#101;re)/ig, "$1here"],
			[/(s)(el&#101;ct)/ig, "$1elect"],
			[/(i)(ns&#101;rt)/ig, "$1nsert"],
			[/(c)(r&#101;ate)/ig, "$1reate"],
			[/(d)(ro&#112;)/ig, "$1rop"],
			[/(a)(lt&#101;r)/ig, "$1lter"],
			[/(d)(el&#101;te)/ig, "$1elete"],
			[/(u)(p&#100;ate)/ig, "$1pdate"],
			[/(\s)(o&#114;)/ig, "$1or"],
			[/(java)(scri&#112;t)/ig, "$1script"],
			[/(j)(scri&#112;t)/ig, "$1script"],
			[/(vb)(scri&#112;t)/ig, "$1script"],
			[/(e&#173;pression)/ig, "expression"],
			[/&#99;(ookie)/ig, "c$1"],
			[/&#79;(bject)/ig, "O$1"],
			[/(scri)&#112;(t)/ig, "$1p$2"]
		].each(function(i, k){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	},
	
	cStr : function(){
		var _str = this;
		[
			[/\</g, "&#60;"],
			[/\>/g, "&#62;"]
		].each(function(i, k){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	},
	
	_cStr : function(){
		var _str = this;
		[
			[/&#60;/g, "<"],
			[/&#62;/g, ">"]
		].each(function(i, k){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	},
	
	tStr : function(){
		var _str = this;
		[
			[/textarea/ig, "t&#101;xtarea"]
		].each(function(i, k){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	},
	
	_tStr : function(){
		var _str = this;
		[
			[/t&#101;xtarea/ig, "textarea"]
		].each(function(i, k){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	},
	
	// 截取字符串前 n 个字符 区分中英文 1中文 = 2英文  以中文为基准
	cut : function( n ){
		var j = 0, temp = "", self = this, _value;
		
		for ( var i = 0 ; i < self.length ; i++ )
		{
			_value = self.charAt(i);
			
			if ( !/[^\u4E00-\u9FA5]/g.test(_value) ){
				j = j + 2;
			}else{
				j = j + 1;
			}
			
			temp += _value;
			if ( j >= (2 * n) ){ break; }
		}
		
		if ( temp != self ){ temp += "..." }
		
		return temp;
	},
	
	removeHTML : function(){ return this.replace(/<[^>]*?>/g, "").replace(/\n\t\r/g, ""); },	
	removeUBB : function(){ return this.replace(/\[(\w+).*?\](.+)\[\/\1\]/g, "$2").replace(/\n\t\r/g, ""); },	
	left : function(i){ return this.substr(0, i); },	
	right : function(i){ return this.substr(this.length - i, i); },	
	mid : function(i, t){ return this.substr(i - 1, t); },
	
	unicode : function(){
		var rs = "", self = this;
			 
		for( var i = 0 ; i < self.length ; i++ )
		{ 
			rs += "&#" + self.charCodeAt(i) + ";" ; 
		} 
		
		return rs;
	},
	
	_unicode : function(){
		var self = this; k = self.split(";"), r = ""; 
		
		for( var x = 0 ; x < k.length ; x++ )
		{ 
			r += String.fromCharCode( k[x].replace( /&#/, "" ) ); 
		} 
		
		return r; 
	}
	
} );

/**
 * Array prototype method
 * useing Array.medthod <function>
 * return <Array>
 */
$.augment( Array, {
	// 取第几个
	// slice(a, b) a 从第几个数开始取值 （起始0） b 取数量、长度
	eq : function(i){
		return i === -1 ?
			   this.slice( i ) :
			   this.slice( i, +i + 1 );
	},
	
	// 数组遍历循环的方法
	each : function(callback, args){
		var i = 0, array = this;
		
		if ( args == undefined ){
			for ( 
				var value = array[0] ; 
				i < array.length && callback.call( array, i, value ) !== false ;
				value = array[++i] 
			){}
		}else{
			for ( ; i < array.length; ) { 
				if ( callback.apply( array[ i++ ], args ) === false ) 
				{ break; }
			}
		}
		
		return array;
	},
	
	// 数组遍历赋值的方法
	map : function( callback ){
		var ret = [], value, _this = this;
		
		for ( var i = 0, length = _this.length; i < length; i++ ) {
			value = callback.call( _this, i, _this[ i ] );
			
			if ( value !== null ) 
			{
				ret[ ret.length ] = value;
			}
			
		}
		
		return ret.concat.apply( [], ret );
	},
	
	// 数组遍历搜索的方法
	indexOf : function( value ){
		var j = -1, i = 0, _this = this;
		
		for ( ; i < _this.length ; i++ )
		{
			if ( _this[i] === value )
			{
				j = i;
				break;
			}
		}
		
		return j;
	},
	
	lastIndexOf : function( value ){
		var len = this.length, 
			self = this, 
			_self = self.reverse(),
			num = _self.indexOf( value );
			
		if ( num == -1 ){
			return -1;
		}else{
			return len - num - 1;
		}
	},
	
	first : function(){ return this.eq(0); },
	last : function(){ return this.eq(-1); },
	remove : function(i){ return this.slice( 0, i ).concat( this.slice(i + 1) ); },
	
	// 形成syQuery对象主方法
	toQuery : function( ret, context ){
		var i = 0, j = 0, selector = this;

		for ( var l = selector.length; j < l; j++ ) 
		{ 
			ret[ i++ ] = selector[ j ]; 
		} 

		ret.length = i;
		ret.object = context || null;
		return ret;
	},
	
	// 数组去除两端空格
	trim : function(){
		return this.map(function( i, k ){
			return k.trim();
		});
	},
	
	// 删除数组中的重复项
	unique : function(callback){
		var tmpArr = this.sort(callback);
		
		for ( var i = tmpArr.length - 1 ; i >= 1 ; i-- )
		{
			if( tmpArr[ i - 1 ] == tmpArr[ i ] ){
				tmpArr.splice( i, 1 );
			}    
		}
		
		return tmpArr;
	}
} );

// 创建每个 is前缀的判断数据类型的方法
$.config.type = ["Function", "String", "Array", "Object", "Boolean", "Number"];
$.config.type.each(function( i, k ){
	$[ "is" + k ] = function( value ){
		return $.type( value ) === k.toLowerCase();
	}
});

(function(){
	
	$.mix( $, {
		
		// 创建判断日期类型的数据方法
		isDate : function( value ){
			if ( $.type( value ) === "date" ){
				return true;
			}else{
				try{
					var date = Date.parse(value);
					return isNaN(date) ? false : true;
				}catch(e){
					return false;
				}
			}
		},
		
		// 创建是否为标准JSON格式的数据方法
		isJson : function( value ){
			try{
				return value.constructor === {}.constructor ? true : false;
			}catch(e){
				return false;
			}
		},
		
		// 创建是否为syQuery格式的方法
		isQuery : function( value ){
			return value.constructor === $.fn.constructor ? true : false;
		},
		
		// 动态获取include文件夹内容并加载对应位置运行
		include : function( URI ){
			if ( $.isArray(URI) ){
				URI = URI.map(function(i, _item){
					var o = new ActiveXObject($.config.ActivexObject.stream),
						Text = filterContent(catchFile(_item, o)) || null;
					o = null;
					return Text;
				});
			}else{
				var o = new ActiveXObject($.config.ActivexObject.stream);
				URI = [filterContent(catchFile(URI, o))];
				o = null;
			}

			URI = URI.join(";");
			return URI;
		}
		
	});
	
	function catchFile( URI, stream ){
		var o = stream ? stream : new ActiveXObject($.config.ActivexObject.stream),
			lens = URI.split("/"),
			localFo = lens.slice(0, -1).join("/"),
			Text = "";
		o.Type = 2; o.Mode = 3; 
		o.Open(); 
			o.Charset = $.charset; 
			o.Position = o.Size; 
			o.LoadFromFile(Server.MapPath( URI ));
			Text = o.ReadText;
		o.Close;
		return catchContent(Text, o, localFo);
	}
	
	function catchContent(context, stream, localFo){
		var l = 0, r = 0, text = "", p = "", e, t, tempText;
		if ( regExpress.includeExp.test(context) ){
			while ( l > -1 ){
				l = context.indexOf("<" + "!--#include");
				if ( l > -1 ){
					text += context.substring(0, l);
					context = context.substring(l + 12);
					r = context.indexOf("-->");
					p = context.substring(0, r);
					e = p.replace(" file=\"", "").replace("\"", "").trim();
					if ( localFo.length == 0 ){
						t = e;
					}else{
						t = localFo + "/" + e;
					}
					context = context.substring(r + 3);
					tempText = catchFile(t, stream);
					text += catchContent(tempText, stream, t.split("/").slice(0, -1).join("/"));
				}else{
					text += context;
					context = "";
				}
			}
			return text;
		}else{
			return context;
		}
	}
	
	function filterContent( context ){
		context = context.replace(regExpress.includeContentForLeftExp, "").replace(regExpress.includeContentForRightExp, "");
		function textformat(t){
			if ( t.length > 0 ){
				return ";Response.Write(\"" + t.replace(/\\/g, "\\\\").replace(/\"/g, "\\\"").replace(/\r/g, "\\r").replace(/\n/g, "\\n").replace(/\s/g, " ").replace(/\t/g, "\\t") + "\");";
			}else{
				return "";
			}
		}
		var blank = "", conSplit = context.split("<" + blank + "%"), r = 0, text = "", temp;
		for ( var i = 0 ; i < conSplit.length ; i++ )
		{
			r = conSplit[i].indexOf("%" + blank + ">");
			if ( r > -1 ){
				temp = textformat(conSplit[i].substring(r + 2));
				text += (/^\=/.test(conSplit[i]) ? ";Response.Write(" + conSplit[i].substring(1, r) + ");" : conSplit[i].substring(0, r)) + temp;
			}else{
				text += textformat(conSplit[i]);
			}
		}
		return text;
	}
	var regExpress = {
		includeExp : /\<\!\-\-\#include\sfile\=\"(.+?)\"\s?\-\->/g,
		includeFileExp : /file\=\"(.+)\"/,
		includeContentForLeftExp : /^[\r\t\s\n]+/,
		includeContentForRightExp : /[\r\t\s\n]+$/
	}
	
})(); (function(){
	
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
	
	$.root = getLocalPath(); // 本框架相当于于网站根目录的上级位置集合字符串。
	
})();

(function(){
	
	/**
	 * @ 需要配置$.plugin路径
	 */
	$.mix($, {
		/**
		 * @为框架添加新的模块
		 * @param key <string> 模块名称 标识
		 * @param fn <function> 详细回调方法
		 * @param eqment <json> 配置参数
		 * @return new function
		 */
		add : function(key, fn, eqment){
			if ( $.module[key] == undefined ){
				return dealEqMent(eqment, function(){
					$.module[key] = fn(); // 内置方法
					$.addKey(key); // 防止重复				
				}); // 尝试加载前置环境
			}else{
				$.error.push("syQuery error : key['" + key + "'] exsit.");
			}
		},
		
		/**
		 * @运行框架模块
		 * @param key <string> 模块名称 标识
		 * @param fn <function> 详细回调方法 其中第一个参数为该模块的返回值
		 * @return anyObject
		 */
		use : function( key, fn, eqment ){
			if ( fn == undefined ){
				return $.module[key];
			}
			
			if ( $.module[key] != undefined ){
				return dealEqMent(eqment, function(){
					fn($.module[key]);							   
				}); // 尝试加载前置环境
			}
		},
		
		/**
		 * @页面执行函数
		 * @param key <string> 模块名称 标识
		 * @param fn <function> 详细回调方法 参数为这些模块的返回值
		 * @return anyObject
		 */
		execute : function( key, fn, eqment ){
			if ( $.isFunction(key) ){
				fn = key;
				key = "";
			}
			
			dealEqMent(eqment, function(){
				var tmpArr = [];
				key.split(",").each(function( i, k ){
					tmpArr.push($.module[k.trim()]);
				});
	
				fn.apply(undefined, tmpArr);						
			}); // 尝试加载前置环境
		},
		
		/**
		 * @输出错误的方法
		 * @param fn <string | undefined | string> 输出分割符
		 * @return string
		 */
		echoError : function( fn ){
			if ( $.isFunction(fn) ){
				$.echo( $.error, function(){
					return this.map(function( i, k ){
						return fn(k);
					}).join("");
				} );
			}else{
				$.echo( $.error.join( fn == undefined ? "<br />" : fn ) );
			}
		},
		
		/**
		 * @批量加载
		 * @param mods <array> 
		 * @param callback <function>
 		 * @return null
		 */
		build : function(mods, callback, isModule){
			var p = $.root + $.plugin;	
			p = (p.length === 0 ? "" : p + "/").replace(/\/\//g, "/");

			if ( !isModule ) isModule = false;
			if ( !callback ) callback = null;
			
			return mods.map(function( i, t ){
				if ( isModule ){
					eval($.include(t));
					return $.isFunction(callback) ? callback() : null;
				}else{
					if ( $.module[t] == undefined){
						eval($.include(p + $.sysFile.replace("{name}", t)));
						return $.isFunction(callback) ? callback() : null;
					}else{
						return null;
					}
				}
			});
		}
	});
	
	function dealEqMent( eq, callback ){
		var ret;
		
		if ( eq != undefined ){
			if ( eq.require ) ret = $.build( eq.require, callback, eq.isModule );
		}else{
			ret = callback ? callback() : undefined;
		}
		
		return ret;
	}
	
})();

(function(){
	var array = Array.prototype,
		rvalidchars = /^[\],:{}\s]*$/,
		rvalidescape = /\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,
		rvalidtokens = /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,
		rvalidbraces = /(?:^|:|,)(?:\s*\[)+/g;
		
	var merge = function(method){
		return array.toQuery.call(method, $.fn, this.object);
	}
	
	$.fn.extend({
		toArray : function(){ return array.slice.call( this, 0 ); },
		slice : function(){ return this.merge(array.slice.apply(this, arguments)); },
		eq : function(i){ return i === -1 ? this.slice( i ) : this.slice( i, +i + 1 ); },
		each : function(fn){ return array.each.call(this, fn); },
		map : function(fn){ return this.merge(array.map.call(this, fn)); },
		first : function(){ return this.eq(0); },
		last : function(){ return this.eq(-1); },
		get : function(num){ return num == undefined ? this.toArray() : ( num < 0 ? this.slice(num)[0] : this[num] ); },
		trim : function(){ return this.merge(array.trim.call(this)); },
		merge : function(method){ return array.toQuery.call(method, this, this.object); },
		even : function(){ return this.map(function(i, k){ return i % 2 === 0 ? null : k; }); },
		odd : function(){ return this.map(function(i, k){ return i % 2 === 0 ? k : null; }); },
		gt : function(j){ return this.map(function(i, k){ return i > j ? k : null; }); },
		lt : function(j){ return this.map(function(i, k){ return i < j ? k : null; }); },
		unique : function(){ return this.merge(array.unique.call(this)); }
	});
	
	$.extend({
		// 唯一标识
		guid : function(){
			return (new ActiveXObject("Scriptlet.TypeLib")).Guid;
		},
		// 对象枚举
		Enumerator : function( t, ret, callback ){
			var _data, _ret, _callback;
			
			if ( ret == undefined ){
				_data = t; _ret = []; _callback = undefined;
			}else if ( callback == undefined ){
				_data = t;
				if ( $.isFunction(ret) ){ callback = ret; ret = []; }
				else if ( $.isArray( ret ) ) { callback = undefined; }
				else{ ret = []; callback = undefined; }
			}else{
				_data = t; _ret = ret; _callback = callback;
			}
			
			try{
				_data = new Enumerator(_data);
				for (; !_data.atEnd() ; _data.moveNext() ) {
					if ( $.isFunction(_callback) ){
						_ret.push(_callback.call(_data, _data.item()));
					}else{
						_ret.push(_data.item());
					}
				}
			}catch(e){}
			
			return _ret;
		},
		
		// QueryString 获取参数方法 集合
		querys : function(key, callback){
			if ( key == undefined ){
				return this.Enumerator(Request.QueryString, callback);
			}else{
				return this.Enumerator(Request.QueryString(key), callback);
			}
		},
		
		// QueryString 获取参数方法 单一
		query : function(){
			return this.querys.apply(this, arguments)[0];
		},
		
		// Form 获取参数方法 集合
		posts : function(key, callback){
			if ( key == undefined ){
				return this.Enumerator(Request.Form, callback);
			}else{
				return this.Enumerator(Request.Form(key), callback);
			}
		},
		
		// Form 获取参数方法 单一
		post : function(){
			return this.posts.apply(this, arguments)[0];
		},
		
		parseJSON : function(data){
			if ( data == undefined || !$.isString(data) ) {
				return null;
			}
	
			// Make sure leading/trailing whitespace is removed (IE can't handle it)
			data = data.trim();
	
			// Make sure the incoming data is actual JSON
			// Logic borrowed from http://json.org/json2.js
			if ( rvalidchars.test(data.replace(rvalidescape, "@")
				.replace(rvalidtokens, "]")
				.replace(rvalidbraces, "")) ) {
	
				// Try to use the native JSON parser first
				return (new Function("return " + data))();
	
			} else {
				$.error.push( "Invalid JSON: " + data );
			}
		},
		
		getIP : function(){
			var userip = String(Request.ServerVariables("HTTP_X_FORWARDED_FOR")).toLowerCase();
			if ( userip == "undefined" ) userip = String(Request.ServerVariables("REMOTE_ADDR")).toLowerCase();
			return userip;
		}
	});
	
})();

/**
 * @ 日期处理类
 */
$.add("date", function(){
	// 固定对象形式
	var date = function(){}
	
	// 扩展原型
	$.mix(date, {
		/**
		 * @ 当前日期处理方法
		 * @ param t <string> 日期形式
		 * @ return string
		 */
		now : function(t){
			return DateFormat(new Date(), t);
		},
		
		/**
		 * @ 转化日期为date格式
		 * @ param value <string> 日期形式
		 * @ return <date>
		 */
		parseDate : parseDate,
		
		/**
		 * @ 任意日期转化方法
		 * @ param date 日期
		 * @ param type <string> 日期形式
		 * @ return <string>
		 */
		dateStr : DateFormat,
		
		/**
		 * @ 计算2个时间之间的天数、小时、分钟、秒、毫秒
		 * @ param A 日期1
		 * @ param B 日期2
		 * @ return <string>
		 */
		diff : function(A, B){
			A = new Date(A).getTime();
			B = new Date(B).getTime();
			
			var _max = Math.max(A, B), _min = Math.min(A, B), _diff = _max - _min;
			
			return diffDateTime(_diff);
		}
	});
	
	// 私有方法
	// 格式化日期格式
	function DateFormat(date, type){
		if ( type == undefined ) type = "Y/m/d H:I:S";
		if ( $.isString(date) || $.isNumber(date) ) date = new Date(date);
		var data = format(date), tmpStr = "", _tmpStr;
		
		for ( var i = 0 ; i < type.length ; i++ )
		{
			_tmpStr = type.charAt(i);
			
			if ( data[_tmpStr] == undefined ){
				tmpStr += _tmpStr;
			}else{
				tmpStr += data[_tmpStr];
			}
		}
		
		return tmpStr;
	}
	
	// 压缩日期为时间戳
	function parseDate(value){
		var date = Date.parse(value);
		return isNaN(date) ? -1 : Number(date);
	}
	
	// 当前目标日期的各种属性
	function format(date){
		var D = {
			shortMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
			longMonths: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
			shortDays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
			longDays: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
		}
		
		return {
			d : (date.getDate() < 10 ? '0' : '') + date.getDate(),
			m : (date.getMonth() < 9 ? '0' : '') + (date.getMonth() + 1),
			Y : date.getFullYear(),
			y : ('' + date.getFullYear()).substr(2),
			a : date.getHours() < 12 ? 'am' : 'pm',
			A : date.getHours() < 12 ? 'AM' : 'PM',
			H : (date.getHours() < 10 ? '0' : '') + date.getHours(),
			I : (date.getMinutes() < 10 ? '0' : '') + date.getMinutes(),
			S : (date.getSeconds() < 10 ? '0' : '') + date.getSeconds(),
			z : date.getTime(),
			w : D.shortDays[date.getDay()],
			W : D.longDays[date.getDay()],
			r : D.shortMonths[date.getMonth()],
			R : D.longMonths[date.getMonth()]
		}
	}
	
	function diffDateTime( time ){
		
		if ( time === 0 ) return "0秒";
		
		var t1 = [86400000, 3600000, 60000, 1000],
			t2 = ["天", "小时", "分钟", "秒"],
			tmpStr = [0, 0, 0, 0];
		
		for ( var i = 0 ; i < t1.length ; i++ )
		{
			var gun = time / t1[i];
			if ( gun < 1 ){
				tmpStr[i] = 0;
				time = gun * t1[i];
			}else{
				tmpStr[i] = Math.floor(gun);
				time = time - tmpStr[i] * t1[i];
			}
		}
		
		tmpStr = tmpStr.map(function( i, k ){
			return k == 0 ? "" : k + t2[i];
		});
		
		return tmpStr.join("");
	}
	
	return date;
});

/**
 * @ session操作
 */
$.add("session", function(){
	// 创建session原型
	var _session = function(){}
	
	$.mix(_session, {
		
		/**
		 * @ 获取一个标识为key的SESSION值
		 * @ param key <string> 标识
		 * @ param t <string | undefined> 默认值
		 * @ return object
		 */
		get : function(key, t){
			return Session(key) || t;
		},
		
		/**
		 * @ 设置一个或多个SESSION方法
		 * @ param key <string | json> 标识 或者 序列化的JSON数据
		 * @ param value <string | undefined> 值
		 * @ return null
		 */
		set : function(key, value){
			if ( value == undefined ){
				for ( var i in key )
				{
					this.set( i, key[i] );
				}
			}else{
				Session( key ) = value;
			}
		},
		
		/**
		 * @ 移除一个或者多个SESSION标识
		 * @ param key <string | array | undefined> 标识
		 * @ return null
		 */
		remove : function(key){
			var _this = this;
			
			if ( key == undefined ){
				// 移除所有session
				Session.Contents.RemoveAll();
			}else if ( $.isArray(key) ){
				key.each(function(i, k){
					_this.remove(k);
				});
			}else{
				Session.Contents.Remove(key);
			}
		}
	});
	
	return _session;
});

/**
 * @ cookie操作
 */
$.add("cookie", function(){
	// 创建cookie原型
	var cookie = function(){
		this.length = 0;
		this.object = 0;
	}
	
	// 扩展原型
	$.mix(cookie, {
		/**
		 * @ 获取一个标识为key的cookie值
		 * @ param key <string> 标识
		 * @ param t <string | undefined> 默认值
		 * @ return object
		 */
		get : function(key, t){
			var t = key.split("."), len = t.length;
			
			if ( len === 2 ){
				return Request.Cookies(t[0])(t[1]) || t;
			}else{
				return Request.Cookies(t[0]) || t;
			}
		},
		
		/**
		 * @ 设置一个或多个cookie方法
		 * @ param key <string | json> 标识 或者 序列化的JSON数据
		 * @ param value <string | undefined> 值
		 * @ return null
		 */
		set : function(key, value){
			if ( value == undefined ){
				for ( var i in key )
				{
					this.set(i, key[i]);
				}
			}else{
				var t = key.split("."), len = t.length;
				
				if ( len === 2 ){
					return Response.Cookies(t[0])(t[1]) = value;
				}else{
					return Response.Cookies(t[0]) = value;
				}
			}
		},
		
		/**
		 * @ 移除一个或者多个cookie标识
		 * @ param key <string | array | undefined> 标识
		 * @ return null
		 */
		remove : function(key){
			if ( $.isArray(key) ){
				var _this = this;
				key.each(function( i, k ){
					_this.remove(k);
				});
			}else{
				Response.Cookies(key.split(".")[0] || key).Expires = "1/1/1980";
			}
		},
		
		/**
		 * @ COOKIE的生存时间
		 * @ param key <string | array | undefined> 标识
		 * @ param value <string> 时间选择器 year(n), month(n), day(n), hour(n), minute(n), second(n), mSecond(n)
		 * @ return null
		 */
		keep : function(key, value){
			if ( value == undefined ){
				for ( var i in key )
				{
					this.keep(i, key[i]);
				}
			}else{
				var newDate = dateDiff(new Date(), value).toGMTString();
				
				$.use("date", function(D){
					newDate = D.dateStr(newDate, "Y/m/d H:I:S");
				});
				
				Response.Cookies(key.split(".")[0] || key).Expires = newDate;	
			}
		},
		
		/**
		 * @ COOKIE的domain属性
		 * @ param key <string | array | undefined> 标识
		 * @ param value <string> 值
		 * @ return null
		 */
		domain : function(key, value){
			if ( value == undefined ){
				for ( var i in key )
				{
					this.domain(i, key[i]);
				}
			}else{
				Response.Cookies(key.split(".")[0] || key).Domain = value;	
			}
		}
	});
	
	function dateDiff(date, value){
		var r = /^(\w+)\((\d+)\)$/.exec(value),
			f = {
				year : function(n){
					return new Date(this + n * 12 * 30 * 24 * 60 * 60 * 1000);
				},
				month : function(n){
					return new Date(this + n * 30 * 24 * 60 * 60 * 1000);
				},
				day : function(n){
					return new Date(this + n * 24 * 60 * 60 * 1000);
				},
				hour : function(n){
					return new Date(this + n * 60 * 60 * 1000);
				},
				minute : function(n){
					return new Date(this + n * 60 * 1000);
				},
				second : function(n){
					return new Date(this + n * 1000);
				},
				msecond : function(n){
					return new Date(this + n);
				}
			};
			
		if ( r ){
			var m1 = r[1], m2 = r[2];
			return f[m1].call(Number(date.getTime()), m2);
		}else{
			return new Date();
		}
	}
	
	// 对象扩展
	$.augment(cookie, {
		init : function(key){
			return [key].toQuery(this);
		},
		get : cookie.get,
		set : function(value){ cookie.set(this[0], value); return this; },
		remove : cookie.remove,
		keep : function(n){
			cookie.keep(this[0], n);
			return this;
		},
		domain : function(value){
			cookie.keep(this[0], value);
			return this;
		}
	});
	
	return cookie;
});

// json 插件
$.add("json", function(){
	// 创建json函数对象
	var json = function(){
		this.length = 0;
		this.object = null;
	}
	
	json.init = function(selector){
		selector = $.isArray(selector) ? selector : [selector];
		return selector.toQuery(new json(), null);
	}
	
	$.augment(json, {
		// 删除JSON中某个属性
		remove : function( k ){
			if ( $.isArray(k) ){
				for ( var i = 0 ; i < k.length ; i++ ){ delete this[k[i]]; }
			}else{
				delete this[k];
			}
			
			return this;
		},
		
		// 添加修改JSON属性
		update : function(key, value){
			if ( value == undefined ){
				return $.mix(this, key);
			}else{
				this[key] = value;
				return this;
			}
		},
		
		param : function( data ){
			
		}
	});
	
	return json.init;
});
%>