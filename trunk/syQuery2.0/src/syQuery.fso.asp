<%
/**
 * Project Name : "Scripting.FileSystemObject" ActivexObject
 * Project Author : evio
 * CreateTime : 2011-04-19
 * Project Version : 2.0
 */
;(function(){
	
	$.extend({
		// 创建基本辅助方法
		formatpath : function(p){
			return p.replace(/\/$/, "");
		},
		
		// @ Determine file type 缩写 - 判断文件默认类型
		DFT : function( t ){
			if ( t == undefined ) t = "f";
			if ( t != "f" && t != "o" ) t = "f";
			return t;
		},
		
		// 创建新的FSO对象
		fso : function(){
			return $.active($.config.ActivexObject.fso);
		},
		
		create : function(f, o){
			f = $.formatpath(f).split("/");
			var temp = "", newpath = "";
			for ( var i = 0 ; i < f.length ; i++ ){
				temp += f[i] + "/";
				newpath = $.formatpath(temp);
				try{
					o.CreateFolder(Server.MapPath(newpath));
				}catch(e){}
			}
		},
		
		name : function(source, target, o, t){
			t = $.DFT( t ); source = $.formatpath(source);
			var _object, rec = source;
			try{
				if ( t == "o" ){
					_object = o.GetFolder(Server.MapPath(source));
				}else{
					_object = obj.GetFile(Server.MapPath(source));
				}
				if ( _object ){
					_object.Name = target;
				}
				rec = rec.split("/").slice(0, -1).join("/") + "/" + target;
			}catch(e){
				$.setError(e.message);
			}
			return rec;
		}
		
	});
	
	$.fn.extend({
		
		exsit : function( t ){
			t = $.DFT( t );
			return t == "o" ? 
				this.object.FolderExists(Server.MapPath(this.get(0))) 
			: 
				this.object.FileExists(Server.MapPath(this.get(0)));
		},
		
		create : function(){
			return this.map(function(i, k){
				if ( $.create(k, this.object) == true ){
					return this;
				}else{
					return null;
				}
			});
		},
		
		collect : function(t, callback){
			t = $.DFT(t);
			return this.map(function(i, k){
				k = $.formatpath(k);
				var fileObject = this.object.GetFolder(Server.MapPath(k)), data, fo;
				
				if ( t == "o" ){ fo = fileObject.SubFolders; }else{ fo = fileObject.Files; }
				
				if ( $.isFunction(callback) ){
					data = $.Enumerator(fo, [], function(){
						return callback.call(this, k);
					});
				}else if ( callback == true )
				{
					data = $.Enumerator(fo, [], function(){
						return k + "/" + this.Name;
					});
				}else{
					data = $.Enumerator(fo, [], function(){
						return this.Name;
					});
				}
				return data;
			});
		},
		
		_delete : function(t){
			t = $.DFT(t);
			return this.map(function(i, k){
				k = $.formatpath(k);
				var rec = k;
				try{
					if ( t == "o" ){
						this.object.DeleteFolder(Server.MapPath(k));
					}else{
						this.object.DeleteFile(Server.MapPath(k));
					}
					rec = null;
				}catch(e){ $.setError(e.message); }
				return rec;
			});
		},
		_deletes : function(t){
			return this.collect(t, true)._delete(t);
		},
		
		
		move : function(target, t){
			t = $.DFT(t); target = $.formatpath(target);
			return this.map(function(i, k){
				k = $.formatpath(k);
				var rec = null;
				try{
					var fileName = k.split("/").slice(-1).join(""), _target = target + "/" + fileName;
					if ( t == "o" ){
						this.object.MoveFolder(Server.MapPath(k), Server.MapPath(_target));
					}else{
						this.object.MoveFile(Server.MapPath(k), Server.MapPath(_target));
					}
					rec = _target;
				}catch(e){ $.setError(e.message); }
				return rec;
			});
		},
		moves : function(target, t){
			return this.collect(t, true).move(target, t);
		},
		
		
		copy : function(target, t){
			t = $.DFT(t); target = $.formatpath(target);
			return this.map(function(i, k){
				k = $.formatpath(k);
				var rec = null;
				try{
					var fileName = k.split("/").slice(-1), _target = target + "/" + fileName;
					if ( t == "o" ){
						this.object.CopyFolder(Server.MapPath(k), Server.MapPath(_target));
					}else{
						this.object.CopyFile(Server.MapPath(k), Server.MapPath(_target));
					}
					rec = _target;
				}catch(e){ $.setError(e.message); }
				return rec;
			});
		},
		copys : function(target, t){
			return this.collect(t, true).copy(target, t);
		},
		
		
		name : function(target, t){
			return this.map(function(i, k){
				return $.name(k, target, this.object, t);
			});
		},
		
		filecreate : function(){
			this.map(function(i, k){
				k = k.split("/").slice(0, -1).join("/");
				return k;
			}).create();
			return this;
		}
	});
	
})();
%>