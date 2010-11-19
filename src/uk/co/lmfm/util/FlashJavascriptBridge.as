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

package uk.co.lmfm.util
{
	import uk.co.lmfm.util.events.FlashJavascriptBridgeEvent;

	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;

	/**
	 * @author Fraser Hobbs
	 * @version 1.00
	 * 
	 * FlashJavascriptBridge : Utility that wraps up ExternalInterface to communicate with JavaScript via its JavaScript counterpart
	 * 
	 * @example
	 * Connect from ActionScript with unique ID shared between ActionScript and JavaScript (recommend the Flash objects ID)
	 * <listing version="1.0">
	 * FlashJavascriptBridge.connect(loaderInfo.parameters.bridgeID, flashJavascriptBridgeFail);
	 * </listing>
	 * 
	 * Add Event Listener
	 * <listing version="1.0">
	 * FlashJavascriptBridge.addEventListener("play",play);
	 * </listing>
	 * 
	 * Dispatch an event to JavaScript
	 * <listing version="1.0">
	 * FlashJavascriptBridge.dispatchEvent(new FlashJavascriptBridgeEvent("playing",{started:123}));
	 * </listing>
	 */
	 
	public class FlashJavascriptBridge
	{
		//	----------------------------------------------------------------
		//	PRIVATE VARIABLES
		//	----------------------------------------------------------------
		
		private static var _id : String;
		private static var _fail : Function;
		private static var _callbacks : Object = new Object();
		private static var _storedSends : Array = [];
		private static var _connectTimer : Timer = new Timer(200);
		private static var _connected : Boolean = false;

		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------
		
		public static function connect(id : String, fail : Function) : void
		{
			_id = id;

			_connectTimer.addEventListener(TimerEvent.TIMER, connectTimerHandler);

			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.addCallback("pingFlash", pingFlash);
					ExternalInterface.addCallback("send", recieve);

					// have to connect from JS first
					_connectTimer.start();
					tryConnect();
				}
				catch (error : Error)
				{
					_fail.call(FlashJavascriptBridge, error);
				}
			}
			else
			{
				_fail.call(FlashJavascriptBridge, new Error("ExternalInterface unavailable"));
			}
		}
		
		public static function addEventListener(name : String, callback : Function) : void
		{
			_callbacks[name] = callback;
		}

		public static function removeEventListener(name : String) : void
		{
			if (_callbacks[name])
			{
				_callbacks[name] = null;
			}
		}

		public static function dispatchEvent(event : FlashJavascriptBridgeEvent) : void
		{
			if (!_connected)
			{
				_storedSends.push(event);
			}
			else
			{
				ExternalInterface.call("FlashJavascriptBridge.recieve", _id, event.type, event.data);
			}
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------

		private static function tryConnect() : void
		{
			var c : Boolean = ExternalInterface.call("FlashJavascriptBridge.connected", _id);

			if (c)
			{
				_connectTimer.stop();
				_connected = true;

				var s : FlashJavascriptBridgeEvent;
				while (_storedSends.length > 0)
				{
					s = _storedSends.shift();
					ExternalInterface.call("FlashJavascriptBridge.recieve", _id, s.type, s.data);
				}
			}
		}
		
		private static function pingFlash() : void
		{
			ExternalInterface.call("FlashJavascriptBridge.echoFlash", _id);
		}

		private static function recieve(type : String, data : Object) : void
		{
			if (_callbacks[type])
			{
				_callbacks[type].call(_callbacks, new FlashJavascriptBridgeEvent(type, data));
			}
		}
		
		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------
		
		private static function connectTimerHandler(event : TimerEvent) : void
		{
			tryConnect();
		}
	}
}