<%
$.add("xml", function(){
	var object = new ActiveXObject($.config.ActivexObject.xml),
		xml = $("xml", object);
		
	var expr = {
		hack : /((nth|eq|gt|lt|first|last|even|odd|not)(\((.+)\))?)/g,
		nth : /(-?)(\d*)(n([+\-]?\d*))?/,
		tag : /^((?:[\w\u00c0-\uFFFF\*\-]|\\.)+)/,
		attr : /\[\s*((?:[\w\u00c0-\uFFFF\-]|\\.)+)\s*(?:(\S?=)\s*(?:(['"])(.*?)\3|(#?(?:[\w\u00c0-\uFFFF\-]|\\.)*)|)|)\s*\]/g
	}
	
	$.mix(xml, {
		/**
		 * 加载XML数据流或者文件
		 * @ param loadXmlMessage <string> XML数据流或者文件位置
		 * @ return <syQuery>
		 */
		load : function( loadXmlMessage ){
			var openStatus = false;
			try{
				openStatus = object.loadXML( loadXmlMessage );
				if ( !openStatus ){
					try{
						openStatus = object.load(Server.MapPath( loadXmlMessage ));
					}catch(e){
						openStatus = false;
					}
				}
			}catch(e){
				try{
					openStatus = object.load(Server.MapPath( loadXmlMessage ));
				}catch(e){
					openStatus = false;
				}
			}
			
			if ( openStatus !== false ){
				return xml(object.documentElement);
			}else{
				return false;
			}
		}
	});
	
	$.fn.extend({
		/**
		 * 扩展查找标签名获得节点的方法
		 * @ param selector <string> 选择器
		 * @ return <syQuery>
		 */
		getElementsByTagName : function( TagName ){
			return this.map(function( i, element ){
				var _elements = element.getElementsByTagName(TagName);
				return _elements.length === 0 ? null : Object2Array(_elements);
			});
		},
		
		/**
		 * 扩展查找属性获得节点的方法
		 * @ param selector <string> 选择器
		 * @ return <syQuery>
		 */
		getElementsByAttr : function( AttrName, AttrValue ){
			return this.map(function( i, element ){
				try{
					return element.getAttribute( AttrName ) === AttrValue ? element : null;
				}catch(e){
					return null
				}
			});
		},
		
		/**
		 * 扩展通过HACK查找节点的方法
		 * @ param HackName <string> 表达式
		 * @ return <syQuery>
		 */
		getElementsByHack : function( HackName ){
			var elementExec = expr.hack.exec(HackName),
				_value;
				
			return this[elementExec[2]].call(this, elementExec[4]);
		},
		
		/**
		 * 2n + 1 类型表达式
		 * @ param HackName <string> 表达式
		 * @ return <syQuery>
		 */
		nth : function( HackName ){
			
			// 如果没有数据，直接返回对象
			if ( this.length === 0 ) return this;
			
			// 使用正则来判断
			var elementExec = expr.nth.exec(HackName),
				nth_1_area = elementExec[1],
				nth_2_area = elementExec[2],
				nth_3_area = elementExec[4],
				len = this.length;

			// 过滤数据
			nth_2_area = nth_2_area == "" ? "0" : nth_2_area;
			nth_3_area = nth_3_area == "" ? "0" : nth_3_area;
			
			var A = Number( nth_1_area + nth_2_area ),
				B = Number( nth_3_area );
			
			var first, last, tmpArr = [];
			
			// 条件判断
			if ( nth_1_area == "-" ){
				first = Math.ceil( (len - B) / A );
				last = Math.floor( (1 - B) / A );
			}else{
				first = Math.ceil( (1 - B) / A );
				last = Math.floor( (len - B) / A );
			}
			
			for ( var i = first; i <= last ; i++ )
			{
				tmpArr.push( A * i + B - 1 );
			}
			
			// 过滤返回数据
			return this.map(function( j, element ){
				return tmpArr.indexOf(j) !== -1 ? element : null;
			});	
		},
		
		/**
		 * :not 类型表达式
		 * @ param HackName <string> 表达式
		 * @ return <syQuery>
		 */
		not : function( HackName ){
			var _this = Object2Array(this),
				Compean = Object2Array(this.getElementsByHack(HackName));
				
			_this = _this.map(function( i, element ){
				return Compean.indexOf(element) === -1 ? element : null;
			});
				
			return _this.toQuery(this, this.object);
		},
		
		/**
		 * 设置或者获取节点的属性值
		 * @ param AttrName <string | json> 节点属性名或者设置节点属性的JSON数据
		 * @ param AttrValue <string> 值
		 * @ return <syQuery>
		 */
		attr : function( AttrName, AttrValue ){
			if ( AttrValue == undefined ){
				if ( $.isJson(AttrName) ){
					for ( var i in AttrName )
					{
						this.attr( i, AttrName[i] );
					}
					return this;
				}else{
					return this[0].getAttribute( AttrName );
				}
			}else{
				this.each(function( j, element ){
					element.setAttribute( AttrName, AttrValue + "" );
				});
				return this;
			}
		},
		
		/**
		 * 移除节点的某个属性
		 * @ param AttrName <string> 节点属性名
		 * @ return <syQuery>
		 */
		removeAttr : function( AttrName ){
			return this.map(function( i, element ){
				element.setAttribute( AttrName, "" );
				
				if ( element.nodeType === 1 ){
					element.removeAttribute( AttrName );
				}
				
				return element;
			});
		},
		
		/**
		 * 添加节点 返回对象根据isReturnParentElement确定
		 * @ param tagName <string> 新节点名
		 * @ param isReturnParentElement <boolean> 是否返回原来的节点， 如果为undefined或者false 则返回新节点，其他反之。
		 * @ return <syQuery>
		 */
		append : function( tagName, isReturnParentElement ){
			return this.map(function( i, element ){
				var _element = this.object.createElement( tagName );
				element.appendChild(_element);
				if ( isReturnParentElement == undefined ){
					return _element;
				}else{
					return element;
				}
			});
		},
		
		/**
		 * 移除节点下所有子节点
		 * @ return <syQuery>
		 */
		empty : function(){
			for ( var i = 0, elem ; (elem = this[i]) != null; i++ ) {
				// Remove any remaining nodes
				while ( elem.firstChild ) {
					elem.removeChild( elem.firstChild );
				}
			}
			
			return this;
		},
		
		/**
		 * 设置或者或者节点的CDATA子节点内的内容
		 * @ param value <string> 需要设置的内容
		 * @ return <syQuery>
		 */
		html : function( value ){
			if ( value == undefined ){
				var element = this[0] || null;	
				// 如果不存在节点
				if ( element === null ) return "";	
				// 如果是文本节点
				if ( element.nodeType == 4 ) return element.text;
				// 如果是CDATA节点
				return element.xml;
			}else{
				this.empty().each(function( i, _element){
					if ( $.isString(value) ){
						if ( value.toLowerCase() == "null" ) value = "";
					}
					
					if ( value == null ) key = "";
					
					_element.appendChild( this.object.createCDATASection(value + "" || "") );
				});
				
				return this;
			}
		},
		
		/**
		 * 设置或者或者节点的文本内容
		 * @ param value <string> 需要设置的内容
		 * @ return <syQuery>
		 */
		text : function( value ){
			if ( value == undefined ){
				var element = this[0] || null;
				if ( element === null ) return "";	
				return element.text;
			}else{
				this.empty().each(function(i, _element){
					if ( $.isString(value) ){
						if ( value.toLowerCase() == "null" ) value = "";
					}
					
					if ( value == null ) value = "";

					_element.appendChild( this.object.createTextNode(value) );
				});
				return this;
			}
		},
		
		/**
		 * 移除一个节点
		 * @ return <syQuery>
		 */
		remove : function(){
			this.each(function(i, k){
				try{ k.parentNode.removeChild(k); }catch(e){}
			});
		},
		
		/**
		 * 获得节点的父节点(最近，相连的。)
		 * @ return <syQuery>
		 */
		parent : function(){
			return this.map(function( i, element ){
				var _parent = element.parentNode;
				return _parent && _parent.nodeType !== 11 ? _parent : null;
			});
		},
		
		/**
		 * 获得节点的下一节点
		 * @ return <syQuery>
		 */
		next : function(){
			return this.map(function( i, element ){
				var _next = element.nextSibling || null;
				return _next;
			});
		},
		
		/**
		 * 获得节点的上一节点
		 * @ return <syQuery>
		 */
		prev : function(){
			return this.map(function( i, element ){
				var _prev = element.previousSibling || null;
				return _prev;
			});
		},
		
		/**
		 * 保存XML文件
		 * @ return <syQuery>
		 */
		saveXML : function( path ){
			this.object.save(Server.MapPath(path));
			return this;
		}
	});
	
	function Object2Array(obj){
		var tmpArr = [];
		
		for ( var i = 0 ; i < obj.length ; i++ )
		{
			tmpArr.push(obj[i]);
		}
		
		return tmpArr;
	}
	
	return xml;
});
%>