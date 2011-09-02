<%
$.add("package", function(){
	var _package = function(){
		try{ 
			this.baseObject = new ActiveXObject("Microsoft.XMLDOM"); 
		}catch(e){ 
			this.baseObject = new ActiveXObject("Msxml2.DOMDocument.5.0"); 
		}
	}
	
	$.augment(_package, {
		/**
		 * 文件打包方法
		 * @ param which <string> 目标文件夹
		 * @ param toWhere <string> 释放的文件名和路径
		 * @ param options <undefined | jsohn> 配置数据
		 * return null
		 */
		pack : function( which, toWhere, options ){
			options = $.extend({
				onError : null,
				replaceFolderPath : null,
				packedFolder : null,
				replaceFilePath : null,
				packedFile : null
			}, options);
			
			var ALLFOS = getAllByFolder( which );
				ALLFOS.push(which);
			var ALLFIS = getAllByFile(ALLFOS),
				ALLNUM = ALLFOS.length + ALLFIS.length,
				_this = this;
				
			var packageXml = '<?xml version="1.0"?><package xmlns:dt="urn:schemas-microsoft-com:datatypes"><count><foldercount></foldercount><filecount></filecount></count><content><folders></folders><files></files></content></package>',
				xml = $.use("xml"),
				root = xml.load(packageXml);
				
			// 确定是否打开XML成功
			if ( root !== false ){
				
				// 写入总文件和文件夹数
				xml(root).getElementsByTagName("count").attr("total", ALLNUM + "");
				xml(root).getElementsByTagName("foldercount").text( ALLFOS.length + "" );
				xml(root).getElementsByTagName("filecount").text( ALLFIS.length + "" );

				// 循环写入文件夹数据的 base64 编码数据
				ALLFOS.each(function( i, k ){
					k = k.replace(/^(\.\.\/)+/, "");
					if ( $.isFunction( options.replaceFolderPath ) ) k = options.replaceFolderPath(k);
					
					xml(root).getElementsByTagName("folders").append("item").html( k );
					
					if ( $.isFunction( options.packedFolder ) ) {
						// 后3参数用于计算压缩率
						// 分别是 当前个数  文件夹总个数  总文件和文件夹个数
						options.packedFolder(k, i + 1, ALLFOS.length, ALLNUM.length);
					}
				});
				
				// 循环写入文件数据的 base64 编码数据
				ALLFIS.each(function( i, k ){
					var binaryText = getFileBinary(k);
					
					k = k.replace(/^(\.\.\/)+/, "");
					if ( $.isFunction( options.replaceFilePath ) ) k = options.replaceFilePath(k);
					
					xml(root).getElementsByTagName("files").append("item").attr({
						path : k, // 插入路径
						filename : k.split("/").last().join("") // 插入文件名
					}).html( getFileBase.call(_this, binaryText) );
					
					if ( $.isFunction( options.packedFile ) ) {
						// 后3参数用于计算压缩率
						// 分别是 当前个数  文件夹总个数  总文件和文件夹个数
						options.packedFile(k, i + 1, ALLFIS.length, ALLNUM.length);
					}
				});
				
				// 保存文件
				xml(root).saveXML(toWhere);
				
			}else{
				if ( $.isFunction( options.onError ) ) options.onError.call(undefined, { message : "打开XML数据流失败" });
			}
		},
		
		/**
		 * 文件解包方法
		 * @ param which <string> 目标文件
		 * @ param toWhere <string> 释放的文件名和路径
		 * @ param options <undefined | jsohn> 配置数据
		 * return null
		 */
		unpack : function( which, toWhere, options ){
			options = $.extend({
				onError : null,
				replaceFolderPath : null,
				packedFolder : null,
				replaceFilePath : null,
				packedFile : null
			}, options);
			
			var ALLNUMBER = 0
				ALLFOSNUM = 0,
				ALLFISNUM = 0,
				_this = this,
				toWhere = toWhere.replace(/\/+$/, "");
				
			var xml = $.use("xml"),
				fso = $.use("fso"),
				STM = $.use("stream"),
				root = xml.load(which);
				
			if ( root !== false ){
				ALLNUMBER = Number(xml(root).getElementsByTagName("count").attr("total"));
				ALLFOSNUM = Number(xml(root).getElementsByTagName("foldercount").text());
				ALLFISNUM = Number(xml(root).getElementsByTagName("filecount").text());
				
				// 首先创建预先的文件夹
				xml(root).getElementsByTagName("folders").getElementsByTagName("item").each(function( i, element ){
					var Path = toWhere + "/" + xml(element).text();

					if ( $.isFunction(options.replaceFolderPath) ) Path = options.replaceFolderPath(Path);
					fso(Path).create();
					if ( $.isFunction(options.packedFolder) ) options.packedFolder(Path, i + 1, ALLFOSNUM, ALLNUMBER);
				});
				
				// 最后创建文件
				xml(root).getElementsByTagName("files").getElementsByTagName("item").each(function( i, element ){
					var Path = toWhere + "/" + xml(element).attr("path"),
						fileName = xml(element).attr("filename");
						
					if ( $.isFunction(options.replaceFilePath) ) Path = options.replaceFilePath(Path);	
					if ( fileName.toLowerCase() === "global.asa" ) Path = $.root + "global.asa";

					var _STM = new STM();
					_STM.save( toFileBase.call(_this, xml(element).text()), Path, 1 );
					_STM = null;
					
					if ( $.isFunction(options.packedFile) ) options.packedFile(Path, i + 1, ALLFISNUM, ALLNUMBER);
				});
			}else{
				if ( $.isFunction( options.onError ) ) options.onError.call(undefined, { message : "打开XML数据流失败" });
			}
		},
		
		// 文件加密
		fileEnCode : function( Path ){ return getFileBase(getFileBinary(Path)); },
		// 文件解密
		fileDeCode : function(Text){ return toFileBase(Text); }
	});
	
	/**
	 * 获取文件夹下所有子文件夹
	 * @ param which <string> 目标文件夹
	 * return <array>
	 */
	function getAllByFolder( which ){
		var FSO = $.use("fso"),
			fos = FSO(which).collect(true, true).toArray(),
			Arr = fos;
			
		return Arr.map(function( i, k ){ return getAllByFolder(k); }).concat(fos);
	}
	
	/**
	 * 获取文件夹下所有子文件
	 * @ param which <string> 目标文件夹
	 * return <array>
	 */
	function getAllByFile( Arr ){
		var FSO = $.use("fso");
		
		return Arr.map(function( i, k ){ return FSO(k).collect(false, true).toArray(); });
	}
	
	function getFileBinary( Path ){
		var STM = $.use("stream"),
			_STM = new STM();
		
		return _STM.load( Path, 1 );
	}
	
	function getFileBase( Text ){
		var temp = this.baseObject.createElement("file");
		
		temp.dataType = "bin.base64";
		temp.nodeTypedValue = Text;
		
		return temp.text;
	}
	
	function toFileBase( Text ){
		var temp = this.baseObject.createElement("file");
		
		temp.dataType = "bin.base64";
		temp.text = Text;
		
		return temp.nodeTypedValue;
	}
	
	return _package;
}, { reqiure : ["stream", "fso", "xml"] });
%>