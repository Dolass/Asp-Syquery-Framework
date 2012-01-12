<%
define("/server/public/data", function(require, exports, module){
	var database = function(serverNs, baseName, userName, userPass){
		this.serverNs = serverNs; // 数据库地址必须基于根目录
		this.baseName = baseName;
		this.userName = userName;
		this.userPass = userPass;
		this.conn = undefined;
		this.recordSet = undefined;
		this.moden = 1;
		this.accessDBStr = [
			function(_this){
				return "provider=Microsoft.jet.oledb.4.0;data source=" + Server.MapPath(data.root + _this.serverNs);
			},
			function(_this){
				return "driver={microsoft access driver (*.mdb)};dbq=" + Server.MapPath(data.root + _this.serverNs);
			}
		];
		this.core = {
			each : function(RS, callback){
				var i = 0;
				RS.MoveFirst();
				
				while ( !RS.Eof )
				{
					callback(RS, i);
					RS.MoveNext();
					i++;
				}
			},
			getRows : function(RS){
				var tempArr = [];
				
				try{ 
					tempArr = RS.GetRows().toArray(); 
				}catch(e){}
				
				return getRows( tempArr, RS.Fields.Count );	  
			},
			// 数据分页过程
			page : function(RS, absolutePage, pageSize, callback){
				var _Core = RS, i = 0;
				
				var RsCount = _Core.RecordCount;
				if ( pageSize > RsCount ) pageSize = RsCount;
				
				var PageCount = Math.ceil( RsCount / pageSize );
				if ( PageCount < 0 ) PageCount = 0;
				if ( absolutePage > PageCount ) absolutePage = PageCount;
				if ( absolutePage < 1 ) absolutePage = 1;
				
				_Core.PageSize = pageSize;
				_Core.AbsolutePage = absolutePage;
				
				while ( !_Core.Eof &&  i < pageSize )
				{
					if ( util.isFunction(callback) ) callback(_Core, i);
					i++;
					_Core.MoveNext();
				}
				
				return [RsCount, pageSize, absolutePage, PageCount];
			},
			
			// 分页符分页过程
			pageBar : function( total, pageSize, absolutePage, pageCount, callback ){
				if ( pageCount == undefined ) pageCount = Math.ceil(total / pageSize);
				
				var space = 0, _Str = "", l_cur, r_cur, _l_cur;
				
				l_cur = absolutePage - 4;
				
				if ( l_cur < 1 ){ l_cur = 1; r_cur = 9; }
				else{
					r_cur = l_cur + 8;
					if ( r_cur > total ) r_cur = total;
					_l_cur = r_cur - 8;
					if ( _l_cur < 1 ){ l_cur = 1; }
					else{ l_cur = _l_cur; }
				}
				
				for ( var t = l_cur ; t <= r_cur ; t++ )
				{
					if ( util.isFunction(callback) ) 
						_Str += callback(t, t == absolutePage, total, pageSize, pageCount) || "";
				}
				
				return _Str;
			}
		}
	}
	
	database.prototype.open = function(){
		var dbObject = new ActiveXObject(data.ActivexObject.conn);
		
		if ( this.baseName === undefined ){
			var i = 0, 
				isOk = false;
			
			// 循环匹配是否打开成功，根据不同的打开方式。
			while ( (isOk === false) && (i < this.accessDBStr.length) )
			{
				try{
					dbObject.open(this.accessDBStr[i](this));
					isOk = true;
					this.conn = dbObject;
				}catch(e){
					i++;
					isOk = false;
				}
			}
			
			return isOk;
			
		}else{
			try{
				dbObject.open("PROVIDER=MSDASQL;DRIVER={SQL Server};SERVER=" + this.serverNs + ";DATABASE=" + this.baseName + ";UID=" + this.userName + ";PWD=" + this.userPass + ";");
				this.conn = dbObject;
				return true;
			}catch(e){
				return false;
			}
		}	
	}
	
	database.prototype.close = function(){
		if ( this.conn !== undefined ){
			this.conn = undefined;
		}
	}
	
	database.prototype.read = function(SQL, callback, type){
		return dataAdodbStatus(function(){
			if ( SQL === undefined ) return undefined;
			
			try{
				var ret;
				
				if ( callback === undefined ){
					ret = this.conn.Execute(SQL);
				}
				else{
					if ( type == undefined ) type = 1;
					this.recordSet.Open(SQL, this.conn, this.moden, type);
					ret = callback.call(this.core, this.recordSet, this.conn, this);
					this.recordSet.Close();
				}
				
				return ret;
			}catch(e){
				util.log("open adodb sql(" + SQL + ") failed!");
			}
		});
	}
	
	database.prototype.insert = function(dataList, table, callback){
		return dataAdodbStatus(function(){
			if ( !util.isArray(dataList) ) dataList = [dataList];
			var ret;
			
			this.recordSet.Open("Select * From " + table, this.conn, this.moden, 2);
			
			dataList.each(function(k)
			{
				this.recordSet.AddNew(); // 添加新数据
				for ( var j in k ){
					this.recordSet(j) = k[j];
				}	
				this.recordSet.Update();
			});
			
			if ( util.isFunction(callback) ){
				ret = callback.call(this.core, this.recordSet, this.conn, this);
			}
			
			this.recordSet.Close();
			
			return ret;
		});
	}
	
	database.prototype.update = function(dataList, table, mainKey, mainKeyValue, callback){
		return dataAdodbStatus(function(){
			if ( !util.isArray(dataList) ) dataList = [dataList];
			var ret;
			
			this.recordSet.Open("Select * From " + table + " Where " + mainKey + "=" + mainKeyValue, this.conn, this.moden, 3);
			
			dataList.each(function(k)
			{
				for ( var j in k ){
					this.recordSet(j) = k[j];
				}	
				this.recordSet.Update();
			});
			
			if ( util.isFunction(callback) ){
				ret = callback.call(this.core, this.recordSet, this.conn, this);
			}
			
			this.recordSet.Close();
			
			return ret;
		});
	}
	
	database.prototype.destroy = function(table, mainKey, mainKeyValue, callback){
		return dataAdodbStatus(function(){
			var ret;
			
			this.recordSet.Open("Select * From " + table + " Where " + mainKey + "=" + mainKeyValue, this.conn, this.moden, 3);
			this.recordSet.Delete();
			
			if ( util.isFunction(callback) ){
				ret = callback.call(this.core, this.recordSet, this.conn, this);
			}
			
			this.recordSet.Close();
			
			return ret;
		});
	}
	
	function dataConnStatus(fn){
		if ( this.conn === undefined ){
			if ( this.open() === true ){
				return fn.call(this);
			}
		}
		
		return undefined;
	}
	
	function dataAdodbStatus(fn){
		return dataConnStatus(function(){
			if ( this.recordSet === undefined )
			{ 
				this.recordSet = new ActiveXObject(data.ActivexObject.record); 
			}
			return fn.call(this);
		});
	}
	
	function getRows( arr, fieldslen ){
		var len = arr.length / fieldslen, data=[], sp; 
		
		for( var i = 0; i < len ; i++ ) { 
			data[i] = new Array(); 
			sp = i * fieldslen; 
			for( var j = 0 ; j < fieldslen ; j++ ) { data[i][j] = arr[sp + j] ; } 
		}
		
		return data; 
	}
	
	return database;
});
%>