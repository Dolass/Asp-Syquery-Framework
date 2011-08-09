<%

// http://www.54bq.com/test.asp

;syQuery.add("oAuth", function(O){
	
	// custom 数值不能修改
	var custom = {
		oauth_signature_method : "HMAC-SHA1",
		oauth_version : "1.0",
		request_token_url : "http://openapi.qzone.qq.com/oauth/qzoneoauth_request_token",
		authorize_url : "http://openapi.qzone.qq.com/oauth/qzoneoauth_authorize",
		access_token_url : "http://openapi.qzone.qq.com/oauth/qzoneoauth_access_token",
		user_info_url : "http://openapi.qzone.qq.com/user/get_user_info"
	}, 
	TXAPP = {
		oauth_consumer_key : "205263",
		oauth_consumer_secret : "85b127e979f29089b1dd652435df3bfa"
	};
	
	syQuery.augment( O, {
		
		queryURL : "",
		oauth_token_secret : "",
		oauth_token : "",
		error : "",
		parameters : {},
		
		custom : function(json){
			var _custom = {
				oauth_consumer_key : TXAPP.oauth_consumer_key,
				oauth_nonce : (new Date).getTime().toString().substr(0, 8),
				oauth_timestamp : (new Date).getTime().toString().substr(0, 10),
				oauth_version : "1.0",
				oauth_signature_method : custom.oauth_signature_method
			}
			
			if ( json != undefined )
			{
				for ( var i in json )
				{
					_custom[i] = json[i];
				}
			}
			
			this.parameters = _custom;
		},
		
		query : function(){
			var normal = ["oauth_consumer_key", "oauth_nonce", "oauth_timestamp", "oauth_version", "oauth_signature_method"], arg = arguments;
			if ( arg.length > 0 ){
				for ( var i = 0 ; i < arg.length ; i++ )
				{
					normal.push(arg[i]);
				}
			}
			var _sort = Array.prototype.sort.call(normal),
				_custom = this.parameters,
				_arr = [];
			
			for ( var i = 0 ; i < _sort.length ; i++ )
			{
				_arr.push( _sort[i] + "=" + _custom[_sort[i]] );
			}
			
			return _arr.join("&");
		},
		
		sign : function(){
			this.custom();
				
			var _SHA1 = new syQuery.SHA1(), 
				_query = this.query(),
				_sign = _SHA1.b64_hmac_sha1(
					TXAPP.oauth_consumer_secret + "&", 
					"GET&" + encodeURIComponent(custom.request_token_url) + "&" + encodeURIComponent(_query)
				);
				
			this.queryURL = custom.request_token_url + "?" + _query + "&oauth_signature=" + encodeURIComponent(_sign); // 保存验证地址
			
			return _sign;
		},
		
		getSecret : function(url){
			var complete = false, _this = this;
			
			$.ajax({
				url : url,
				type : "GET",
				onSuccess : function(data){
					var arr = data.split("&");
					if ( arr.length == 2 ){
						complete = true;
						_this.oauth_token_secret = arr[1].split("=")[1];
						_this.oauth_token = arr[0].split("=")[1];
					}else{
						_this.error = data.split("=")[1];
					}
				}
			});
			
			if ( complete == true ){
				$.session(cacheMark + "oauth_token_secret", _this.oauth_token_secret);
				$.session(cacheMark + "oauth_token", _this.oauth_token);
			}
			
			return complete;
		},
		
		redirect : function(url){
			Response.Redirect(custom.authorize_url + "?oauth_consumer_key=" + TXAPP.oauth_consumer_key + "&oauth_token=" + this.oauth_token + "&oauth_callback=" + encodeURIComponent(url));
		},
		
		getOpenID : function(){
			this.custom({ oauth_token : $.query("oauth_token"), oauth_vericode : $.query("oauth_vericode") });
			var _query = this.query("oauth_token", "oauth_vericode"),
				_SHA1 = new syQuery.SHA1(),
				_sign = _SHA1.b64_hmac_sha1(
					TXAPP.oauth_consumer_secret + "&" + $.session(cacheMark + "oauth_token_secret"), 
					"GET&" + encodeURIComponent(custom.access_token_url) + "&" + encodeURIComponent(_query)
				),
				complete = false;
				
			this.queryURL = custom.access_token_url + "?" + _query + "&oauth_signature=" + encodeURIComponent(_sign);

			$.ajax({
				url : this.queryURL,
				type : "GET",
				onSuccess : function(data){
					var _arr = data.split("&");
					if ( _arr.length == 5 )
					{
						complete = true;
						$.session(cacheMark + "oauth_token", _arr[1].split("=")[1]);
						$.session(cacheMark + "oauth_token_secret", _arr[2].split("=")[1]);
						$.session(cacheMark + "openid", _arr[3].split("=")[1]);
					}
				}
			});
			
			return complete;
		},
		
		getUserInfoMation : function(){
			this.custom({ format : "json", openid : $.session(cacheMark + "openid"), oauth_token : $.session(cacheMark + "oauth_token") });
			var _query = this.query("format","openid","oauth_token"),
				_SHA1 = new syQuery.SHA1(),
				_sign = _SHA1.b64_hmac_sha1(
					TXAPP.oauth_consumer_secret + "&" + $.session(cacheMark + "oauth_token_secret"), 
					"GET&" + encodeURIComponent(custom.user_info_url) + "&" + encodeURIComponent(_query)
				),
				_returnBack;
				
			this.queryURL = custom.user_info_url + "?" + _query + "&oauth_signature=" + encodeURIComponent(_sign);
			
			$.ajax({
				url : this.queryURL,
				type : "GET",
				dataType : "json",
				onSuccess : function(data){
					if ( data.ret == 0 ){
						var nickname = data.nickname;
						var figureurl = data.figureurl;
						var figureurl_1 = data.figureurl_1;
						var figureurl_2 = data.figureurl_2;
						_returnBack = { 
							success : true, 
							nickname : data.nickname, 
							figureurl : data.figureurl, 
							figureurl_1 : data.figureurl_1, 
							figureurl_2 : data.figureurl_2, 
							oauth_token_secret : $.session(cacheMark + "oauth_token_secret"), 
							oauth_token : $.session(cacheMark + "oauth_token"), 
							openid : $.session(cacheMark + "openid") 
						}
					}else{
						_returnBack = { success : false, message : "获取信息失败" }
					}
				}
			});
			
			return _returnBack;
		}
		
	} );
	
});
%>