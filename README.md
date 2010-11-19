HTML5 / Flash video player
==========================

About
-----

A jQuery plugin for creating cross browser [HTML5 video](http://www.whatwg.org/specs/web-apps/current-work/multipage/video.html) with Flash fallback.

API
---

### Initialise DOM elements specified by the passed selectors
<code>
    $("video").video({"swf":"swf/video.swf"});
</code>

Optional arguments:
swf (type: String, default: video.swf) Path to the video swf. 
video (type: String, default: video.m4v) Video to play if the src attribute is unavailable. 
params (type: Object) Flash params
height (type: String, default: 100%)
width (type: String, default: 100%)
menu (type: String, default: false)
allowscriptaccess (type: String, default: always)
wmode (type: String, default: transparent)
quality (type: String, default: high)

### Bind to video state change event

<code>    $("#videoPlayer").bind("stateChange", stateChangeHandler);
    stateChangeHandler = function(event)
    {
	log("state : " + event.state);
    };
</code>

### Bind to video progress event

<code>
    $("#videoPlayer").bind("videoProgress", progressHandler);
    progressHandler = function(event)
    {
    	log("currentTime : " + event.currentTime);
    	log("duration : " + event.duration);
    	log("loaded : " + event.loaded);
    };
</code>

### Play video

<code>
    $("#videoPlayer").video("play");
</code>

### Pause video

<code>
    $("#videoPlayer").video("pause");
</code>

### Stop video

<code>
    $("#videoPlayer").video("stop");
</code>

### Seek (in milliseconds) video

<code>
    $("#videoPlayer").video("seek", 4000);
</code>

### Seek to percent of video duration (fraction of 1)

<code>
    $("#videoPlayer").video("seekPercent", 0.5);
</code>

### Scrub through the video at defined increment (in milliseconds) every 100 milliseconds. Use negative number for going backwards.

<code>
    $("#videoPlayer").video("scrubStart", 500);
</code>

### Stop scrubbing through the video

<code>
    $("#videoPlayer").video("scrubStop");
</code>

### Get video state (waiting,ready,ended,loading,playing,paused)

<code>
    $("#videoPlayer").video("getState");
</code>

### Get playback mode (html5,flash,no)

<code>
    $("#videoPlayer").video("getPlayback");
</code>