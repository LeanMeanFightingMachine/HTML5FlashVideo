HTML5 / Flash video player
==========================

About
-----

A jQuery plugin for creating cross browser [HTML5 video](http://www.whatwg.org/specs/web-apps/current-work/multipage/video.html) with Flash fallback.

API
---

### Initialise DOM elements specified by the passed selectors

    $("video").video({"swf":"swf/video.swf"});

**Optional arguments:**
 *	swf (type: String, default: video.swf) Path to the video swf. 
 *	video (type: String, default: video.m4v) Video to play if the src attribute is unavailable. 
 *	params (type: Object) Flash params:
    *   height (type: String, default: 100%)
    *   width (type: String, default: 100%)
    *   menu (type: String, default: false)
    *   allowscriptaccess (type: String, default: always)
    *   wmode (type: String, default: transparent)
    *   quality (type: String, default: high)

### Bind to video state change event

    $("#videoPlayer").bind("stateChange", stateChangeHandler);
    
    stateChangeHandler = function(event)
    {
		log("state : " + event.state);
    };

### Bind to video progress event

    $("#videoPlayer").bind("videoProgress", progressHandler);
    progressHandler = function(event)
    {
    	log("currentTime : " + event.currentTime);
    	log("duration : " + event.duration);
    	log("loaded : " + event.loaded);
    };

### Play video

    $("#videoPlayer").video("play");

### Pause video

    $("#videoPlayer").video("pause");

### Stop video

    $("#videoPlayer").video("stop");

### Seek (in milliseconds) video

    $("#videoPlayer").video("seek", 4000);

### Seek to percent of video duration (fraction of 1)

    $("#videoPlayer").video("seekPercent", 0.5);

### Scrub through the video at defined increment (in milliseconds) every 100 milliseconds. Use negative number for going backwards.

    $("#videoPlayer").video("scrubStart", 500);

### Stop scrubbing through the video

    $("#videoPlayer").video("scrubStop");

### Get video state (waiting,ready,ended,loading,playing,paused)

    $("#videoPlayer").video("getState");

### Get playback mode (html5,flash,no)

    $("#videoPlayer").video("getPlayback");