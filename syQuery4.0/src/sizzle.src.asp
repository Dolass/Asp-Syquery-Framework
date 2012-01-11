<%@LANGUAGE="JAVASCRIPT" CODEPAGE="65001"%>
<%
Response.Buffer = true;
Response.Charset = "UTF-8";
/**
 * @ version 4.0
 * @ author evio
 * @ change the mode for loader framework.
 * @ http://sizzle.cc
 * @ now start.
 */

// Base namespace for the framework.
var sizzle = { _sizzle : sizzle },
	data = {
		config : {
			debug : false,
			charset : "UTF-8",
			useApp : true,
			appName : "sizzle"
		},
		console : [],
		base : "/src/",
		modLoads : {},
		ActivexObject : {
			conn : "ADODB.CONNECTION",
			record : "ADODB.RECORDSET",
			fso : "Scripting.FileSystemObject",
			stream : "Adodb" + "." + "Stream",
			xmlhttp : "Microsoft.XMLHTTP",
			xml : "Microsoft.XMLDOM",
			winhttp : "WinHttp.WinHttpRequest.5.1"
		}
	},
	util = {},
	fn = {},
	JSON = {}.constructor,
	define, require;

// Base Function On Sizzle.
(function(U, D, F){
	
	var toString = Object.prototype.toString, AP = Array.prototype;
	
	// output msg
	F.write = function(ResponseText, isEnd){
		Response.Write(ResponseText);
		isEnd && Response.End();
	}
	
	// object's type
	U.type = function(object){
		return Object.prototype.toString.call(object).split(" ")[1].toLowerCase().replace("]", "");
	}
	
	// log msg
	U.log = function( msg, type ){
		D.console.push('<li class="' + (type ? type : "info") + '">' + msg + '</li>');
	}
	
	// write logs
	U.console = function(){
		D.console.length > 0 && F.write('<ol class="console">' + D.console.join("") + '</ol>');
	}
	
	U.isArray = function(object){ return this.type(object) === "array"; }
	U.isString = function(object){ return this.type(object) === "string"; }
	U.isFunction = function(object){ return this.type(object) === "function"; }
	U.isNumber = function(object){ return this.type(object) === "number"; }
	U.isBoolean = function(object){ return this.type(object) === "boolean"; }
	U.isInt = function(object){ return this.isNumber(object) ? true : ( !this.isString(object) ? false :  !isNaN(object) ) ; }
	U.isObject = function(object){ return this.type(object) === "object"; }
	
	U.unique = function(arr) {
    	var ret = [], o = {};

    	forEach(arr, function(item) { o[item] = 1; });

    	if (Object.keys) { ret = Object.keys(o); }
    	else { for (var p in o) { if (o.hasOwnProperty(p)) { ret.push(p); } } };

    	return ret;
  	};
	
	U.proxy = function( fn, context ) {
		var slice = Array.prototype.slice,
			args = slice.call( arguments, 2 ),
			proxy = function() {
				return fn.apply( context, args.concat( slice.call( arguments ) ) );
			};
		
		return proxy;
	}

	
	var forEach = U.forEach = AP.forEach ? function(arr, fn) { arr.forEach(fn); } :
      function(arr, fn) {
        for (var i = 0, len = arr.length; i < len; i++) { fn(arr[i], i, arr); };
      };
	
})(util, data, fn);

// fetch on sizzle
(function(F, D, U, S){
	// parse frame's path to sizzle.data
	var _base = getLocalPath( Server.MapPath("/"), Server.MapPath("."));
	if ( _base.length == 0 ) _base = "/";
	D.base = (_base + D.base.replace(/^\//, "") + "/").replace(/\/+/g, "/");
	
	// get the server page by Request.ServerVariables
	D.host = "http://" + Request.ServerVariables("HTTP_HOST");
	
	var regExpress = {
		includeExp : /\<\!\-\-\#include\sfile\s?\=\s?\"(.+?)\"\s?\-\->/g,
		includeFileExp : /file\=\"(.+)\"/,
		includeContentForLeftExp : /^[\r\t\s\n]+/,
		includeContentForRightExp : /[\r\t\s\n]+$/
	}
	
	F.selector = function(selector){
		if ( !/\.asp$/.test(selector) ) selector = selector + ".asp";
		
		if ( /^[\/|\.]/.test(selector) ){
			return Server.MapPath(selector);
		}else{
			return Server.MapPath(D.base + selector);
		}
	}
	
	F.module = function(id, deps, factory){
		this.id = id;
		this.deps = deps || [];
		this.factory = factory;
		this.exports = {};
	}
	
	define = F.define = function(){
		var id = "", deps = [], factory,
			arglen = arguments.length;
		
		if ( arglen === 0 ) return;
		
		for ( var i = 0 ; i < arglen ; i++ ){
			if ( U.isString(arguments[i]) ){
				id = arguments[i]
			}else if ( U.isArray(arguments[i]) ){
				deps = arguments[i];
			}else if ( U.isFunction(arguments[i]) ){
				factory = arguments[i];
			}
		}
		
		if ( id === undefined ) return;
		
		id = F.selector(id);
		
		if ( D.modLoads[id] == undefined ){
			if ( U.isFunction(factory) ){
				var _deps = parseDependencies(factory.toString());
				deps = deps.concat(_deps);
			}
			
			var Mod = new F.module(id, deps, factory);
			D.modLoads[id] = Mod;
		}
	}
	
	S.use = function(ids, fn){
		loadDeps( ids, false, function(relizeIds){ S.load(relizeIds, fn, false); } );
	}
	
	S.load = function(){
		var ids, 
			fn, 
			parseServer, 
			applyArguments = [];
		
		for ( var j = 0 ; j < arguments.length ; j++ ){
			if ( U.isString(arguments[j]) ){
				ids = [arguments[j]];
			}else if ( U.isArray(arguments[j]) ){
				ids = arguments[j];
			}else if ( U.isFunction(arguments[j]) ){
				fn = arguments[j];
			}else if ( U.isBoolean(arguments[j]) ){
				parseServer = arguments[j];
			}
		}
		
		if ( parseServer == undefined ) parseServer = true;
		
		for ( var i = 0 ; i < ids.length ; i++ ){
			var id = ids[i];
			if ( parseServer == true ) id = F.selector(id);
			var Mod = D.modLoads[id],
				deps = Mod.deps || [],
				factory = Mod.factory;
				
			if ( deps.length > 0 ) loadDeps(deps);
			var _Mod = factory != undefined ? factory.call(S, S.load, Mod.exports || {}, Mod) || (Mod.exports || {}) : undefined; // important
			applyArguments.push(_Mod);
		}
		
		return fn == undefined ? applyArguments : fn.apply(S, applyArguments);
	}
	
	S.include = F.fetch = function(id, parseServer){
		if ( parseServer == undefined ) parseServer = true;
		if ( parseServer == true ) id = F.selector(id);
		return GrepSytax(ReadFileContainer(id));
	}
	
	function ReadFileContainer(id){
		var o = new ActiveXObject(D.ActivexObject.stream), Text;
			o.Type = 2; o.Mode = 3; 
			o.Open(); 
				o.Charset = D.config.charset; 
				o.Position = o.Size; 
				o.LoadFromFile(id);
				Text = o.ReadText;
			o.Close;
			o = undefined;
		
		return reLoadContainerFileRelative(Text, id.split("/").slice(0, -1).join("/"));
	}
	
	function reLoadContainerFileRelative(context, localFo){
		var l = 0, text = "", r = 0, p = "", e, t, tempText;
		if ( regExpress.includeExp.test(context) ){
			while ( l > -1 ){
				l = context.indexOf("<" + "!--#include");
				if ( l > -1 ){
					text += context.substring(0, l); // 查找到的include前面部分
					context = context.substring(l + 12); // include文件部分
					r = context.indexOf("-->"); // 搜索结尾
					p = context.substring(0, r); // 得到文件区域
					e = p.replace(/file\s?\=\s?\"/, "").replace(/\"/g, "").trim();// 得到文件
					if ( localFo.length == 0 ){
						t = e;
					}else{
						t = localFo + "/" + e;
					} // 替换文件路径
					context = context.substring(r + 3); // 得到include后面部分
					tempText = ReadFileContainer(Server.MapPath(t)); // 文件打开后的内容
					text += reLoadContainerFileRelative(tempText, t.split("/").slice(0, -1).join("/"));
					//text = text + tempText + context;
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
	
	function GrepSytax(context){
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
	
	function parseDependencies(code) {
		var pattern = /(?:^|[^.])\brequire\s*\(\s*(["'])([^"'\s\)]+)\1\s*\)/g;
		var ret = [], match;
	
		code = removeComments(code);
		while ((match = pattern.exec(code))) {
		  if (match[2]) {
			ret.push(match[2]);
		  }
		}
	
		return U.unique(ret);
	}
	
	function removeComments(code) {
		return code
			.replace(/(?:^|\n|\r)\s*\/\*[\s\S]*?\*\/\s*(?:\r|\n|$)/g, '\n')
			.replace(/(?:^|\n|\r)\s*\/\/.*(?:\r|\n|$)/g, '\n');
	}
	
	function getLocalPath( root, local ){
		if ( root != local ){
			return (function(){
				var j = local.replace(
							new RegExp( "^" + root.replace(/\\/g, "\\\\") ), 
							""
						).substring(1).split("\\").length, 
					temp = "";
					
				for ( var i = 0 ; i < j ; i++ ){ temp += "../"; }
				
				return temp;
			})();
		}else{
			return "";
		}
	}
	
	function loadDeps(ids, callback, fn){
		var relizeIds = [];
		if ( !U.isArray(ids) ) ids = [ids];
		for ( var i = 0 ; i < ids.length ; i++ ){
			var id = F.selector(ids[i]);
			if ( D.modLoads[id] == undefined ){
				eval( F.fetch(id, false) );
			}
			relizeIds.push(id);
			U.isFunction(callback) && callback(id);
		}
		U.isFunction(fn) && fn(relizeIds);
	}
	
})(fn, data, util, sizzle);

// String Object Prototype.
(function(S, U, F){
	var rvalidchars = /^[\],:{}\s]*$/,
		rvalidescape = /\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,
		rvalidtokens = /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,
		rvalidbraces = /(?:^|:|,)(?:\s*\[)+/g;
	
	S.trim = S.trim ? S.trim : function(){
		return this.replace(/^\s+/, "").replace(/\s+$/, "");
	}
	S.parseJSON = function(){
		var data = this;
		if ( data == undefined || !util.isString(data) ) {
			return undefined;
		}

		data = data.trim();

		if ( rvalidchars.test(data.replace(rvalidescape, "@")
			.replace(rvalidtokens, "]")
			.replace(rvalidbraces, "")) ) 
		{	
			return (new Function("return " + data))();
		} else {
			return undefined;
		}
	}
	S.write = function(){
		F.write(this);
		return this;
	}
	S.sql = function(){
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
		].each(function(k, i){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	}
	
	S._sql = function(){
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
		].each(function(k, i){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	}
	
	S.cStr = function(){
		var _str = this;
		[
			[/\</g, "&#60;"],
			[/\>/g, "&#62;"]
		].each(function(k, i){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	}
	
	S._cStr = function(){
		var _str = this;
		[
			[/&#60;/g, "<"],
			[/&#62;/g, ">"]
		].each(function(k, i){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	}
	
	S.tStr = function(){
		var _str = this;
		[
			[/textarea/ig, "t&#101;xtarea"]
		].each(function(k, i){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	}
	
	S._tStr = function(){
		var _str = this;
		[
			[/t&#101;xtarea/ig, "textarea"]
		].each(function(k, i){
			_str = _str.replace(k[0], k[1]);
		});
		
		return _str;
	}
	
	// 分割字符串，以英文为标准
	S.cut = function(){
		// 参数选择 根据类型 
		// 参数说明：
		// <int> 切割字数
		// <boolean> 是否启用中文筛选
		// <string> 省略的字符
		var n, q, s, j = 0, temp = "", self = this, _value;
		
		for ( var o = 0 ; o < arguments.length ; o++ )
		{
			if ( U.isInt(arguments[o]) ){ n = arguments[o]; }
			if ( U.isString(arguments[o]) ){ s = arguments[o]; }
			if ( U.isBoolean(arguments[o]) ){ q = arguments[o]; }
		}
		
		for ( var i = 0 ; i < self.length ; i++ )
		{
			_value = self.charAt(i);
			if ( q ){
				var _ts = /[^\u4E00-\u9FA5]/g.test(_value);
				if ( _ts && j + 1 <= n ){ j++; temp += _value; }
				else{
					if ( j + 2 <= n ){ j = j + 2; temp += _value; }
					else{ break; }
				}
			}
			else{
				if ( j + 1 <= n ){ j++; temp += _value; }
				else{ break; }
			}
		}
		
		if ( temp != self ){ temp += (s || "...") }
		return temp;
	}
	
	S.removeHTML = function(){ return this.replace(/<[^>]*?>/g, "").replace(/\n\t\r/g, ""); }
	S.removeUBB = function(){ return this.replace(/\[(\w+).*?\](.+)\[\/\1\]/g, "$2").replace(/\n\t\r/g, ""); }	
	S.left = function(i){ return this.substr(0, i); }
	S.right = function(i){ return this.substr(this.length - i, i); }
	S.mid = function(i, t){ return this.substr(i - 1, t); }
	
	S.unicode = function(){
		var rs = "", self = this;
			 
		for( var i = 0 ; i < self.length ; i++ )
		{ 
			rs += "&#" + self.charCodeAt(i) + ";" ; 
		} 
		
		return rs;
	}
	
	S._unicode = function(){
		var self = this; k = self.split(";"), r = ""; 
		
		for( var x = 0 ; x < k.length ; x++ )
		{ 
			r += String.fromCharCode( k[x].replace( /&#/, "" ) ); 
		} 
		
		return r; 
	}
	
	S.session = function(){
		return F.session(this) || "";
	}
	
	S.clearSession = function(){
		F.clearSession(this);
	}
	
	S.application = function(value){
		var _this = this;
		if ( value === undefined ){
			return F.application(_this.toString());
		}else{
			F.application(_this.toString(), value);
		}
	}
	
	S.clearApplication = function(){
		var _this = this;
		F.clearApplication(_this.toString());
	}
	
})(String.prototype, util, fn);

// Array Object Prototype.
(function(A, U, F){
	A.unique = function(r){
		return r === true ? U.unique(this).reverse() : U.unique(this);
	}
	A.each = function(fn){
		return U.forEach(this, fn);
	}
	// 取第几个
	// slice(a, b) a 从第几个数开始取值 （起始0） b 取数量、长度
	A.eq = function(i){
		return i === -1 ?
			   this.slice( i ) :
			   this.slice( i, +i + 1 );
	}
	A.map = function( callback ){
		var ret = [], value, _this = this;
		
		for ( var i = 0, length = _this.length; i < length; i++ ) 
		{
			value = callback.call( _this, _this[ i ], i ) || null;
			if ( value !== null ) { ret[ ret.length ] = value; }
		}
		
		return ret.concat.apply( [], ret );
	}
	
	// 数组遍历搜索的方法
	A.indexOf = function( value ){
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
	}
	
	A.lastIndexOf = function( value ){
		var j = -1, _this = this;
		
		for ( var i = _this.length ; i > -1 ; i-- )
		{
			if ( _this[i] === value )
			{
				j = _this.length - i - 1;
				break;
			}
		}
		
		return j;
	}
	
	A.first = function(){ return this.eq(0); }
	A.last = function(){ return this.eq(-1); }
	
	A.remove = function(data){ 
		if ( U.isString(data) ){
			var i = this.indexOf(data);
			if ( i > -1 ){
				return this.remove(i);
			}
		}else if (data === 0){
			this.splice(0, 1);
		}else if ( U.isInt(data) ) {
			this.splice(data, 1);
		}
		
		return this;
	}
	
	A.trim = function(){
		return this.map(function(k){
			return k.toString().trim();
		});
	}
	
	A.unique = function(){
		return U.unique(this);
	}
	
	A.session = function(){
		return this.map(function(k){
			return F.session(k) || null;
		});
	}
	
	A.clearSession = function(){
		this.each(function(k){
			F.clearSession(k);
		});
	}
	
	A.application = function(){
		return F.application(this);
	}
	
	A.clearApplication = function(){
		F.clearApplication(this);
	}
	
})(Array.prototype, util, fn);





(function(N, U){
	
	N.write = function(){
		this.toString().write();
	}
	
})(Number.prototype, util);

(function(DT){
	
	DT.format = function(type){
		var date = this,
			year = (date.getFullYear()).toString(),
			_month = date.getMonth(),
			month = (_month + 1).toString(),
			day = (date.getDate()).toString(),
			hour = (date.getHours()).toString(),
			miniter = (date.getMinutes()).toString(),
			second = (date.getSeconds()).toString(),
			_day, _year;
			
		var dateArray = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];	
		
		month = month.length === 1 ? "0" + month : month;
		_day = day;
		day = day.length === 1 ? "0" + day : day;
		hour = hour.length === 1 ? "0" + hour : hour;
		miniter = miniter.length === 1 ? "0" + miniter : miniter;
		second = second.length === 1 ? "0" + second : second;
			
		return type.replace(/y/g, year)
				.replace(/m/g, month)
				.replace(/d/g, day)
				.replace(/h/g, hour)
				.replace(/i/g, miniter)
				.replace(/s/g, second)
				.replace(/M/g, dateArray[_month])
				.replace(/D/g, _day);
	}
	
})(Date.prototype, util);





(function(O, U, F){
	
	O.toStr = function(){
		return JSON.stringify(this);
	}
	
	O.session = function(){
		for ( var i in this ){
			F.session(i, this[i]);
		}
	}
	
	O.application = function(){
		F.application(this);
	}
	
	O.cookie = function(i){
		F.cookie(this, undefined, i);
	}
	
})(Object.prototype, util, fn);



(function(F, U, D){
	F.emtor = function(data, callback){
		var _data = new Enumerator(data),
			_ret = [];
		
		for (; !_data.atEnd() ; _data.moveNext() ) {
			if ( util.isFunction(callback) ){
				_ret.push(callback.call(_data, _data.item()));
			}else{
				_ret.push(_data.item());
			}
		}
		
		return _ret;
	}
	
	F.posts = function(key){
		try{
			return F.emtor(Request.Form(key));
		}catch(e){
			return [];
		}
	}
	F.gets = function(key){
		try{
			return F.emtor(Request.QueryString(key));
		}catch(e){
			return [];
		}
	}
	F.get = function(key, ret){
		var value = this.gets(key);
		if ( U.isArray(value) && value.length === 0 ){
			return ret || undefined;
		}else{
			return value[0];
		}
	}
	
	F.post = function(key, ret){
		var value = this.posts(key);
		if ( U.isArray(value) && value.length === 0 ){
			return ret || undefined;
		}else{
			return value[0];
		}
	}
	
	F.getIP = function(){
		var userip = String(Request.ServerVariables("HTTP_X_FORWARDED_FOR")).toLowerCase();
		if ( userip == "undefined" ) userip = String(Request.ServerVariables("REMOTE_ADDR")).toLowerCase();
		return userip;
	}
	
	F.session = function(key, value){
		if ( key === undefined && value === undefined ){
			this.clearSession();
		}else{
			if ( value === undefined ){
				return Session(key);
			}else{
				Session(key) = value;
			}
		}
	}
	
	F.clearSession = function(key){
		if ( key === undefined ){
			Session.Contents.RemoveAll();
		}else{
			Session.Contents.Remove(key);
		}
	}
	
	F.application = function(key, value){
		if ( key === undefined && value === undefined ){
			this.clearApplication();
		}else{
			var dirct;
			if ( value === undefined ){
				if ( U.isObject(key) ){
					Application.Lock();
					dirct = Application.StaticObjects(D.config.appName);
					for ( var i in key ){
						dirct.Item(i) = key[i];
					}
					Application.UnLock();
				}else if ( U.isArray(key) ){
					dirct = Application.StaticObjects(D.config.appName);
					return key.map(function(k){
						return dirct.Item(k);
					});
				}else if ( U.isString(key) ){
					dirct = Application.StaticObjects(D.config.appName);
					return dirct.Item(key);
				}
			}else{
				Application.Lock();
				dirct = Application.StaticObjects(D.config.appName);
				dirct.Item(key) = value;
				Application.UnLock();
			}
		}
	}
	
	F.clearApplication = function(key){
		Application.Lock();
		if ( key === undefined ){
			Application.StaticObjects(D.config.appName).RemoveAll();
		}else{
			var dirct = Application.StaticObjects(D.config.appName), i;
			try{
				if ( U.isArray(key) ){
					for ( i = 0 ; i < key.length ; i++ ){
						dirct.Remove(key[i]);
					}
				}else if ( U.isString(key) ){
					dirct.Remove(key);
				}
			}catch(e){}
		}
		Application.UnLock();
	}
	
	F.cookie = function(name, value, expire){
		var root = "";
		
		if ( U.isObject(name) ){
			for ( var i in name ){
				F.cookie(i, name[i], expire);
			}
			return;
		}
		
		if ( U.isString(name) ){
			if ( value === undefined ){
				return (function(n){
					try{
						var _name = splitCookie(n);
						root = _name[0];
						if ( _name.length === 2 ){
							return Request.Cookies(_name[0])(_name[1]) || "";
						}else{
							return Request.Cookies(_name[0]) || "";
						}
					}catch(e){
						return "";
					}
				})(name);
			}else{
				var _name = splitCookie(name);
				root = _name[0];
				if ( _name.length === 2 ){
					Response.Cookies(_name[0])(_name[1]) = value;
				}else{
					Response.Cookies(_name[0]) = value;
				}
			}
		}

		if ( expire === undefined || !U.isInt(expire) || ( expire === 0 ) ){
			return;
		}
		
		// expire 根据天数据  1000ms = 1s  60000ms = 1min 3600000ms = 1h 86400000ms = 1d
		if ( root.length > 0 ){
			if ( expire > 0 ){
				var NowDateStamp = new Date();
				NowDateStamp.setDate(NowDateStamp.getDate() + expire);

				Response.Cookies(root).Expires = NowDateStamp.format("M D, y");	
			}
		}
	}
	
	F.clearCookie = function(name){
		name = splitCookie(name);
		Response.Cookies(name[0]).Expires = "1/1/1980";
	}
	
	function splitCookie(name){
		return name.split(",").trim();
	}
	
})(fn, util, data);


(function () {
    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf()) ?
                   this.getUTCFullYear()   + '-' +
                 f(this.getUTCMonth() + 1) + '-' +
                 f(this.getUTCDate())      + 'T' +
                 f(this.getUTCHours())     + ':' +
                 f(this.getUTCMinutes())   + ':' +
                 f(this.getUTCSeconds())   + 'Z' : null;
        };

        String.prototype.toJSON =
        Number.prototype.toJSON =
        Boolean.prototype.toJSON = function (key) {
            return this.valueOf();
        };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

        escapable.lastIndex = 0;
        return escapable.test(string) ?
            '"' + string.replace(escapable, function (a) {
                var c = meta[a];
                return typeof c === 'string' ? c :
                    '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
            }) + '"' :
            '"' + string + '"';
    }


    function str(key, holder) {

// Produce a string from holder[key].

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.

            return String(value);

// If the type is 'object', we might be dealing with an object or an array or
// null.

        case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

            if (!value) {
                return 'null';
            }

// Make an array to hold the partial results of stringifying this object value.

            gap += indent;
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === '[object Array]') {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                v = partial.length === 0 ? '[]' :
                    gap ? '[\n' + gap +
                            partial.join(',\n' + gap) + '\n' +
                                mind + ']' :
                          '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

// If the replacer is an array, use it to select the members to be stringified.

            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    k = rep[i];
                    if (typeof k === 'string') {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

            v = partial.length === 0 ? '{}' :
                gap ? '{\n' + gap + partial.join(',\n' + gap) + '\n' +
                        mind + '}' : '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

            var i;
            gap = '';
            indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                     typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

            return str('', {'': value});
        };
    }


// If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) {

// The parse method takes a text and an optional reviver function, and returns
// a JavaScript value if the text is a valid JSON text.

            var j;

            function walk(holder, key) {

// The walk method is used to recursively walk the resulting structure so
// that modifications can be made.

                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }


// Parsing happens in four stages. In the first stage, we replace certain
// Unicode characters with escape sequences. JavaScript handles many characters
// incorrectly, either silently deleting them, or treating them as line endings.

            text = String(text);
            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }

// In the second stage, we run the text against regular expressions that look
// for non-JSON patterns. We are especially concerned with '()' and 'new'
// because they can cause invocation, and '=' because it can cause mutation.
// But just to be safe, we want to reject all unexpected forms.

// We split the second stage into 4 regexp operations in order to work around
// crippling inefficiencies in IE's and Safari's regexp engines. First we
// replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
// replace all simple value tokens with ']' characters. Third, we delete all
// open brackets that follow a colon or comma or that begin the text. Finally,
// we look to see that the remaining characters are only whitespace or ']' or
// ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.

            if (/^[\],:{}\s]*$/.
test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@').
replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

// In the third stage we use the eval function to compile the text into a
// JavaScript structure. The '{' operator is subject to a syntactic ambiguity
// in JavaScript: it can begin a block or an object literal. We wrap the text
// in parens to eliminate the ambiguity.

                j = eval('(' + text + ')');

// In the optional fourth stage, we recursively walk the new structure, passing
// each name/value pair to a reviver function for possible transformation.

                return typeof reviver === 'function' ?
                    walk({'': j}, '') : j;
            }

// If the text is not JSON parseable, then a SyntaxError is thrown.

            throw new SyntaxError('JSON.parse');
        };
    }
}());

// 输出global.asa文件
(function(D){
	var globalAsa = "/global.asa",
		fso = new ActiveXObject(D.ActivexObject.fso), 
		text = '<object id="' + ( D.config.appName || 'sizzle' ) + '" runat="server" scope="Application" progid="Scripting.Dictionary"></object><script language="JScript" runat="Server">function Session_OnStart(){};function Session_OnEnd(){};function Application_OnStart(){};function Application_OnEnd(){};</script>';
	
	if ( D.config.useApp && !fso.FileExists(Server.MapPath(globalAsa)) ){
		var stream = new ActiveXObject(D.ActivexObject.stream);
		
			stream.Type = 2; 
			stream.Mode = 3; 
			stream.Open();
			stream.Charset = D.config.charset;
			stream.Position = stream.Size; 
			stream.WriteText = text;
			stream.SaveToFile(Server.MapPath(globalAsa), 2);
			stream.Close;
			stream = null;
	}
	
	fso = null;
})(data);
%>