<!--#include file="config.asp" -->
<!--#include file="public/lib/syQuery.sha1.asp" -->
<!--#include file="public/system/oAuth.class.asp" -->
<%
var oAuth = new syQuery.oAuth(),
	oAuth_sign = oAuth.sign(),
	oAuth_url = oAuth.queryURL;
	if ( oAuth.getSecret(oAuth_url) ){
		oAuth.redirect("http://www.54bq.com/callback.asp");
	}
%>