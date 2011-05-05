/*
ModalBox - The pop-up window thingie with AJAX, based on prototype and script.aculo.us.

Copyright Andrey Okonetchnikov (andrej.okonetschnikow@gmail.com), 2006-2007
All rights reserved.
 
VERSION 1.5.5
Last Modified: 09/06/2007
*/

if (!window.Modalbox)
	var Modalbox = new Object();

Modalbox.Methods = {
	overrideAlert: false, // Override standard browser alert message with ModalBox
	focusableElements: new Array,
	options: {
		title: "ModalBox Window", // Title of the ModalBox window
		overlayClose: true, // Close modal box by clicking on overlay
		width: 500, // Default width in px
		height: 90, // Default height in px
		overlayOpacity: .75, // Default overlay opacity
		overlayDuration: .1, // Default overlay fade in/out duration in seconds
		slideDownDuration: 0, // Default Modalbox appear slide down effect in seconds
		slideUpDuration: 0, // Default Modalbox hiding slide up effect in seconds
		resizeDuration: 0, // Default resize duration seconds
		inactiveFade: true, // Fades MB window on inactive state
		transitions: true, // Toggles transition effects. Transitions are enabled by default
		loadingString: "Please wait. Loading...", // Default loading string message
		closeString: "Close window", // Default title attribute for close window link
		params: {},
		method: 'get' // Default Ajax request method
	},
	_options: new Object,
	
	setOptions: function(options) {
		Object.extend(this.options, options || {});
	},
	
	_init: function(options) {
	document.body.style.cursor = 'wait';
		// Setting up original options with default options
		Object.extend(this._options, this.options);
		this.setOptions(options);
		//Create the overlay
		this.MBoverlay = Builder.node("div", { id: "MB_overlay", opacity: "0" });
		//Create the window
		this.MBwindow = Builder.node("div", {id: "MB_window", style: "display: none"}, [
			this.MBframe = Builder.node("div", {id: "MB_frame"}, [
				this.MBheader = Builder.node("div", {id: "MB_header"}, [
					this.MBcaption = Builder.node("div", {id: "MB_caption"}),
					this.MBclose = Builder.node("a", {id: "MB_close", title: this.options.closeString, href: "#"}, [
						Builder.build("<span>&times;</span>"),
					]),
				]),
				this.MBcontent = Builder.node("div", {id: "MB_content"}, [
					this.MBloading = Builder.node("div", {id: "MB_loading"}, this.options.loadingString),
				]),
			]),
		]);
		// Inserting into DOM
		document.body.insertBefore(this.MBwindow, document.body.childNodes[0]);
		document.body.insertBefore(this.MBoverlay, document.body.childNodes[0]);

		// Initial scrolling position of the window. To be used for remove scrolling effect during ModalBox appearing
		this.initScrollX = window.pageXOffset || document.body.scrollLeft || document.documentElement.scrollLeft;
		this.initScrollY = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;
		
		//Adding event observers
		this.hide = this.hide.bindAsEventListener(this);
		this.close = this._hide.bindAsEventListener(this);
		this.kbdHandler = this.kbdHandler.bindAsEventListener(this);
		this._initObservers();

		this.initialized = true; // Mark as initialized
		this.active = true; // Mark as active
		this.currFocused = 0;
	},
	
	show: function(content, options) {
		if(!this.initialized) this._init(options); // Check for is already initialized
		
		this.content = content;
		this.setOptions(options);
		
		Element.update(this.MBcaption, this.options.title); // Updating title of the MB
		
		if(this.MBwindow.style.display == "none") { // First modal box appearing
			this._appear();
			this.event("onShow"); // Passing onShow callback
		}
		else { // If MB already on the screen, update it
			this._update();
			this.event("onUpdate"); // Passing onUpdate callback
		} 
	},
	
	hide: function(options) { // External hide method to use from external HTML and JS
		if(this.initialized) {
			if(options) Object.extend(this.options, options); // Passing callbacks
			if(this.options.transitions){
				Effect.SlideUp(this.MBwindow, { duration: this.options.slideUpDuration, afterFinish: this._deinit.bind(this) } );
				document.body.style.cursor = 'default';
				}
			else {
				Element.hide(this.MBwindow);
				this._deinit();
			}
		} else throw("Modalbox isn't initialized");
	},
	
	alert: function(message){
		var html = '<div class="MB_alert"><p>' + message + '</p><input type="button" onclick="Modalbox.hide()" value="OK" /></div>';
		Modalbox.show(html, {title: 'Alert: ' + document.title, width: 300});
	},
		
	_hide: function(event) { // Internal hide method to use inside MB class
		if(event) Event.stop(event);
		this.hide();
	},
	
	_appear: function() { // First appearing of MB
		if (navigator.appVersion.match(/\bMSIE\b/))
			this._toggleSelects();
		this._setOverlay();
		this._setWidth();
		this._setPosition();
		if(this.options.transitions) {
			Element.setStyle(this.MBoverlay, {opacity: 0});
			new Effect.Fade(this.MBoverlay, {
					from: 0, 
					to: this.options.overlayOpacity, 
					duration: this.options.overlayDuration, 
					afterFinish: function() {
						new Effect.SlideDown(this.MBwindow, {
							duration: this.options.slideDownDuration, 
							afterFinish: function(){ 
								this._setPosition(); 
								this.loadContent();
							}.bind(this)
						});
					}.bind(this)
			});
		} else {
			Element.setStyle(this.MBoverlay, {opacity: this.options.overlayOpacity});
			Element.show(this.MBwindow);
			this._setPosition(); 
			this.loadContent();
		}
		this._setWidthAndPosition = this._setWidthAndPosition.bindAsEventListener(this);
		Event.observe(window, "resize", this._setWidthAndPosition);
	},
	
	resize: function(byWidth, byHeight, options) { // Change size of MB without loading content
		var wHeight = Element.getHeight(this.MBwindow);
		var wWidth = Element.getWidth(this.MBwindow);
		var hHeight = Element.getHeight(this.MBheader);
		var cHeight = Element.getHeight(this.MBcontent);
		var newHeight = ((wHeight - hHeight + byHeight) < cHeight) ? (cHeight + hHeight - wHeight) : byHeight;
		this.setOptions(options); // Passing callbacks
		if(this.options.transitions) {
			new Effect.ScaleBy(this.MBwindow, byWidth, newHeight, {
					duration: this.options.resizeDuration, 
				  	afterFinish: function() { 
						this.event("_afterResize"); // Passing internal callback
						this.event("afterResize"); // Passing callback
					}.bind(this)
				});
		} else {
			this.MBwindow.setStyle({width: wWidth + byWidth + "px", height: wHeight + newHeight + "px"});
			setTimeout(function() {
				this.event("_afterResize"); // Passing internal callback
				this.event("afterResize"); // Passing callback
			}.bind(this), 1);
			
		}
		
	},
	
	_update: function() { // Updating MB in case of wizards
		Element.update(this.MBcontent, "");
		this.MBcontent.appendChild(this.MBloading);
		Element.update(this.MBloading, this.options.loadingString);
		this.currentDims = [this.MBwindow.offsetWidth, this.MBwindow.offsetHeight];
		Modalbox.resize((this.options.width - this.currentDims[0]), (this.options.height - this.currentDims[1]), {_afterResize: this._loadAfterResize.bind(this) });
	},
	
	loadContent: function () {
		if(this.event("beforeLoad") != false) { // If callback passed false, skip loading of the content
			if(typeof this.content == 'string') {
				
				var htmlRegExp = new RegExp(/<\/?[^>]+>/gi);
				if(htmlRegExp.test(this.content)) { // Plain HTML given as a parameter
					this._insertContent(this.content);
					this._putContent();
				} else 
					new Ajax.Request( this.content, { method: this.options.method.toLowerCase(), parameters: this.options.params, 
						onComplete: function(transport) {
							var response = new String(transport.responseText);
							this._insertContent(transport.responseText.stripScripts());
							response.extractScripts().map(function(script) { 
								return eval(script.replace("<!--", "").replace("// -->", ""));
							}.bind(window));
							this._putContent();
						}.bind(this)
					});
					
			} else if (typeof this.content == 'object') {// HTML Object is given
				this._insertContent(this.content);
				this._putContent();
			} else {
				Modalbox.hide();
				throw('Please specify correct URL or HTML element (plain HTML or object)');
			}
		}
	},
	
	_insertContent: function(content){
		Element.extend(this.MBcontent);
		this.MBcontent.update("");
		if(typeof content == 'string')
			this.MBcontent.hide().update(content);
		else if (typeof this.content == 'object') { // HTML Object is given
			var _htmlObj = content.cloneNode(true); // If node already a part of DOM we'll clone it
			// If clonable element has ID attribute defined, modifying it to prevent duplicates
			if(this.content.id) this.content.id = "MB_" + this.content.id;
			/* Add prefix for IDs on all elements inside the DOM node */
			this.content.getElementsBySelector('*[id]').each(function(el){ el.id = "MB_" + el.id });
			this.MBcontent.hide().appendChild(_htmlObj);
			this.MBcontent.down().show(); // Toggle visibility for hidden nodes
		}
	},
	
	_putContent: function(){
		// Prepare and resize modal box for content
		if(this.options.height == this._options.height)
			Modalbox.resize(0, this.MBcontent.getHeight() - Element.getHeight(this.MBwindow) + Element.getHeight(this.MBheader), {
				afterResize: function(){
					this.MBcontent.show();
					this.focusableElements = this._findFocusableElements();
					this._setFocus(); // Setting focus on first 'focusable' element in content (input, select, textarea, link or button)
					this.event("afterLoad"); // Passing callback
				}.bind(this)
			});
		else { // Height is defined. Creating a scrollable window
			this._setWidth();
			this.MBcontent.setStyle({overflow: 'auto', height: Element.getHeight(this.MBwindow) - Element.getHeight(this.MBheader) - 13 + 'px'});
			this.MBcontent.show();
			this.focusableElements = this._findFocusableElements();
			this._setFocus(); // Setting focus on first 'focusable' element in content (input, select, textarea, link or button)
			this.event("afterLoad"); // Passing callback
		}
	},
	
	activate: function(options){
		this.setOptions(options);
		this.active = true;
		Event.observe(this.MBclose, "click", this.close);
		if(this.options.overlayClose) Event.observe(this.MBoverlay, "click", this.hide);
		Element.show(this.MBclose);
		if(this.options.transitions && this.options.inactiveFade) new Effect.Appear(this.MBwindow, {duration: this.options.slideUpDuration});
	},
	
	deactivate: function(options) {
		this.setOptions(options);
		this.active = false;
		Event.stopObserving(this.MBclose, "click", this.close);
		if(this.options.overlayClose) Event.stopObserving(this.MBoverlay, "click", this.hide);
		Element.hide(this.MBclose);
		if(this.options.transitions && this.options.inactiveFade) new Effect.Fade(this.MBwindow, {duration: this.options.slideUpDuration, to: .75});
	},
	
	_initObservers: function(){
		Event.observe(this.MBclose, "click", this.close);
		if(this.options.overlayClose) Event.observe(this.MBoverlay, "click", this.hide);
		Event.observe(document, "keypress", Modalbox.kbdHandler );
	},
	
	_removeObservers: function(){
		Event.stopObserving(this.MBclose, "click", this.close);
		if(this.options.overlayClose) Event.stopObserving(this.MBoverlay, "click", this.hide);
		Event.stopObserving(document, "keypress", Modalbox.kbdHandler );
	},
	
	_loadAfterResize: function() {
		this._setWidth();
		this._setPosition();
		this.loadContent();
	},
	
	_setFocus: function() { // Setting focus to be looped inside current MB
		if(this.focusableElements.length > 0) {
			var i = 0;
			var firstEl = this.focusableElements.find(function findFirst(el){
				i++;
				return el.tabIndex == 1;
			}) || this.focusableElements.first();
			this.currFocused = (i == this.focusableElements.length - 1) ? (i-1) : 0;
			firstEl.focus(); // Focus on first focusable element except close button
		} else
			$("MB_close").focus(); // If no focusable elements exist focus on close button
	},
	
	_findFocusableElements: function(){ // Collect form elements or links from MB content
		document.body.style.cursor = 'default';
		var els = this.MBcontent.getElementsBySelector('input:not([type~=hidden]), select, textarea, button, a[href]');
		els.invoke('addClassName', 'MB_focusable');
		return this.MBcontent.getElementsByClassName('MB_focusable');
	},
	
	kbdHandler: function(e) {
		var node = Event.element(e);
		switch(e.keyCode) {
			case Event.KEY_TAB:
				Event.stop(e);
				if(!e.shiftKey) { //Focusing in direct order
					if(this.currFocused == this.focusableElements.length - 1) {
						this.focusableElements.first().focus();
						this.currFocused = 0;
					} else {
						this.currFocused++;
						this.focusableElements[this.currFocused].focus();
					}
				} else { // Shift key is pressed. Focusing in reverse order
					if(this.currFocused == 0) {
						this.focusableElements.last().focus();
						this.currFocused = this.focusableElements.length - 1;
					} else {
						this.currFocused--;
						this.focusableElements[this.currFocused].focus();
					}
				}
				break;			
			case Event.KEY_ESC:
				if(this.active) this._hide(e);
				break;
			case 32:
				this._preventScroll(e);
				break;
			case 0: // For Gecko browsers compatibility
				if(e.which == 32) this._preventScroll(e);
				break;
			case Event.KEY_UP:
			case Event.KEY_DOWN:
			case Event.KEY_PAGEDOWN:
			case Event.KEY_PAGEUP:
			case Event.KEY_HOME:
			case Event.KEY_END:
				// Safari operates in slightly different way. This realization is still buggy in Safari.
				if(/Safari|KHTML/.test(navigator.userAgent) && !["textarea", "select"].include(node.tagName.toLowerCase()))
					Event.stop(e);
				else if( (node.tagName.toLowerCase() == "input" && ["submit", "button"].include(node.type)) || (node.tagName.toLowerCase() == "a") )
					Event.stop(e);
				break;
		}
	},
	
	_preventScroll: function(event) { // Disabling scrolling by "space" key
		if(!["input", "textarea", "select", "button"].include(Event.element(event).tagName.toLowerCase())) 
			Event.stop(event);
	},
	
	_deinit: function()
	{	
		this._removeObservers();
		Event.stopObserving(window, "resize", this._setWidthAndPosition );
		if(this.options.transitions) {
			Effect.toggle(this.MBoverlay, 'appear', {duration: this.options.overlayDuration, afterFinish: this._removeElements.bind(this) });
		} else {
			this.MBoverlay.hide();
			this._removeElements();
		}
		Element.setStyle(this.MBcontent, {overflow: '', height: ''});
	},
	
	_removeElements: function () {
		if (navigator.appVersion.match(/\bMSIE\b/)) {
			this._prepareIE("", ""); // If set to auto MSIE will show horizontal scrolling
			window.scrollTo(this.initScrollX, this.initScrollY);
		}
		Element.remove(this.MBoverlay);
		Element.remove(this.MBwindow);
		
		/* Replacing prefixes 'MB_' in IDs for the original content */
		if(typeof this.content == 'object' && this.content.id && this.content.id.match(/MB_/)) {
			this.content.getElementsBySelector('*[id]').each(function(el){ el.id = el.id.replace(/MB_/, ""); });
			this.content.id = this.content.id.replace(/MB_/, "");
		}
		/* Initialized will be set to false */
		this.initialized = false;
		
		if (navigator.appVersion.match(/\bMSIE\b/))
			this._toggleSelects(); // Toggle back 'select' elements in IE
		this.event("afterHide"); // Passing afterHide callback
		this.setOptions(this._options); //Settings options object into intial state
	},
	
	_setOverlay: function () {
		if (navigator.appVersion.match(/\bMSIE\b/)) {
			this._prepareIE("100%", "hidden");
			if (!navigator.appVersion.match(/\b7.0\b/)) window.scrollTo(0,0); // Disable scrolling on top for IE7
		}
	},
	
	_setWidth: function () { //Set size
		Element.setStyle(this.MBwindow, {width: this.options.width + "px", height: this.options.height + "px"});
	},
	
	_setPosition: function () {
		Element.setStyle(this.MBwindow, {left: Math.round((Element.getWidth(document.body) - Element.getWidth(this.MBwindow)) / 2 ) + "px"});
	},
	
	_setWidthAndPosition: function () {
		Element.setStyle(this.MBwindow, {width: this.options.width + "px"});
		this._setPosition();
	},
	
	_getScrollTop: function () { //From: http://www.quirksmode.org/js/doctypes.html
		var theTop;
		if (document.documentElement && document.documentElement.scrollTop)
			theTop = document.documentElement.scrollTop;
		else if (document.body)
			theTop = document.body.scrollTop;
		return theTop;
	},
	// For IE browsers -- IE requires height to 100% and overflow hidden (taken from lightbox)
	_prepareIE: function(height, overflow){
		var body = document.getElementsByTagName('body')[0];
		body.style.height = height;
		body.style.overflow = overflow;
  
		var html = document.getElementsByTagName('html')[0];
		html.style.height = height;
		html.style.overflow = overflow; 
	},
	// For IE browsers -- hiding all SELECT elements
	_toggleSelects: function() {
		var selects = $$("select");
		if(this.initialized) {
			selects.invoke('setStyle', {'visibility': 'hidden'});
		} else {
			selects.invoke('setStyle', {'visibility': ''});
		}
			
	},
	event: function(eventName) {
		if(this.options[eventName]) {
			var returnValue = this.options[eventName](); // Executing callback
			this.options[eventName] = null; // Removing callback after execution
			if(returnValue != undefined) 
				return returnValue;
			else 
				return true;
		}
		return true;
	}
}

Object.extend(Modalbox, Modalbox.Methods);

if(Modalbox.overrideAlert) window.alert = Modalbox.alert;

Effect.ScaleBy = Class.create();
Object.extend(Object.extend(Effect.ScaleBy.prototype, Effect.Base.prototype), {
  initialize: function(element, byWidth, byHeight, options) {
    this.element = $(element)
    var options = Object.extend({
	  scaleFromTop: true,
      scaleMode: 'box',        // 'box' or 'contents' or {} with provided values
      scaleByWidth: byWidth,
	  scaleByHeight: byHeight
    }, arguments[3] || {});
    this.start(options);
  },
  setup: function() {
    this.elementPositioning = this.element.getStyle('position');
      
    this.originalTop  = this.element.offsetTop;
    this.originalLeft = this.element.offsetLeft;
	
    this.dims = null;
    if(this.options.scaleMode=='box')
      this.dims = [this.element.offsetHeight, this.element.offsetWidth];
	 if(/^content/.test(this.options.scaleMode))
      this.dims = [this.element.scrollHeight, this.element.scrollWidth];
    if(!this.dims)
      this.dims = [this.options.scaleMode.originalHeight,
                   this.options.scaleMode.originalWidth];
	  
	this.deltaY = this.options.scaleByHeight;
	this.deltaX = this.options.scaleByWidth;
  },
  update: function(position) {
    var currentHeight = this.dims[0] + (this.deltaY * position);
	var currentWidth = this.dims[1] + (this.deltaX * position);
	
	currentHeight = (currentHeight > 0) ? currentHeight : 0;
	currentWidth = (currentWidth > 0) ? currentWidth : 0;
	
    this.setDimensions(currentHeight, currentWidth);
  },

  setDimensions: function(height, width) {
    var d = {};
    d.width = width + 'px';
    d.height = height + 'px';
    
	var topd  = Math.round((height - this.dims[0])/2);
	var leftd = Math.round((width  - this.dims[1])/2);
	if(this.elementPositioning == 'absolute' || this.elementPositioning == 'fixed') {
		if(!this.options.scaleFromTop) d.top = this.originalTop-topd + 'px';
		d.left = this.originalLeft-leftd + 'px';
	} else {
		if(!this.options.scaleFromTop) d.top = -topd + 'px';
		d.left = -leftd + 'px';
	}
    this.element.setStyle(d);
  }
});