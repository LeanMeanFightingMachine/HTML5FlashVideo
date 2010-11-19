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

package uk.co.lmfm.util.events
{
	/**
	 * @author Fraser Hobbs
	 * @version 1.00
	 * 
	 * FlashJavascriptBridgeEvent : FlashJavascriptBridge events
	 */
	 
	public class FlashJavascriptBridgeEvent
	{
		//	----------------------------------------------------------------
		//	PRIVATE VARIABLES
		//	----------------------------------------------------------------
		
		private var _type:String;
		private var _data:Object;
		
		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		public function FlashJavascriptBridgeEvent(type : String, data : Object = null)
		{
			_type = type;
			_data = data;
		}
		
		//	----------------------------------------------------------------
		//	GETTERS/SETTERS
		//	----------------------------------------------------------------
		
		public function get type():String
		{
			return _type;
		}
		
		public function get data():Object
		{
			return _data;
		}
	}
}
