<%
$.add("fso", function(){
	// 创建fso批量对象
	var F = $("fso", new ActiveXObject($.config.ActivexObject.fso));
	
	// 扩展框架实例
	$.fn.extend({
		// 判断文件或者文件夹是否存在
		// chfile 是否为文件
		exsit : function( chkf ){
			return chkf ? this.object.FolderExists(Server.MapPath(this.get(0))) : 
						  this.object.FileExists(Server.MapPath(this.get(0)));
		},
		
		// 创建文件夹
		create : function(){
			this.each(function(i, k){
				k = pathlose(k);
				create(k, this.object);
			});
			
			return this;
		},
		
		// 搜索文件或文件夹
		collect : function( chkf, callback ){	
			return this.map(function(i, k){
				k = pathlose(k);
				var _object = this.object.GetFolder(Server.MapPath(k)),
					_fck = chkf ? _object.SubFolders : _object.Files,
					_data;
					
				if ( $.isFunction() ){
					data = $.Enumerator(_fck, [], function(n){
						return callback.call(this, n);
					});
				}
				else if ( callback === true ){
					data = $.Enumerator(_fck, [], function(n){
						return k + "/" + n.Name;
					});
				}
				else{
					data = $.Enumerator(_fck, [], function(n){
						return n.Name;
					});
				}
				
				return data;
			});
		},
		
		// 删除文件或文件夹
		destory : function( chkf ){
			this.each(function(i, k){
				k = pathlose(k);
				try{
					if ( chkf ){
						this.object.DeleteFolder(Server.MapPath(k));
					}else{
						this.object.DeleteFile(Server.MapPath(k));
					}
				}catch(e){}
			});
		},
		
		// 删除文件夹下的所有文件或者文件夹
		destorys : function( chkf ){
			this.collect( chkf, true ).destory(chkf);
		},
		
		// 移动文件或文件夹
		move : function( toWhere, chkf ){
			toWhere = pathlose(toWhere);
			return this.map(function(i, k){
				k = pathlose(k);
				
				var fileName = k.split("/").slice(-1), 
					_target = toWhere + "/" + fileName;
					
				if ( chkf ){
					this.object.MoveFolder(Server.MapPath(k), Server.MapPath(_target));
				}else{
					this.object.MoveFile(Server.MapPath(k), Server.MapPath(_target));
				}
				
				return _target || null;
			});
		},
		
		// 移动所有某文件夹下的文件或者文件夹到toWhere文件夹下去。
		moves : function( toWhere, chkf ){
			return this.collect(chkf, true).move(toWhere, chkf);
		},
		
		// 拷贝文件或文件夹
		copy : function( toWhere, chkf, retype ){
			toWhere = pathlose(toWhere);
			return this.map(function(i, k){
				k = pathlose(k);
				
				var fileName = k.split("/").slice(-1), 
					_target = toWhere + "/" + fileName;
					
				if ( chkf ){
					this.object.CopyFolder(Server.MapPath(k), Server.MapPath(_target));
				}else{
					this.object.CopyFile(Server.MapPath(k), Server.MapPath(_target));
				}
				
				return retype ? k : (_target || null);
			});
		},
		
		// 拷贝所有某文件夹下的文件或者文件夹到toWhere文件夹下去。
		copys : function( toWhere, chkf, retype ){
			return this.collect(chkf, true).copy(toWhere, chkf, retype);
		},
		
		// 重命名文件或者文件夹
		name : function( nameStr, chkf, retype ){
			return this.map(function(i, k){
				var _object; k = pathlose(k);
				
				if ( chkf ){
					_object = this.object.GetFolder(Server.MapPath(k));
				}else{
					_object = this.object.GetFile(Server.MapPath(k));
				}
				
				if ( _object ) _object.Name = nameStr;
				
				return retype ? k.split("/").slice(0, -1).join("/") + "/" + nameStr : nameStr;
			});
		}
	});
	
	function chkObject( object ){
		return object == undefined ? new ActiveXObject($.config.ActivexObject.fso) : object;
	}
	
	function pathlose( path ){
		return path.replace(/\/+$/, "");
	}
	
	function create(path, o){
		var pathArr = path.split("/"),
			temp = "", 
			newpath = "";
			
		for ( var i = 0 ; i < pathArr.length ; i++ )
		{
			temp += pathArr[i] + "/";
			newpath = pathlose(temp);
			try{
				o.CreateFolder(Server.MapPath(newpath));
			}catch(e){}
		}
	}
	
	return F;
});
%>