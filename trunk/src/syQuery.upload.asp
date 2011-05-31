<%
;(function(){

	$.extend({
	
		uploadSetting : {
			speed : 1000,
			object : null,
			splitLine : "",
			finline : "",
			area : {},
			filenameExpr : /filename=\"([^\"]+)\"/i,
			nameExpr : /name=\"([^\"]+)\"/i,
			contentTypeExpr : /Content-Type: ([^\n\r]+)/i
		},
		
		uploadConfig : {
		
			// 普通获取二进制数据方法
			readBinary : function(object){
				var totalSize = Request.TotalBytes, speed = $.uploadSetting.speed, hasRead = 0, tempRead = 0, binaryData;
				if ( totalSize < speed ) speed = totalSize;
				
				object.Open();
				object.Type = 1;
				
				while ( hasRead < totalSize )
				{
				
					if ( hasRead + speed < totalSize ){ tempRead = speed; }
					else{ tempRead = totalSize - hasRead; }
					
					hasRead += tempRead;
					object.Write(Request.BinaryRead(tempRead));
					
				}
				
				object.Position = 0;
				binaryData = object.Read();
				object.Close();
				return binaryData;
			},
			
			// HTML5获取文件数据方法
			html5 : function( text, options ){
				text = text[0];
				var _fileArea = $.uploadSetting.nameExpr.exec(text), 
					_fileName = $.uploadSetting.filenameExpr.exec(text), 
					_contentType = $.uploadSetting.contentTypeExpr.exec(text);
				binaryData = $.uploadConfig.readBinary(object);
				
				if ( _fileArea ){
				
					$.uploadSetting.area[ _fileArea[1] ] = {}
					
					if ( _fileName ){
						$.uploadSetting.area[ _fileArea[1] ].filename = _fileName[1];
						$.uploadSetting.area[ _fileArea[1] ].size = Request.TotalBytes;
						$.uploadSetting.area[ _fileArea[1] ].ext = _fileName[1].split(".").slice(-1).join("");
						$.uploadSetting.area[ _fileArea[1] ].contentType = _contentType[1];
						$.uploadSetting.area[ _fileArea[1] ].fileSavePath = $.uploadConfig.writePath(options, $.uploadSetting.area[ _fileArea[1] ]);
						$(binaryData, $.stream()).save($.uploadSetting.area[ _fileArea[1] ].fileSavePath, 1);
					}else{
						if ( $.isFunction(options.onError) )
						{
							options.onError.call({message : "找不到文件名，文件已损坏或废弃。"});
						}
					}
					
				}else{
					if ( $.isFunction(options.onError) )
					{
						options.onError.call({message : "不支持HTML5控件"});
					}
				}
				
			},
			
			writePath : function(o, k){
				// old , time , []
				
				var path = o.savePath.replace(/\/$/, "");
				
				if ( $.isArray(o.saveType) ){
					return path + "/" + o.saveType.join(".");
				}else{
					if ( o.saveType == "old" ){
						return path + "/" + k.filename;
					}else if ( o.saveType == "time" ){
						return path + "/" + $.now("z") + "." + k.ext;
					}
				}
				return path + "/" + $.now("z") + "." + k.ext;
			},
			
			fileExtMatch : function(ext, extArray){
				var checked = false;
				for ( var i = 0 ; i < extArray.length ; i++ )
				{
					if ( extArray[i] === ext ){
						checked = true;
						break;
					}
				}
				return checked;
			}
		},
		
		upload : function(options){
			
			// 继承数据
			options = $.extend({
			
				/** 配置选择项
				 * beforeUpload : function,
				 * saveType : "time",
				 * savePath : "upload",
				 * onSuccess : function,
				 * onError : function
				 */
				 
				saveType : "time",
				savePath : "upload",
				extArray : ["jpg", "png", "gif", "bmp", "rar", "zip"]
			}, options || {});
			
			// 执行上传前函数
			if ( $.isFunction(options.beforeUpload) ) {
				if ( options.beforeUpload() == false ) return ;
			}
			
			// 判断是否可以使用HTML5模式上传
			var html5Data = $.Enumerator(Request.ServerVariables("HTTP_CONTENT_DISPOSITION")), binaryData, initData;

			if ( html5Data.length > 0 ){
				binaryData = $.uploadConfig.html5( html5Data, options );
			}else{
			
				var object = $.uploadSetting.object = $.stream(), partValue, STARTPOS, tempPos, keepInArray = [];
				binaryData = $.uploadConfig.readBinary(object);
				
				// 处理中文
				object.Type = 2;
				object.Open();
				object.WriteText(binaryData);
				object.Position = 0;
				object.Charset = "ascii";
				object.Position = 2;
				initData = object.ReadText; 
				
				//$.echo(initData)
				
				// 获取分割线
				$.uploadSetting.splitLine = initData.split("\n")[0]; 
				$.uploadSetting.splitLineLength = $.uploadSetting.splitLine.length;
				
				$.uploadSetting.finline = $.uploadSetting.splitLine.substring(0, $.uploadSetting.splitLine.length - 1); 
				$.uploadSetting.finlineLength = $.uploadSetting.finline.length;
				
				// 开始循环取数据 (关键)
				partValue = initData; // 缓存数据， 初始化为整个数据。
				STARTPOS = 0; // 表示循环每次开始的位置。
				
				var t_start, t_end, t_data;
				
				// 冒泡筛选数据
				while ( (tempPos = partValue.indexOf($.uploadSetting.splitLine)) != -1 )
				{
					t_start = STARTPOS;
					t_end = t_start + tempPos;
					t_data = partValue.substring(0, tempPos);

					partValue = partValue.substring(tempPos + $.uploadSetting.splitLineLength);
					STARTPOS = t_end + $.uploadSetting.splitLineLength;
					
					keepInArray.push({
						data : t_data,
						start : t_start,
						end : t_end
					});
				}
				
				if ( (tempPos = partValue.indexOf($.uploadSetting.finline)) != -1 )
				{
					t_start = STARTPOS;
					t_end = t_start + tempPos;
					t_data = partValue.substring(0, tempPos);
					
					keepInArray.push({
						data : t_data,
						start : t_start,
						end : t_end
					});
				}
				
				// 处理主体
				$(keepInArray).map(function( i, k )
				{
					if ( /^\n+/.test(k.data) )
					{
						k.start += /^\n+/.exec(k.data)[0].length;
						k.data = k.data.replace(/^\n+/, "");
					}
					
					var newDataSplit = k.data.split("\n\r");
					
					// 确定开始位置
					k.start += ( k.data.indexOf(newDataSplit[1]) + 1 );
					
					// 获取头部信息
					k.data = newDataSplit[0];
					
					k.textValue = newDataSplit.slice(1, -1).join("");
					
					return k;
					
				}).each(function(i, k)
				{
					if ( $.uploadSetting.nameExpr.test( k.data ) )
					{
						var _expr = $.uploadSetting.nameExpr.exec( k.data ), areaName = _expr[1];
						$.uploadSetting.area[ areaName ] = {}
						
						if ( $.uploadSetting.filenameExpr.test( k.data ) )
						{
							_expr = $.uploadSetting.filenameExpr.exec( k.data );
							$.uploadSetting.area[ areaName ].filename = _expr[1];
							
							_expr = $.uploadSetting.contentTypeExpr.exec( k.data );
							$.uploadSetting.area[ areaName ].contentType = _expr[1];
							
							$.uploadSetting.area[ areaName ].ext = $.uploadSetting.area[ areaName ].filename.split(".").slice(-1).join("");
							$.uploadSetting.area[ areaName ].size = k.end - k.start;
						}
						
						$.uploadSetting.area[ areaName ].STARTPOS = k.start;
						$.uploadSetting.area[ areaName ].ENDPOS = k.end;
						
					}
				});
				
				$.jsonEach($.uploadSetting.area, function(i, k){
					if ( k.filename != undefined && k.filename.length > 0 )
					{
						if ( $.uploadConfig.fileExtMatch(k.ext, options.extArray) == false ){
							if ( $.isFunction(options.onError) )
							{
								options.onError.call({ message : "上传格式不匹配" });
							}
						}else{
							try{
								var _stream = $.stream();
								_stream.Type = 1;
								_stream.Mode = 3;
								_stream.Open();
								
								//加载起始位置
								object.Position = k.STARTPOS + 2 ; // +2 是因为开始位置已经偏移了2位。
								
								// 加载内容长度
								object.CopyTo( _stream, k.size );
								
								k.fileSavePath = $.uploadConfig.writePath(options, k); // 文件最终保存位置

								_stream.SaveToFile(Server.MapPath(k.fileSavePath), 2);
								_stream.Close();
								_stream = null;
								
								if ( $.isFunction(options.onSuccess) )
								{
									options.onSuccess.call(k);
								}
								
							}catch(e){
								if ( $.isFunction(options.onError) )
								{
									options.onError.call(e);
								}
							}
						}
					}else{
						$.uploadSetting.area[ i ].value = initData.substring(k.STARTPOS, k.ENDPOS - 2);
					}
				});
					
			}
			
			return $.uploadSetting.area;
		}
	})
})();
%>