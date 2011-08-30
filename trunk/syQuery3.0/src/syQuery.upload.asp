<%
$.add("upload", function(){
	var upload = function(){
		/**
		 * 上传速度控制
		 */
		this.speed = 100;
		
		/**
		 * 分割字符串
		 */
		this.cutLine = "";
		this.cutLineLength = 0;
		this.lastLine = "";
		this.lastLineLength = 0;
		
		/**
		 * 保存文件模式
		 */
		this.saveType = "time";
		
		/**
		 * 文件保存地址
		 */
		this.uploadFile = "upload";
		
		/**
		 * 允许上传文件类型
		 */
		this.uploadType = ["jpg", "png", "gif", "bmp", "rar", "zip"];
		
		/**
		 * Stream操作对象
		 */
		this.object = new ActiveXObject($.config.ActivexObject.stream);
		
		/**
		 * 上传错误分析
		 */
		this.errorNumber = 0; // 发生错误个数
		this.errorArray = []; // 错误信息
		
	}
	
	// 需要用到的正则表达式
	var filenameExpr = /filename=\"([^\"]+)\"/i,
		nameExpr = /name=\"([^\"]+)\"/i,
		contentTypeExpr = /Content-Type: ([^\n\r]+)/i;
	
	// 扩展对象方法
	$.augment(upload, {
		/**
		 * 上传入口
		 * @ param options <json> 上传数据配置
		 * @ return <json>
		 */
		upload : function( options ){
			// 判断是否需要上传前条件约束
			if ( $.isFunction(this.beforeUpload) ){
				if ( this.beforeUpload() === false ) return;
			}
			
			// 配置数据初始化
			if ( options ){
				for ( var optionsItem in options )
				{
					this[optionsItem] = options[optionsItem];
				}
			}
			
			// 判断是否可以使用HTML5控件上传
			var html5Data = $.Enumerator(Request.ServerVariables("HTTP_CONTENT_DISPOSITION"));
			
			if ( html5Data.length > 0 ){
				return this.html5Upload(html5Data);
			}else{
				return this.commonUpload();
			}
		},
		
		/**
		 * 普通上传模式
		 * return <json>
		 */
		commonUpload : function(){
			var data = commonReadBinary.call(this),
				keepInArray = [],
				StartPos,  // 数据开始位置
				tempPos,   // 数据进度临时位置
				initData,  // 基本数据
				cacheData, // 缓存数据
				t_start,   // 每个数据在整个缓存数据中的开始位置
				t_end,	   // 每个数据在整个缓存数据中的结束位置
				t_data,    // 分块数据
				area = {};
			
			// 通过Stream方法获得可显示内容 initData
			this.object.Type = 2;
			this.object.Open();
			this.object.WriteText(data);
			this.object.Position = 0;
			this.object.Charset = "ascii";
			this.object.Position = 2;
			initData = this.object.ReadText;
			
			// 获取分割线相关数据
			this.cutLine = initData.split("\n")[0]; // 分割线字符串
			this.cutLineLength = this.cutLine.length; // 分割线长度
			this.lastLine = this.cutLine.substring(0, this.cutLineLength - 1);  // 数据结尾分割线
			this.lastLineLength = this.lastLine.length; // 数据结尾分割线长度
			
			// 开始循环处理数据 (关键)
			cacheData = initData; // 缓存数据
			StartPos = 0; // 表示循环每次开始的位置。
			
			// 处理中间所有数据
			while ( (tempPos = cacheData.indexOf(this.cutLine)) != -1 )
			{
				t_start = StartPos;
				t_end = t_start + tempPos;
				t_data = cacheData.substring(0, tempPos);

				cacheData = cacheData.substring(tempPos + this.cutLineLength);
				StartPos = t_end + this.cutLineLength;
				
				keepInArray.push({
					data : t_data,
					start : t_start,
					end : t_end
				});
			}
			
			// 处理最后一项数据
			if ( (tempPos = cacheData.indexOf(this.lastLine)) != -1 )
			{
				t_start = StartPos;
				t_end = t_start + tempPos;
				t_data = cacheData.substring(0, tempPos);
				
				keepInArray.push({
					data : t_data,
					start : t_start,
					end : t_end
				});
			}
			
			// 校正数据的起点和终点
			keepInArray.map(function(i, k){
				if ( /^\n+/.test(k.data) ){
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
			})
			// 临时保存所有数据
			.each(function(i, k){
				if ( nameExpr.test( k.data ) )
				{
					var _expr = nameExpr.exec( k.data ), 
						areaName = _expr[1];
						
					area[ areaName ] = {}
					
					if ( filenameExpr.test( k.data ) )
					{
						_expr = filenameExpr.exec( k.data );
						area[ areaName ].filename = _expr[1];
						
						_expr = contentTypeExpr.exec( k.data );
						area[ areaName ].contentType = _expr[1];
						
						area[ areaName ].ext = area[ areaName ].filename.split(".").slice(-1).join("");
						area[ areaName ].size = k.end - k.start;
					}
					
					area[ areaName ].STARTPOS = k.start;
					area[ areaName ].ENDPOS = k.end;	
				}
			});
			
			// 实时保存数据到文件
			for ( var areaItem in area )
			{
				var areaData = area[areaItem];
				if ( areaData.filename != undefined && areaData.filename.length > 0 ){
					if ( fileExtMatch(areaData.ext, this.uploadType) == false ){
						if ( $.isFunction(this.onError) )
						{
							this.onError({ message : "上传格式不匹配" });
						}
					}else{
						try{
							this.saveObject = new ActiveXObject($.config.ActivexObject.stream);
							this.saveObject.Type = 1;
							this.saveObject.Mode = 3;
							this.saveObject.Open();
							
							//加载起始位置
							this.object.Position = areaData.STARTPOS + 2 ; // +2 是因为开始位置已经偏移了2位。
							
							// 加载内容长度
							this.object.CopyTo( this.saveObject, areaData.size );
							
							areaData.fileSavePath = lastSavePath.call(this, areaData); // 文件最终保存位置

							this.saveObject.SaveToFile(Server.MapPath(areaData.fileSavePath), 2);
							this.saveObject.Close();
							this.saveObject = null;
							
							if ( $.isFunction(this.onSuccess) )
							{
								this.onSuccess.call(areaData);
							}
							
						}catch(e){
							if ( $.isFunction(this.onError) )
							{
								this.onError(e);
							}
						}
					}
				}else{
					area[ areaItem ].value = initData.substring(areaData.STARTPOS, areaData.ENDPOS - 2);
				}
			}
			
			return area;
		},
		
		/**
		 * HTML5控件上传
		 * return <json>
		 */
		html5Upload : function( HTML5DATA ){
			HTML5DATA = HTML5DATA[0];
			
			var _fileArea = nameExpr.exec(HTML5DATA), 
				_fileName = filenameExpr.exec(HTML5DATA), 
				_contentType = contentTypeExpr.exec(HTML5DATA),
				area = {},
				RequestData = commonReadBinary.call(this);
				
			if ( _fileArea ){
				
				area[ _fileArea[1] ] = {}
				
				if ( _fileName ){
					area[ _fileArea[1] ].filename = _fileName[1];
					area[ _fileArea[1] ].size = Request.TotalBytes;
					area[ _fileArea[1] ].ext = _fileName[1].split(".").slice(-1).join("");
					area[ _fileArea[1] ].contentType = _contentType[1];
					area[ _fileArea[1] ].fileSavePath = lastSavePath.call(this, area[ _fileArea[1] ]);
					
					// 保存
					(new $.use("stream")()).save(RequestData, area[ _fileArea[1] ].fileSavePath, 1);
				}else{
					if ( $.isFunction(this.onError) )
					{
						this.onError({message : "找不到文件名，文件已损坏或废弃。"});
					}
				}
				
			}else{
				if ( $.isFunction(this.onError) )
				{
					this.onError({message : "不支持HTML5控件"});
				}
			}
			
			return area;
		}
	});
	
	// 读取数据内容
	function commonReadBinary(){
		var totalSize = Request.TotalBytes,
			speed = this.speed,
			hasRead = 0, 
			tempRead = 0, 
			binaryData;

		if ( totalSize < speed ) speed = totalSize;
		
		this.object.Open();
		this.object.Type = 1;
		
		while ( hasRead < totalSize )
		{
			if ( hasRead + speed < totalSize ){ tempRead = speed; }
			else{ tempRead = totalSize - hasRead; }
			
			hasRead += tempRead;
			this.object.Write(Request.BinaryRead( tempRead ));	
		}
		
		this.object.Position = 0;
		binaryData = this.object.Read();
		this.object.Close();
		
		return binaryData;
	}
	
	// 判断文件格式是否合法
	function fileExtMatch(ext, extArray){
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
	
	// 最终返回的文件地址
	function lastSavePath( area ){
		var path = this.uploadFile.replace(/\/+$/, "");
		
		if ( $.isArray(this.saveType) ){
			return path + "/" + this.saveType.join(".");
		}else{
			if ( this.saveType == "old" ){
				return path + "/" + area.filename;
			}else if ( this.saveType == "time" ){
				return path + "/" + (new Date().getTime()) + "." + area.ext;
			}
		}
		return path + "/" + (new Date().getTime()) + "." + area.ext;
	}
	
	return upload;	
}, { reqiure : ["stream"] });
%>