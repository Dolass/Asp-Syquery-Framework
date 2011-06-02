<%@LANGUAGE="JAVASCRIPT" CODEPAGE="65001"%>
<%
;var $ = new Object();
/**
 * syQuery 核心代码
 * $ <object> 模型
 * $.fn <syQuery object> 对象
 */
(function(){
	var syQuery = (function()
	{
		/**
		 * 函数入口： $ - 原型
		 * 参	数： selector[, object]
		 * 返 回 值： syQuery原型对象
		 */
		var _Query = function( selector, object )
		{
			return new _Query.fn.init( selector, object );
		},
		push = Array.prototype.push,
		hasOwn = Object.prototype.hasOwnProperty;
		
		/**
		 * 批处理入口： $.fn - 原型 ( $.fn.init )
		 * 参	  数： selector[, object]
		 * 返  回  值： syQuery原型对象
		 */
		_Query.fn = _Query.prototype = {
			init : function( selector, object ){
				return _Query.makeArray( selector, this, object );
			},							// $(selector, object);
			syQuery : "2.0", 			// 版本号
			constructor : _Query, 		// syQuery的constructor属性，伪建新函数的constructor属性。
			length : 0,
			object : null,
			size : function(){ return this.length; }
		}
		
		_Query.error = []; // 错误信息
		_Query.setError = function( k ){
			this.error.push(k);
		}
		_Query.getError = function(callback){
			var value = $.isFunction(callback) ? callback.call(_Query.error) : callback ;
			return this.error.join(value);
		}
		
		// SyQuery的总配置
		_Query.config = { method : {}, charset : "utf-8", setup : {} }
		
		_Query.config.method.mix = function( p, r, s, ov )
		{
			if (ov || !(p in r)) {
                r[p] = s[p];
            }
		}
		
		_Query.config.ActivexObject = {
			conn : "ADODB.CONNECTION",
			record : "ADODB.RECORDSET",
			fso : "Scripting.FileSystemObject",
			stream : "Adodb" + "." + "Stream",
			xmlhttp : "Microsoft.XMLHTTP",
			xml : "Microsoft.XMLDOM",
			winhttp : "WinHttp.WinHttpRequest.5.1"
		}
		
		_Query.config.method.retMake_array = function( selector, object ){
			return _Query.merge( this, selector, object );
		}
		
		_Query.config.method.retMake_object = function( selector, object ){
			var s ;
			try{ selector.constructor; s = true; }catch(e){ s = false; }
			if ( selector == undefined ){
				return this;
			}else if ( !s ){
				push.call(this, selector);
				this.object = object || null;
				return this;
			}else if ( typeof selector.length === "number"  )
			{
				return _Query.merge( this, selector, object );
			}else{
				push.call(this, selector);
				this.object = object || null;
				return this;
			}
		}
		
		_Query.config.method.retMake_undefined = function( selector, object )
		{
			return this;
		}
		
		_Query.config.method.retMake_null = function( selector, object )
		{
			return this;
		}
		
		_Query.config.retArray = ["function", "string", "boolean", "number", "date"];
		
		/**
		 * 数据类型数组
		 * 作用： 批量生成普通数据类型识别函数
		 * 返回值： item 的小写
		 */
		_Query.dataTypeArray = ["Function", "String", "Array", "Object", "Boolean", "Undefined", "Null", "Number", "Date"];
		
		/**
		 * 特殊数据类型数组
		 * 作用： 批量生成普通数据类型识别函数
		 * 返回值： domain字符串
		 */
		_Query.dataSpecialTypeArray = [
			{ matchData : {}.constructor, domain : "isJson" },
			{ matchData : _Query.fn.constructor, domain : "isQuery" }
		]

		/**
		 * 获取数据类型具体方法
		 */
		_Query.type = function( D )
		{
			return Object.prototype.toString.apply( D ).split(" ")[1].toLowerCase().replace("]", "");
		}
		
		/**
		 * 处理数组循环的回调方法
		 */
		_Query.arrEach = function( array, callback, args )
		{
			var i = 0;
			if ( args == undefined ){
				for ( var value = array[0] ; i < array.length && callback.call( value, i, value ) !== false ; value = array[++i] ){}
			}else{
				for ( ; i < length; ) { if ( callback.apply( array[ i++ ], args ) === false ) { break; } }
			}
			return array;
		}
		
		/**
		 * 处理JSON数据循环的回调方法
		 */
		_Query.jsonEach = function( json, callback, args )
		{
			var i;
			if ( args == undefined ){
				for ( i in json ) { if ( callback.call( json[ i ], i, json[ i ] ) === false ) { break; } }
			}else{
				for ( i in json ) { if ( callback.apply( json[ i ], args ) === false ) { break; } }
			}
			return json;
		}
		
		/**
		 * 智能处理数组和JSON数据的循环回调方法
		 */
		_Query.each = function( data, callback, args ){
			if ( _Query.isJson(data) || $.isNewFunction(data) || $.isFunction(data) ){
				return _Query.jsonEach( data, callback, args );
			}else if ( _Query.isArray(data) || $.isQuery(data) ) {
				return _Query.arrEach( data, callback, args );
			}else{
				return data
			}
		}
		
		/**
		 * 处理数组循环的回调方法
		 */
		_Query.arrEach( _Query.dataTypeArray, function( i, k ){
			 _Query[ "is" + k ] = function( data ){
				 return this.type(data) == k.toLowerCase();
			}
		} );
		
		/**
		 * 返回是否为SyQuery对象的布尔值。
		 */
		_Query.arrEach( _Query.dataSpecialTypeArray, function( i, k ){
			 _Query[ k.domain ] = function( data ){
				 return data.constructor == k.matchData;
			}
		} );
		
		/**
		 * 判断是否为new function创建的对象
		 */
		_Query.isNewFunction = function( data ){
			if ( $.isObject(data) )
			{
				if ( $.isJson(data) ){
					return false;
				}else{
					for ( var i in data ){}
					return i === undefined || hasOwn.call( data, i );
				}
			}else{
				return false;
			}
		}
		
		/**
		 * 对简单数据类型进行模型创建。
		 */
		_Query.arrEach( _Query.config.retArray , function(){
			_Query.config.method["retMake_" + this] = function( selector, object )
			{
				push.call(this, selector);
				this.object = object || null;
				return this;
			}
		} );
		
		/**
		 * 是否为空的数据
		 */
		_Query.isEmObject = function( obj ){
			if ( !obj ) { return false; }
			var key, i = 0; for ( key in obj ) { i++; }
			if ( $.isJson(obj) ){
				return i == 0;
			}else{
				return key === undefined || hasOwn.call( obj, key );
			}
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
		
		/**
		 * 将 target(upplier) 对象的成员复制到 source(eceiver) 对象上。
		 * over <Boolean> override, 表示复制时是否采用覆盖模式。默认为 true. 
		 * args <Array> whitelist, 非空时，表示仅添加该列表中的成员。
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
						_Query.config.method.mix( p, source, target, over );
					}
				}
			}else{
				 for ( p in target ) {
                    _Query.config.method.mix( p, source, target, over );
                 }
			}
			return source;
		}
		
		/**
		 * 方法的继承
		 * args <Array> whitelist, 非空时，表示仅添加该列表中的成员。
		 */
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
		 * 形成syQuery对象的方法
		 * selector <anyObject> 数据
		 * object <object | null> 范围对象
		 */
		_Query.makeArray = function( selector, result, object )
		{
			var selectorType = this.type(selector), method = _Query.config.method["retMake_" + selectorType];
			if ( this.isFunction(method) )
			{
				return method.call( result, selector, object );
			}else{
				return result;
			}
		}
		
		/**
		 * 为syQuery对象增加子项的方法
		 * ret <syQuery object> syQuery对象
		 * selector <anyObject> 数据
		 * object <object | null> 范围对象
		 */
		_Query.merge = function( ret, selector, object )
		{
			var i = ret.length, j = 0;
			if ( typeof selector.length === "number" )
			{
				for ( var l = selector.length; j < l; j++ ) 
				{ 
					ret[ i++ ] = selector[ j ]; 
				} 
			}else{
				while ( selector[j] !== undefined ) 
				{
					ret[ i++ ] = selector[ j++ ]; 
				} 
			}
			ret.length = i;
			ret.object = object || null;
			return ret;
		}
		
		_Query.fn.init.prototype = _Query.fn;
		return _Query;
	})();
	$ = syQuery;
})();
(function(){
	/**
	 * 设定一些方法，供模块化用。
	 */
	var trim = String.prototype.trim,
		trimLeft = /^\s+/, trimRight = /\s+$/,
		rvalidchars = /^[\],:{}\s]*$/,
		rvalidescape = /\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,
		rvalidtokens = /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,
		rvalidbraces = /(?:^|:|,)(?:\s*\[)+/g,
		slice = Array.prototype.slice
		split = String.prototype.split,
		replace = String.prototype.replace,
		substr = String.prototype.substr,
		indexOf = String.prototype.indexOf,
		lastIndexOf = String.prototype.lastIndexOf,
		publicMethodFunction = [
			{ method : split, methodName : "split" },
			{ method : replace, methodName : "replace" },
			{ method : substr, methodName : "substr" },
			{ method : indexOf, methodName : "indexOf" },
			{ method : lastIndexOf, methodName : "lastIndexOf" }
		];
	
	$.extend({
		/**
	 	 * 去掉字符串两端的空格
	 	 */
		trim : trim ? function( text ) 
		{ 
			return text == (null || undefined) ? "" : trim.call( text );
		} : function( text ) 
		{ 
			return text == (null || undefined) ? "" : text.toString().replace( trimLeft, "" ).replace( trimRight, "" ); 
		},
		
		/**
	 	 * 删除数组中某一索引的数据后返回被删除的数组。
	 	 */
		out : function( array,  i )
		{
			return array.slice( 0, i ).concat( array.slice(i + 1) );
		},
		
		/**
	 	 * 序列化对象下的属性或方法，组成数组。
	 	 */
		Enumerator : function( t, ret, callback )
		{
			if ( ret == undefined )
			{
				ret = []; callback = null;
			}else if ( callback == undefined )
			{
				if ( $.isFunction(ret) )
				{
					callback = ret;
					ret = [];
				}else if ( $.isArray( ret ) ) {
					callback = null;
				}else{
					ret = []; callback = null;
				}
			}
			try{
				t = new Enumerator(t);
				for (; !t.atEnd() ; t.moveNext() ) {
					if ( $.isFunction(callback) )
					{
						ret.push(callback.call(t.item()));
					}else{
						ret.push(t.item());
					}
				}
			}catch(e){}
			return ret;
		},
		
		/**
	 	 * 获得从GET方法获得的数据。组成数组返回。
	 	 */
		querys : function( items, callback )
		{
			if ( items == undefined ) { 
				items = Request.QueryString;
				callback = null;
			}else if ( $.isFunction(items) ) {
				callback = items;
				items = Request.QueryString;
			}else{
				items = Request.QueryString(items);
			}
			return this.Enumerator( items, callback );
		},
		
		/**
	 	 * 获得从POST方法获得的数据。组成数组返回。
	 	 */
		posts : function( items, callback ){
			if ( items == undefined ) { 
				items = Request.Form;
				callback = null;
			}else if ( $.isFunction(items) ) {
				callback = items;
				items = Request.Form;
			}else{
				items = Request.Form(items);
			}
			return this.Enumerator( items, callback );
		},
		
		/**
	 	 * 获取一个GET方法下的数据。
	 	 */
		query : function( items, callback )
		{
			return this.querys( items, callback )[0];
		},
		
		/**
	 	 * 获取一个POST方法下的数据。
	 	 */
		post : function( items, callback )
		{
			return this.posts( items, callback )[0];
		},
		
		/**
	 	 * 遍历syQuery对象或者数组或者new function对象下的数据，经过处理后组成新数据。原长度不变，内容改变。
		 * 如果返回 null 则删除该数据
	 	 */
		map : function( elems, callback ){
			var ret = [], value, _this = this;
			for ( var i = 0, length = elems.length; i < length; i++ ) {
				value = callback.call( elems, i, elems[ i ] );
				if ( value != null ) {
					ret[ ret.length ] = value;
				}
			}
			return ret.concat.apply( [], ret );
		},
		
		grep: function( elems, callback, inv ) {
			var ret = [], retVal;
			inv = !!inv;

			// Go through the array, only saving the items
			// that pass the validator function
			for ( var i = 0, length = elems.length; i < length; i++ ) {
				retVal = !!callback( elems[ i ], i );
				if ( inv !== retVal ) {
					ret.push( elems[ i ] );
				}
			}

			return ret;
		},
		
		inArray : function( elem, array ) {
			if ( array.indexOf ) {
				return array.indexOf( elem );
			}
	
			for ( var i = 0, length = array.length; i < length; i++ ) {
				if ( array[ i ] === elem ) {
					return i;
				}
			}
			
			return -1;
		},
		
		/**
	 	 * 返回一个时间戳。
	 	 */
		parseDate : function(date){
			var date = Date.parse(date);
			return isNaN(date) ? "" : date;
		},
		
		/**
	 	 * 判断是否为日期类型
	 	 */
		isDateTime : function( d ){
			if ( $.isDate(d) ){
				return true;
			}else{
				return $.parseDate(d) != "";
			}
		},
		
		/**
	 	 * 转换时间格式模型函数。
		 * t <string> 时间格式 
		 * k <Date | string | object> 时间
	 	 */
		date : function( t, k ){
			function dateValue( type ){
				var returnStr = "";
				for ( var i = 0; i < type.length; i++ ) 
				{ 
					var curChar = type.charAt(i); 
					if (dateArray[curChar]) 
					{ 
						returnStr += (dateArray[curChar])(); 
					} else 
					{ 
						returnStr += curChar; 
					} 
				}
				return returnStr;
			}
			var dateArray = {
				shortMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
				longMonths: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
				shortDays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
				longDays: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
				// Day
				d: function() { 
					return (date.getDate() < 10 ? '0' : '') + date.getDate(); 
				},
				// Week
				w: function() { 
					return syQuery.trim(this.r().split(" ")[0]) 
				},
				W: function() { 
					return (function(){ 
						var week = dateArray.w(), 
							out = ""; 
						for (var x = 0 ; x < dateArray.shortDays.length ; x++)
						{ 
							if (dateArray.shortDays[x] == week)
							{ 
								out = dateArray.longDays[x]; 
								break; 
							}
						} 
						return out; 
					})() 
				},
				// Month
				F: function() { 
					return dateArray.longMonths[date.getMonth()]; 
				},
				m: function() { 
					return (date.getMonth() < 9 ? '0' : '') + (date.getMonth() + 1); 
				},
				// Year
				Y: function() { 
					return date.getFullYear(); 
				},
				y: function() { 
					return ('' + date.getFullYear()).substr(2); 
				},
				// Time
				a: function() { 
					return date.getHours() < 12 ? 'am' : 'pm'; 
				},
				A: function() { 
					return date.getHours() < 12 ? 'AM' : 'PM'; 
				},
				H: function() { 
					return (date.getHours() < 10 ? '0' : '') + date.getHours(); 
				},
				I: function() { 
					return (date.getMinutes() < 10 ? '0' : '') + date.getMinutes(); 
				},
				S: function() { 
					return (date.getSeconds() < 10 ? '0' : '') + date.getSeconds(); 
				},
				z : function(){ 
					return date.getTime(); 
				}
			}, date = new Date();
			if ( t == undefined )
			{
				t = "Y/m/d H:I:S";
				return dateValue(t);
			}
			if ( k == undefined )
			{
				if ( $.isDateTime(t) ){
					k = $.isDate(t) ? t : (new Date($.parseDate(t)));
					t = "Y/m/d H:I:S";
				}else{
					k = new Date();
				}
				date = k;
				return dateValue(t);
			}
			if ( $.isDateTime(k) ){
				k = $.isDate(k) ? k : (new Date($.parseDate(k)));
				date = k;
				return dateValue(t);
			}else{
				return "";
			}
		},
		
		/**
	 	 * 当前时间
		 * i <string> 时间格式
	 	 */
		now : function(i)
		{
			return $.date(i);
		},
		
		parseJSON : function(data){
			if ( data == undefined || !$.isString(data) ) {
				return null;
			}
	
			// Make sure leading/trailing whitespace is removed (IE can't handle it)
			data = $.trim( data );
	
			// Make sure the incoming data is actual JSON
			// Logic borrowed from http://json.org/json2.js
			if ( rvalidchars.test(data.replace(rvalidescape, "@")
				.replace(rvalidtokens, "]")
				.replace(rvalidbraces, "")) ) {
	
				// Try to use the native JSON parser first
				return (new Function("return " + data))();
	
			} else {
				$.setError( "Invalid JSON: " + data );
			}
		},
		
		/**
	 	 * 普通获取Session的方法
	 	 */
		getSession : function( key )
		{
			return Session(key);
		},
		
		/**
	 	 * 普通设置Session的方法
	 	 */
		setSession : function( key, value )
		{
			Session( key ) = value;
		},
		
		/**
	 	 * Session方法模型函数
		 * key <json | string> 
		 * 		当key为JSON格式，那么将设置Session
		 *		当key为string格式，那么将获取Session或者设置Session
		 * value <string | array | object | json> 当不为undefined时为设置Session，其他为获取Session
	 	 */
		session : function( key , value )
		{
			if ( value == undefined ){
				if ( $.isJson( key ) )
				{
					for ( var i in key )
					{
						$.setSession( i, key[i] );
					}
				}else if ( $.isString(key) ){
					return $.getSession(key);
				}
			}else{
				$.setSession( key, value );
			}
		},
		
		/**
	 	 * 移除某个Session或者多个Session
	 	 */
		removeSession : function(key){
			if ( $.isString(key) ){
				Session.Contents.Remove(key);
			}else if ( $.isArray(key) ){
				$.arrEach(key, function(i, k){
					$.removeSession(k);
				});
			}else{
				Session.Contents.RemoveAll();
			}
		},
		
		getCookie : function(key){
			var keySplit = key.split(".");
			if ( keySplit.length == 2 ){
				return Request.Cookies( keySplit[0] )( keySplit[1] );
			}else{
				return Request.Cookies( key );
			}
		},
		
		setCookie : function( key, value, expr, domain ){
			var keySplit = key.split("."), temp = "";
			if ( keySplit.length == 2 ){
				Response.Cookies( keySplit[0] )( keySplit[1] ) = value;
				temp = keySplit[0];
			}else{
				Response.Cookies( key ) = value;
				temp = key;
			}
			if ( expr != undefined ){
				var now = (new Date()).getTime();
				var diff = now + parseInt(expr * 24 * 60 * 60 * 1000);
				Response.Cookies(temp).Expires = $.date("F d,Y", ( new Date(diff) ));
			}
			if ( domain != undefined ){
				Response.Cookies(temp).Domain = domain;
			}
		},
		
		cookie : function( key, value, expr, domain ){
			if ( value == undefined ){
				if ( $.isJson(key) ){
					for ( var i in key ){
						var val = key[i];
						if ( $.isJson( val ) ){
							for ( var j in val )
							{
								$.setCookie( i + "." + j, val[j], expr, domain );
							}
						}else{
							$.setCookie( i, val, expr, domain );
						}
					}
				}else{
					return $.getCookie( key );
				}
			}else{
				$.setCookie( key, value, expr, domain );
			}			
		},
		
		removeCookie : function( key ){
			if ( $.isArray( key ) ){
				$.arrEach(key, function(i, k){
					$.removeCookie(k);				
				});
			}else{
				Response.Cookies(key).Expires = "1/1/1980";
			}
		},
		
		makeJsonParme : function( key, value ){
			var jLeft = '"' + key + '"', jRight = '';
			if ( $.isString( value ) ){
				jRight = '"' + escape(value) + '"';
			}else if ( $.isNumber( value ) ) {
				jRight = value;
			}else if ( $.isBoolean( value ) ) {
				jRight = String(value).toLowerCase();
			}
			if ( jRight != '' ){
				return jLeft + ':' + jRight;
			}else{
				return '';
			}
		},
		
		makeJson : function( key, value ){
			if ( value == undefined ){
				var i, a = [] ;
				if ( $.isArray( key ) ){
					$.arrEach(key, function(i, k){
						if ( $.isArray( k ) ){
							a.push( $.makeJsonParme( k[0], k[1] ) );
						}else if ( $.isJson( k ) ){
							for ( i in k ){
								a.push( $.makeJsonParme( i, k[i] ) );
							}
						}
					})
				}else if ( $.isJson( key ) ){
					for ( i in key ){
						a.push( $.makeJsonParme( i, key[i] ) );
					}
				}
				a = $.map(a, function(i, k){
					if ( k == '' ){
						return null;
					}else{
						return k;
					}
				});
				return '{' + a.join(",") + '}';
			}else{
				return '{' + $.makeJsonParme(key, value) + '}';
			}
		},
		
		toArray : function( data ){
			var a = [];
			for ( var i = 0 ; i < data.length ; i++ )
			{
				a.push( data[i] )
			}
			return a;
		},
		
		getIP : function(){
			var userip = String(Request.ServerVariables("HTTP_X_FORWARDED_FOR")).toLowerCase();
			if ( userip == "undefined" ) userip = String(Request.ServerVariables("REMOTE_ADDR")).toLowerCase();
			return userip;
		},
		
		active : function( k ){
			return new ActiveXObject( k );
		},
		
		param : function( a ) {
			var s = [],
				add = function( key, value ) {
					// If value is a function, invoke it and return its value
					value = $.isFunction( value ) ? value() : value;
					s[ s.length ] = encodeURIComponent( key ) + "=" + encodeURIComponent( value );
				};
			if ( $.isArray( a ) ){
				$.arrEach(a, function(i, k){
					add( k[0], k[1] );
				});
			}else if ( $.isJson( a ) ){
				$.jsonEach(a, function(i, k){
					add( i, k );
				});
			}
			// Return the resulting serialization
			return s.join( "&" ).replace( /%20/g, "+" );
		},
		
		mat : function( str, reg, callback ){
			return $.map(str.match(reg), function(i, k){
				var r = reg.exec(k);
				if ( r ){
					if ( $.isFunction(callback) ) 
					{
						return callback.call(r, k);
					}else{
						return null;
					};
				}else{
					return null;
				}
			});
		}
	});
	
	$.fn.extend({
		each : function( callback, args )
		{
			return $.each( this, callback, args );
		},
		
		map : function( callback )
		{
			return $.makeArray( $.map(this, callback) , $(), this.object );
		},
		
		trim : function()
		{
			return this.map(function(i, k){
				return $.trim(k);
			});
		},
		
		toArray: function() 
		{
			return slice.call( this, 0 );
		},
		
		out : function( i )
		{
			return $.makeArray( $.out( this.toArray(), i ) , $(), this.object );
		},
		
		echo : function()
		{
			var _arguments = arguments;
			if ( _arguments.length == 0 ){
				$.echo( this.get(0) );
				return ;
			}
			var num = 0, str = "", fn, args, context;
			for ( var j = 0 ; j < _arguments.length ; j++ )
			{
				if ( $.isString( _arguments[j] ) )
				{
					str = _arguments[j];
				}else if ( $.isNumber( _arguments[j] ) )
				{
					num = _arguments[j];
				}else if ( $.isFunction( _arguments[j] ) )
				{
					fn = _arguments[j];
				}else if ( $.isArray( _arguments[j] ) ){
					args = _arguments[j];
				}
			}
			if ( num == 0 ){
				context = this.toArray().join(str);
			}else{
				context = this.toArray().slice( 0, num ).join(str);
			}
			$.echo( context, fn, args );
		},
		
		get : function(num)
		{
			return num == undefined ? this.toArray() : ( num < 0 ? this.slice(num)[ 0 ] : this[ num ] ); 
		},
		
		eq: function( i ) 
		{
			return i === -1 ?
				this.slice( i ) :
				this.slice( i, +i + 1 );
		},
		
		slice : function()
		{
			return $.makeArray( slice.apply( this, arguments ), $(), this.object );
		},
		
		left : function(i)
		{
			return this.substr(0, i);
		},
		
		right : function(i)
		{
			return this.substr(this.size() - i, i);
		},
		
		mid : function(i, t)
		{
			return this.substr(i - 1, t);
		},
		
		instr : function(t)
		{
			this.indexOf(t);
		},
		
		instrrev : function(t)
		{
			return this.lastIndexOf(t);
		},
		
		first : function()
		{
			return this.eq(0);
		},
		
		last : function()
		{
			return this.eq(-1);
		},
		
		parseDate : function(){
			return this.map(function(i, k){
				return $.parseDate(k);					 
			});
		},
		
		date : function(t){
			return this.map(function(i, k){
				return $.date(t, k);					 
			});
		},
		
		lcase : function(){
			return this.map(function(i, k){
				return k.toLowerCase();
			});
		},
		
		ucase : function(){
			return this.map(function(i, k){
				return k.toUpperCase();	
			});
		},
		
		removeHTML : function(){
			return this.replace(/<[^>]*?>/g, "").replace(/\n\t\r/g, "");
		},
		
		removeUBB : function(){
			return this.replace(/\[(\w+).*?\](.+)\[\/\1\]/g, "$2").replace(/\n\t\r/g, "");
		},
		
		cutStr : function(n){
			return this.map(function(i, k){
				var j = 0, temp = "";
				for ( var i = 0 ; i < k.length ; i++ ){
					if ( !/[^\u4E00-\u9FA5]/g.test(k.charAt(i)) ){
						j = j + 2;
					}else{
						j = j + 1;
					}
					temp += k.charAt(i);
					if ( j >= (2 * n) ){ break; }
				}
				if ( temp != k ){ temp += "..." }
				return temp;
			});
		}
	});

	$.arrEach(publicMethodFunction, function(){
		var _this = this;
		
		$.fn[_this.methodName] = function(){
			var _arguments = arguments;
			return this.map(function(i, k){
				return _this.method.apply(k, _arguments);		 
			});
		}
	});
	
})();
%>