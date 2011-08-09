<%
;syQuery.add("memSystem", function(M){
	
	function randstr(l){
		var x = "0123456789qwertyuioplkjhgfdsazxcvbnm", 
			tmp = "";
		for( var i = 0 ; i < l ; i++ ) 
		{ 
			tmp += x.charAt(Math.ceil(Math.random() * 100000000) % x.length); 
		}
		return tmp;
	}
	
	syQuery.augment( M, {
		register : function(options, conn){
			options = $.extend({
				regtype : "normal", // normal | qq
				username : "",
				password : "",
				mail : "",
				website : "",
				openid : "",
				token : "",
				secret : "",
				figureurl : "",
				figureurl_1 : "",
				figureurl_2 : ""
			}, options || {});
			
			var returnback = { success : false, message : "正在初始化" }, 
				p = [],
				_hashkey = randstr(40),
				_now = $.now(),
				_ip = $.getIP(),
				_id;
			
			if ( options.regtype == "normal" ){
				var _SHA1 = new syQuery.SHA1()
					_rand = randstr(6);
				p.push(
					{ key : "nickname", text : options.username },
					{ key : "salt", text : _rand },
					{ key : "hashkey", text : _hashkey },
					{ key : "password", text : _SHA1.b64_sha1(options.password + _rand) },
					{ key : "mail", text : options.mail },
					{ key : "website", text : options.website },
					{ key : "regtime", text : _now },
					{ key : "regip", text : _ip },
					{ key : "logintime", text : _now },
					{ key : "loginip", text : _ip },
					{ key : "regtype", text : "normal" }
				);
			}else if ( options.regtype == "qq" ){
				p.push(
					{ key : "nickname", text : options.username },
					{ key : "hashkey", text : _hashkey },
					{ key : "openid", text : options.openid },
					{ key : "figureurl", text : options.figureurl },
					{ key : "figureurl_1", text : options.figureurl_1 },
					{ key : "figureurl_2", text : options.figureurl_2 },
					{ key : "oauth_token_secret", text : options.secret },
					{ key : "oauth_token", text : options.token },
					{ key : "regtime", text : _now },
					{ key : "regip", text : _ip },
					{ key : "logintime", text : _now },
					{ key : "loginip", text : _ip },
					{ key : "regtype", text : "qq" }
				);
			}else{
				returnback.message = "未知注册类型";
				return;
			}
			try{
				$(p).insert(conn, "[member]", "id", function(){
					_id = this("id").value;
				});
			}catch(e){ returnback.message = e.message; }
			
			if ( _id > 0 ){
				returnback.success = true;
				returnback.message = "注册成功";
			}
			
			if ( options.regtype == "qq" ){
				$.cookie(cacheMark + "user.id", _id, 1);
				$.cookie(cacheMark + "user.nickname", options.username, 1);
				$.cookie(cacheMark + "user.figureurl", options.figureurl, 1);
				$.cookie(cacheMark + "user.figureurl_1", options.figureurl_1, 1);
				$.cookie(cacheMark + "user.figureurl_2", options.figureurl_2, 1);
				$.cookie(cacheMark + "user.hashkey", _hashkey, 1);
			}
			
			return returnback;
			
		}
	} );
});
%>