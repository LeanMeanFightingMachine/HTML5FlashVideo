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

package uk.co.lmfm.display.video
{
	import uk.co.lmfm.display.video.events.VideoEvent;
	import uk.co.lmfm.display.video.events.VideoProgressEvent;
	import uk.co.lmfm.util.FlashJavascriptBridge;
	import uk.co.lmfm.util.events.FlashJavascriptBridgeEvent;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	/**
	 * @author Fraser Hobbs
	 * @version 1.00
	 * 
	 * VideoController : Base class for controlling video with javascript
	 */
	 
	public class VideoController extends Sprite
	{
		//	----------------------------------------------------------------
		//	PRIVATE VARIABLES
		//	----------------------------------------------------------------
		
		private var _video:Video = new Video();
		private var _autoplay:Boolean;
		private var _preload:Boolean;
		private var _poster:Loader = new Loader();
		private var _posterDimensions:Boolean = false;
		private var _videoDimensions:Boolean = false;
		
		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		public function VideoController()
		{
			_autoplay = loaderInfo.parameters.autoplay == "true";
			_preload = loaderInfo.parameters.preload == "true";
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_video.smoothing = true;
			_video.addEventListener(VideoEvent.CAN_PLAY_THROUGH, canPlayThroughHandler);
			_video.addEventListener(VideoEvent.LOAD_START, loadStartHandler);
			_video.addEventListener(VideoEvent.ENDED, endedHandler);
			_video.addEventListener(VideoEvent.RESIZE, videoResizeHandler);
			_video.addEventListener(VideoEvent.PLAYING, videoPlayingHandler);
			_video.addEventListener(VideoEvent.ERROR, videoErrorHandler);
			_video.addEventListener(VideoProgressEvent.PROGRESS, progressHandler);
			_video.source = videoURI();
			_video.visible = false;
			
			addChild(_poster);
			addChild(_video);
			
			if(loaderInfo.parameters.poster)
			{
				_poster.contentLoaderInfo.addEventListener(Event.COMPLETE, posterLoadCompleteHandler);
				_poster.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, posterIOErrorHandler);
				_poster.load(new URLRequest(loaderInfo.parameters.poster));
			}
			else
			{
				if(_autoplay)
				{
					_video.play();
				}
				else if(_preload)
				{
					_video.load();
				}
			}
			
			FlashJavascriptBridge.connect(loaderInfo.parameters.bridgeID, flashJavascriptBridgeFail);
			FlashJavascriptBridge.addEventListener("play",play);
			FlashJavascriptBridge.addEventListener("stop",stop);
			FlashJavascriptBridge.addEventListener("pause",pause);
			FlashJavascriptBridge.addEventListener("seek",seek);
			FlashJavascriptBridge.addEventListener("seekPercent",seekPercent);
			FlashJavascriptBridge.addEventListener("scrubStart",scrubStart);
			FlashJavascriptBridge.addEventListener("scrubStop",scrubStop);
			
			stage.addEventListener(Event.RESIZE, resizeHandler);
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------
		
		private function play(event:FlashJavascriptBridgeEvent):void
		{
			_video.play();
		}
		
		private function pause(event:FlashJavascriptBridgeEvent):void
		{
			_video.pause();
		}
		
		private function stop(event:FlashJavascriptBridgeEvent):void
		{
			_video.stop();
		}
		
		private function scrubStart(event:FlashJavascriptBridgeEvent):void
		{
			_video.scrubStart(event.data.time);
		}
		
		private function scrubStop(event:FlashJavascriptBridgeEvent):void
		{
			_video.scrubStop();
		}
		
		private function seek(event:FlashJavascriptBridgeEvent):void
		{
			_video.seek(event.data.time);
		}
		
		private function seekPercent(event:FlashJavascriptBridgeEvent):void
		{
			_video.seekPercent(event.data.percent);
		}
		
		private function videoURI():String
		{
			var video:String = loaderInfo.parameters.video;
			if(video.indexOf("/") != 0 && video.indexOf("file://") < 0 && video.indexOf("http://") < 0 && video.indexOf("https://") < 0)
			{
				var html:String = loaderInfo.parameters.location;
				html = html.substring(0,html.lastIndexOf("/"));
				
				while(video.indexOf("../") > -1)
				{
					video = video.substring(3,video.length);
					html = html.substring(0,html.lastIndexOf("/"));
				}
				
				video = html + "/" + video;
			}
			
			return video;
		}
		
		private function resizePoster():void
		{
			var wr:Number = _poster.loaderInfo.width / stage.stageWidth;
			var hr:Number = _poster.loaderInfo.height / stage.stageHeight;
			
			var r:Number = wr > hr ? wr : hr;
			
			_poster.width = _poster.loaderInfo.width / r;
			_poster.height = _poster.loaderInfo.height / r;
			
			_poster.x = (stage.stageWidth - _poster.width) / 2;
			_poster.y = (stage.stageHeight - _poster.height) / 2;
		}
		
		private function resizeVideo():void
		{
			var wr:Number = _video.videoWidth / stage.stageWidth;
			var hr:Number = _video.videoHeight / stage.stageHeight;
			
			var r:Number = wr > hr ? wr : hr;
			
			_video.width = _video.videoWidth / r;
			_video.height = _video.videoHeight / r;
			
			_video.x = (stage.stageWidth - _video.width) / 2;
			_video.y = (stage.stageHeight - _video.height) / 2;
		}
		
		private function flashJavascriptBridgeFail(error:Error):void
		{
			
		}
		
		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------

		private function videoErrorHandler(event : VideoEvent) : void
		{
			FlashJavascriptBridge.dispatchEvent(new FlashJavascriptBridgeEvent("error"));
		}
		
		private function progressHandler(event : VideoProgressEvent) : void
		{
			var data:Object = {};
			data.currentTime = event.currentTime;
			data.duration = event.duration;
			data.loaded = event.loaded;
			
			FlashJavascriptBridge.dispatchEvent(new FlashJavascriptBridgeEvent("progress",data));
		}

		private function posterIOErrorHandler(event : IOErrorEvent) : void
		{
			if(_autoplay)
			{
				_video.play();
			}
			else if(_preload)
			{
				_video.load();
			}
		}

		private function loadStartHandler(event : VideoEvent) : void
		{
			FlashJavascriptBridge.dispatchEvent(new FlashJavascriptBridgeEvent("loadstart"));
		}

		private function videoPlayingHandler(event : VideoEvent) : void
		{
			FlashJavascriptBridge.dispatchEvent(new FlashJavascriptBridgeEvent("playing"));
			_video.visible = true;
			_poster.visible = false;
		}

		private function posterLoadCompleteHandler(event : Event) : void
		{
			_posterDimensions = true;
			resizePoster();
			
			if(_autoplay)
			{
				_video.play();
			}
			else if(_preload)
			{
				_video.load();
			}
		}

		private function videoResizeHandler(event : VideoEvent) : void
		{
			_videoDimensions = true;
			resizeVideo();
		}

		private function resizeHandler(event : Event) : void
		{
			if(_videoDimensions) resizeVideo();
			if(_posterDimensions) resizePoster();
		}
		
		private function endedHandler(event:VideoEvent):void
		{
			FlashJavascriptBridge.dispatchEvent(new FlashJavascriptBridgeEvent("ended"));
		}

		private function canPlayThroughHandler(event:VideoEvent):void
		{
			event.target.removeEventListener(VideoEvent.CAN_PLAY_THROUGH, canPlayThroughHandler);
			
			FlashJavascriptBridge.dispatchEvent(new FlashJavascriptBridgeEvent("canplaythrough"));
			
			if(!_posterDimensions)
			{
				_video.visible = true;
			}
		}
	}
}
