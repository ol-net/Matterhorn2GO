/*
The Matterhorn2Go Project
Copyright (C) 2011  University of OsnabrÃ¼ck; Part of the Opencast Matterhorn Project

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
	import business.LoadNextSeries;
	import events.NotConnectedEvent;
	import events.ThumbnailLoadedEvent;
	import events.VideoAvailableEvent;
	import events.VideoNotFoundEvent;
	import events.VideosLoadedEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	
	import spark.events.IndexChangeEvent;
	
	public class SeriesDataHandler extends EventDispatcher 
	{
		private var serviceObj:HTTPService;
		private var serviceObj2:HTTPService;

		private var matterhornURL:String;
		
		private var xmlSeries:XMLListCollection;
		private var publicSeries:XMLListCollection;
		private var cDate:Object;
		
		private var total:int;
		private var limit:int;
		private var offset:int;
		private var sText:String = "";
		private var oValue:String = "0";
		
		private var index:Number;
		
		private var newSearch:Boolean = false;
		
		private var lernfunk:Boolean = false;
		
		private var url:String;
		
		static private var instance:SeriesDataHandler;
		
		protected var xpathValue:Object = new XMLHandler();
		
		private var loadNextSeries:LoadNextSeries;
		
		private var initLoad:Boolean = true;
		
		private var initThumbnail:Boolean = true;

		private var urlThumbnail:String;
		
		public function SeriesDataHandler()
		{
			this.serviceObj = new HTTPService();
			this.serviceObj2 = new HTTPService();
			this.publicSeries = new XMLListCollection();
		}
		
		static public function getInstance():SeriesDataHandler 
		{
			if (instance == null) instance = new SeriesDataHandler();
			
			return instance;
		}
		
		// The initialisation function
		public function init():void
		{	
			if(initLoad)
			{
				initLoad = false;
				url = URLClass.getInstance().getURL();
				publicSeries = new XMLListCollection();
				this.matterhornURL = URLClass.getInstance().getURL()+'series.xml';
				serviceObj.resultFormat = 'e4x';
				serviceObj.method = 'GET';
				serviceObj.useProxy = false;
				serviceObj.addEventListener(ResultEvent.RESULT, processResult);
				serviceObj.addEventListener(FaultEvent.FAULT, notConnected);
				serviceObj.url = matterhornURL+'?q='+sText+'&limit='+20+'&offset='+oValue+'&series=true';	
				serviceObj.send();	
				
				serviceObj2.resultFormat = 'e4x';
				serviceObj2.method = 'GET';
				serviceObj2.useProxy = false;
				serviceObj2.addEventListener(ResultEvent.RESULT, processResult2);
				//serviceObj2.url = URLClass.getInstance().getURL()+'episode.xml?q=""&limit=1&offset=1';
				serviceObj2.send();	
			}
		}
		
		// The result processing function
		public function processResult2(response:ResultEvent):void
		{
			initThumbnail = true;
			var XMLResults:XML = response.result as XML;
			
			//trace()
			//trace(XMLResults.result)
			
			this.urlThumbnail = XMLResults.result.mediapackage.attachments.attachment.url[0];
			
			if(urlThumbnail == null)
				this.urlThumbnail = "assets/splashscreen/nothumb.png";
			
			if(xmlSeries != null)
			{
				createNewElement();
			}
			//attachments/attachment[1]/url
			
			//xmlVideos = new XMLListCollection(XMLResults.result.mediapackage);
			
		}
		
		// The result processing function
		public function processResult(response:ResultEvent):void
		{			
			var XMLResults:XML = response.result as XML;
			total = XMLResults.@total;
			limit = XMLResults.@limit;
			offset = XMLResults.@offset;
						
			if (total == 0)
			{	
				initLoad = true;
				var videoNotFound:VideoNotFoundEvent = new VideoNotFoundEvent(VideoNotFoundEvent.VIDEOSNOTFOUND);
				dispatchEvent(videoNotFound);
				var videoLoaded:VideosLoadedEvent = new VideosLoadedEvent(VideosLoadedEvent.VIDEOSLOADED);
				dispatchEvent(videoLoaded);
				
				return;
			}
			
			this.loadNextSeries = LoadNextSeries.getInstance();

			xmlSeries = new XMLListCollection(XMLResults.result);
			
			index = 0;
			
			getImage(xmlSeries.getItemAt(index).@id);
		}
		
		public function notConnected(event:FaultEvent):void 
		{	
			initLoad = true;
			initThumbnail = true;
			index = 0;
			xmlSeries = null;
			
			var notConnected:NotConnectedEvent = new NotConnectedEvent(NotConnectedEvent.NOTCONNECTED);
			dispatchEvent(notConnected);
		}
		
		public function createNewElement():void
		{	
			if(index < xmlSeries.length)
			{
			var mediapackage:Object = 
				"<mediapackage id='"+xmlSeries.getItemAt(index).@id+"'>" +
				"<title>"+xmlSeries.getItemAt(index).dcTitle+"</title>" +
				"<author>"+xmlSeries.getItemAt(index).dcCreator+"</author>" +
				"<contributer>"+xmlSeries.getItemAt(index).dcContributer+"</contributer>"+
				"<date>"+xmlSeries.getItemAt(index).dcCreated+"</date>"+
				"<thumbnail>"+urlThumbnail+"</thumbnail>"+
				"</mediapackage>";

			var xml:XML = new XML(mediapackage);
			
			if(newSearch)
			{
				publicSeries = new XMLListCollection();
				newSearch = false;
			}
			
			publicSeries.addItem(xml);
			}
			else
			{
				return;
			}
			
			index = index + 1;
			
			if(index < xmlSeries.length) 
			{
				getImage(xmlSeries.getItemAt(index).@id);
				//getImage(xmlSeries.getItemAt(index).dcTitle);
			}
			else
			{
				var videoLoaded:VideosLoadedEvent = new VideosLoadedEvent(VideosLoadedEvent.VIDEOSLOADED);

				initLoad = true;
				
				if(loadNextSeries.getPage() < loadNextSeries.getMaxPages())
				{
					mediapackage = 
						"<mediapackage id='update_button' type='series'><code>update_view</code></mediapackage>";
					
					xml = new XML(mediapackage);
					
					publicSeries.addItem(xml);
				}
				dispatchEvent(videoLoaded);
			}
		}
		
		// search videos
		public function search(searchText:String, offset_value:String):void
		{	
			if(initLoad)
			{
				if(sText != searchText)
				{
					newSearch = true;
				}
				
				this.sText = searchText;
				this.oValue = offset_value;
			
				initLoad = false;
				
				var url:String = matterhornURL;
				var searchurl:String = url+'?q='+sText+'&limit='+20+'&offset='+oValue+'&series=true';
				//trace(searchurl)
				serviceObj.url = searchurl;
				serviceObj.send();
			}
		}
		
		public function getImage(id:String):void
		{	
			if(initThumbnail)
			{
				initThumbnail = false;
				
				if(URLClass.getInstance().getURL() != 'http://lernfunk.de/plug-ins/lernfunk-matterhorn-search-proxy/proxy.py/search/')
				{
					serviceObj2.url =URLClass.getInstance().getURL()+'episode.xml?id='+id+'&limit=1&offset=1';
				}
				else
				{
					serviceObj2.url =URLClass.getInstance().getURL()+'episode.xml?q='+id+'&limit=1&offset=1&lfunk=1';
				}
				
				serviceObj2.send();	
			}
		}
		
		public function getXMLListCollection():XMLListCollection
		{
			return publicSeries;
		}
		
		public function setXMLListCollection(v:XMLListCollection):void
		{
			this.index = 0;
			this.publicSeries = v;
		}
		
		public function setXMLSeries(xm:XMLListCollection):void
		{
			this.index = 0;
			this.xmlSeries = xm;
		}
		
		public function getTotal():int
		{
			return total;
		}
		
		public function getLimit():int
		{
			return limit;
		}
		
		public function setLimit(l:int):void
		{
			limit = l;
		}
		
		public function getOffset():int
		{
			return offset;
		}
		
		public function setOffset(o:int):void
		{
			offset = o;
		}
		
		public function getText():String
		{
			return sText;
		}
		
		public function setText():void
		{
			sText = "";
		}
		
		public function setNewSearch():void
		{
			newSearch = true;
		}
		
		public function setOValue():void
		{
			oValue = "0";
		}
		
		public function getURL():String
		{
			return url;
		}
		
		public function initLoadOK():void
		{
			initLoad = true;
		}
		
		public function initThumbnailOK():void
		{
			initThumbnail = true;
		}
	}
}