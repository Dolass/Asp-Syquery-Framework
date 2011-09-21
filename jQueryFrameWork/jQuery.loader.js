// JavaScript Document
;(function($, win){
	/**
	 * 事件绑定器
	 * arguments[0] 指定时间名称抑或syQuery指定的事件
	 * arguments[1] ~ arguments[n] 需要绑定的方法集合
	 * return null
	 */
	var syQuery = function(){
		if ( arguments.length == 0 ) return; // 空参数即返回
		var EveType = arguments[0],
			EveArray = [];
		
		if ( arguments[1] ){
			if ( $.isArray(arguments[1]) ){
				EveArray = arguments[1];
			}else{
				EveArray = array.slice.call(arguments, 1);
			}
			
			// 注册到事件数组中
			if ( !syQuery.Eve[EveType] ) syQuery.Eve[EveType] = [];

			EveArray.each(function(i, k){
				syQuery.Eve[EveType].push(k);
			});
		}
	},
	array = Array.prototype,
	event = event || window.event,
	cssLoadTimer;
	
	/**
	 * 公用局部变量 开始
	 * publish evio 2011-09-20
	 * configure framework
	 */
	syQuery.Eve = {}
	syQuery.module = {}
	syQuery.css = {}
	syQuery.config = {
		debug : false,
		host : "loader.cn/{where}",
		file : ""
	}
	
	// 公用局部变量 结束
	 
	syQuery.augment = function(s, a){ return $.extend(true, s.prototype, a); }
	syQuery.mix = function(s, t){ return $.extend(true, s, t); }
	
	syQuery.log = function(msg, cat, src) {
		if (this.config.debug) {
			if (src) {
				msg = src + ': ' + msg;
			}
			if (console.log) {
				console[cat && console[cat] ? cat : 'log'](msg);
			}
		}
	}
	
	// 注册Array操作到Array原型上
	syQuery.augment(Array, {
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
		map : function( callback ){
			var ret = [], value, _this = this;
			for ( var i = 0, length = _this.length; i < length; i++ ) {
				value = callback.call( _this, i, _this[ i ] );
				if ( value !== null ){
					ret[ ret.length ] = value;
				}	
			}
			
			return ret.concat.apply( [], ret );
		},
		
		trim : function(){
			return this.map(function(i, k){
				return k.replace(/^\s+/, "").replace(/\s+$/, "");
			});
		}
	});
	
	syQuery.mix(syQuery, {
		/**
		 * 运行框架之注册系统模块的方法
		 * @ param key  <string>   注册模块的名称
		 * @ param fn   <function> 注册模块的内容
		 * @ param ment <json>     模块运行需要的环境加载
		 * @ return null
		 * 注册完毕，它将会被加载到 syQuery.module 上成为系统新的模块。
		 * 注意：最好每个注册模块都有返回值，即时返回true 或者 false 也好。
		 * 如果特殊情况，可以不返回值。 但是理论上，这个返回值就是这个模块的入口。
		 * 没有如果就无法回调内部方法。
		 */
		add : function(key, fn, ment){
			var self = this;
			if ( !ment ) ment = { cover : false }
			if ( !ment.require ) ment.require = [];
			if ( !ment.file ) ment.file = self.config.file;
			
			self.build(ment.require, function(){
				if ( self.module[key] ){
					if ( ment.cover ) {
						self.module[key] = fn();
					}else{
						self.log("exsit", "warn", "module {" + key + "}");
					}
				}else{
					self.module[key] = fn();
				}
			}, ment.file);
		},
		
		/**
		 * 运行框架之调用系统注册模块的方法
		 * @ param key  <string>   注册模块的名称
		 * @ param fn   <function> 回调使用的方法 可省略。
		 * @ param ment <json>     回调使用所需要的坏境加载。
		 * @ return 当 fn == undefined 的时候存在返回值，其他时候是回调函数的返回值。
		 * 调用后，每个系统模块会被一次加载排列在fn的arguments上。
		 * 可以通过次序调用每个模块的入口。
		 * 注意，当没有fn的时候，函数只返回注册模块的入口，如果模块只有一个，将只返回这个模块的入口。如果有多个，就返回入口的集合。
		 * 当fn存在，且fn有返回值，那么函数返回最终的也是fn返回的值。
		 */
		use : function(key, fn, ment){
			var self = this;
			if ( !ment ) ment = { cover : false }
			if ( !ment.require ) ment.require = [];
			if ( !ment.file ) ment.file = self.config.file;
			
			self.build(ment.require, function(){
				var modArr = self.load(key);
				return fn.apply( self, $.isArray(modArr) ? modArr : [modArr] );
			}, ment.file);
		},
		
		/**
		 * 运行框架之聪模块名获取对象集合
		 * @ param key <string> 模块集合字符串
		 * @ return <object | undefined>
		 * 它与use的区别在于，他能单独返回对象，而use没有任何值返回。
		 * 也可以这么理解，USE是过程， load是对象。
		 */
		load : function(key){
			var keyArr = key.split(",").trim(),
				modArr = [],
				self = this;
				
			// 取得syQuery.module中插件对象
			// 其实可以使用 syQuery.module["key"]来获取
			for ( var i = 0 ; i < keyArr.length ; i++ )
			{
				modArr.push(self.module[keyArr[i]]);
			}
			
			return modArr.length === 1 ? modArr[0] : modArr;
		},
		
		/**
		 * 运行框架之搭建模块需要的环境 或者 系统运行需要的环境
		 * @ param mods <string> 模块名的集合 （逗号分隔）
		 * @ param callback <function> 加载完毕后回调的函数
		 * @ param file <string> 配置系统文件所在的目录
		 * 需要注意的是 file 可以省略 省略后即默认 syQuery.config.file 的值
		 * 没有返回值
		 */
		build : function(mods, callback, file){
			var self = this;
			if ( file == undefined ) file = self.config.file;
			
			// 模块地址转换
			// 注意 file 的值
			mods = mods.map(function(i, k){
				if ( /^http\:\/\//i.test(k) ){
					return k;
				}else{
					return "http://" + (self.config.host.replace("{where}", file) + "/" + k + ".js").replace(/\/\//g, "/");
				}
			});
			
			// 加载模块
			self.loadScripts(mods, {
				complete : callback
			});
		},
		
		/**
		 * 运行框架之检测DOM节点加载情况的方法
		 * @ param node  <HTMLELEMENT>   DOM Node
		 * @ param successCallback   <function> 加载成功后回调的函数方法
		 * @ param errorCallback <function>     加载失败后回调的函数方法
		 * @ return null
		 * 基本所有的DOM节点都能判断，只有LINK节点的CSS加载无法这样判断。
		 * 遇到CSS加载，需要通过其他方法来解决，请参阅本框架对CSS加载的具体方法。
		 */
		domReady : function( node, successCallback, errorCallback ){
			var DOMContentLoaded;
			// FOR FF ETC..
			if ( document.addEventListener ) {
				DOMContentLoaded = function() {	
					node.removeEventListener( "DOMContentLoaded", DOMContentLoaded, false );
				};
				node.addEventListener( "DOMContentLoaded", DOMContentLoaded, false );
				node.addEventListener( "load", successCallback, false );
				node.addEventListener( "error", errorCallback, false );
			// FOR IE ETC..
			} else if ( document.attachEvent ) {
				DOMContentLoaded = function() {
					var RS = node.readyState;
					if ( /loaded|complete/i.test(RS) ) {
                        node.onreadystatechange = null;
						$.isFunction(oldCallback) && oldCallback();
                        successCallback.call(node);
                    }
				};
				// 不考虑失败的情况，不得已而为之。
				var oldCallback = node.onreadystatechange;
				node.attachEvent( "onreadystatechange", DOMContentLoaded );
				//node.attachEvent( "onload", successCallback );
				//node.attachEvent( "onerror", errorCallback );
			}
		},
		
		/**
		 * 运行框架之动态加载JAVASCRIPT文件（远程&&本地）的方法
		 * @ param url  <string>   文件地址
		 * @ param success   <function | json> 成功回调函数 或者 配置参数
		 * @ param charset <function>    设置编码
		 * @ return script node
		 * 能监听数据加载完毕后执行固定的回调方法。
		 * 只适用于script脚本加载。
		 */
		loadScript : function(url, success, charset){
			var config = {},
				doc = win.document,
				head = doc.head || doc.getElementsByTagName("head")[0],
				node = doc.createElement("script"),
				self = this;
			
			// 继承数据
			// 注意success的数据变化意味着结构的变化	
			if ( $.isFunction(success) ){
				config.success = success;
				if ( charset ) config.charset = charset;
			}else if ( $.isPlainObject(success) ){
				config = success;
			}
			
			node.src = url;
            node.async = true;
			if (config.charset) node.charset = config.charset;
			
			if ( config.success || config.error ){
				self.domReady(
					node, 
					function() {
						self.log(url, "info", "script loaded ");
                    	$.isFunction(config.success) && config.success.call(node);
                	},
					function(){
						self.log(url, "warn", "script can't load ");
						$.isFunction(config.error) && config.error.call(node);
					}
				);
			}
			
			head.insertBefore(node, head.firstChild);
			return node;
			
		},
		
		/**
		 * 运行框架之批量动态加载JAVASCRIPT文件（远程&&本地）的方法
		 * @ param urls  <string>   文件地址集合
		 * @ param config   <json> 配置参数
		 * @ param i <number> 起始加载文件序号
		 * 只适用于script脚本加载。
		 */
		loadScripts : function(urls, config, i){
			if ( !i ) i = 0;

			config = $.extend({
				success : null,    // 单步回调
				error : null,
				complete : null,    // 完成回调
				charset : "UTF-8"   // 设置编码
			}, config);
			
			var len = urls.length,
				self = this;
				
			if ( i + 1 > len ){
				$.isFunction(config.complete) && config.complete(len);
			}else{
				self.loadScript(urls[i], {
					// 加载成功
					// 所有浏览器都支持
					success : function(){
						if ( $.isFunction(config.success) ) config.success(urls[i], i + 1, len);
						self.loadScripts(urls, config, ++i);
					},
					
					// 加载失败
					// 比如说 404 403 etc...
					// 这些情况的话，IE浏览器不支持， IE不考虑失败情况，这是不得已而为之。
					error : function(){
						if ( $.isFunction(config.error) ) config.error(urls[i], i + 1, len);
						self.loadScripts(urls, config, ++i);
					},
					
					// 设置编码
					charset : config.charset
				});
			}
		},
		
		/**
		 * 运行框架之动态加载CSS文件
		 * @ param url  <string>   css文件地址
		 * @ param success   <json> 回调函数
		 * 只适用于CSS脚本加载。
		 */
		loadCss : function(url, success){
			var doc = document,
				head = doc.head || doc.getElementsByTagName("head")[0],
				node = doc.createElement("link"),
				self = this;
				
			node.rel = "stylesheet";
			node.href = url;
			node.type = "text/css";
			node.async = true;
			
			if (window.attachEvent) {
				self.domReady(node, success);
			}else{
				if ( syQuery.css[url] ){
					syQuery.css[url].callbacks.push(success);
				}else{
					syQuery.css[url] = {
                        node : node,
                        callbacks : [success]
                    };
				}
				startCssTimer();
			}
			
			head.appendChild(node);
		},
		
		/**
		 * 运行框架之动态加载CSS文件
		 * @ param mods  <array>   css文件地址集合
		 * @ param complete   <json> 回调函数
		 * @ param i <number> 起始加载文件序号
		 * 只适用于CSS脚本加载。
		 */
		loadCsses : function(mods, complete, i){
			if ( !i ) i = 0;
			var len = mods.length,
				self = this,
				config;
			
			if ( $.isFunction(complete) ){
				config = {
					complete : complete
				}
			}else{
				config = $.extend({
					success : null,
					complete : null
				}, complete);
			}
			
			if ( i + 1 > len ){
				$.isFunction(config.complete) && config.complete(len);
			}else{
				self.loadCss(mods[i], function(){
					if ( $.isFunction(config.success) ) config.success(mods[i], i + 1, len);
					self.loadCsses(mods, config, ++i);
				})
			}
		}
	})
	
	// 页面加载完毕后需要绑定的方法
	$(document).ready(function(){
		windowEventPreventDefault();
		windowDocumentClickEventBindMethod();
	});
	
	// 右键菜单自定义功能
	function windowEventPreventDefault(){
		if ( syQuery.Eve.contextMenu ){
			if ( syQuery.Eve.contextMenu.length > 0 ){
				document.oncontextmenu = function(e){
					syQuery.Eve.contextMenu.each(function(i, callback){
						if (window.event){
							// IE
							window.event.cancelBubble = true;
							window.event.returnValue = false;
						}
						if ( e && e.stopPropagation && e.preventDefault ){
							// other
							e.stopPropagation();
							e.preventDefault();
						}
						callback();
					});
				}
			}
		}
	}
	
	// 页面任意位置点击自定义功能
	function windowDocumentClickEventBindMethod(){
		if ( syQuery.Eve.documentClick ){
			if ( syQuery.Eve.documentClick.length > 0 ){
				$(document).bind("click", function(event){
					syQuery.Eve.documentClick.each(function(i, _domEvent){
						if (($(_domEvent.dom)[0] == event.target) || ($(event.target).parents(_domEvent.dom).length !== 0))
						{}else{
							_domEvent.fn();
						}
					});
				});
			}
		}
	}
	
	function startCssTimer(){
		if ( !cssLoadTimer ){
			cssPoleLoad();	
		}else{
			syQuery.log("css polling.. wait!", "warn");
		}
	}
	
	function cssPoleLoad(){
		var monitors = syQuery.css,
			S = syQuery,
			isWebKit = !!navigator['userAgent'].match(/AppleWebKit/);
			
        for (var url in monitors) {
			
            var d = monitors[url],
                node = d.node,
                callbacks = d.callbacks,
                loaded = false;
			
			if ( isWebKit ){
				 if (node['sheet']) {
                    loaded = true;
                }
			}else{
				if (node['sheet']) {
					try {
						if (node['sheet'].cssRules) {
							loaded = true;
						}
					} catch(ex) {
						if (ex.name === 'NS_ERROR_DOM_SECURITY_ERR') {
							loaded = true;
						}
					}
				}
			}

            if (loaded) {
				cssLoadTimer = undefined;
				var temp = callbacks;
				delete syQuery.css[url];
				
				for ( var i = 0 ; i < temp.length ; i++ )
				{
					temp[i].call(node);
				}
            } else {
                cssLoadTimer = setTimeout(cssPoleLoad, 1000);
            }
        }
	}
	
	// 注册框架对象到全局对象
	win.$$ = win.syQuery = syQuery;
})(jQuery, window);