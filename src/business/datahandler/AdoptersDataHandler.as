/*
The Matterhorn2Go Project
Copyright (C) 2011  University of Osnabrück; Part of the Opencast Matterhorn Project

This project is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 
USA 
*/
package business.datahandler
{	
	
	import business.datahandler.URLClass;
	import business.datahandler.XMLHandler;
	
	import events.AdoptersLoadedEvent;
	import events.NotConnectedEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class AdoptersDataHandler extends EventDispatcher
	{		
		private var serviceObj:HTTPService; 
		private var adopters:XMLListCollection;
		static private var instance:AdoptersDataHandler;
		
		private var useFilterFlag:String;
	
		public function AdoptersDataHandler()
		{
			serviceObj = new HTTPService();
		}
	
		public static function getInstance():AdoptersDataHandler
		{
			if (instance == null) instance = new AdoptersDataHandler();

			return instance;
		}
	
		public function init():void
		{	
			serviceObj.url = "http://vm083.rz.uos.de/release/webservices/matterhorn2go";
			serviceObj.resultFormat = 'e4x';
			serviceObj.method = 'GET';
			serviceObj.useProxy = false;
			serviceObj.addEventListener(ResultEvent.RESULT, processResult);	
			serviceObj.addEventListener(FaultEvent.FAULT, notConnected);
			serviceObj.send();
		}
		
		public function initGetFilter():void
		{	
			serviceObj.url = "http://vm083.rz.uos.de/release/webservices/matterhorn2go";
			serviceObj.resultFormat = 'e4x';
			serviceObj.method = 'GET';
			serviceObj.useProxy = false;
			serviceObj.addEventListener(ResultEvent.RESULT, processResultFilter);	
			serviceObj.addEventListener(FaultEvent.FAULT, notConnected);
			serviceObj.send();
		}
		
		protected function processResultFilter(response:ResultEvent):void
		{			
			var XMLResults:XML = response.result as XML;
			var tmp:String = URLClass.getInstance().getURL();
			var xmlHandler:XMLHandler = new XMLHandler();
			var tmp2:String = xmlHandler.getResult("adopters/adopter[AdopterURL='"+tmp+"']/Filter", XMLResults);
			useFilterFlag = tmp2;
			
			var xmlAdoptersLoaded:AdoptersLoadedEvent = new AdoptersLoadedEvent(AdoptersLoadedEvent.ADOPTERSLOADED);
			dispatchEvent(xmlAdoptersLoaded);	
			
			serviceObj.removeEventListener(ResultEvent.RESULT, processResultFilter);
			serviceObj.removeEventListener(FaultEvent.FAULT, notConnected);
		}
	
		protected function processResult(response:ResultEvent):void
		{			
			var XMLResults:XML = response.result as XML;	
			adopters = new XMLListCollection(XMLResults.children());
			var tmp:String = URLClass.getInstance().getURLNoSearch();

			var xmlHandler:XMLHandler = new XMLHandler();
			var tmp2:String = xmlHandler.getResult("adopters/adopter[AdopterURL='"+tmp+"']/AdopterURL", XMLResults);
			useFilterFlag = tmp2;
			
			
			if(tmp != tmp2)
			{
				var ad:Object = "<adopter><AdopterURL>"+tmp+"</AdopterURL><AdopterName>Your Custom URL</AdopterName></adopter>";
				
				var xml:XML = new XML(ad);
			    adopters.addItem(xml);
			}
			
			var xmlAdoptersLoaded:AdoptersLoadedEvent = new AdoptersLoadedEvent(AdoptersLoadedEvent.ADOPTERSLOADED);
			dispatchEvent(xmlAdoptersLoaded);	
			
			serviceObj.removeEventListener(ResultEvent.RESULT, processResult);	
			serviceObj.removeEventListener(FaultEvent.FAULT, notConnected);
		}
		
		public function notConnected(event:FaultEvent):void 
		{
			var notConnected:NotConnectedEvent = new NotConnectedEvent(NotConnectedEvent.NOTCONNECTED);
			dispatchEvent(notConnected);
		}
		
		public function getXMLListAdopters():XMLListCollection
		{
			return adopters;
		}
		
		public function getFilter():String
		{
			return useFilterFlag;
		}
    }
}