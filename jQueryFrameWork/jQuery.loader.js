// JavaScript Document
/**
 * syQuery 客户端框架
 * 扩展了jQuery 加载器功能和全局运行规则，使用方法请参阅说明。
 */
(function($){
	// 全局事件原型函数
	var syQuery = function(){
		if ( arguments.length == 0 ) return;
		
		// 获得eventType值
		var eventType = arguments[0];
		
		// 将数据加入到框架内部
		if ( syQuery.event[eventType] && $.isArray( syQuery.event[eventType] ) ){
			
			// 遍历数据
			for ( var i = 1 ; i < arguments.length ; i++ )
			{
				syQuery.event[eventType].push(arguments[i]);
			}	
		}
	},
	event = event || window.event;
	
	// 全局事件调用集合
	syQuery.event = {
		contextMenu : [],
		documentClick : []
	}
	
	// 已加载模块集合 通过 syQuery.add
	syQuery.module = {}
	syQuery.Evq = [];
	
	// 全局参数设置
	syQuery.Config = {
		debug : true,
		site : "http://syQuery.cn"
	}
	
	// console 封装
	// categories are "info", "warn", "error", "time" etc.
	syQuery.log = function(msg, cat, src) {
		if (this.Config.debug) {
			if (src) {
				msg = src + ': ' + msg;
			}
			if (console.log) {
				console[cat && console[cat] ? cat : 'log'](msg);
			}
		}
	}
	
	function windowEventPreventDefault( e ){
		if ( syQuery.event.contextMenu.length > 0 ){
			// 执行绑定的方法
			document.oncontextmenu = function(e){
				for ( var i = 0 ; i < syQuery.event.contextMenu.length ; i++ ){
					if (window.event){
						window.event.cancelBubble = true;
						window.event.returnValue = false;
					}
					if ( e && e.stopPropagation && e.preventDefault ){
						e.stopPropagation();
						e.preventDefault();
					}
					syQuery.event.contextMenu[i]();
				}
			}	
		}
	}
	
	function windowDocumentClickEventBindMethod(){
		if ( syQuery.event.documentClick.length > 0 ){
			$(window.document).bind("click", function(event){
				for ( var i = 0 ; i < syQuery.event.documentClick.length ; i++ )
				{
					var _domEvent = syQuery.event.documentClick[i];
					if (($(_domEvent.dom)[0] == event.target) || ($(event.target).parents(_domEvent.dom).length !== 0))
					{
						continue;
					}else{
						_domEvent.fn();
					}
				}
			});
		}
	}
	
	// 页面执行完毕绑定的方法
	$(document).ready(function(){
		windowEventPreventDefault();
		windowDocumentClickEventBindMethod();
	});
	
	// 扩展方法
	$.extend(true, syQuery, {
		
		// 延迟函数
		later: function(fn, when, periodic) {
            when = when || 0;
            return {
                id: (periodic) ? setInterval(fn, when) : setTimeout(fn, when),
                interval: periodic,
                cancel: function() {
                    if (this.interval) {
                        clearInterval(r);
                    } else {
                        clearTimeout(r);
                    }
                }
            };
        },
		
		// script状态监听函数
		scriptOnLoad : document.addEventListener ?
			function(node, callback){
				node.addEventListener('load', callback, false);
			} : 
			function(node, callback){
                var oldCallback = node.onreadystatechange;
                node.onreadystatechange = function() {
                    var rs = node.readyState;
                    if (/loaded|complete/i.test(rs)) {
                        node.onreadystatechange = null;
                        oldCallback && oldCallback();
                        callback();
                    }
                };
			},
			
		// 动态加载框架文件
		buildScript : function( url, success, charset ){
			var doc = document,
				head = doc.head || doc.getElementsByTagName("head")[0],
				node = doc.createElement("script"),
				config = success,
				error,
                timeout,
                timer,
				self = this;
				
			if ($.isPlainObject(config)) {
                success = config.success;
                error = config.error;
                timeout = config.timeout;
                charset = config.charset;
            }
			
			function clearTimer() {
                if (timer) {
                    timer.cancel();
                    timer = undefined;
                }
            }
			
			node.src = url;
            node.async = true;
			if (charset) {
                node.charset = charset;
            }
			
			if (success || error) {
                self.scriptOnLoad(node, function() {
                    clearTimer();
					syQuery.log(url, "info", "script loaded ");
                    $.isFunction(success) && success.call(node);
                });

                if ($.isFunction(error)) {

                    //标准浏览器
                    if (doc.addEventListener) {
                        node.addEventListener("error", function() {
                            clearTimer();
                            error.call(node);
                        }, false);
                    }

                    timer = self.later(function() {
                        timer = undefined;
                        error();
                    }, (timeout || 1) * 1000);
                }
            }
			
            head.insertBefore(node, head.firstChild);
			
            return node;
		},
		
		// 为框架扩展模块的方法
		add : function( moduleName, moduleCallback, moduleEvquireMent ){
			var self = this;
			
			if ( moduleEvquireMent != undefined ){
				return self.build(moduleEvquireMent, function(){
					return self.add(moduleName, moduleCallback);
				});
			}
			
			if ( self.module[moduleName] == undefined ){
				self.module[moduleName] = moduleCallback();
			}else{
				self.log("exsit", "warn", "module {" + moduleName + "}");
			}
		},
		
		use : function(moduleName, moduleCallback, moduleEvquireMent){
			var self = this,
				modArr = [],
				i = 0,
				mods;
			
			if ( moduleEvquireMent != undefined ){
				return self.build(moduleEvquireMent, function(){
					return self.use(moduleName, moduleCallback);
				});
			}
			
			// 取得syQuery.module中插件对象
			// 其实可以使用 syQuery.module["key"]来获取
			mods = moduleName.split(",");
			for ( i = 0 ; i < mods.length ; i++ )
			{
				modArr.push(syQuery.module[mods[i].replace(/^\s+/, "").replace(/\s+$/, "")]);
			}
			
			// 如果就指定模块名，没有没有FN的话，直接返回这个包含了对象的数组
			// 如果该数组只存在一个对象，那么返回这个数组第一个数据对象，其他则返回数组
			if ( moduleCallback == undefined ) return modArr.length === 0 ? modArr[0] : modArr;
			return moduleCallback.apply(self, modArr);
		},
		
		build : function( mod, callback ){
			
			/**
			 * mod 必须是个数组
			 * callback 可以是json格式或者function
			 * 		- success  回调成功后执行的方法
			 * 		- callback 回调单步加载完毕时执行的方法
			 */
			var i, 
				A = mod.require.length, 
				B = 0,
				timer,
				reTimer = true,
				config = {};
				
			if ( $.isFunction(callback) ) config.success = callback;

			if ( mod.require != undefined ){
				for ( i = 0 ; i < A ; i++ ){
					var file = mod.require[i];
					
					// 如果不是远程地址，直接强制使用默认地址头
					// 再加上文件路径和JS来组成完整的文件远程地址
					// 在通过script标签的包围来加载运行代码
					if ( file.substr(0, 7).toLowerCase() != "http://" ) {
						file = this.Config.site + "/" + file + ".js";
					}
					
					if ( $.inArray(file, syQuery.Evq) == -1 ){	
						this.buildScript(file, function(){	
							syQuery.Evq.push(file);
							B++;
							$(this).remove(); // 移除
							
							/**
							 * 这里的config.callback作用是可以回调当前加载的步骤。
							 * 参数第一个为 加载的当前序列好号
							 * 参数第二个为 一共需要加载的数量
							 * 可以使用这2个参数来执行加载进度条显示效果
							 */
							if ( config.callback != undefined && $.isFunction(config.callback) ) {
								config.callback.call(undefined, B, A);
							}
						});	
					}else{
						reTimer = false;
						break;
					}
				}
				
				function laterCallback(){
					if ( A == B ){
						clearTimeout(timer);
						config.success();
					}else{
						laterCallback();
					}
				}
				
				// 延迟判断。确保加载完毕后执行success方法
				// 这里为什么需要使用延迟监听呢，主要是因为远程文件加载过程不能准确判断加载时间完毕
				// 使用延迟，达到可以同步的目的
				if ( reTimer == true ) { 
					timer = setTimeout(laterCallback, 500); 
				}else {
					config.success();
				}
			}	
		}
	});
	
	window.syQuery = syQuery;
})(jQuery);
