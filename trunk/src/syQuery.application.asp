<%
;(function(){
	
	/**
	 * 需要global.asa支持，设置静态APP对象名
	 * <object id="syQuery" runat="server" scope="Application" progid="Scripting.Dictionary"></object>
	 * 来支持Application
	 */
	$.config.app = "syQuery";
	
	// 增加对象方法
	$.extend({
		
		setApp : function(json){
			Application.Lock();
			$.jsonEach(json, function(i, j){
				Application.StaticObjects($.config.app).Item(i) = j; 
			});
			Application.UnLock();
		}
		
		app : function( key, value ){
			var temp = {}
			
			if ( value != undefined ){
				temp[key] = value;
				$.setApp(temp);
			}else{
				if ( $.isJson(key) ){
					$.setApp(key);
				}else if ( $.isString(key) ){
					return Application.StaticObjects($.config.app).Item(key);
				}
			}
		}
	});
	
})();
%>