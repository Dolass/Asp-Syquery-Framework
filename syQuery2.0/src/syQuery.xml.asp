<%
;(function(){
	
	$.extend({

		xmlConfig : {
		
			match : {
				chunker : /((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^\[\]]*\]|['"][^'"]*['"]|[^\[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/,
				ID: /#((?:[\w\u00c0-\uFFFF\-]|\\.)+)/,
				CLASS: /\.((?:[\w\u00c0-\uFFFF\-]|\\.)+)/,
				NAME: /\[name=['"]*((?:[\w\u00c0-\uFFFF\-]|\\.)+)['"]*\]/,
				ATTR: /\[\s*((?:[\w\u00c0-\uFFFF\-]|\\.)+)\s*(?:(\S?=)\s*(?:(['"])(.*?)\3|(#?(?:[\w\u00c0-\uFFFF\-]|\\.)*)|)|)\s*\]/g,
				TAG: /^((?:[\w\u00c0-\uFFFF\*\-]|\\.)+)/,
				CHILD: /:(only|nth|last|first)-child(?:\(\s*(even|odd|(?:[+\-]?\d+|(?:[+\-]?\d*)?n\s*(?:[+\-]\s*\d+)?))\s*\))?/g,
				POS: /:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^\-]|$)/g,
				PSEUDO: /:((?:[\w\u00c0-\uFFFF\-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/g,
				GT : /\>/g,
				SPLITEXPR : /^(\w+?)\[(.+?)\]$/
			},
			
			formatSelector : function( selector )
			{
				return $(selector.split(",")).trim().map(function(i, k){
					var ret = { set : "", expr : k }, keep = [];
					while ( ret.expr.length > 0 )
					{
						ret = $.xmlConfig.exprMatch.chunker(ret);
						keep.push($.xmlConfig.exprMatch.Mac(ret.set));
					}
					return keep;
				}).toArray();
			},
			
			exprMatch : {
			
				chunker : function(ret)
				{
					var temp = $.xmlConfig.match.chunker.exec(ret.expr);
					if ( temp )
					{
						ret.set = $.trim(temp[1]); ret.expr = $.trim(temp[3]);
						return ret;
					}else{
						return {set : "", expr : ""}
					}
				},
				
				Mac : function(selector)
				{
					var newAArr = ["ATTR", "TAG", "CHILD", "POS", "PSEUDO", "GT"], toBe;
					for ( var i = 0 ; i < newAArr.length ; i++ )
					{	
						var key = newAArr[i];
						if ($.xmlConfig.match[key].test(selector)) selector = $.xmlConfig.toBeMethod[key].call(selector);
					}
					return selector;
				}
			},
			
			toBeMethod : {
				
				"ATTR" : function()
				{
					return this.replace($.xmlConfig.match.ATTR, "{ATTR['$1','$4']}");
				},
				
				"TAG" : function()
				{
					return this.replace($.xmlConfig.match.TAG, "{TAG['$1']}");
				},
				
				"CHILD" : function()
				{
					return this.replace($.xmlConfig.match.CHILD, "{CHILD['$1','$2']}");
				},
				
				"POS" : function()
				{
					return this.replace($.xmlConfig.match.POS, "{POS['$1','$2']}");
				},
				
				"PSEUDO" : function()
				{
					return this.replace($.xmlConfig.match.PSEUDO, "{PSEUDO['$1','$3']}");
				},
				
				"GT" : function()
				{
					return this.replace($.xmlConfig.match.GT, "{GT}");
				}
			},
			
			callback : {
				"TAG" : function(tag)
				{
					return $.map(this, function(i, k){
						var list = k.getElementsByTagName(tag);
						if ( list.length == 0 ) return null;	
						return $.toArray(k.getElementsByTagName(tag));
					});
				},
				
				"ATTR" : function(name, value)
				{
					return $.map(this, function(i, k){
						try{
							return k.getAttribute( name ) == value ? k : null;
						}catch(e){
							return null;
						}
					});
				},
				
				"CHILD" : function(key, value)
				{
					return $.xmlConfig.callChild[key](this, value);
				},
				
				"POS" : function(key, value)
				{
					return $.xmlConfig.callChild[key](this, value);
				}
			},
			
			callChild : {
				
				first : function(ele){
					return [ele[0]] || [];
				},
				
				last : function(ele){
					return ele.slice(-1) || [];
				},
				
				nth : function(ele, type)
				{
					var test = /(-?)(\d*)(?:n([+\-]?\d*))?/.exec(type);
					if ( test ){
						
						if ( !/n/.test(type) ){
							
							var deep = parseInt(type) - 1;
							return [ ele[ deep < 0 ? 0 : deep ] ];
							
						}else{	

							var _fo = test[1], a = test[2], b = test[3], k = ele.length, first, last, MathArr = [];

							if ( a == "" ) a = "0"; if ( b == "" ) b == "0";
							a = parseInt(_fo + a) || 0; b = parseInt(b) || 0;
							
							if ( _fo == "-" ){
								first = Math.ceil( (k - b) / a );
								last = Math.floor( (1 - b) / a );
							}else{
								first = Math.ceil( (1 - b) / a );
								last = Math.floor( (k - b) / a );
							}
							
							for ( var i = first; i <= last ; i++ )
							{
								MathArr.push( ele[a * i + b - 1] );
							}
							
							return MathArr;
						}
					}else{
						return [];
					}
				},
				
				odd : function(ele)
				{
					return this.nth(ele, "2n");
				},
				
				even : function(ele)
				{
					return this.nth(ele, "2n+1")
				},
				
				eq : function(ele, i)
				{
					return this.nth(ele, i)
				},
				
				lt : function(ele, j)
				{
					return $.map(ele, function(i, k){
						if ( i < j ){
							return k;
						}else{
							return null;
						}
					});
				},
				
				gt : function(ele, j)
				{
					return $.map(ele, function(i, k){
						if ( i > j ){
							return k;
						}else{
							return null;
						}
					});
				}
			}
		},

		xml : function(expr)
		{
			var object = $.active($.config.ActivexObject.xml), root, open = true;
			if ( expr == undefined ) return [null, object];
			try{
				object.load(Server.MapPath(expr));
			}catch(e){
				try{
					object.loadXML(expr);
				}catch(e){
					open = false;
				}
			}
			if ( open == true ){
				root = object.documentElement;
			}else{
				root = null;
			}
			return [root, object];
		},
		
		attr : function(ele, key, value)
		{
			if ( value != undefined ){
				ele.setAttribute(key, "" + value);
			}else{
				if ( $.isJson(key) ){
					$.jsonEach(key, function(i, k){
						ele.setAttribute(i, "" + k);
					});
				}else if ( $.isString(key) ){
					if ( !ele.attributes[ key ] && (ele.hasAttribute && !ele.hasAttribute( key )) ) {
						return "";
					}else{
						return ele.getAttribute( key );
					}
				}else{
					return "";
				}
			}
		},
		
		append : function( elem, name, obj, exec )
		{
			var newElem = obj.createElement(name);
			elem.appendChild(newElem);
			if ( exec ){
				return elem;
			}else{
				return newElem;
			}
		}
		
	});

	$.fn.extend({
		
		find : function(selector)
		{
			var formatArr = $.xmlConfig.formatSelector(selector);
			//$.echo(formatArr);
			return this.map(function(i, k){
				var Elements = [k];
				
				for ( var i = 0 ; i < formatArr.length ; i++ )
				{
				
					var keyArr = formatArr[i].replace(/^\{/, "").replace(/\}$/, "").split("}{"), t1, t2, t3, t4;
					
					for ( var j = 0 ; j < keyArr.length ; j++ )
					{
						var key = $.xmlConfig.match.SPLITEXPR.exec(keyArr[j]);
						
						if ( key ){
							t1 = key[1]; t4 = key[2].split(",");
							
							if ( t4.length == 2 ){
								t2 = t4[0].replace(/^\'/, "").replace(/\'$/, "");
								t3 = t4[1].replace(/^\'/, "").replace(/\'$/, "");
							}else{
								t2 = t4[0].replace(/^\'/, "").replace(/\'$/, "");
								t3 = "";
							}
							
							var a = [t2];
							if ( t3 != "" ) a.push(t3);
							
							Elements = $.xmlConfig.callback[t1].apply(Elements, a);
						}
						
					}
					
				}
				return Elements;
				
			});
		},
		
		attrs : function( key, value )
		{		
			return this.map(function(i, k){ return $.attr(k, key, value); })
		},
		
		attr : function( key, value )
		{
			return $.attr(this[0], key, value);
		},
		
		removeAttr : function( name )
		{
			return this.each(function(i, k){
				$.attr( k, name, "" );
				if ( k.nodeType === 1 ) 
				{
					k.removeAttribute( name );
				}
			});
		},
		
		append : function( key, exec )
		{
			return this.map(function(i, k){
				if ( $.isArray(key) )
				{
					var newArray = [];
					for ( var i = 0, len = key.length ; i < len ; i++ )
					{
						newArray.push( $.append( k, key[i], this.object, exec ) );	
					}
					return newArray;
				}
				if ( $.isFunction(key) )
				{
					return $.append( k, key.call(k, this.object), this.object, exec );
				}
				return $.append( k, key, this.object, exec );
			});
		},
		
		empty: function() 
		{
			for ( var i = 0, elem; (elem = this[i]) != null; i++ ) {
				// Remove any remaining nodes
				while ( elem.firstChild ) {
					elem.removeChild( elem.firstChild );
				}
			}
			
			return this;
		},
		
		saveXML : function(path)
		{
			this.object.save(Server.MapPath(path));
			return this;
		},
		
		html : function(key){
			if ( key == undefined ){
			
				var elem = this.get(0).firstChild || null;
				if ( elem === null ) return "";
				
				if ( elem.nodeType == 4 )
				{
					return elem.text;
				}
				
				return elem.xml;
			}else{
				var obj = this.object;
				this.empty().each(function(i, k){
					if ( $.isString(key) )
					{
						if ( key.toLowerCase() == "null" ){
							key = "";
						}
					}
					
					if ( key == null ){ key = ""; }
					
					var e = obj.createCDATASection(key + "" || "");
					k.appendChild(e);
				});
				
				return this;
			}
		},
		
		text : function(value)
		{
			if ( value != undefined )
			{
				var obj = this.object;
				this.empty().each(function(i, k){
					if ( $.isString(value) ){
						if ( value.toLowerCase() == "null" ){
							value = "";
						}
					}
					if ( value == null ){value = "";}
					var e = obj.createTextNode(value);
					k.appendChild(e);
				});
				return this;
			}else{
				var elem = this.get(0).firstChild || null;
				if ( elem === null ) return "";
				return elem.text;
			}
		},
		
		remove : function()
		{
			this.each(function(i, k){
				try{ k.parentNode.removeChild(k); }catch(e){}
			});
		},
		
		xsl : function(path)
		{
			var xsl = $.xml(), target = this.object;
			xsl[1].async = false;
			xsl[1].load(Server.MapPath(path));
			target.async = false;
			try{
				return target.transformNode(xsl[1]);
			}catch(e){
				return e.message;
			}
		},
		
		parent : function()
		{
			var par = this.get(0).parentNode;
			return par && par.nodeType !== 11 ? $(par, this.object) : $([], this.object);
		},
		
		parents : function(selector){
			var _this = this, parentsArr = [], matchQuery = $(this.object.documentElement, this.object).find(selector);
			
			while ( _this.get(0) != this.object.documentElement )
			{
				_this = _this.parent();
				if ( selector != undefined ){
				
					// match the exprssion parent nodes.
					if ($.grep(matchQuery, function(e, j){
					
						// check parent node equ
						return e == _this.get(0);
					}, false).length > 0 ){
						parentsArr.push(_this.get(0));
					};
					
				}else{
					parentsArr.push(_this.get(0));
				}
			}
			
			return $(parentsArr, this.object);
		}
	});
	
	$.jsonEach({
		next : "nextSibling",
		prev : "previousSibling"
	}, function( name, fn ){
		$.fn[ name ] = function(){
			try{
				return $(this.get(0)[fn], this.object);
			}catch(e){
				return  $([], this.object);
			}
		}
	});
	
})();
%>