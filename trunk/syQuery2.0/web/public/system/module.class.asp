<%
;syQuery.add("module", function( M ){
	
	// 为模块添加方法
	syQuery.augment(M, {
		
		root : "", // 指定目录
		
		// 打开模块安装包信息 所在目录 "private/plugin/" + fo
		open : function(fo)
		{
			
			// 确认地址
			var modulePath = this.root + "private/plugin/" + fo, 
				xmlConfigFile = modulePath + "/install.xml", 
				xmlConfig,
				XO,
				AO;

			var xmlSetting = {
				name : "",
				msg : "",
				mark : "",
				fo : fo,
				start : "",
				istitle : "",
				root : "",
				author : "",
				url : "",
				go : ""
			}
			
			// 配置文件是否存在	
			if ( $(xmlConfigFile, $.fso()).exsit() ){
				xmlConfig = $.xml(xmlConfigFile);
				// 获取2个对象
				XO = xmlConfig[0]; AO = xmlConfig[1];
				// 判断是否打开成功
				if ( XO != null ){
					
					xmlSetting.name = $(XO, AO).find("name").text() || "";
					xmlSetting.msg = $(XO, AO).find("message").html() || "";
					xmlSetting.mark = $(XO, AO).find("mark").text() || "";
					xmlSetting.istitle = ($(XO, AO).find("istitle").text() == "true" ? true : false) || false;
					xmlSetting.start = $(XO, AO).find("start").text() || "";
					xmlSetting.root = $(XO, AO).find("root").text() || "";
					xmlSetting.author = $(XO, AO).find("author").text() || "";
					xmlSetting.url = $(XO, AO).find("url").text() || "";
					xmlSetting.go = $(XO, AO).find("go").text() || "";
					xmlSetting.success = true;
					
					//this.xmlRoot = XO;
					//this.xmlObject = AO;
					
					XO = null; AO = null; // 关闭对象
					
					return xmlSetting;
				}else{
					return { success : false, message : "打开配置文件出错" }
				}
			}else{
				return { success : false, message : "配置文件不存在或已被安装" }
			}
		},
		
		// 插入到数据库
		inData : function( jsonObject, connObject, fn )
		{
			$([
				{ key : "mo_name", 		text : jsonObject.name },
				{ key : "mo_msg", 		text : jsonObject.msg },
				{ key : "mo_mark", 		text : jsonObject.mark },
				{ key : "mo_fo", 		text : jsonObject.fo },
				{ key : "mo_start", 	text : jsonObject.start },
				{ key : "mo_istitle", 	text : jsonObject.istitle },
				{ key : "mo_root", 		text : jsonObject.root },
				{ key : "mo_author", 	text : jsonObject.author },
				{ key : "mo_url", 		text : jsonObject.url },
				{ key : "mo_setuptime", text : $.now() },
				{ key : "mo_active", 	text : false }
			]).insert(connObject, "[module]", "id");
			if ( fn != undefined ) fn();
		},
		
		// 移动文件夹
		move : function( fo ){
			var modulePath = this.root + "private/plugin/" + fo,
				installPath = this.root + "public/module";
				
			$(modulePath, $.fso()).move(installPath, "o");
		}
		
	});
});
%>