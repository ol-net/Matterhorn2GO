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
	import business.LoadNextEpisodes;
	
	import events.NotConnectedEvent;
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
	
	public class EpisodesDataHandler extends EventDispatcher 
	{
		private var serviceObj:HTTPService;
		private var matterhornURL:String;
		
		private var xmlVideos:XMLListCollection;
		private var publicVideos:XMLListCollection;
		private var cDate:Object;
		
		private var total:int;
		private var limit:int;
		private var offset:int;
		private var sText:String = "";
		private var sId:String = "";
		private var oValue:String = "0";
		
		private var checkInstance:CheckForPublicVideo;
		
		private var index:Number;
		
		private var newSearch:Boolean = false;
		
		private var lernfunk:Boolean = false;
		
		private var url:String;
		
		static private var instance:EpisodesDataHandler;
		
		protected var xpathValue:Object = new XMLHandler();
		
		private var loadNextEpisodes:LoadNextEpisodes;
		
		private var initLoad:Boolean = true;
		
		public function EpisodesDataHandler()
		{			
			this.serviceObj = new HTTPService();
			this.publicVideos = new XMLListCollection();
		}
		
		static public function getInstance():EpisodesDataHandler 
		{
			if (instance == null) instance = new EpisodesDataHandler();
			
			return instance;
		}
		
		// The initialisation function
		public function init():void
		{
			if(initLoad)
			{
				initLoad = false;
				
				url = URLClass.getInstance().getURL();
				publicVideos = new XMLListCollection();
				this.matterhornURL = URLClass.getInstance().getURL()+'episode.xml';
				serviceObj.resultFormat = 'e4x';
				serviceObj.method = 'GET';
				serviceObj.useProxy = false;
				serviceObj.addEventListener(ResultEvent.RESULT, processResult);
				serviceObj.addEventListener(FaultEvent.FAULT, notConnected);

				if(sId == '')
				{
					serviceObj.url = matterhornURL+'?q='+sText+'&limit='+20+'&offset='+oValue+'&lfunk=1';
				}
				else
				{
					if(URLClass.getInstance().getURL() != 'http://lernfunk.de/plug-ins/lernfunk-matterhorn-search-proxy/proxy.py/')
					{
						serviceObj.url = matterhornURL+'?id='+sId+'&limit='+20+'&offset='+oValue;
					}
					else
					{
						serviceObj.url = matterhornURL+'?q='+sId+'&limit='+20+'&offset='+oValue+'&lfunk=1';
					}
				}
				
				
				serviceObj.send();	
			}
		}
		
		// The initialisation function
		public function initID():void
		{	
			if(initLoad)
			{
				initLoad = false;
				
				url = URLClass.getInstance().getURL();
				publicVideos = new XMLListCollection();
				this.matterhornURL = URLClass.getInstance().getURL()+'episode.xml';
				serviceObj.resultFormat = 'e4x';
				serviceObj.method = 'GET';
				serviceObj.useProxy = false;
				serviceObj.addEventListener(ResultEvent.RESULT, processResult);
				serviceObj.addEventListener(FaultEvent.FAULT, notConnected);
				
				if(URLClass.getInstance().getURL() != 'http://lernfunk.de/plug-ins/lernfunk-matterhorn-search-proxy/proxy.py/')
				{
					serviceObj.url = matterhornURL+'?id='+sId+'&limit='+20+'&offset='+oValue;
				}
				else
				{
					serviceObj.url = matterhornURL+'?q='+sId+'&limit='+20+'&offset='+oValue;
				}
				
				serviceObj.send();	
			}
		}
		
		// The result processing function
		public function processResult(response:ResultEvent):void
		{
			var videoLoaded:VideosLoadedEvent = new VideosLoadedEvent(VideosLoadedEvent.VIDEOSLOADED);
			
			var XMLResults:XML = response.result as XML;
			total = XMLResults.@total;
			limit = XMLResults.@limit;
			offset = XMLResults.@offset;
			
			initLoad = true;
			
			if (total == 0)
			{	
				var videoNotFound:VideoNotFoundEvent = new VideoNotFoundEvent(VideoNotFoundEvent.VIDEOSNOTFOUND);
				dispatchEvent(videoNotFound);
				
				dispatchEvent(videoLoaded);
				
				return;
			}
			
			this.loadNextEpisodes = LoadNextEpisodes.getInstance();

			xmlVideos = new XMLListCollection(XMLResults.result.mediapackage);
			
			index = 0;
			
			//var videoPath:String = "media/track[mimetype='video/x-flv'][@type='presenter/delivery'][tags/tag[2]='medium-quality'][2]/url"; 
			var videoPath:String = "media/track[mimetype='video/x-flv'][@type='presenter/delivery']/url"; 
			
			while(index < xmlVideos.length)
			{
				var ob:Object = xmlVideos.getItemAt(index) as Object;
				
				var path:String = xpathValue.getXMLResult(videoPath, ob);
				
				if(path != "" && path != null) 
				{
					createNewElement();
				}
				
				index = index + 1;
			}
			
			if(loadNextEpisodes.getPage() < loadNextEpisodes.getMaxPages())
			{
				var mediapackage:Object = 
					"<mediapackage id='update_button' type='episode'><code>update_view</code></mediapackage>";
				
				var xml:XML = new XML(mediapackage);
				
				publicVideos.addItem(xml);
			}
			
			dispatchEvent(videoLoaded);
		}
		
		public function notConnected(event:FaultEvent):void 
		{
			initLoad = true;
			index = 0;
			
			var notConnected:NotConnectedEvent = new NotConnectedEvent(NotConnectedEvent.NOTCONNECTED);
			dispatchEvent(notConnected);
		}
		
		public function createNewElement():void
		{	
			var imagePath:String = "mediapackage/attachments/attachment[1]/url";
			
			var mediapackage:Object = 
				"<mediapackage id='"+xmlVideos.getItemAt(index).@id+"'>" +
				"<title>"+xmlVideos.getItemAt(index).title+"</title>" +
				"<author>"+xmlVideos.getItemAt(index).creators.creator+"</author>" +
				"<date>"+xmlVideos.getItemAt(index).@start+"</date>" +
				"<thumbnail>"+xpathValue.getResult(imagePath, xmlVideos.getItemAt(index))+"</thumbnail>" +
				"</mediapackage>";
			
			var xml:XML = new XML(mediapackage);
			
			if(newSearch)
			{
				publicVideos = new XMLListCollection();
				newSearch = false;
			}
			
			publicVideos.addItem(xml);
		}
		
		// search videos
		public function search(searchText:String, offset_value:String):void
		{	
			if(sText != searchText)
			{
				sId = '';
				newSearch = true;
			}
			
			this.sText = searchText;
			this.oValue = offset_value;
			
			if(initLoad)
			{
				initLoad = false;

				var url:String = matterhornURL;
				var searchurl:String;

				if(sId != '')
				{	
					if(URLClass.getInstance().getURL() != 'http://lernfunk.de/plug-ins/lernfunk-matterhorn-search-proxy/proxy.py/')
					{
						searchurl = url+'?id='+sId+'&limit='+20+'&offset='+oValue;
					}
					else
					{
						searchurl = url+'?q='+sId+'&limit='+20+'&offset='+oValue+'&lfunk=1';
					}
				}
				else
				{
					searchurl = url+'?q='+sText+'&limit='+20+'&offset='+oValue;
				}
				
				serviceObj.url = searchurl;
				serviceObj.send();	
			}
		}
		
		public function getXMLListCollection():XMLListCollection
		{
			return publicVideos;
		}
		
		public function setXMLListCollection(v:XMLListCollection):void
		{
			this.index = 0;
			this.publicVideos = v;
		}
		
		public function setXMLVideos(xm:XMLListCollection):void
		{
			this.index = 0;
			this.xmlVideos = xm;
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
		
		public function setSearchText(s:String):void
		{
			sText = s;
		}
		
		public function setIdText(s:String):void
		{
			sId = s;
		}
		
		public function setNewSearch():void
		{
			sId = "";
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
	}
}