<%$.add("data",function(){var e=$("data"),b=function(g){this.length=0;this.object=g||null};$.augment(b,{each:function(j){var h=this[0],g=0;h.MoveFirst();while(!h.Eof){j(g,h);h.MoveNext();g++}return this},getRows:function(){var h=this[0],g=[];try{g=h.GetRows().toArray()}catch(i){}return a(g,h.Fields.Count)}});$.mix(e,{open:function(h,g){if(g==undefined){g=new ActiveXObject($.config.ActivexObject.conn)}var j={method:"access",userName:"",userPass:"",serverNs:"",baseName:""};if($.isString(h)){j.serverNs=h}else{if($.isJson(h)){j=$.extend(j,h)}}var i=c(g,j,0);return{success:i.success,object:i.object}},close:function(g){try{g.Close();g=null}catch(h){g=null}},select:function(l,n,j,h,g,i){var m=this,k;g=g==undefined?1:g;i=i==undefined?1:i;h=h==undefined?new ActiveXObject($.config.ActivexObject.record):h;j=j==undefined?new ActiveXObject($.config.ActivexObject.conn):j;if($.isArray(l)){l.each(function(p,o){return m.select(o,n,h,j,g,i)})}else{h.Open(l,j,g,i);k=n.call([h].toQuery(new b()),h,j);h.Close();return k}},insert:function(j,i,m,h,g){var l=this,k;g=g==undefined?new ActiveXObject($.config.ActivexObject.record):g;h=h==undefined?new ActiveXObject($.config.ActivexObject.conn):h;if(!$.isArray(j)){j=[j]}g.Open("Select * From "+i,h,1,2);j.each(function(p,n){g.AddNew();for(var o in n){g(o)=n[o]}g.Update()});k=m.call([g].toQuery(new b()),g,h);g.Close();return k},update:function(j,n,o,l,m,g,h){var k=this,i;h=h==undefined?new ActiveXObject($.config.ActivexObject.record):h;g=g==undefined?new ActiveXObject($.config.ActivexObject.conn):g;if(!$.isArray(j)){j=[j]}h.Open("Select * From "+n+" Where "+o+"="+l,g,1,3);j.each(function(r,p){for(var q in p){h(q)=p[q]}h.Update()});i=m.call([h].toQuery(new b()),h,g);h.Close();return i},destory:function(i,j,n,m,h,g){var l=this,k;g=g==undefined?new ActiveXObject($.config.ActivexObject.record):g;h=h==undefined?new ActiveXObject($.config.ActivexObject.conn):h;g.Open("Select * From "+i+" Where "+j+"="+n,h,1,3);k=m.call([g].toQuery(new b()),g,h);g.Delete();g.Close();return k}});function f(k){var h="";for(var g=0;g<k;g++){h+="../"}return h}function d(h,g){return h.method==="access"?"provider=Microsoft.jet.oledb.4.0;data source="+Server.MapPath(f(g)+h.serverNs):"PROVIDER=MSDASQL;DRIVER={SQL Server};SERVER="+h.serverNs+";DATABASE="+h.baseName+";UID="+h.userName+";PWD="+h.userPass+";"}function c(k,i,g){if(g>=10){return{success:false,object:null}}try{k.Open(d(i,g));return{success:true,object:k}}catch(h){return c(k,i,++g)}}function a(h,m){var g=h.length/m,o=[],n;for(var l=0;l<g;l++){o[l]=new Array();n=l*m;for(var k=0;k<m;k++){o[l][k]=h[n+k]}}return o}return e});%>