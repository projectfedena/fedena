
var RedBox = {

  showInline: function(id)
  {
    this.showOverlay();
    new Effect.Appear('RB_window', {duration: 0.4, queue: 'end'});        
    this.cloneWindowContents(id);
  },

  loading: function()
  {
    this.showOverlay();
    Element.show('RB_window');
    this.setWindowPositions();
  },

  addHiddenContent: function(id)
  {
    this.removeChildrenFromNode($('RB_window'));
    this.moveChildren($(id), $('RB_window'));
    this.activateRBWindow();
  },
  
  activateRBWindow: function()
  {
    Element.hide('RB_loading');
    this.setWindowPositions();
  },

  close: function()
  {
    new Effect.Fade('RB_window', {duration: 0.4});
    new Effect.Fade('RB_overlay', {duration: 0.4});
    this.showSelectBoxes();
  },

  showOverlay: function()
  {
    var inside_redbox = '<div id="RB_window" style="display: none;"><div id="RB_loading"></div></div><div id="RB_overlay" style="display: none;"></div>'
    if ($('RB_redbox'))
    {
      Element.update('RB_redbox', "");
      new Insertion.Top($('RB_redbox'), inside_redbox);  
    }
    else
    {
      new Insertion.Top(document.body, '<div id="RB_redbox" align="center">' +  inside_redbox + '</div>');      
    }

    this.setOverlaySize();
    this.hideSelectBoxes();
    new Effect.Appear('RB_overlay', {duration: 0.4, to: 0.6, queue: 'end'});
  },

  setOverlaySize: function()
  {
    if (window.innerHeight && window.scrollMaxY)
    {  
      yScroll = window.innerHeight + window.scrollMaxY;
    } 
    else if (document.body.scrollHeight > document.body.offsetHeight)
    { // all but Explorer Mac
      yScroll = document.body.scrollHeight;
    }
    else
    { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
      yScroll = document.body.offsetHeight;
    }
    $("RB_overlay").style['height'] = yScroll +"px";
  },

  setWindowPositions: function()
  {
    this.setWindowPosition('RB_window');
  },

  setWindowPosition: function(window_id)
  {
		var arrayPageSize = this.getPageSize();    
		var arrayPageScroll = this.getPageScroll();
		
		var boxTop = arrayPageScroll[1] + (arrayPageSize[3] / 10);
		var boxLeft = arrayPageScroll[0];
		Element.setTop(window_id, boxTop);
		Element.setLeft(window_id, boxLeft);
  },
  
  //
  // getPageScroll()
  // Returns array with x,y page scroll values.
  // Stolen by from lightbox.js, by Lokesh Dhakar - http://www.huddletogether.com
  // Core code from - quirksmode.com
  //
  getPageScroll: function(){

  	var xScroll, yScroll;

  	if (self.pageYOffset) {
  		yScroll = self.pageYOffset;
  		xScroll = self.pageXOffset;
  	} else if (document.documentElement && document.documentElement.scrollTop){	 // Explorer 6 Strict
  		yScroll = document.documentElement.scrollTop;
  		xScroll = document.documentElement.scrollLeft;
  	} else if (document.body) {// all other Explorers
  		yScroll = document.body.scrollTop;
  		xScroll = document.body.scrollLeft;	
  	}

  	arrayPageScroll = new Array(xScroll,yScroll) 
  	return arrayPageScroll;
  },  
  
  //
  // getPageSize()
  // Returns array with page width, height and window width, height
  // Stolen by from lightbox.js, by Lokesh Dhakar - http://www.huddletogether.com
  // Core code from - quirksmode.com
  // Edit for Firefox by pHaez
  //
  getPageSize: function() {

  	var xScroll, yScroll;

  	if (window.innerHeight && window.scrollMaxY) {	
  		xScroll = window.innerWidth + window.scrollMaxX;
  		yScroll = window.innerHeight + window.scrollMaxY;
  	} else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
  		xScroll = document.body.scrollWidth;
  		yScroll = document.body.scrollHeight;
  	} else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
  		xScroll = document.body.offsetWidth;
  		yScroll = document.body.offsetHeight;
  	}

  	var windowWidth, windowHeight;

  //	console.log(self.innerWidth);
  //	console.log(document.documentElement.clientWidth);

  	if (self.innerHeight) {	// all except Explorer
  		if(document.documentElement.clientWidth){
  			windowWidth = document.documentElement.clientWidth; 
  		} else {
  			windowWidth = self.innerWidth;
  		}
  		windowHeight = self.innerHeight;
  	} else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
  		windowWidth = document.documentElement.clientWidth;
  		windowHeight = document.documentElement.clientHeight;
  	} else if (document.body) { // other Explorers
  		windowWidth = document.body.clientWidth;
  		windowHeight = document.body.clientHeight;
  	}	

  	// for small pages with total height less then height of the viewport
  	if(yScroll < windowHeight){
  		pageHeight = windowHeight;
  	} else { 
  		pageHeight = yScroll;
  	}

  //	console.log("xScroll " + xScroll)
  //	console.log("windowWidth " + windowWidth)

  	// for small pages with total width less then width of the viewport
  	if(xScroll < windowWidth){	
  		pageWidth = xScroll;		
  	} else {
  		pageWidth = windowWidth;
  	}
  //	console.log("pageWidth " + pageWidth)

  	arrayPageSize = new Array(pageWidth,pageHeight,windowWidth,windowHeight) 
  	return arrayPageSize;
  },

  removeChildrenFromNode: function(node)
  {
    while (node.hasChildNodes())
    {
      node.removeChild(node.firstChild);
    }
  },

  moveChildren: function(source, destination)
  {
    while (source.hasChildNodes())
    {
      destination.appendChild(source.firstChild);
    }
  },

  cloneWindowContents: function(id)
  {
    var content = $(id).cloneNode(true);
    content.style['display'] = 'block';
    $('RB_window').appendChild(content);  

    this.setWindowPositions();
  },
  
  hideSelectBoxes: function()
  {
  	selects = document.getElementsByTagName("select");
  	for (i = 0; i != selects.length; i++) {
  		selects[i].style.visibility = "hidden";
  	}
  },

  showSelectBoxes: function()
  {
  	selects = document.getElementsByTagName("select");
  	for (i = 0; i != selects.length; i++) {
  		selects[i].style.visibility = "visible";
  	}
  }



}