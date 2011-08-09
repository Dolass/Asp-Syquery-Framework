<%
/**
 * Project Name : "Microsoft.XMLHTTP" ActivexObject
 * Project Author : evio
 * CreateTime : 2011-04-21
 * Project Version : 2.0
 * condition : need MSXML4.0 support
 */
;(function(){
	
	$.extend({
		
		xmlhttp : function(){
			return $.active($.config.ActivexObject.xmlhttp);
		},
		
		// Ajax全局参数设置
		ajaxSettings : {
			dataType : {
				
				// 返回一般文本字符串
				text : "responseText",
				
				// 返回二进制数据流
				binary : "responseBody",
				
				// 返回XML格式数据流
				xml : "responseXML",
				
				// 返回Stream对象数据流
				stream : "responseStream"
			},
			accepts : {
				xml: "application/xml, text/xml",
				html: "text/html",
				text: "text/plain",
				json: "application/json, text/javascript",
				"*": "*/*"
			}
		},
		
		// ajaxSetup : <function>
		ajaxSetup : function( o ){
			return $.extend({
				url : null,
				type : "GET",
				contentType : "application/x-www-form-urlencoded",
				async : false,
				dataType : "text",
				
				// xhr.readyState:
				onBeforeOpen : null,
				onBeforeSend : null,
				onHttped : null,
				onSending : null,
				
				// xhr.status (200 305 404 405 500 504)
				onSuccess : null,
				onNotModify : null,
				onNotFound : null,
				onForbid : null,
				onServerError : null,
				onTimeout : null,
				
				onOtherError : null,
				
				readyState : 0,
				status : 0,
				
				callbackSub : null
				
			}, o || {});
		},
		
		ajax : function(options, xhr){
			if ( xhr == undefined ) xhr = $.xmlhttp();
			var t = $.ajaxSetup(options);
				
			/**
			 * 配置部分 开始
			 */
			 
			t.status = 0; t.readyState = 0;
			 
			var sXhr = {
				
				// 运行readyState代码
				callReadyStateFn : function(fn, xhr){
					if ( $.isFunction(fn) ) fn.call(xhr);
				},
				
				// 运行过程
				onReadyStateChange : function() {
					t.readyState = xhr.readyState;
					switch ( t.readyState ){
						case 0 : sXhr.callReadyStateFn(t.onBeforeOpen, xhr); break;
						case 1 : sXhr.callReadyStateFn(t.onBeforeSend, xhr); break;
						case 2 : sXhr.callReadyStateFn(t.onHttped, xhr); break;
						case 3 : sXhr.callReadyStateFn(t.onSending, xhr); break;
						default : sXhr.readyComplete.call(xhr);
					}
				},
				
				// 过程完毕
				readyComplete : function(){
					t.status = xhr.status;
					switch ( t.status ){
						case 200 : sXhr.statusCallback.onSuccess.call(xhr); break;
						case 304 : sXhr.statusCallback.onNotModify.call(xhr); break;
						case 404 : sXhr.statusCallback.onNotFound.call(xhr); break;
						case 405 : sXhr.statusCallback.onForbid.call(xhr); break;
						case 500 : sXhr.statusCallback.onServerError.call(xhr); break;
						case 504 : sXhr.statusCallback.onTimeout.call(xhr); break;
						default : sXhr.readyComplete.call(xhr, t.status);
					}
				},
				
				subCallback : function( x ){
					if ( x == "text" || x == "binary" || x == "stream" || x == "xml" )
					{
						return [  this[ $.ajaxSettings.dataType[x] ]  ];
					}
					if ( x == "json" ){
						return [$.parseJSON( this.responseText )];
					}
				},
				
				statusCallback : {
					
					// 200  fn : onSuccess
					onSuccess : function(){
						t.callbackSub = sXhr.subCallback.call( this, t.dataType )
						if ( $.isFunction(t.onSuccess) ) t.onSuccess.apply(xhr, t.callbackSub);
					},
					
					// 304  fn : onNotModify
					onNotModify : function(){
						if ( $.isFunction(t.onNotModify) ) t.onNotModify.call(xhr);
					},
					
					// 404  fn : onNotFound
					onNotFound : function(){
						if ( $.isFunction(t.onNotFound) ) t.onNotModify.call(xhr);
					},
					
					// 405  fn : onForbid
					onForbid : function(){
						if ( $.isFunction(t.onForbid) ) t.onForbid.call(xhr);
					},
					
					// 500  fn : onServerError
					onServerError : function(){
						if ( $.isFunction(t.onServerError) ) t.onServerError.call(xhr);
					},
					
					// 504  fn : onTimeout
					onTimeout : function(){
						if ( $.isFunction(t.onTimeout) ) t.onTimeout.call(xhr);
					},
					
					// *    fn : onOtherError
					onOtherError : function( i ){
						if ( $.isFunction(t.onOtherError) ) t.onOtherError.call(xhr, i);
					}
				},
				
				addUrl : function(url, data){
					var has = url.indexOf("?");
					if ( has == -1 ){
						data = url + "?" + $.param(data);
					}else{
						if ( /\?$/.test(url) ){
							data = url + $.param(data);
						}else{
							data = url + "&" + $.param(data);
						}
					}
					return data;
				}
			}
			/**
			 * 配置部分 结束
			 */
			if ( t.type == "GET" && t.data != undefined )
			{
				t.url = sXhr.addUrl(t.url, t.data);
				t.data = null;
			}else{
				if ( t.data == undefined ){
					t.data = null;
				}else{
					t.data = $.param(t.data);
				}
			}
			
			if ( t.username != undefined ){
				xhr.open( t.type, t.url, t.async, t.username, t.password );
			}else{
				xhr.open( t.type, t.url, t.async );
			}
			
			xhr.onreadystatechange = sXhr.onReadyStateChange;
			
			if ( t.type == "POST" ) xhr.setRequestHeader("Content-Type", t.contentType) ;
			
			xhr.send(t.data);
			
			xhr.abort();
			
			return t.callbackSub; // 必定是数组
		},
		
		send : function(url, options){
			if ( url == undefined ) return;
			if ( options == undefined ) { options = { url : url } }
			return $.ajax(options);
		},
		
		ajaxGet : function(url, data, fn, options){
			
			if ( options == undefined ){
				options = {} 
			}else{
				if ( $.isString(options) ){
					options = { dataType : options }
				}
			}
			
			if ( !$.isJson(options) ) { options = {} }
			
			options.type = "GET";
			options.url = url;
			options.data = data;
			options.onSuccess = fn;
			
			return $.ajax(options);
		},
		
		ajaxPost : function(url, data, fn, options){
			
			if ( options == undefined ){
				options = {} 
			}else{
				if ( $.isString(options) ){
					options = { dataType : options }
				}
			}
			
			if ( !$.isJson(options) ) { options = {} }
			
			options.type = "POST";
			options.url = url;
			options.data = data;
			options.onSuccess = fn;
			
			return $.ajax(options);
		},
		
		ajaxGetJson : function(url, data, fn){
			return $.ajaxGet(url, data, fn, "json");
		},
		
		ajaxPostJson : function(url, data, fn){
			return $.ajaxPost(url, data, fn, "json");
		}
	});
	
})();
%>