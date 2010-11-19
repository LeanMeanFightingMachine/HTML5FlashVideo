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
 * FlashJavascriptBridge : Utility that communicates with Flash object via its ActionScript counterpart
 * 
 * @example
 * Connect from JavaScript with unique ID shared between ActionScript and JavaScript (recommend the Flash objects ID), a reference to the Flash object and a target parameter to be returned with each event
 * <listing version="1.0">
 * FlashJavascriptBridge.connect(id,$obj.children()[0],obj);
 * </listing>
 * 
 * Add Event Listener
 * <listing version="1.0">
 * FlashJavascriptBridge.addEventListener(id,"playing",playingHandler);
 * </listing>
 * 
 * Dispatch an event to ActionScript
 * <listing version="1.0">
 * FlashJavascriptBridge.dispatchEvent(id,new FlashJavascriptBridgeEvent("play",{started:123}));
 * </listing>
 */

FlashJavascriptBridge = {};

FlashJavascriptBridge.connect = function(id, swf, target)
{
	FlashJavascriptBridge[id] = {};
	FlashJavascriptBridge[id].swf = swf;
	FlashJavascriptBridge[id].target = target;
	FlashJavascriptBridge[id].callbacks = {};
	FlashJavascriptBridge[id].storedSends = [];
	FlashJavascriptBridge[id].connected = false;
};

FlashJavascriptBridge.addEventListener = function(id,name,callback)
{
	if(FlashJavascriptBridge[id])
	{
		FlashJavascriptBridge[id].callbacks[name] = callback;
	}
};

FlashJavascriptBridge.recieve = function(id,name,data)
{
	if(FlashJavascriptBridge[id])
	{
		if(FlashJavascriptBridge[id].callbacks[name])
		{
			FlashJavascriptBridge[id].callbacks[name](new FlashJavascriptBridgeEvent(name,data,FlashJavascriptBridge[id].target));
		}
	}
	
	return true;
};

FlashJavascriptBridge.connected = function(id)
{
	if(FlashJavascriptBridge[id])
	{
		FlashJavascriptBridge[id].connected = true;
		return true;
	}
	
	return false;
};

FlashJavascriptBridge.echoFlash = function(id)
{
	clearInterval(FlashJavascriptBridge[id].interval);
	
	var s;
	while(FlashJavascriptBridge[id].storedSends.length > 0)
	{
		s = FlashJavascriptBridge[id].storedSends.shift();
		FlashJavascriptBridge[id].swf.send(s.type, s.data);
	}
};

FlashJavascriptBridge.dispatchEvent = function(id,event)
{
	if(FlashJavascriptBridge[id])
	{
		if(FlashJavascriptBridge[id].connected && FlashJavascriptBridge[id].swf)
		{
			if(typeof FlashJavascriptBridge[id].swf["TGetProperty"] === 'function')
			{
				if(!FlashJavascriptBridge[id].swf.TGetProperty("/", 12))
				{
					FlashJavascriptBridge[id].connected = false;
				}
			}
		}
		
		FlashJavascriptBridge[id].storedSends.push(event);
		
		if(FlashJavascriptBridge[id].interval)
		{
			clearInterval(FlashJavascriptBridge[id].interval);
		}
		
		FlashJavascriptBridge[id].interval = setInterval("FlashJavascriptBridge.pingFlash('"+id+"')",100);
		FlashJavascriptBridge.pingFlash(id);
	}
};

FlashJavascriptBridge.pingFlash = function(id)
{
	if(FlashJavascriptBridge[id].swf && FlashJavascriptBridge[id].connected)
	{
		if(FlashJavascriptBridge[id].swf.pingFlash)
		{
			FlashJavascriptBridge[id].swf.pingFlash();
		}
	}
};

FlashJavascriptBridgeEvent = function(type, data, target)
{
	this.type = type;
	this.data = data;
	this.target = target;
};

