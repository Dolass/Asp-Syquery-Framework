<%
/**
 * Project Name : "Adodb.Stream" ActivexObject
 * Project Author : evio
 * CreateTime : 2011-04-19
 * Project Version : 2.0
 */
;(function(){
	
	/**
	 * 配置数据
	 * $.config.setup.stream 配置数据
	 *			-	Mode (3)
	 */
	$.config.setup.stream = {
		Mode : 3
	};
	
	$.extend({
		stream : function(){
			return $.active($.config.ActivexObject.stream);
		},
		
		loader : function(o, i, callback, arg){
			if ( i != 1 ) i = 2;
			var fine = false;
			o.Type = i; o.Mode = $.config.setup.stream.Mode; o.Open();
			try{ 
				fine = callback.call(o, i, arg);
			}catch(e){ 
				$.setError(e.message); 
			}
			o.Close;
			return fine;
		},
		
		load : function(p, o, i){
			return $.loader(o, i, function(_i){
				if ( _i == 2 ) this.Charset = $.config.charset;
				if ( _i == 2 ) { this.Position = this.Size; }else{ this.Position = 0; }
				this.LoadFromFile(Server.MapPath(p));
				if ( _i == 1 ) { return this.Read(); }else{ return this.ReadText; }
			});
		},
		
		save : function(t, p, o, i){
			return $.loader(o, i, function(_i){
				if ( _i == 2){ this.Charset = $.config.charset; }
				if ( _i == 1 ){ this.Position = 0; this.write(t); }
				else{ this.Position = this.Size; this.WriteText = t; }
				this.SaveToFile(Server.MapPath(p), 2);
				return true;
			});
		},
		
		bin : function(t, o){
			return $.loader(o, 1, function(_i){
				o.Write(t);
				o.Position = 0;
				o.Type = 2;
				o.Charset = $.config.charset;
				return o.ReadText;
			});
		}
	});
	
	
	$.fn.extend({
		load : function(i){
			return $.loader(this.object, i, function(_i, _Query){
				var _this = this;
				if ( _i == 2 ) this.Charset = $.config.charset;
				return _Query.map(function(j, k){
					if ( _i == 2 ) { _this.Position = _this.Size; }else{ _this.Position = 0; }
					_this.LoadFromFile(Server.MapPath(k));
					if ( _i == 1 ) { return _this.Read(); }else{ return _this.ReadText; }
				});
			}, this);
		},
		
		save : function(p, i){
			if ( !$.isArray(p) ) p = [p];
			return this.map(function(j, k){
				var temp = $.save(k, p[j], this.object, i);
				if ( temp == false ) return null;
				return p[j];
			});
		},
		
		bin : function(){
			return this.map(function(i, k){
				return $.bin(k, this.object);
			});
		}
	});
	
})();
%>