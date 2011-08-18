<%
$.add("xmlhttp", function(){
	var ajax = function(){
		var self = this;
		self.type = "GET";
		self.async = false;
		self.object = new ActiveXObject($.config.ActivexObject.xmlhttp);
		self.contentType = "application/x-www-form-urlencoded";
		self.send = function(){
			var xhr = self.object;
			
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
					case 0 : if ( $.isFunction(_this.onBeforeOpen) ) _this.onBeforeOpen(xhr); break;
					case 1 : if ( $.isFunction(_this.onBeforeSend) ) _this.onBeforeSend(xhr); break;
					case 2 : if ( $.isFunction(_this.onHttped) ) _this.onHttped(xhr); break;
					case 3 : if ( $.isFunction(_this.onSending) ) _this.onSending(xhr); break;
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
				var _this = self.core;
				switch ( xhr.status ){
					case 200 : if ( $.isFunction(_this.onSuccess) ) _this.onSuccess(xhr); break;
					case 304 : if ( $.isFunction(_this.onNotModify) ) _this.onNotModify(xhr); break;
					case 404 : if ( $.isFunction(_this.onNotFound) ) _this.onNotFound(xhr); break;
					case 405 : if ( $.isFunction(_this.onForbid) ) _this.onForbid(xhr); break;
					case 500 : if ( $.isFunction(_this.onServerError) ) _this.onServerError(xhr); break;
					case 504 : if ( $.isFunction(_this.onTimeout) ) _this.onTimeout(xhr); break;
					default : if ( $.isFunction(_this.onError) ) _this.onError.call(xhr, xhr.status);
				}
			}
		}
	}

	$.augment(ajax, {
		// 设置URL
		url : function(url){
			this.url = url;
			return this;
		},
		contentType : function(contentType){
			this.contentType = contentType;
			return this;
		},
		data : function(data){
			if ( $.isJson(data) ){
				this.data = param(data);
			}else{
				this.data = data;
			}
			return this;
		},
		type : function(type){
			this.type = type;
			return this;
		},
		async : function(async){
			this.anync = async;
			return this;
		},
		confirm : function(uname, upass){
			this.userName = uname;
			this.password = upass;
			return this;
		},
		setHeader : function(json){
			this.setHeader = json;
			return this;
		},
		subCore : function(key, callback){
			this.core[key] = callback;
			return this;
		}
	});
	
	function param(data){
		var tmpArr = [];
		for ( var i in data )
		{
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
	
	return ajax;
});
%>