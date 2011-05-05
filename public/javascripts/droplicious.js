/*
droplicious v.1.0
Copyright @2009 http://headfirstproductions.ca
Author: Darren Terhune
Contributors: Jan Sovak http://canada-jack.com, Mason Meyer http://www.masonmeyer.com/
Created May 21, 2009
*/

var dropliciousShowingUpDuration = 0.3;
var dropliciousHidingDuration = 0.1;
var dropliciousHideDelay = 0;

function dropliciousShowingUpEffect(dEl){
	 if(!Element.visible(dEl))
	new Effect.BlindDown( $(dEl),  { duration: dropliciousShowingUpDuration, queue: {position: 'end', scope: dEl.id, limit:2} } );
}
function dropliciousHidingEffect(dEl){
	new Effect.BlindUp( $(dEl),  { duration: dropliciousHidingDuration, queue: {position: 'end', scope: dEl.id, limit:2 } });
}
function setDelayedHide(id){
	$(id).addClassName('waitingtohide')
	if(!$(id).hasClassName('hidding')){
		if (!$(id).hasClassName('hiddingtimerset')){	
			$(id).addClassName('hiddingtimerset');
			setTimeout("delayedHide('" + id + "')", dropliciousHideDelay * 1000);
		}
	}
}
function delayedHide(id){
	var dropElement = $(id);
	dropElement.removeClassName('hiddingtimerset');
	if ($(dropElement).hasClassName('waitingtohide')){
		dropliciousHidingEffect(dropElement);
		$(dropElement).addClassName('hidding');
		setTimeout("finishedHiding('" + id + "')",dropliciousHidingDuration * 1000);
	}
}
function finishedHiding(id){
	var dropElement = $(id);
	dropElement.removeClassName('waitingtohide');
	dropElement.removeClassName('hidding');
	dropElement.removeClassName('active');
}
function linkMouseOut(id){
	var currentElement = Event.element(id).id;
	var currentElement = $(currentElement);
	var dropElement = currentElement.next();		
	if ($(dropElement).hasClassName('active')){
		setDelayedHide($(dropElement).id);
	}
}
function linkMouseOver(id){
	var currentElement = Event.element(id).id;
	var currentElement = $(currentElement);
	var dropElement = currentElement.next();	
	if (!$(dropElement).hasClassName('hidding')){
		dropElement.removeClassName('waitingtohide');
	}
	if (!$(dropElement).hasClassName('active')){
		dropElement.addClassName('active');
		dropliciousShowingUpEffect(dropElement);
	}
}
function submenuMouseOut(id){
	var currentElement = Event.findElement(id,'ul');
	var currentElement = $(currentElement);
	var dropElement = currentElement;	
	if ($(dropElement).hasClassName('active')){
		setDelayedHide($(dropElement).id);
	}
}
function submenuMouseOver(id){
	var currentElement = Event.findElement(id,'ul');
	var currentElement = $(currentElement);
	var dropElement = currentElement;
	if (!$(dropElement).hasClassName('hidding')){
		dropElement.removeClassName('waitingtohide');
	}
}
document.observe('dom:loaded', function() {
	var dropDowns = $$('a.drops');	
	dropDowns.each(function(name) {
		name.observe('mousemove', linkMouseOver.bindAsEventListener(this));
		name.observe('mouseout', linkMouseOut.bindAsEventListener(this));
	})
	var dropDowns = $$('ul.scriptaculously');
	dropDowns.each(function(name){
		name.observe('mousemove', submenuMouseOver.bindAsEventListener(this));
		name.observe('mouseout', submenuMouseOut.bindAsEventListener(this));
	})
})