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

	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * @author Fraser Hobbs
	 * @version 1.00
	 * 
	 * Video : Extends the default class flash.media.Video and handles netstream and netconnection. Making video easier to use and match more closely the html5 functionality
	 */
	public class Video extends flash.media.Video
	{
		//	----------------------------------------------------------------
		//	PRIVATE VARIABLES
		//	----------------------------------------------------------------
		
		private var _stream:NetStream;
		private var _connection:NetConnection;
		private var _streamStatus:Array;
		private var _duration:Number;
		private var _source:String;
		private var _loadStarted:int;
		private var _safety:int = 1000;
		private var _bpms:int;
		private var _videoWidth:int;
		private var _isWaitingToPlay:Boolean = false;
		private var _isReadyToPlay:Boolean = false;
		private var _isPlaying:Boolean = false;
		private var _isBuffering:Boolean = false;
		private var _isStalled:Boolean = false;
		private var _isLoading:Boolean = false;
		private var _isPaused:Boolean = false;
		private var _client:Object = new Object();
		private var _timeLoaded:Number;
		private var _progressTimer:Timer = new Timer(100);
		private var _seek:Number;
		private var _seekPercent:Number;
		private var _seekpoints:Array = new Array();
		private var _scrubAmount:Number;
		private var _scrubPosition:Number;
		private var _scrubTimer:Timer = new Timer(100);
		
		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		public function Video()
		{
			super();
			
			_progressTimer.addEventListener(TimerEvent.TIMER, progressTimerHandler);
			_scrubTimer.addEventListener(TimerEvent.TIMER, scrubTimerHandler);
			
			_connection = new NetConnection();
			_connection.connect(null);
			
			_stream = new NetStream(_connection);
			_stream.bufferTime = 0;
			
			_client.onMetaData = onMetaData;
			_stream.client = _client;
			attachNetStream(_stream);
			
			_streamStatus = [];
			
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------
		
		public function play():void
		{
			if(_isPlaying || _isWaitingToPlay) return;
			
			if(_isBuffering)
			{
				_isWaitingToPlay = true;
			}
			else if(_isReadyToPlay)
			{
				if(_isPaused)
				{
					_isPlaying = true;
					_stream.resume();
					_progressTimer.start();
					dispatchEvent(new VideoEvent(VideoEvent.PLAYING));
				}
				else
				{
					startPlay();
				}
			}
			else
			{
				_isWaitingToPlay = true;
				startLoad();
			}
			
			_isPaused = false;
		}
		
		public function stop():void
		{
			if(_isPlaying)
			{
				_isPlaying = false;
				_stream.pause();
				_stream.seek(0);
				
				if(!_isLoading)
				{
					_progressTimer.stop();
				}
				
				dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS, 0, _duration, _timeLoaded));
			}
			else if(_isPaused)
			{
				_stream.seek(0);
				_isPaused = false;
				
				dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS, 0, _duration, _timeLoaded));
			}
			else
			{
				_isWaitingToPlay = false;
			}
		}
		
		public function pause():void
		{
			if(!_isPlaying && !_isWaitingToPlay) return;
			
			if(_isPlaying)
			{
				startPause();

				if(!_isLoading)
				{
					_progressTimer.stop();
				}
			}
			else
			{
				_isWaitingToPlay = false;
			}
		}

		public function load():void
		{
			if(!_source) return;

			startLoad();
		}
		
		public function destroy():void
		{
			clear();
			attachNetStream(null);
			
			_streamStatus = null;
			
			_client.onMetaData = null;
			_client = null;
			
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			_connection.close();
			_connection = null;
			
			_stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_stream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			_stream.close();
			_stream = null;
		}
		
		public function close():void
		{
			_stream.seek(0);
			_stream.close();
		}
		
		public function scrubStart(time:Number):void
		{
			if(_seekpoints.length > 0)
			{
				if(_isPlaying)
				{
					_stream.pause();
				}

				_scrubPosition = _stream.time * 1000;
				_scrubAmount = time;
				scrub();
				_scrubTimer.start();
			}
		}
		
		public function scrubStop():void
		{
			if(_isPlaying)
			{
				_stream.resume();
			}
			
			_scrubTimer.stop();
		}
		
		public function seek(time:Number):void
		{
			if(_duration)
			{
				seekTo(time);
			}
			else
			{
				_seek = time;
			}
		}
		
		public function seekPercent(percent:Number):void
		{
			percent = (percent > 1 ? 1 : percent) < 0 ? 0 : percent;
			
			if(_duration)
			{
				seekTo(_duration * percent);
			}
			else
			{
				_seekPercent = percent;
			}
		}

		//	----------------------------------------------------------------
		//	GETTERS/SETTERS
		//	----------------------------------------------------------------
		
		public function get loaded():Number
		{
			return _stream.bytesLoaded;
		}
		
		public function get total():Number
		{
			return _stream.bytesTotal;
		}
		
		public function get source() : String
		{
			return _source;
		}
		
		public function set updateFrequency(__updateFrequency : int) : void
		{
			_progressTimer.delay = __updateFrequency;
		}
		
		public function set source(__source : String) : void
		{
			_source = __source;
			
			if(_isPlaying || _isWaitingToPlay)
			{
				_isPlaying = false;
				_isWaitingToPlay = false;
				play();
			}
			else if(_isBuffering || _isReadyToPlay)
			{
				load();
			}
		}
		
		public function get safety() : int
		{
			return _safety;
		}
		
		public function set safety(__safety : int) : void
		{
			_safety = __safety;
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------
		
		private function seekTo(time:Number):void
		{
			if(time > 0 && time <= _duration)
			{
				_stream.seek(time / 1000);
				dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS, time, _duration, _timeLoaded));
			}
		}
		
		private function scrub():void
		{
			_scrubPosition += _scrubAmount;
			var i:int;
			
			if(_scrubAmount > 0)
			{
				for (i = 0; i < _seekpoints.length; i++)
				{
					if(_seekpoints[i] > _scrubPosition)
					{
						if(_seekpoints[i] <= _timeLoaded)
						{
							seekTo(_seekpoints[i]);
						}
						
						return;
					}
				}
			}
			else
			{
				for (i = _seekpoints.length - 1; i >= 0; i--)
				{
					if(_seekpoints[i] < _scrubPosition)
					{
						seekTo(_seekpoints[i]);
						return;
					}
				}
			}
		}
		
		private function startLoad():void
		{
			_isBuffering = true;
			_isReadyToPlay = false;
			_isLoading = true;
			_loadStarted = getTimer();
			
			_stream.play(_source);
			_stream.pause();
			
			dispatchEvent(new VideoEvent(VideoEvent.LOAD_START));
			
			_progressTimer.start();
			
			if(!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function startPlay():void
		{
			_streamStatus = [];
			_isWaitingToPlay = false;
			_isPlaying = true;
			
			if(_seek)
			{
				_stream.seek(_seek / 1000);
				_seek = undefined;
			}
			else if(_seekPercent)
			{
				_stream.seek((_duration / 1000) * _seekPercent);
				_seekPercent = undefined;
			}
			
			_stream.resume();
			
			resizeCheck();
			
			dispatchEvent(new VideoEvent(VideoEvent.PLAYING));
			
			_progressTimer.start();
			
			if(!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function startPause():void
		{
			_isPlaying = false;
			_isPaused = true;
			_stream.pause();
		}
		
		private function resizeCheck():void
		{
			if(videoWidth > 0 && videoWidth != _videoWidth)
			{
				_videoWidth = videoWidth;
				dispatchEvent(new VideoEvent(VideoEvent.RESIZE));
			}
		}
		
		private function onMetaData(data:Object):void
		{
			_duration = data.duration * 1000;
			_bpms = _stream.bytesTotal / _duration;
			
			for (var i : int = 0; i < data.seekpoints.length; i++)
			{
				_seekpoints.push(data.seekpoints[i].time * 1000);
			}
			
			dispatchEvent(new VideoEvent(VideoEvent.LOADED_METADATA));
		}
		
		private function loadComplete() : void
		{
			_isLoading = false;
			
			if(!_isPlaying)
			{
				_progressTimer.stop();
			}
		}
		
		private function error():void
		{
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			dispatchEvent(new VideoEvent(VideoEvent.ERROR));
		}

		private function readyToPlay():void
		{
			_stream.seek(0);
			
			dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS, 0, _duration, _timeLoaded));
			dispatchEvent(new VideoEvent(VideoEvent.CAN_PLAY_THROUGH));
			
			_isReadyToPlay = true;
			_isBuffering = false;
			
			if(_isWaitingToPlay)
			{
				startPlay();
			}
			else
			{
				if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
			
			resizeCheck();
		}
		
		private function ended():void
		{
			_stream.pause();
			_stream.seek(0);
			
			_progressTimer.stop();
			dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS, 0, _duration, _timeLoaded));
			
			_isPlaying = false;
			
            if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
            dispatchEvent(new VideoEvent(VideoEvent.ENDED));
		}
		
		private function pushStatus(status:String):void
        {
            _streamStatus.push(status);
            
            while (_streamStatus.length> 3) _streamStatus.shift();
        }
		
		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------
		
		private function progressTimerHandler(event : TimerEvent) : void
		{
			dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS, _stream.time * 1000, _duration, _timeLoaded));
			
			if(_isLoading)
			{
				if(_stream.bytesTotal == _stream.bytesLoaded)
				{
					loadComplete();
				}
			}
		}
		
		private function scrubTimerHandler(event : TimerEvent) : void
		{
			scrub();
		}
		
		private function ioErrorHandler(event : IOErrorEvent) : void
		{
			error();
		}

		private function asyncErrorHandler(event : AsyncErrorEvent) : void
		{
			error();
		}
		
		private function enterFrameHandler(event:Event):void
		{
			if(!_duration) return;
			
			resizeCheck();
			
			_timeLoaded = (_stream.bytesLoaded / _stream.bytesTotal) * _duration;
			
			var loadDuration:int = getTimer() - _loadStarted;
			var rate:Number =  _stream.bytesLoaded / loadDuration;
			var loadTimeLeft:Number = (_stream.bytesTotal - _stream.bytesLoaded) / rate;
			
			if(!_isReadyToPlay)
			{
				if(_timeLoaded - (_stream.time * 1000) > loadTimeLeft + _safety || loadTimeLeft == 0)
				{
					readyToPlay();
				}
			}
			else if(_isPlaying && (_stream.time * 1000) >= _timeLoaded)
			{
				_loadStarted = getTimer();
				_isStalled = true;
				_stream.pause();
			}
			else if(_isPlaying && _isStalled)
			{
				if(_timeLoaded - (_stream.time * 1000) > loadTimeLeft + _safety || loadTimeLeft == 0)
				{
					_stream.resume();
					_isStalled = false;
				}
			}
			else
			{
				_isStalled = false;
			}
		}

		private function netStatusHandler(event:NetStatusEvent):void
		{
			if(event.info.code == "NetStream.Play.StreamNotFound")
			{
				error();
				return;
			}
			
			pushStatus(event.info.code);
			
			var stopIdx:Number = _streamStatus.lastIndexOf("NetStream.Play.Stop");
            var flushIdx:Number = _streamStatus.lastIndexOf("NetStream.Buffer.Flush");
            var emptyIdx:Number = _streamStatus.lastIndexOf("NetStream.Buffer.Empty");
           
            var mediaFinished:Boolean = false;
           
            if (stopIdx > -1 && flushIdx > -1 && emptyIdx > -1)
            {
                if (flushIdx < stopIdx && stopIdx < emptyIdx)
                {
                    mediaFinished = true;
                }
            }
            else if (flushIdx > -1 && emptyIdx > -1)
            {
                if (flushIdx < emptyIdx) mediaFinished = true;
            }
            else if (stopIdx > -1 && flushIdx > -1)
            {
                mediaFinished = true;
            }
            
            if(mediaFinished && _isPlaying)
            {   
                ended();
            }
		}
	}
}
