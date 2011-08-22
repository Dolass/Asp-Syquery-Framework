<%
$.add("stream", function(){
	var stream = function(moden){
		if ( moden == undefined ) moden = 3;
		
		/**
		 * @ STM 对象
		 */
		this.object = new ActiveXObject($.config.ActivexObject.stream);
		
		/**
		 * @ STM模型加载器
		 * @ param binary <string> 文件读取模式  1,二进制 : 2,文本
		 * @ param callback <function> 回调函数
		 * @ return value
		 */
		this.loader = function( binary, callback ){
			
			if ( binary !== 1 ) binary = 2;
			var object = this.object, nice;
			
			object.Type = binary; 
			object.Mode = moden; 
			object.Open();
			
			try{ 
				nice = callback(object);
			}catch(e){
				$.error.push("ACTX STM Error : [" + e.message + "]");
			}
			
			object.Close;
			return nice;
		}
	}
	
	$.augment(stream, {
		/**
		 * @ 读取文件内容
		 * @ param path <string> 路径地址
		 * @ param i <string> 文件读取模式  1,二进制 : 2,文本
		 * @ param callback <function> 回调函数
		 * @ return value
		 */
		load : function(path, i, callback){
			return this.loader(i, function(object){
				if ( i === 2 ) object.Charset = $.charset;
				
				var nice;
				
				object.Position = i === 2 ? object.Size : 0;
				object.LoadFromFile(Server.MapPath(path));
				nice = i === 2 ? object.ReadText : object.Read();

				return $.isFunction(callback) ? callback(nice) : nice;
				
			});
		},
		
		/**
		 * @ 保存文件
		 * @ param path <string> 路径地址
		 * @ param Text <string> 文件内容
		 * @ param i <string> 文件读取模式  1,二进制 : 2,文本
		 * @ param callback <function> 回调函数
		 * @ return value
		 */
		save : function(Text, Path, i, callback){
			return this.loader(i, function(object){
				if ( i === 2 ){ object.Charset = $.charset; }

				if ( i === 2 ){
					object.Position = object.Size; 
					object.WriteText = Text;  
				}else{ 
					object.Position = 0; 
					object.write(Text);
				}
				
				object.SaveToFile(Server.MapPath(Path), 2);
				
				return $.isFunction(callback) ? callback() : true;
			});
		},
		
		/**
		 * @ 二进制转文本
		 * @ param Text <string> 文件内容
		 * @ param callback <function> 回调函数
		 * @ return value
		 */
		bin : function(Text, callback){
			return this.loader(1, function(object){
				object.Write(Text);
				object.Position = 0;
				object.Type = 2;
				object.Charset = $.charset;;
				return callback ? callback.call(object, object.ReadText) : object.ReadText;
			});
		}
	});
	
	$.fn.extend({
		load : function(binary){
			var STM = new stream();
			return this.map(function(i, ConVent){
				return STM.load(ConVent, binary);
			});
		},
		save : function(Path, binary){
			var STM = new stream();
			return this.map(function(i, ConVent){
				return STM.save(ConVent, Path, binary);
			});
		},
		bin : function(){
			var STM = new stream();
			return this.map(function(i, ConVent){
				return STM.bin(ConVent);
			});
		}
	});
	
	return stream;
	
});
%>