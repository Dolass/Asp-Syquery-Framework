<%
$.add("cache", function(){
	var cache = function(conn){
		this.flag = "syQuery";
		this.root = "syQuery3.0/docs/cache";
		this.conn = conn;
	},
		DATA = $.use("data"),
		STREAM = $.use("stream"),
		FSO = $.use("fso");
	
	$.augment(cache, {
		/**
		 * @ 重置缓存
		 */
		set : function( key, value ){
			if ( value == undefined ){
				Application.Lock(); 
				for ( var i in key ){
					Application.StaticObjects(this.flag).Item(i) = key[i]; 
				}
				Application.UnLock();
			}else{
				Application.Lock(); 
				Application.StaticObjects(this.flag).Item(key) = value; 
				Application.UnLock();
				return value;
			}
		},
		
		/**
		 * @ 获取缓存
		 */
		get : function(key){
			return Application.StaticObjects(this.flag).Item(key) || undefined;
		},
		
		/**
		 * @ 获取数据库缓存
		 * @ param key <string> 缓存标识
		 * @ param moden <number> 0, 1, 2
		 *		# [0]  app - file - data  [undefined,null]
		 *		# [1]  app - data
		 *		# [2]  file - data 
		 * @ param sql <string> SQL语句
		 */
		load : function( key, moden, sql ){
			var AppFile = $.root + this.root + "/" + this.flag + "." + key + ".cache",
				AppTMP;
				moden = !moden ? 0 : moden;
			
			if ( ( moden === 0 || ( moden === 1 ) ) && this.get( key ) != undefined ){
				// 直接取App的数据
				return this.get( key );
			}else if ( ( moden === 0 || ( moden === 2 ) ) && FSO( AppFile ).exsit() ){
				// 直接取文件的数据
				return eval( (new STREAM()).load(AppFile, 2) );
			}else{
				// 直接聪数据库中取
				AppTMP = getDataByBase(sql, this.conn);
				
				// 判断是否要逆转缓存
				// 1. 是否是使用App缓存模式
				if ( moden === 0 || ( moden === 1 ) ) this.set(key, AppTMP);
				
				// 2. 是否是使用文件缓存模式
				if ( moden === 0 || ( moden === 2 ) ) this.write(key, moden, AppTMP);
				
				return AppTMP;
			}
		},
		
		/**
		 * @ 设置数据库缓存
		 * @ param key <string> 缓存标识
		 * @ param moden <number> 0, 1, 2
		 *		# [0]  app - file - data  [undefined,null]
		 *		# [1]  app - data
		 *		# [2]  file - data 
		 * @ param sql <string> SQL语句
		 */
		write : function(key, moden, sql){
			var AppFile = $.root + this.root + "/" + this.flag + "." + key + ".cache",
				RsData = $.isString(sql) ? getDataByBase(sql, this.conn) : sql,
				_RsData;
				moden = !moden ? 0 : moden;
			
			// 设置App数据
			if ( moden === 0 || moden === 1 ){
				this.set(key, RsData);
			}
			
			// 设置文件数据
			if ( moden === 0 || moden === 2 ){
				// 将RS中的数据转化为文本
				_RsData = "[" + RsData.map(function(i, m){
					// 第一次循环
					return "[" + m.map(function(j, n){
						// 第二次循环
						return (n == null || n == undefined) ? "''" : "'" + encodeURIComponent(n) + "'";
					}).join(",") + "]";
				}).join(",") + "]";
				
				// 如果文件夹不存在，直接创建该文件夹
				FSO(AppFile.split("/").slice(0, -1).join("/")).create();
				
				// 保存文件缓存片段
				(new STREAM()).save(_RsData, AppFile, 2);
				
				return RsData;
			}
		}
	});
	
	function getDataByBase(sql, conn){
		// 返回 getRows 数组
		return DATA.select(sql, function(){
			return this.getRows();
		}, conn);
	}
	
	return cache;
}, { reqiure : ["fso", "stream", "data"] });
%>