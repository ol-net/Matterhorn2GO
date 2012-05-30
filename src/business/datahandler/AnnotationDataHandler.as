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
	import events.AnnotationLoadedEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.collections.*;
	import spark.events.IndexChangeEvent;
	
	public class AnnotationDataHandler extends EventDispatcher
	{		
		private var serviceObj:HTTPService; 		
		private var list:XMLListCollection;		
		static private var instance:AnnotationDataHandler;
		private var total:int;
		
		public function AnnotationDataHandler()
		{
			serviceObj = new HTTPService();
		}
		
		public static function getInstance(id:String):AnnotationDataHandler{
			if (instance == null) instance = new AnnotationDataHandler();
			
			instance.init(id);
			
			return instance;
		}
		
		public function init(id:String):void{			
			serviceObj.resultFormat = 'e4x';
			serviceObj.method = 'GET';
			serviceObj.useProxy = false;
			serviceObj.addEventListener(ResultEvent.RESULT, processResult);			
			serviceObj.url = URLClass.getInstance().getURL()+'/annotation/annotations.xml?episode='+id+'&type=comment&day=&limit=500&offset=0';
			serviceObj.send();
		}
		
		protected function processResult(response:ResultEvent):void
		{			
			var XMLResults:XML = response.result as XML;			
			list = new XMLListCollection(XMLResults.children());
			total = XMLResults.@total;
			
			var xmlAnnoLoaded:AnnotationLoadedEvent = new AnnotationLoadedEvent(AnnotationLoadedEvent.ANNOTATIONLOADED);
			dispatchEvent(xmlAnnoLoaded);	
		}
		
		public function getAnnotationListCollection():XMLListCollection
		{						
			return myReverseList(list);
		}
		
		public function myReverseList(list:XMLListCollection):XMLListCollection{
			var list2:XMLListCollection = new XMLListCollection();
			var i:Number;
			for(i = 0; i<list.length; i++){
				list2.addItemAt(list[i], 0);
			}				
			return list2;
		}
		
		public function getTotal():int{
			return total;
		}
	}
}