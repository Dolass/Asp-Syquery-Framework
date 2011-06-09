<%
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
	},
	access_token = "";
	
	syQuery.augment( O, {
		
		queryURL : "",
		oauth_token_secret : "",
		oauth_token : "",
		error : "",
		
		custom : function(){
			return {
				oauth_consumer_key : TXAPP.oauth_consumer_key,
				oauth_nonce : (new Date).getTime().toString().substr(0, 8),
				oauth_timestamp : (new Date).getTime().toString().substr(0, 10),
				oauth_version : "1.0",
				oauth_signature_method : custom.oauth_signature_method
			}
		},
		
		query : function(){
			var _sort = Array.prototype.sort.call(["oauth_consumer_key", "oauth_nonce", "oauth_timestamp", "oauth_version", "oauth_signature_method"]),
				_custom = this.custom(),
				_arr = [];
			
			for ( var i = 0 ; i < _sort.length ; i++ )
			{
				_arr.push( _sort[i] + "=" + _custom[_sort[i]] );
			}
			
			return _arr.join("&");
		},
		
		sign : function(){	
			var _SHA1 = new syQuery.SHA1(), 
				_query = this.query(),
				_sign = _SHA1.b64_hmac_sha1(
					TXAPP.oauth_consumer_secret + "&" + access_token, 
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
				async : false,
				dataType : "text",
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
		
		redirect : function(){
			Response.Redirect(custom.authorize_url + '?oauth_consumer_key=' + TXAPP.oauth_consumer_key + '&oauth_token=' + this.oauth_token + '&oauth_callback=http%3A%2F%2Fwww.54bq.com%2Fboke%2Fcallback.asp');
		}
		
	} );
	
});
%>