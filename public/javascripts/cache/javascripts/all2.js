//** AnyLink JS Drop Down Menu v2.0- (c) Dynamic Drive DHTML code library: http://www.dynamicdrive.com
//** Script Download/ instructions page: http://www.dynamicdrive.com/dynamicindex1/dropmenuindex.htm
//** January 29th, 2009: Script Creation date

//**May 22nd, 09': v2.1
	//1) Automatically adds a "selectedanchor" CSS class to the currrently selected anchor link
	//2) For image anchor links, the custom HTML attributes "data-image" and "data-overimage" can be inserted to set the anchor's default and over images.

//**June 1st, 09': v2.2
	//1) Script now runs automatically after DOM has loaded. anylinkmenu.init) can now be called in the HEAD section

if (typeof dd_domreadycheck=="undefined") //global variable to detect if DOM is ready
	var dd_domreadycheck=false

var anylinkmenu={

menusmap: {},
preloadimages: [],
effects: {delayhide: 200, shadow:{enabled:true, opacity:0.3, depth: [5, 5]}, fade:{enabled:false, duration:500}}, //customize menu effects

dimensions: {},

getoffset:function(what, offsettype){
	return (what.offsetParent)? what[offsettype]+this.getoffset(what.offsetParent, offsettype) : what[offsettype]
},

getoffsetof:function(el){
	el._offsets={left:this.getoffset(el, "offsetLeft"), top:this.getoffset(el, "offsetTop"), h: el.offsetHeight}
},

getdimensions:function(menu){
	this.dimensions={anchorw:menu.anchorobj.offsetWidth, anchorh:menu.anchorobj.offsetHeight,
		docwidth:(window.innerWidth ||this.standardbody.clientWidth)-20,
		docheight:(window.innerHeight ||this.standardbody.clientHeight)-15,
		docscrollx:window.pageXOffset || this.standardbody.scrollLeft,
		docscrolly:window.pageYOffset || this.standardbody.scrollTop
	}
	if (!this.dimensions.dropmenuw){
		this.dimensions.dropmenuw=menu.dropmenu.offsetWidth
		this.dimensions.dropmenuh=menu.dropmenu.offsetHeight
	}
},

isContained:function(m, e){
	var e=window.event || e
	var c=e.relatedTarget || ((e.type=="mouseover")? e.fromElement : e.toElement)
	while (c && c!=m)try {c=c.parentNode} catch(e){c=m}
	if (c==m)
		return true
	else
		return false
},

setopacity:function(el, value){
	el.style.opacity=value
	if (typeof el.style.opacity!="string"){ //if it's not a string (ie: number instead), it means property not supported
		el.style.MozOpacity=value
		if (el.filters){
			el.style.filter="progid:DXImageTransform.Microsoft.alpha(opacity="+ value*100 +")"
		}
	}
},

showmenu:function(menuid){
	var menu=anylinkmenu.menusmap[menuid]
	clearTimeout(menu.hidetimer)
	this.getoffsetof(menu.anchorobj)
	this.getdimensions(menu)
	var posx=menu.anchorobj._offsets.left + (menu.orientation=="lr"? this.dimensions.anchorw : 0) //base x pos
	var posy=menu.anchorobj._offsets.top+this.dimensions.anchorh - (menu.orientation=="lr"? this.dimensions.anchorh : 0)//base y pos
	if (posx+this.dimensions.dropmenuw+this.effects.shadow.depth[0]>this.dimensions.docscrollx+this.dimensions.docwidth){ //drop left instead?
		posx=posx-this.dimensions.dropmenuw + (menu.orientation=="lr"? -this.dimensions.anchorw : this.dimensions.anchorw)
	}
	if (posy+this.dimensions.dropmenuh>this.dimensions.docscrolly+this.dimensions.docheight){  //drop up instead?
		posy=Math.max(posy-this.dimensions.dropmenuh - (menu.orientation=="lr"? -this.dimensions.anchorh : this.dimensions.anchorh), this.dimensions.docscrolly) //position above anchor or window's top edge
	}
	if (this.effects.fade.enabled){
		this.setopacity(menu.dropmenu, 0) //set opacity to 0 so menu appears hidden initially
		if (this.effects.shadow.enabled)
			this.setopacity(menu.shadow, 0) //set opacity to 0 so shadow appears hidden initially
	}
	menu.dropmenu.setcss({left:posx+'px', top:posy+'px', visibility:'visible'})
	if (this.effects.shadow.enabled){
		//menu.shadow.setcss({width: menu.dropmenu.offsetWidth+"px", height:menu.dropmenu.offsetHeight+"px"})
		menu.shadow.setcss({left:posx+anylinkmenu.effects.shadow.depth[0]+'px', top:posy+anylinkmenu.effects.shadow.depth[1]+'px', visibility:'visible'})
	}
	if (this.effects.fade.enabled){
		clearInterval(menu.animatetimer)
		menu.curanimatedegree=0
		menu.starttime=new Date().getTime() //get time just before animation is run
		menu.animatetimer=setInterval(function(){anylinkmenu.revealmenu(menuid)}, 20)
	}
},

revealmenu:function(menuid){
	var menu=anylinkmenu.menusmap[menuid]
	var elapsed=new Date().getTime()-menu.starttime //get time animation has run
	if (elapsed<this.effects.fade.duration){
		this.setopacity(menu.dropmenu, menu.curanimatedegree)
		if (this.effects.shadow.enabled)
			this.setopacity(menu.shadow, menu.curanimatedegree*this.effects.shadow.opacity)
	}
	else{
		clearInterval(menu.animatetimer)
		this.setopacity(menu.dropmenu, 1)
		menu.dropmenu.style.filter=""
	}
	menu.curanimatedegree=(1-Math.cos((elapsed/this.effects.fade.duration)*Math.PI)) / 2
},

setcss:function(param){
	for (prop in param){
		this.style[prop]=param[prop]
	}
},

setcssclass:function(el, targetclass, action){
	var needle=new RegExp("(^|\\s+)"+targetclass+"($|\\s+)", "ig")
	if (action=="check")
		return needle.test(el.className)
	else if (action=="remove")
		el.className=el.className.replace(needle, "")
	else if (action=="add" && !needle.test(el.className))
		el.className+=" "+targetclass
},

hidemenu:function(menuid){
	var menu=anylinkmenu.menusmap[menuid]
	clearInterval(menu.animatetimer)
	menu.dropmenu.setcss({visibility:'hidden', left:0, top:0})
	menu.shadow.setcss({visibility:'hidden', left:0, top:0})
},

getElementsByClass:function(targetclass){
	if (document.querySelectorAll)
		return document.querySelectorAll("."+targetclass)
	else{
		var classnameRE=new RegExp("(^|\\s+)"+targetclass+"($|\\s+)", "i") //regular expression to screen for classname
		var pieces=[]
		var alltags=document.all? document.all : document.getElementsByTagName("*")
		for (var i=0; i<alltags.length; i++){
			if (typeof alltags[i].className=="string" && alltags[i].className.search(classnameRE)!=-1)
				pieces[pieces.length]=alltags[i]
		}
		return pieces
	}
},

addDiv:function(divid, divclass, inlinestyle){
	var el=document.createElement("div")
	if (divid)
		el.id=divid
	el.className=divclass
	if (inlinestyle!="" && typeof el.style.cssText=="string")
		el.style.cssText=inlinestyle
	else if (inlinestyle!="")
		el.setAttribute('style', inlinestyle)
	document.body.appendChild(el)
	return el
},

getmenuHTML:function(menuobj){
	var menucontent=[]
	var frag=""
	for (var i=0; i<menuobj.items.length; i++){
		frag+='<li><a href="' + menuobj.items[i][1] + '" target="' + menuobj.linktarget + '">' + menuobj.items[i][0] + '</a></li>\n'
		if (menuobj.items[i][2]=="efc" || i==menuobj.items.length-1){
			menucontent.push(frag)
			frag=""
		}
	}
	if (typeof menuobj.cols=="undefined")
		return '<ul>\n' + menucontent.join('') + '\n</ul>'
	else{
		frag=""
		for (var i=0; i<menucontent.length; i++){
			frag+='<div class="' + menuobj.cols.divclass + '" style="' + menuobj.cols.inlinestyle + '">\n<ul>\n' + menucontent[i] + '</ul>\n</div>\n'
		}
		return frag
	}
},

addEvent:function(targetarr, functionref, tasktype){
	if (targetarr.length>0){
		var target=targetarr.shift()
		if (target.addEventListener)
			target.addEventListener(tasktype, functionref, false)
		else if (target.attachEvent)
			target.attachEvent('on'+tasktype, function(){return functionref.call(target, window.event)})
		this.addEvent(targetarr, functionref, tasktype)
	}
},

domready:function(functionref){ //based on code from the jQuery library
	if (dd_domreadycheck){
		functionref()
		return
	}
	// Mozilla, Opera and webkit nightlies currently support this event
	if (document.addEventListener) {
		// Use the handy event callback
		document.addEventListener("DOMContentLoaded", function(){
			document.removeEventListener("DOMContentLoaded", arguments.callee, false )
			functionref();
			dd_domreadycheck=true
		}, false )
	}
	else if (document.attachEvent){
		// If IE and not an iframe
		// continually check to see if the document is ready
		if ( document.documentElement.doScroll && window == window.top) (function(){
			if (dd_domreadycheck) return
			try{
				// If IE is used, use the trick by Diego Perini
				// http://javascript.nwbox.com/IEContentLoaded/
				document.documentElement.doScroll("left")
			}catch(error){
				setTimeout( arguments.callee, 0)
				return;
			}
			//and execute any waiting functions
			functionref();
			dd_domreadycheck=true
		})();
	}
	if (document.attachEvent && parent.length>0) //account for page being in IFRAME, in which above doesn't fire in IE
		this.addEvent(window, function(){functionref()}, "load");
},

addState:function(anchorobj, state){
	if (anchorobj.getAttribute('data-image')){
		var imgobj=(anchorobj.tagName=="IMG")? anchorobj : anchorobj.getElementsByTagName('img')[0]
		if (imgobj){
			imgobj.src=(state=="add")? anchorobj.getAttribute('data-overimage') : anchorobj.getAttribute('data-image')
		}
	}
	else
		anylinkmenu.setcssclass(anchorobj, "selectedanchor", state)
},

addState:function(anchorobj, state){
	if (anchorobj.getAttribute('data-image')){
		var imgobj=(anchorobj.tagName=="IMG")? anchorobj : anchorobj.getElementsByTagName('img')[0]
		if (imgobj){
			imgobj.src=(state=="add")? anchorobj.getAttribute('data-overimage') : anchorobj.getAttribute('data-image')
		}
	}
	else
		anylinkmenu.setcssclass(anchorobj, "selectedanchor", state)
},

setupmenu:function(targetclass, anchorobj, pos){
	this.standardbody=(document.compatMode=="CSS1Compat")? document.documentElement : document.body
	var relattr=anchorobj.getAttribute("rel")
	dropmenuid=relattr.replace(/\[(\w+)\]/, '')
	var dropmenuvar=window[dropmenuid]
	var dropmenu=this.addDiv(null, dropmenuvar.divclass, dropmenuvar.inlinestyle) //create and add main sub menu DIV
	dropmenu.innerHTML=this.getmenuHTML(dropmenuvar)
	var menu=this.menusmap[targetclass+pos]={
		id: targetclass+pos,
		anchorobj: anchorobj,	
		dropmenu: dropmenu,
		revealtype: (relattr.length!=dropmenuid.length && RegExp.$1=="click")? "click" : "mouseover",
		orientation: anchorobj.getAttribute("rev")=="lr"? "lr" : "ud",
	    shadow: this.addDiv(null, "anylinkshadow", null) //create and add corresponding shadow
	}
	menu.anchorobj._internalID=targetclass+pos
	menu.anchorobj._isanchor=true
	menu.dropmenu._internalID=targetclass+pos
	menu.shadow._internalID=targetclass+pos
	menu.dropmenu.setcss=this.setcss
	menu.shadow.setcss=this.setcss
	menu.shadow.setcss({width: menu.dropmenu.offsetWidth+"px", height:menu.dropmenu.offsetHeight+"px"})
	this.setopacity(menu.shadow, this.effects.shadow.opacity)
	this.addEvent([menu.anchorobj, menu.dropmenu, menu.shadow], function(e){ //MOUSEOVER event for anchor, dropmenu, shadow
		var menu=anylinkmenu.menusmap[this._internalID]
		if (this._isanchor && menu.revealtype=="mouseover" && !anylinkmenu.isContained(this, e)){ //event for anchor
			anylinkmenu.showmenu(menu.id)
			anylinkmenu.addState(this, "add")
		}
		else if (typeof this._isanchor=="undefined"){ //event for drop down menu and shadow
			clearTimeout(menu.hidetimer)
		}
	}, "mouseover")
	this.addEvent([menu.anchorobj, menu.dropmenu, menu.shadow], function(e){ //MOUSEOUT event for anchor, dropmenu, shadow
		if (!anylinkmenu.isContained(this, e)){
			var menu=anylinkmenu.menusmap[this._internalID]
			menu.hidetimer=setTimeout(function(){
				anylinkmenu.addState(menu.anchorobj, "remove")
				anylinkmenu.hidemenu(menu.id)
			}, anylinkmenu.effects.delayhide)
		}
	}, "mouseout")
	this.addEvent([menu.anchorobj, menu.dropmenu], function(e){ //CLICK event for anchor, dropmenu
		var menu=anylinkmenu.menusmap[this._internalID]
		if ( this._isanchor && menu.revealtype=="click"){
			if (menu.dropmenu.style.visibility=="visible")
				anylinkmenu.hidemenu(menu.id)
			else{
				anylinkmenu.addState(this, "add")
				anylinkmenu.showmenu(menu.id)
			}
			if (e.preventDefault)
				e.preventDefault()
			return false
		}
		else
			menu.hidetimer=setTimeout(function(){anylinkmenu.hidemenu(menu.id)}, anylinkmenu.effects.delayhide)
	}, "click")
},

init:function(targetclass){
	this.domready(function(){anylinkmenu.trueinit(targetclass)})
},

trueinit:function(targetclass){
	var anchors=this.getElementsByClass(targetclass)
	var preloadimages=this.preloadimages
	for (var i=0; i<anchors.length; i++){
		if (anchors[i].getAttribute('data-image')){ //preload anchor image?
			preloadimages[preloadimages.length]=new Image()
			preloadimages[preloadimages.length-1].src=anchors[i].getAttribute('data-image')
		}
		if (anchors[i].getAttribute('data-overimage')){ //preload anchor image?
			preloadimages[preloadimages.length]=new Image()
			preloadimages[preloadimages.length-1].src=anchors[i].getAttribute('data-overimage')
		}
		this.setupmenu(targetclass, anchors[i], i)
	}
}

}


var anylinkmenu1={divclass:'anylinkmenu', inlinestyle:'', linktarget:''} //First menu variable. Make sure "anylinkmenu1" is a unique name!
anylinkmenu1.items = [
	["Timetable", "/timetable"],
	["Examinations", "/examination"],
	["News", "/news"],
    ["Users", "/user/manage"]
]

addEvent(window, "load", makeNiceTitles);

var XHTMLNS = "http://www.w3.org/1999/xhtml";
var CURRENT_NICE_TITLE;
var browser = new Browser();

function makeNiceTitles() {
    if (!document.createElement || !document.getElementsByTagName) return;
    // add namespace methods to HTML DOM; this makes the script work in both
    // HTML and XML contexts.
    if(!document.createElementNS)
    {
        document.createElementNS = function(ns,elt) {
            return document.createElement(elt);
        }
    }

    if( !document.links )
    {
        document.links = document.getElementsByTagName("a");
    }
    for (var ti=0;ti<document.links.length;ti++) {
        var lnk = document.links[ti];
        if (lnk.title) {
            lnk.setAttribute("nicetitle",lnk.title);
            lnk.removeAttribute("title");
            addEvent(lnk,"mouseover",showNiceTitle);
            addEvent(lnk,"mouseout",hideNiceTitle);
            addEvent(lnk,"focus",showNiceTitle);
            addEvent(lnk,"blur",hideNiceTitle);
        }
    }
    var instags = document.getElementsByTagName("ins");
    if (instags) {
    for (var ti=0;ti<instags.length;ti++) {
        var instag = instags[ti];
        if (instag.dateTime) {
            var strDate = instag.dateTime;
            var dtIns = new Date(strDate.substring(0,4),parseInt(strDate.substring(4,6)-1),strDate.substring(6,8),strDate.substring(9,11),strDate.substring(11,13),strDate.substring(13,15));
            instag.setAttribute("nicetitle","Added on "+dtIns.toString());
            addEvent(instag,"mouseover",showNiceTitle);
            addEvent(instag,"mouseout",hideNiceTitle);
            addEvent(instag,"focus",showNiceTitle);
            addEvent(instag,"blur",hideNiceTitle);
        }
    }
    }
}

function findPosition( oLink ) {
  if( oLink.offsetParent ) {
    for( var posX = 0, posY = 0; oLink.offsetParent; oLink = oLink.offsetParent ) {
      posX += oLink.offsetLeft;
      posY += oLink.offsetTop;
    }
    return [ posX, posY ];
  } else {
    return [ oLink.x, oLink.y ];
  }
}

function showNiceTitle(e) {
    if (CURRENT_NICE_TITLE) hideNiceTitle(CURRENT_NICE_TITLE);
    if (!document.getElementsByTagName) return;
    if (window.event && window.event.srcElement) {
        lnk = window.event.srcElement
    } else if (e && e.target) {
        lnk = e.target
    }
    if (!lnk) return;
    if (lnk.nodeName.toUpperCase() != 'A') {
        // lnk is not actually the link -- ascend parents until we hit a link
        lnk = getParent(lnk,"A");
    }
    if (!lnk) return;
    nicetitle = lnk.getAttribute("nicetitle");
    
    var d = document.createElementNS(XHTMLNS,"div");
    d.className = "nicetitle";
    tnt = document.createTextNode(nicetitle);
    pat = document.createElementNS(XHTMLNS,"p");
    pat.className = "titletext";
    pat.appendChild(tnt);
    d.appendChild(pat);
    /*if (lnk.href) {
        tnd = document.createTextNode(lnk.href);
        pad = document.createElementNS(XHTMLNS,"p");
        pad.className = "destination";
        pad.appendChild(tnd);
        d.appendChild(pad);
    }*/
    
    STD_WIDTH = 300;
    if (lnk.href) {
        h = lnk.href.length;
    } else { h = nicetitle.length; }
    if (nicetitle.length) {
      t = nicetitle.length;
    }
    h_pixels = h*6; t_pixels = t*10;
    
    if (h_pixels > STD_WIDTH) {
        w = h_pixels;
    } else if ((STD_WIDTH>t_pixels) && (t_pixels>h_pixels)) {
        w = t_pixels;
    } else if ((STD_WIDTH>t_pixels) && (h_pixels>t_pixels)) {
        w = h_pixels;
    } else {
        w = STD_WIDTH;
    }
        
    d.style.width = w + 'px';    

    /*
    mx = lnk.offsetLeft;
    my = lnk.offsetTop;
    */
    mpos = findPosition(lnk);
    mx = mpos[0];
    my = mpos[1];
    //xy = getMousePosition(e);
    //mx = xy[0]; my = xy[1];
    
    d.style.left = (mx+15) + 'px';
    d.style.top = (my+35) + 'px';
    if (window.innerWidth && ((mx+w) > window.innerWidth)) {
        d.style.left = (window.innerWidth - w - 25) + "px";
    }
    if (document.body.scrollWidth && ((mx+w) > document.body.scrollWidth)) {
        d.style.left = (document.body.scrollWidth - w - 25) + "px";
    }
    
    document.getElementsByTagName("body")[0].appendChild(d);
    
    CURRENT_NICE_TITLE = d;
}

function hideNiceTitle(e) {
    if (!document.getElementsByTagName) return;
    if (CURRENT_NICE_TITLE) {
        document.getElementsByTagName("body")[0].removeChild(CURRENT_NICE_TITLE);
        CURRENT_NICE_TITLE = null;
    }
}

// Add an eventListener to browsers that can do it somehow.
// Originally by the amazing Scott Andrew.
function addEvent(obj, evType, fn){
  if (obj.addEventListener){
    obj.addEventListener(evType, fn, false);
    return true;
  } else if (obj.attachEvent){
	var r = obj.attachEvent("on"+evType, fn);
    return r;
  } else {
	return false;
  }
}

function getParent(el, pTagName) {
	if (el == null) return null;
	else if (el.nodeType == 1 && el.tagName.toLowerCase() == pTagName.toLowerCase())	// Gecko bug, supposed to be uppercase
		return el;
	else
		return getParent(el.parentNode, pTagName);
}

function getMousePosition(event) {
  if (browser.isIE) {
    x = window.event.clientX + document.documentElement.scrollLeft
      + document.body.scrollLeft;
    y = window.event.clientY + document.documentElement.scrollTop
      + document.body.scrollTop;
  }
  if (browser.isNS) {
    x = event.clientX + window.scrollX;
    y = event.clientY + window.scrollY;
  }
  return [x,y];
}

// Determine browser and version.

function Browser() {
// blah, browser detect, but mouse-position stuff doesn't work any other way
  var ua, s, i;

  this.isIE    = false;
  this.isNS    = false;
  this.version = null;

  ua = navigator.userAgent;

  s = "MSIE";
  if ((i = ua.indexOf(s)) >= 0) {
    this.isIE = true;
    this.version = parseFloat(ua.substr(i + s.length));
    return;
  }

  s = "Netscape6/";
  if ((i = ua.indexOf(s)) >= 0) {
    this.isNS = true;
    this.version = parseFloat(ua.substr(i + s.length));
    return;
  }

  // Treat any other "Gecko" browser as NS 6.1.

  s = "Gecko";
  if ((i = ua.indexOf(s)) >= 0) {
    this.isNS = true;
    this.version = 6.1;
    return;
  }
}

