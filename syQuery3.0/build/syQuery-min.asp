<%@LANGUAGE="JAVASCRIPT" CODEPAGE="65001"%>
<%var $=(function(){var a=["config","ready","error","root","charset","createQuery","merge","mix","augment","type","echo","fn","die","isFunction","isString","isArray","isObject","isBoolean","isNumber","isDate","isJson","isQuery","include","add","use","execute","query","querys","posts","post","Enumerator","parseJSON","getIP"];var c=function(e,d,f){if(c.isString(e)){if(a.indexOf(e)==-1){c[e]=function(g,h){h=d?d:h;return new c.fn.init(g,h,f)};a.push(e);return c[e]}else{c.error.push("syQuery error : key["+e+"] exsit.")}}else{if(c.isFunction(e)){c.ready.push(e)}}};push=Array.prototype.push;c.addKey=function(d){if(a.indexOf(d)===-1){a.push(d)}};c.config={ActivexObject:{conn:"ADODB.CONNECTION",record:"ADODB.RECORDSET",fso:"Scripting.FileSystemObject",stream:"Adodb.Stream",xmlhttp:"Microsoft.XMLHTTP",xml:"Microsoft.XMLDOM",winhttp:"WinHttp.WinHttpRequest.5.1"}};c.ready=[];c.error=[];c.root="";c.charset="utf-8";c.plugin="syQuery3.0/src";c.loaded=[];c.fn=c.prototype={init:function(d,f,g){var e=c.createQuery(d,this,f);if(g!=undefined){var h=g.call(e);if(h){return h}}return e},constructor:c,syQuery:"3.0",length:0,object:null,size:function(){return this.length}};c.createQuery=function(d,f,g){if(d==undefined){return f}if(this.isArray(d)){return d.toQuery(f,g)}else{if(this.isObject(d)){var h;try{d.constructor;h=true}catch(i){h=false}if(this.isNumber(d.length)&&(h===true)){return Array.prototype.toQuery.call(d,f,g)}else{push.call(f,d);f.object=g||null;return f}}else{push.call(f,d);f.object=g||null;return f}}};c.merge=function(h,d,g){var m=h.length,f=0;if(typeof d.length==="number"){for(var e=d.length;f<e;f++){h[m++]=d[f]}}else{while(d[f]!==undefined){h[m++]=d[f++]}}h.length=m;h.object=g||null;return h};c.mix=function(g,l,j,e){if(!g||!l){return g}if(j==undefined){j=true}var d,f,h;if(e&&(d=e.length)){for(f=0;f<d;f++){h=e[f];if(h in l){b(h,g,l,j)}}}else{for(h in l){b(h,g,l,j)}}return g};c.extend=c.fn.extend=function(h,i,g){var d=h||{},f=i||{},e=g||[];if(!i&&!g){d=this;f=h}return c.mix(d,f,true,e)};c.augment=function(){var e=arguments,d=e.length-2,h=e[0],g=e[d],j=e[d+1],f=1;if(this.type(j)!="array"){g=j;j=undefined;d++}if(this.type(g)!="boolean"){g=undefined;d++}for(;f<d;f++){this.mix(h.prototype,e[f].prototype||e[f],g,j)}return h};c.type=function(d){return Object.prototype.toString.apply(d).split(" ")[1].toLowerCase().replace("]","")};c.echo=function(e,f,d){if(f==undefined){Response.Write(e);return}if(d==undefined){Response.Write(f.call(e));return}Response.Write(f.apply(e,d))};c.die=function(){this.echo.apply(undefined,arguments);Response.End()};var b=function(g,f,e,d){if(d||!(g in f)){f[g]=e[g]}};c.fn.init.prototype=c.fn;return c})();$.augment(String,{trim:function(){return this.replace(/^\s+/,"").replace(/\s+$/,"")},sql:function(){var a=this;[[/(w)(here)/ig,"$1h&#101;re"],[/(s)(elect)/ig,"$1el&#101;ct"],[/(i)(nsert)/ig,"$1ns&#101;rt"],[/(c)(reate)/ig,"$1r&#101;ate"],[/(d)(rop)/ig,"$1ro&#112;"],[/(a)(lter)/ig,"$1lt&#101;r"],[/(d)(elete)/ig,"$1el&#101;te"],[/(u)(pdate)/ig,"$1p&#100;ate"],[/(\s)(or)/ig,"$1o&#114;"],[/(java)(script)/ig,"$1scri&#112;t"],[/(j)(script)/ig,"$1scri&#112;t"],[/(vb)(script)/ig,"$1scri&#112;t"],[/(expression)/ig,"e&#173;pression"],[/(c)(ookie)/ig,"&#99;ookie"],[/(Object)/ig,"&#79;bject"],[/(script)/ig,"scri&#112;t"]].each(function(c,b){a=a.replace(b[0],b[1])});return a},_sql:function(){var a=this;[[/(w)(h&#101;re)/ig,"$1here"],[/(s)(el&#101;ct)/ig,"$1elect"],[/(i)(ns&#101;rt)/ig,"$1nsert"],[/(c)(r&#101;ate)/ig,"$1reate"],[/(d)(ro&#112;)/ig,"$1rop"],[/(a)(lt&#101;r)/ig,"$1lter"],[/(d)(el&#101;te)/ig,"$1elete"],[/(u)(p&#100;ate)/ig,"$1pdate"],[/(\s)(o&#114;)/ig,"$1or"],[/(java)(scri&#112;t)/ig,"$1script"],[/(j)(scri&#112;t)/ig,"$1script"],[/(vb)(scri&#112;t)/ig,"$1script"],[/(e&#173;pression)/ig,"expression"],[/&#99;(ookie)/ig,"c$1"],[/&#79;(bject)/ig,"O$1"],[/(scri)&#112;(t)/ig,"$1p$2"]].each(function(c,b){a=a.replace(b[0],b[1])});return a},cStr:function(){var a=this;[[/\</g,"&#60;"],[/\>/g,"&#62;"]].each(function(c,b){a=a.replace(b[0],b[1])});return a},_cStr:function(){var a=this;[[/&#60;/g,"<"],[/&#62;/g,">"]].each(function(c,b){a=a.replace(b[0],b[1])});return a},tStr:function(){var a=this;[[/textarea/ig,"t&#101;xtarea"]].each(function(c,b){a=a.replace(b[0],b[1])});return a},_tStr:function(){var a=this;[[/t&#101;xtarea/ig,"textarea"]].each(function(c,b){a=a.replace(b[0],b[1])});return a},cut:function(f){var d=0,c="",b=this,a;for(var e=0;e<b.length;e++){a=b.charAt(e);if(!/[^\u4E00-\u9FA5]/g.test(a)){d=d+2}else{d=d+1}c+=a;if(d>=(2*f)){break}}if(c!=b){c+="..."}return c},removeHTML:function(){return this.replace(/<[^>]*?>/g,"").replace(/\n\t\r/g,"")},removeUBB:function(){return this.replace(/\[(\w+).*?\](.+)\[\/\1\]/g,"$2").replace(/\n\t\r/g,"")},left:function(a){return this.substr(0,a)},right:function(a){return this.substr(this.length-a,a)},mid:function(b,a){return this.substr(b-1,a)},unicode:function(){var b="",a=this;for(var c=0;c<a.length;c++){b+="&#"+a.charCodeAt(c)+";"}return b},_unicode:function(){var b=this;k=b.split(";"),r="";for(var a=0;a<k.length;a++){r+=String.fromCharCode(k[a].replace(/&#/,""))}return r}});$.augment(Array,{eq:function(a){return a===-1?this.slice(a):this.slice(a,+a+1)},each:function(e,a){var b=0,d=this;if(a==undefined){for(var c=d[0];b<d.length&&e.call(d,b,c)!==false;c=d[++b]){}}else{for(;b<length;){if(e.apply(d[b++],a)===false){break}}}return d},map:function(f){var a=[],d,e=this;for(var b=0,c=e.length;b<c;b++){d=f.call(e,b,e[b]);if(d!==null){a[a.length]=d}}return a.concat.apply([],a)},indexOf:function(c){var a=-1,b=0,d=this;for(;b<d.length;b++){if(d[b]===c){a=b;break}}return a},lastIndexOf:function(e){var b=this.length,c=this,a=c.reverse(),d=a.indexOf(e);if(d==-1){return -1}else{return b-d-1}},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},remove:function(a){return this.slice(0,a).concat(this.slice(a+1))},toQuery:function(d,f){var e=d.length,c=0,a=this;for(var b=a.length;c<b;c++){d[e++]=a[c]}d.length=e;d.object=f||null;return d},trim:function(){return this.map(function(b,a){return a.trim()})}});$.config.type=["Function","String","Array","Object","Boolean","Number"];$.config.type.each(function(b,a){$["is"+a]=function(c){return $.type(c)===a.toLowerCase()}});(function(){$.mix($,{isDate:function(value){if($.type(value)==="date"){return true}else{try{var date=Date.parse(value);return isNaN(date)?false:true}catch(e){return false}}},isJson:function(value){return value.constructor==={}.constructor?true:false},isQuery:function(value){return value.constructor===$.fn.constructor?true:false},include:function(URI){if($.isArray(URI)){URI.each(function(i,_item){$.include(_item)})}else{var o=new ActiveXObject($.config.ActivexObject.stream);eval(filterContent(catchFile(URI,o)));o=null}}});function catchFile(URI,stream){var o=stream?stream:new ActiveXObject($.config.ActivexObject.stream),lens=URI.split("/"),localFo=lens.slice(0,-1).join("/"),Text="";o.Type=2;o.Mode=3;o.Open();o.Charset=$.charset;o.Position=o.Size;o.LoadFromFile(Server.MapPath(URI));Text=o.ReadText;o.Close;return catchContent(Text,o,localFo)}function catchContent(context,stream,localFo){var l=0,r=0,text="",p="",e,t,tempText;if(regExpress.includeExp.test(context)){while(l>-1){l=context.indexOf("<!--#include");if(l>-1){text+=context.substring(0,l);context=context.substring(l+12);r=context.indexOf("-->");p=context.substring(0,r);e=p.replace(' file="',"").replace('"',"").trim();if(localFo.length==0){t=e}else{t=localFo+"/"+e}context=context.substring(r+3);tempText=catchFile(t,stream);text+=catchContent(tempText,stream,t.split("/").slice(0,-1).join("/"))}else{text+=context;context=""}}return text}else{return context}}function filterContent(context){context=context.replace(regExpress.includeContentForLeftExp,"").replace(regExpress.includeContentForRightExp,"");function textformat(t){if(t.length>0){return';Response.Write("'+t.replace(/\\/g,"\\\\").replace(/\"/g,'\\"').replace(/\r/g,"\\r").replace(/\n/g,"\\n").replace(/\s/g," ").replace(/\t/g,"\\t")+'");'}else{return""}}var blank="",conSplit=context.split("<"+blank+"%"),r=0,text="",temp;for(var i=0;i<conSplit.length;i++){r=conSplit[i].indexOf("%"+blank+">");if(r>-1){temp=textformat(conSplit[i].substring(r+2));text+=(/^\=/.test(conSplit[i])?";Response.Write("+conSplit[i].substring(1,r)+");":conSplit[i].substring(0,r))+temp}else{text+=textformat(conSplit[i])}}return text}var regExpress={includeExp:/\<\!\-\-\#include\sfile\=\"(.+?)\"\s?\-\->/g,includeFileExp:/file\=\"(.+)\"/,includeContentForLeftExp:/^[\r\t\s\n]+/,includeContentForRightExp:/[\r\t\s\n]+$/}})();(function(){var a=Server.MapPath("/"),c=Server.MapPath(".");function b(){if(a!=c){return(function(){var e=c.replace(new RegExp("^"+a.replace(/\\/g,"\\\\")),"").substring(1).split("\\").length,d="";for(var f=0;f<e;f++){d+="../"}return d})()}else{return""}}$.root=b()})();(function(){$.mix($,{add:function(b,c,d){if($[b]==undefined){a(d);$[b]=c();$.addKey(b)}else{$.error.push("syQuery error : key["+b+"] exsit.")}},use:function(b,c){if(c==undefined){return $[b]}if($[b]!=undefined){return c($[b])}},execute:function(c,d,e){if($.isFunction(c)){d=c;c=""}a(e);var b=[];c.split(",").each(function(g,f){b.push($[f.trim()])});d.apply(undefined,b)},echoError:function(b){if($.isFunction(b)){$.echo($.error,function(){return this.map(function(d,c){return b(c)}).join("")})}else{$.echo($.error.join(b==undefined?"<br />":b))}}});function a(c){if(c!=undefined){if(c.reqiure){var d=$.root,f=$.plugin,b="";b=d+f;b=b.length===0?"":b+"/";for(var e=0;e<c.reqiure.length;e++){if($.loaded.indexOf(c.reqiure[e])==-1){$.include(b+"syQuery."+c.reqiure[e]+"-min.asp");$.loaded.push(c.reqiure[e])}}}}}})();(function(){var f=Array.prototype,a=/^[\],:{}\s]*$/,b=/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,c=/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,d=/(?:^|:|,)(?:\s*\[)+/g;var e=function(g){return f.toQuery.call(g,$.fn,this.object)};$.fn.extend({toArray:function(){return f.slice.call(this,0)},slice:function(){return this.merge(f.slice.apply(this,arguments))},eq:function(g){return g===-1?this.slice(g):this.slice(g,+g+1)},each:function(g){return f.each.call(this,g)},map:function(g){return this.merge(f.map.call(this,g))},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},get:function(g){return g==undefined?this.toArray():(g<0?this.slice(g)[0]:this[g])},trim:function(){return this.merge(f.trim.call(this))},merge:function(g){return f.toQuery.call(g,$.fn,this.object)}});$.extend({Enumerator:function(j,h,n){var l,i,g;if(h==undefined){l=j;i=[];g=undefined}else{if(n==undefined){l=j;if($.isFunction(h)){n=h;h=[]}else{if($.isArray(h)){n=undefined}else{h=[];n=undefined}}}else{l=j;i=h;g=n}}try{l=new Enumerator(l);for(;!l.atEnd();l.moveNext()){if($.isFunction(g)){i.push(g.call(l,l.item()))}else{i.push(l.item())}}}catch(m){}return i},querys:function(g,h){if(g==undefined){return this.Enumerator(Request.QueryString,h)}else{return this.Enumerator(Request.QueryString(g),h)}},query:function(){return this.querys.apply(this,arguments)[0]},posts:function(g,h){if(g==undefined){return this.Enumerator(Request.Form,h)}else{return this.Enumerator(Request.Form(g),h)}},post:function(){return this.posts.apply(this,arguments)[0]},parseJSON:function(g){if(g==undefined||!$.isString(g)){return null}g=g.trim();if(a.test(g.replace(b,"@").replace(c,"]").replace(d,""))){return(new Function("return "+g))()}else{$.error.push("Invalid JSON: "+g)}},getIP:function(){var g=String(Request.ServerVariables("HTTP_X_FORWARDED_FOR")).toLowerCase();if(g=="undefined"){g=String(Request.ServerVariables("REMOTE_ADDR")).toLowerCase()}return g}})})();$.add("date",function(){var b=function(){};$.mix(b,{now:function(f){return c(new Date(),f)},parseDate:e,dateStr:c,diff:function(f,j){f=new Date(f).getTime();j=new Date(j).getTime();var g=Math.max(f,j),h=Math.min(f,j),i=g-h;return a(i)}});function c(g,l){if(l==undefined){l="Y/m/d H:I:S"}if($.isString(g)||$.isNumber(g)){g=new Date(g)}var m=d(g),f="",j;for(var h=0;h<l.length;h++){j=l.charAt(h);if(m[j]==undefined){f+=j}else{f+=m[j]}}return f}function e(g){var f=Date.parse(g);return isNaN(f)?-1:Number(f)}function d(f){var g={shortMonths:["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],longMonths:["January","February","March","April","May","June","July","August","September","October","November","December"],shortDays:["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],longDays:["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]};return{d:(f.getDate()<10?"0":"")+f.getDate(),m:(f.getMonth()<9?"0":"")+(f.getMonth()+1),Y:f.getFullYear(),y:(""+f.getFullYear()).substr(2),a:f.getHours()<12?"am":"pm",A:f.getHours()<12?"AM":"PM",H:(f.getHours()<10?"0":"")+f.getHours(),I:(f.getMinutes()<10?"0":"")+f.getMinutes(),S:(f.getSeconds()<10?"0":"")+f.getSeconds(),z:f.getTime(),w:g.shortDays[f.getDay()],W:g.longDays[f.getDay()],r:g.shortMonths[f.getMonth()],R:g.longMonths[f.getMonth()]}}function a(m){if(m===0){return"0秒"}var j=[86400000,3600000,60000,1000],h=["天","小时","分钟","秒"],f=[0,0,0,0];for(var g=0;g<j.length;g++){var l=m/j[g];if(l<1){f[g]=0;m=l*j[g]}else{f[g]=Math.floor(l);m=m-f[g]*j[g]}}f=f.map(function(o,n){return n==0?"":n+h[o]});return f.join("")}return b});$.add("session",function(){var a=function(){};$.mix(a,{get:function(c,b){return Session(c)||b},set:function(c,d){if(d==undefined){for(var b in c){this.set(b,c[b])}}else{Session(c)=d}},remove:function(b){var c=this;if(b==undefined){Session.Contents.RemoveAll()}else{if($.isArray(b)){b.each(function(e,d){c.remove(d)})}else{Session.Contents.Remove(b)}}}});return a});$.add("cookie",function(){var a=function(){this.length=0;this.object=0};$.mix(a,{get:function(e,d){var d=e.split("."),c=d.length;if(c===2){return Request.Cookies(d[0])(d[1])||d}else{return Request.Cookies(d[0])||d}},set:function(f,g){if(g==undefined){for(var e in f){this.set(e,f[e])}}else{var d=f.split("."),c=d.length;if(c===2){return Response.Cookies(d[0])(d[1])=g}else{return Response.Cookies(d[0])=g}}},remove:function(c){if($.isArray(c)){var d=this;c.each(function(f,e){d.remove(e)})}else{Response.Cookies(c.split(".")[0]||c).Expires="1/1/1980"}},keep:function(e,f){if(f==undefined){for(var d in e){this.keep(d,e[d])}}else{var c=b(new Date(),f).toGMTString();$.use("date",function(g){c=g.dateStr(c,"Y/m/d H:I:S")});Response.Cookies(e.split(".")[0]||e).Expires=c}},domain:function(d,e){if(e==undefined){for(var c in d){this.domain(c,d[c])}}else{Response.Cookies(d.split(".")[0]||d).Domain=e}}});function b(e,i){var g=/^(\w+)\((\d+)\)$/.exec(i),h={year:function(f){return new Date(this+f*12*30*24*60*60*1000)},month:function(f){return new Date(this+f*30*24*60*60*1000)},day:function(f){return new Date(this+f*24*60*60*1000)},hour:function(f){return new Date(this+f*60*60*1000)},minute:function(f){return new Date(this+f*60*1000)},second:function(f){return new Date(this+f*1000)},msecond:function(f){return new Date(this+f)}};if(g){var d=g[1],c=g[2];return h[d].call(Number(e.getTime()),c)}else{return new Date()}}$.augment(a,{init:function(c){return[c].toQuery(this)},get:a.get,set:function(c){a.set(this[0],c);return this},remove:a.remove,keep:function(c){a.keep(this[0],c);return this},domain:function(c){a.keep(this[0],c);return this}});return a});$.add("json",function(){var a=function(){this.length=0;this.object=null};a.init=function(b){b=$.isArray(b)?b:[b];return b.toArray(new a(),null)};$.augment(a,{remove:function(b){if($.isArray(b)){for(var c=0;c<b.length;c++){delete this[b[c]]}}else{delete this[b]}return this},update:function(b,c){if(c==undefined){return $.mix(this,b)}else{this[b]=c;return this}},param:function(b){}});return a.init});%>