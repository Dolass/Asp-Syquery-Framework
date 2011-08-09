<!--#include file="config.asp" -->
<!--#include file="public/lib/syQuery.sha1.asp" -->
<!--#include file="public/system/oAuth.class.asp" -->
<!--#include file="public/system/memSystem.class.asp" -->
<%
Response.Charset = "utf-8";
var oAuth  = new syQuery.oAuth();

API.run(function(){
	if ( oAuth.getOpenID() ){
		var oAuthCallback = oAuth.getUserInfoMation();
		if ( oAuthCallback.success ){
			var mem = new syQuery.memSystem(),
				connObject = API.use("db_open"),
				conn = null;
				
			if ( connObject.success ){
				conn = connObject.object;
				
				if ( conn.Execute("Select count(*) From [member] Where openid='" + oAuthCallback.openid + "'")(0) > 0 ){
					// 登入
				}else{
					var regBack = mem.register({
						regtype : "qq",
						username : oAuthCallback.nickname,
						openid : oAuthCallback.openid,
						token : oAuthCallback.oauth_token,
						secret : oAuthCallback.oauth_token_secret,
						figureurl : oAuthCallback.figureurl,
						figureurl_1 : oAuthCallback.figureurl_1,
						figureurl_2 : oAuthCallback.figureurl_2
					}, conn);
					
					$.echo(regBack.message);
				}
				
			}else{
				$.echo("登入失败")
			}
		}else{
			$.echo(oAuthCallback.message);
		}
	}else{
		$.echo("授权失败");
	}
});
%>