<%
$.add("xmlhttp", function(){
	var ajax = function(){
		var self = this;
		
		self.type = "GET";
		self.dataType = "text";
		self.async = false;
		self.object = new ActiveXObject($.config.ActivexObject.xmlhttp);
		self.contentType = "application/x-www-form-urlencoded";
		
		self.send = function(){
			var xhr = self.object;
			
			// 如果是GET方法，需要追加数据至URL尾部。
			if ( self.type.toUpperCase() == "GET" && self.data != undefined )
			{
				self.url = modifiyURI(self.url, self.data);
				self.data = null;
			}else{
				if ( self.data == undefined ){
					self.data = null;
				}
			}
			
			// 打开ajax发送请求
			if ( this.userName ){
				xhr.open( self.type.toUpperCase(), self.url, self.async, self.username, self.password );
			}else{
				xhr.open( self.type.toUpperCase(), self.url, self.async );
			}
			
			// ajax请求的各种状态
			xhr.onreadystatechange = function(){
				var _this = self.core;
				switch (xhr.readyState)
				{
					// 当前打开对象前执行的方法
					case 0 : if ( $.isFunction(_this.onBeforeOpen) ) _this.onBeforeOpen.call(xhr); break;
					
					// 发送数据前执行的方法
					case 1 : if ( $.isFunction(_this.onBeforeSend) ) _this.onBeforeSend.call(xhr); break;
					
					// HTTP传输执行的方法
					case 2 : if ( $.isFunction(_this.onHttped) ) _this.onHttped.call(xhr); break;
					
					// 正在发送数据的方法
					case 3 : if ( $.isFunction(_this.onSending) ) _this.onSending.call(xhr); break;
					
					// 状态改变的方法
					default : _this.onReady(xhr);
				}
			};
			
			// 如果是POST的请求，必须设置头部信息。
			if ( self.type.toUpperCase() == "POST" ) xhr.setRequestHeader("Content-Type", t.contentType);
			
			// 发送请求
			xhr.send(self.data);
			
			return this;
			
		}
		
		this.abort = function(){
			this.object.abort();
		}
		
		this.core = { 
			onReady : function(xhr){
				
				var _this = self.core,
					_reto = returnValue(xhr);
					
				switch ( xhr.status )
				{
					// 成功
					case 200 : if ( $.isFunction(_this.onSuccess) ) _this.onSuccess.call(xhr, _reto); break;
					// 未改变
					case 304 : if ( $.isFunction(_this.onNotModify) ) _this.onNotModify.call(xhr, _reto); break;
					// 未找到
					case 404 : if ( $.isFunction(_this.onNotFound) ) _this.onNotFound.call(xhr, _reto); break;
					// 禁止
					case 405 : if ( $.isFunction(_this.onForbid) ) _this.onForbid.call(xhr, _reto); break;
					// 服务器内部错误
					case 500 : if ( $.isFunction(_this.onServerError) ) _this.onServerError.call(xhr, _reto); break;
					// 超时
					case 504 : if ( $.isFunction(_this.onTimeout) ) _this.onTimeout.call(xhr, _reto); break;
					// 其他错误
					default : if ( $.isFunction(_this.onError) ) _this.onError.call(xhr, xhr.status);
				}
			}
		}
		
		var returnValue = function(xhr){
			if ( self.dataType === "json" ){
				return $.parseJson(xhr[responseType["text"]]);
			}else if ( self.dataType === "asp" ){
				return (new Function(xhr[responseType["text"]]))();
			}else{
				return xhr[responseType[self.dataType]];
			}
		}
	}

	$.augment(ajax, {
		setUrl : function(url){ this.url = url; return this; },
		setContentType : function(contentType){ this.contentType = contentType; return this; },
		setData : function(data){
			if ( $.isJson(data) ){
				this.data = param(data);
			}else{
				this.data = data;
			}
			return this;
		},
		setType : function(type){ this.type = type; return this; },
		setAsync : function(async){ this.anync = async; return this; },
		setConfirm : function(uname, upass){ this.userName = uname; this.password = upass; return this; },
		setHeader : function(json){ this.setHeader = json; return this; },
		setCore : function(key, callback){
			if ( callback == undefined ){
				for ( var i in key ){
					this.core[i] = key[i];
				}
			}else{
				this.core[key] = callback;
			}
			
			return this;
		},
		success : function(callback){ this.core["onSuccess"] = callback; return this; },
		setDataType : function(type){ this.dataType = type; return this; }
	});
	
	$.mix(ajax, {
		post : function(url, data, callback, dataType){
			var ajax = this;
				
				ajax = ajax.type("POST");
				ajax = ajax.url(url);
				ajax = ajax.success(callback);
				ajax = ajax.setDataType(dataType || "text");
				
			if ( data ) ajax = ajax.data(data);
			
			ajax.send().abort();
		},
		
		get : function(url, data, callback, dataType){
			var ajax = this;
				
				ajax = ajax.type("GET");
				ajax = ajax.url(url);
				ajax = ajax.success(callback);
				ajax = ajax.setDataType(dataType || "text");
				
			if ( data ) ajax = ajax.data(data);
			
			ajax.send().abort();
		}
	});
	
	function param(data){
		var tmpArr = [];
		for ( var i in data ){
			var _item = data[i];
			if ( $.isArray(_item) ){
				_item.each(function(j, k){
					tmpArr.push(i + "=" + k);
				});
			}else{
				tmpArr.push(i + "=" + _item);
			}
		}
		return tmpArr.join("&");
	}
	
	function modifiyURI(URI, DATA){
		if ( URI.indexOf("?") === -1 ){
			URI += "?" + DATA;
		}else{
			if ( /\?$/.test(URI) ){
				URI += DATA;
			}else{
				URI += "&" + DATA;
			}
		}
		return URI;
	}
	
	var responseType = {
		// 返回一般文本字符串
		"text" : "responseText",
		// 返回二进制数据流
		"binary" : "responseBody",	
		// 返回XML格式数据流
		"xml" : "responseXML",
		// 返回Stream对象数据流
		"stream" : "responseStream"
	}
	
	return ajax;
});
%>