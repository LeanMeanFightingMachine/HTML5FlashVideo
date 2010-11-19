/**
* Copyright (c) 2010 Lean Mean Fighting Machine Ltd
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

/**
 * @author Fraser Hobbs
 * @version 1.00
 * 
 * jquery.video : A jQuery plugin that wraps up the functionality of the HTML5 video object and handles falling back to flash if required
 * 
 * @example
 * Initialise DOM elements specified by the passed selectors
 * <listing version="1.0">
 * $("video").video({"swf":"swf/video.swf"});
 * </listing>
 * 
 * Optional arguments:
 * swf (type: String, default: video.swf) Path to the video swf. 
 * video (type: String, default: video.m4v) Video to play if the src attribute is unavailable. 
 * params (type: Object) Flash params
 * 	height (type: String, default: 100%)
 *	width (type: String, default: 100%)
 *	menu (type: String, default: false)
 *	allowscriptaccess (type: String, default: always)
 *	wmode (type: String, default: transparent)
 *	quality (type: String, default: high)
 * 
 * 
 * Bind to video state change event
 * <listing version="1.0">
 * $("#videoPlayer").bind("stateChange", stateChangeHandler);
 * stateChangeHandler = function(event)
 * {
 * 		log("state : " + event.state);
 * };
 * </listing>
 * 
 * 
 * Bind to video progress event
 * <listing version="1.0">
 * $("#videoPlayer").bind("videoProgress", progressHandler);
 * progressHandler = function(event)
 * {
 * 		log("currentTime : " + event.currentTime);
 * 		log("duration : " + event.duration);
 * 		log("loaded : " + event.loaded);
 * };
 * </listing>
 * 
 * 
 * Play video
 * <listing version="1.0">
 * $("#videoPlayer").video("play");
 * </listing>
 * 
 * 
 * Pause video
 * <listing version="1.0">
 * $("#videoPlayer").video("pause");
 * </listing>
 * 
 * 
 * Stop video
 * <listing version="1.0">
 * $("#videoPlayer").video("stop");
 * </listing>
 * 
 * 
 * Seek (in milliseconds) video
 * <listing version="1.0">
 * $("#videoPlayer").video("seek", 4000);
 * </listing>
 * 
 * 
 * Seek to percent of video duration (fraction of 1)
 * <listing version="1.0">
 * $("#videoPlayer").video("seekPercent", 0.5);
 * </listing>
 * 
 * 
 * Scrub through the video at defined increment (in milliseconds) every 100 milliseconds. Use negative number for going backwards.
 * <listing version="1.0">
 * $("#videoPlayer").video("scrubStart", 500);
 * </listing>
 * 
 * 
 * Stop scrubbing through the video
 * <listing version="1.0">
 * $("#videoPlayer").video("scrubStop");
 * </listing>
 * 
 * 
 * Get video state (waiting,ready,ended,loading,playing,paused)
 * <listing version="1.0">
 * $("#videoPlayer").video("getState");
 * </listing>
 * 
 * 
 * Get playback mode (html5,flash,no)
 * <listing version="1.0">
 * $("#videoPlayer").video("getPlayback");
 * </listing>
 */

(function( $ ){

	var WAITING_STATE = "waiting";
	var READY_STATE = "ready";
	var ENDED_STATE = "ended";
	var LOADING_STATE = "loading";
	var PLAYING_STATE = "playing";
	var PAUSED_STATE = "paused";
	
	var FLASH_PLAYBACK = "flash";
	var HTML5_PLAYBACK = "html5";
	var NO_PLAYBACK = "no";
	
	var setup = function(obj,$obj,options) {
		
		if(!options.video && $obj.attr("src"))
		{
			options.video = $obj.attr("src");
		}
		
		var settings = {
			'swf' : 'video.swf',
			'video' : 'video.m4v'
		};
		
		$.extend( settings, options );
		
		$obj.data('video', {
			target : $obj,
			state : WAITING_STATE,
			playback : NO_PLAYBACK
		});
		
		if($obj.is("video")) {
	 		if(obj.canPlayType && obj.buffered && !obj.error)
			{
				setupHTML5(obj,$obj,settings);
			}
			else if($.flash.hasVersion(10))
			{
				setupFlash(obj,$obj,settings);
			}
		}
		
		return $obj.data('video');
	};
	
	var getData = function(obj) {
		var $obj = $(obj);
		var data = $obj.data('video');
				
		if (!data) {
     		data = setup(obj,$obj);
		}
		
		return data;
	};
	
	var setupFlash = function(obj,$obj,settings) {
		
		var div = $("<div />");
		var i = $obj.attr("id");
		var c = $obj.attr("class");
		var w = obj.getAttribute("width");
		var h = obj.getAttribute("height");
		
		if(i){ div.attr("id", i); }
		if(c){ div.attr("class", c); }
		if(w){ div.css("width",w); }
		if(h){ div.css("height",h); }
		
		var params = {
			height: "100%",
			width: "100%",
			menu: "false",
			allowscriptaccess: "always",
			wmode: "transparent",
			quality: "high"
		};
		
		if(settings.params)
		{
			$.extend( params, settings.params );
		}
		
		var id = 'flash_' + Math.floor(Math.random() * 999999999);
		
		var flashvars = {};
		
		if($obj.attr("autoplay"))
		{
			flashvars.autoplay = true;				
		}
		else
		{
			flashvars.autoplay = false;
		}
		
		if($obj.attr("loop"))
		{
			flashvars.loop = true;
		}
		else
		{
			flashvars.loop = false;
		}
		
		flashvars.poster = $obj.attr("poster");
		
		flashvars.preload = false;
		
		if($obj.attr("preload") == "" || $obj.attr("preload") == "auto")
		{
			flashvars.preload = true;
		}
		
		flashvars.poster = $obj.attr("poster");
		flashvars.video = settings.video;
		flashvars.location = window.location.href;
		flashvars.bridgeID = id;
		
		var vars = {id: id, swf: settings.swf, flashvars: flashvars};
		$.extend( vars, params );
		
		//swap video for div
		$obj.replaceWith( div );
		$obj = div;
		obj = $obj[0];
		
		$obj.data('video', {
			target : $obj,
			state : WAITING_STATE,
			playback : FLASH_PLAYBACK,
			bridgeID : id
		});
		
		$obj.flash(vars);
		
		FlashJavascriptBridge.connect(id,$obj.children()[0],obj);
		FlashJavascriptBridge.addEventListener(id,"canplaythrough",canplaythroughHandler);
		FlashJavascriptBridge.addEventListener(id,"ended",endedHandler);
		FlashJavascriptBridge.addEventListener(id,"playing",playingHandler);
		FlashJavascriptBridge.addEventListener(id,"progress",flashProgressHandler);
	};
	
	var setupHTML5 = function(obj,$obj,settings) {
		
		var data = $obj.data('video');
		data.playback = HTML5_PLAYBACK;
		
		obj.addEventListener("ended", endedHandler, false);
		obj.addEventListener("playing", playingHandler, false);
		obj.addEventListener("error", errorHandler, false);
		
		if(navigator.userAgent.match(/iPad/i) || navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i))
		{
			if(obj.getAttribute("autoplay") != null)
			{
				obj.load();
				obj.play();
			}
		}
		
		if(obj.readyState == 4)
		{
			data.state = READY_STATE;
		    $obj.trigger({type:"stateChange",state:data.state});
		    
		    if(obj.autoplay)
		    {
		    	data.state = PLAYING_STATE;
			    $obj.trigger({type:"stateChange",state:data.state});
		    }
		}
		else
		{
			obj.addEventListener("loadstart", loadstartHandler, false);
			obj.addEventListener("canplaythrough", canplaythroughHandler, false);
		}
		
		$obj.everyTime(100, "progress", function() { html5ProgressHandler(this); });
	};
	
	var endedHandler = function(event) {
		
		var $obj = $(event.target);
		var data = $obj.data('video');
		
		if(data.playback == HTML5_PLAYBACK)
		{
			event.target.pause();
			event.target.currentTime = 0;
		}
		
		$obj.trigger({type:"stateChange",state:ENDED_STATE});
		data.state = READY_STATE;
		$obj.trigger({type:"stateChange",state:data.state});
	};
	
	var loadstartHandler = function(event) {
		
		var $obj = $(event.target);
		var data = $obj.data('video');
		
		data.state = LOADING_STATE;
		$obj.trigger({type:"stateChange",state:data.state});
	};
	
	var html5ProgressHandler = function(obj) {
		
		var $obj = $(obj);
		var data = $obj.data('video');
		
		var loaded = obj.buffered.length > 0 ? obj.buffered.end(0) : 0;
		
		$obj.trigger({type:"videoProgress",currentTime:Math.floor(obj.currentTime * 1000),duration:Math.floor(obj.duration * 1000),loaded:Math.floor(loaded * 1000)});
		
		if(data.state != PLAYING_STATE && loaded == obj.duration)
		{
			$obj.stopTime("progress");
		}
	}
	
	var scrubHandler = function(obj) {
		
		var $obj = $(obj);
		var data = $obj.data('video');
		
		var time = obj.currentTime + (data.scrub / 1000);
		
		if(obj.duration && time <= obj.buffered.end(0) && time >= 0)
		{
			obj.currentTime = time;
			
			var loaded = obj.buffered.length > 0 ? obj.buffered.end(0) : 0;
			if(data.state != PLAYING_STATE && loaded == obj.duration)
			{
				$obj.trigger({type:"videoProgress",currentTime:Math.floor(time * 1000),duration:Math.floor(obj.duration * 1000),loaded:Math.floor(loaded * 1000)});
			}
		}
	};
	
	var flashProgressHandler = function(event) {
		
		var $obj = $(event.target);
		
		$obj.trigger({type:"videoProgress",currentTime:event.data.currentTime,duration:event.data.duration,loaded:event.data.loaded});
	};
	
	var playingHandler = function(event) {
		
		var $obj = $(event.target);
		var data = $obj.data('video');
		
		data.state = PLAYING_STATE;
		$obj.trigger({type:"stateChange",state:data.state});
	};
	
	var pausedHandler = function(event) {
		
		var $obj = $(event.target);
		var data = $obj.data('video');
		
		data.state = PAUSED_STATE;
		$obj.trigger({type:"stateChange",state:data.state});
	};
	
	var canplaythroughHandler = function(event) {
		
		event.target.removeEventListener("canplaythrough", canplaythroughHandler, false);
		
		var $obj = $(event.target);
		var data = $obj.data('video');
		
		data.state = READY_STATE;
		$obj.trigger({type:"stateChange",state:data.state});
	};
	
	var errorHandler = function(event) {
		log("errorHandler");
	};
	
	var methods = {
		init : function(options) {
			
			return this.each(function(){
		     	var $this = $(this);
		     	
		     	var data = $this.data('video');
				
				if (!data) {
		     		setup(this,$this,options);
				}
			});
		 },
		 
		 destroy : function() {
		
			return this.each(function(){
		
				var $this = $(this);
				var data = $this.data('video');
		
		     	// Namespacing FTW
				$(window).unbind('.video');
				data.target.remove();
				$this.removeData('video');
			});
		
		 },
		 
		 play : function() {
		 	
		 	return this.each(function(){
		
				var $this = $(this);
				var data = getData(this);
				
				if(data.playback == HTML5_PLAYBACK)
				{
					this.play();
					$this.stopTime("progress");
					$this.everyTime(100, "progress", function() { html5ProgressHandler(this); });
				}
				else if(data.playback == FLASH_PLAYBACK)
				{
					FlashJavascriptBridge.dispatchEvent(data.bridgeID,new FlashJavascriptBridgeEvent("play"));
				}
			});
		 	
		 },
		 
		 stop : function() {
		 	
		 	return this.each(function(){
		
				var $this = $(this);
				var data = getData(this);
				
				if(data.playback == HTML5_PLAYBACK)
				{
					this.pause();
					this.currentTime = 0;
				}
				else if(data.playback == FLASH_PLAYBACK)
				{
					FlashJavascriptBridge.dispatchEvent(data.bridgeID,new FlashJavascriptBridgeEvent("stop"));
				}
		
		     	data.state = READY_STATE;
		     	$this.trigger({type:"stateChange",state:data.state});
			});
			
		 },
		 
		 pause : function() {
		 	
		 	return this.each(function(){
		
				var $this = $(this);
				var data = getData(this);
				
				if(data.playback == HTML5_PLAYBACK)
				{
					this.pause();
				}
				else if(data.playback == FLASH_PLAYBACK)
				{
					FlashJavascriptBridge.dispatchEvent(data.bridgeID,new FlashJavascriptBridgeEvent("pause"));
				}
		
		     	data.state = PAUSED_STATE;
		     	$this.trigger({type:"stateChange",state:data.state});
			});
		 	
		 },
		 
		 scrubStart : function(time) {
			 	
		 	return this.each(function(){
		
				var $this = $(this);
				var data = getData(this);
				$.extend( data, {scrub:time} );
				$this.data('video', data);
				
		     	if(data.playback == HTML5_PLAYBACK)
				{
		     		if(data.state == PLAYING_STATE)
		     		{
		     			this.pause();
		     		}
		     		
		     		$this.stopTime("scrub");
					$this.everyTime(100, "scrub", function() { scrubHandler(this); });
				}
		     	else if(data.playback == FLASH_PLAYBACK)
				{
					FlashJavascriptBridge.dispatchEvent(data.bridgeID,new FlashJavascriptBridgeEvent("scrubStart",{time:time}));
				}
			});
		 	
		 },
		 
		 scrubStop : function() {
			 	
		 	return this.each(function(){
		
				var $this = $(this);
				var data = getData(this);
		
		     	if(data.playback == HTML5_PLAYBACK)
				{
		     		if(data.state == PLAYING_STATE)
		     		{
		     			this.play();
		     		}
		     		
		     		$this.stopTime("scrub");
				}
		     	else if(data.playback == FLASH_PLAYBACK)
				{
					FlashJavascriptBridge.dispatchEvent(data.bridgeID,new FlashJavascriptBridgeEvent("scrubStop"));
				}
			});
		 	
		 },
		 
		 seek : function(time) {
		 	
		 	return this.each(function(){
		
				var $this = $(this);
				var data = getData(this);
		
		     	if(data.playback == HTML5_PLAYBACK)
				{
					if(this.duration && time <= this.duration && time >= 0)
					{
						this.currentTime = time / 1000;
					}
				}
		     	else if(data.playback == FLASH_PLAYBACK)
				{
					FlashJavascriptBridge.dispatchEvent(data.bridgeID,new FlashJavascriptBridgeEvent("seek",{time:time}));
				}
			});
		 	
		 },
		 
		 seekPercent : function(percent) {
		 	
		 	return this.each(function(){
		
				var $this = $(this);
				var data = getData(this);
				
				if(percent > 1 || percent < 0)
				{
					return;
				}
				
		     	if(data.playback == HTML5_PLAYBACK)
				{
					if(this.duration)
					{
						this.currentTime = this.duration * percent;
					}
				}
		     	else if(data.playback == FLASH_PLAYBACK)
				{
					FlashJavascriptBridge.dispatchEvent(data.bridgeID,new FlashJavascriptBridgeEvent("seekPercent",{percent:percent}));
				}
			});
		 	
		 },
		 
		 getState : function() {
		 	
		 	var data = getData(this);
		 	return data.state;
		 },
		 
		 getPlayback : function() {
			 	
			 var data = getData(this);
			 return data.playback;
		 }
	};

	$.fn.video = function(method) {
    
		if ( methods[method] ) {
			return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
		}
		else if ( typeof method === 'object' || ! method ) {
			return methods.init.apply( this, arguments );
		}
		else {
			$.error( 'Method ' +  method + ' does not exist on jQuery.video' );
		}
	};

})( jQuery );

// usage: log('inside coolFunc',this,arguments);
// paulirish.com/2009/log-a-lightweight-wrapper-for-consolelog/
window.log = function() {
	log.history = log.history || [];   // store logs to an array for reference
	log.history.push(arguments);
	if(this.console){
		console.log( Array.prototype.slice.call(arguments) );
	}
};

// catch all document.write() calls
(function(doc){
  var write = doc.write;
  doc.write = function(q){ 
    log('document.write(): ',arguments); 
    if (/docwriteregexwhitelist/.test(q)) write.apply(doc,arguments);  
  };
})(document);

