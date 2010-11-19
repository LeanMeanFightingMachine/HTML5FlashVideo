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

package uk.co.lmfm.display.video.events
{
	import flash.events.Event;

	/**
	 * @author Fraser Hobbs
	 */
	public class VideoProgressEvent extends Event
	{
		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------
		
		public static const PROGRESS : String = "progress";
		
		//	----------------------------------------------------------------
		//	PRIVATE VARIABLES
		//	----------------------------------------------------------------
		
		private var _currentTime : int;
		private var _duration : int;
		private var _loaded : int;
		
		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		public function VideoProgressEvent(type : String, currentTime : int, duration : int, loaded : int, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);

			_currentTime = currentTime;
			_duration = duration;
			_loaded = loaded;
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------

		override public function clone() : Event
		{
			return new VideoProgressEvent(type, currentTime, duration, loaded, bubbles, cancelable);
		}
		
		//	----------------------------------------------------------------
		//	GETTERS/SETTERS
		//	----------------------------------------------------------------

		public function get currentTime() : int
		{
			return _currentTime;
		}

		public function get duration() : int
		{
			return _duration;
		}

		public function get loaded() : int
		{
			return _loaded;
		}
	}
}
