<%
;(function(){
	
	$.extend({
		
		winhttp : function(){
			return $.active($.config.ActivexObject.winhttp);
		},
		
		winSetup : function(options){
			return $.extend({	
				url : "",	
				type : "GET",	
				async : false,
				contentType : "application/x-www-form-urlencoded",		
				dataType : "text"	
			}, options || {});
		},
		
		win : function(options, whr){
			if ( whr == undefined ) whr = $.winhttp();
			var t = $.winSetup(options);
			
			/**
			 * 配置部分 开始
			 */
			var sWhr = {
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
			
			if ( t.type == "GET" && t.data != undefined )
			{
				t.url = sWhr.addUrl(t.url, t.data);
				t.data = null;
			}else{
				if ( t.data == undefined ){
					t.data = null;
				}else{
					t.data = $.param(t.data);
				}
			}
			
			whr.Open( t.type, t.url, t.async );   
		   	whr.Option(4) = 13056;   
   			whr.Option(6) = false;  
			
			if ( t.type == "POST" ){
				obj.setRequestHeader("Content-Type", t.contentType);
			}
			
			if ( t.header != undefined )
			{
				for ( var key in t.header )
				{
					if( key=="Cookie" ){//根据 MSDN 的建议，设置Cookie前，先设置一个无用的值   
                		whr.setRequestHeader("Cookie", "string");   
            		}   
            		whr.setRequestHeader(key, t.header[key]);   
				}
			}
			
			if ( t.referer != undefined )
			{
				// 伪造头部
				whr.setRequestHeader("Referer", t.referer);
			}
			
			whr.Send(t.data);
			
			if (whr.WaitForResponse()){
				if ( t.dataType == "text" ){
					if ( $.isFunction(t.onSuccess) ) t.onSuccess.call(whr, whr.ResponseText);
				}else if ( t.dataType == "json" ){
					if ( $.isFunction(t.onSuccess) ) t.onSuccess.call(whr, $.parseJSON(whr.ResponseText));
				}
			}else{
				if ( $.isFunction(t.onError) ) t.onError.call(whr);
			}
			whr.abort();
		},
		
		winGet : function(url, data, fn, options){
			
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
			
			return $.win(options);
		},
		
		winPost : function(url, data, fn, options){
			
			if ( options == undefined ){
				options = {} 
			}else{
				if ( $.isString(options) ){
					options = { dataType : options }
				}
			}
			
			if ( !$.isJson(options) ) { options = {} }
			
			options.type = "Post";
			options.url = url;
			options.data = data;
			options.onSuccess = fn;
			
			return $.win(options);
		}
		
	});
	
})();
%>