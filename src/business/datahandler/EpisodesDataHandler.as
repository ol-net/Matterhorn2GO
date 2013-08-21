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
	import business.download.DownloadEpisodeThumbnails;
	import business.core.LoadNextEpisodes;
	import business.auth.Auth;
	import business.auth.ConnectionChecker;
	import business.auth.dbaccess.SQLAuthViewHandler;
	import business.auth.events.AccessDeniedEvent;
	import business.auth.events.AccessOkEvent;
	import business.auth.events.ConnectionCheckerEvent;
	import business.core.NamespaceRemover;
	
	import business.download.events.EpisodeThumbnailLoadedEvent;
	import business.datahandler.events.NotConnectedEvent;
	import business.datahandler.events.VideoAvailableEvent;
	import business.datahandler.events.VideoNotFoundEvent;
	import business.datahandler.events.VideosLoadedEvent;
	import business.datahandler.events.AllVideosLoadedEvent;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	
	import spark.events.IndexChangeEvent;	
	
	public class EpisodesDataHandler extends EventDispatcher 
	{
		private var res:ResultEvent;

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
		
		private var index:Number;
		private var thumbnail_index:Number;
		
		private var newSearch:Boolean = false;
		
		private var lernfunk:Boolean = false;
		
		private var url:String;
		
		static private var instance:EpisodesDataHandler;
		
		protected var xpathValue:Object = new XMLHandler();
		
		private var loadNextEpisodes:LoadNextEpisodes;
		
		private var initLoad:Boolean = true;
		
		private var imageName:String = "";
		
		private var downloaded:Boolean = false;
		
		private var downLoader:DownloadEpisodeThumbnails;

		
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
					//serviceObj.url = matterhornURL+'?id='+sId+'&limit='+20+'&offset='+oValue;
					
					if(URLClass.getInstance().getURL() != 'http://lernfunk.de/plug-ins/lernfunk-matterhorn-search-proxy/proxy.py/search/')
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
				
				//serviceObj.url = matterhornURL+'?id='+sId+'&limit='+20+'&offset='+oValue;

				if(URLClass.getInstance().getURL() != 'http://lernfunk.de/plug-ins/lernfunk-matterhorn-search-proxy/proxy.py/search/')
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
			this.res = response;
			
			var xml:XMLHandler = new XMLHandler();
			
			var XMLResults:XML = response.result as XML;
			
			XMLResults = NamespaceRemover.remove(XMLResults);
			XMLResults = NamespaceRemover.removeDefaultNamespaceFromXML(XMLResults);
			
			var connectionInfo:String = XMLResults.query; 
			
			var conChecker:ConnectionChecker = ConnectionChecker.getInstance();
			var useAuthConnection:Boolean = conChecker.getAuthUSE();

			if(useAuthConnection)
			{
				conChecker.addEventListener(ConnectionCheckerEvent.CONNECTIONCHECKED, connectionCheckerDone);
				conChecker.checkConnection(connectionInfo);
			}
			else
			{
				setResponse(response);
			}
		}
		
		public function connectionCheckerDone(e:ConnectionCheckerEvent):void
		{
			setResponse(this.res);
		}
		
		public function setResponse(response:ResultEvent):void
		{
			var XMLResults:XML = response.result as XML;
			
			XMLResults = NamespaceRemover.remove(XMLResults);
			XMLResults = NamespaceRemover.removeDefaultNamespaceFromXML(XMLResults);

			total = XMLResults.@total;
			limit = XMLResults.@limit;
			offset = XMLResults.@offset;
			
			initLoad = true;
			
			if (total == 0)
			{	
				var videoNotFound:VideoNotFoundEvent = new VideoNotFoundEvent(VideoNotFoundEvent.VIDEOSNOTFOUND);
				dispatchEvent(videoNotFound);
				
				var allvideoLoaded:AllVideosLoadedEvent = new AllVideosLoadedEvent(AllVideosLoadedEvent.ALLVIDEOSLOADED);
				dispatchEvent(allvideoLoaded);
				
				return;
			}
			
			this.loadNextEpisodes = LoadNextEpisodes.getInstance();
				
			xmlVideos = new XMLListCollection(XMLResults.result.mediapackage);
			
			index = 0;
			thumbnail_index = 0;

			downloaded = true;
			
			//while(index < xmlVideos.length)
			//{
				//imageDownloader();
				//index = index + 1;
			imageDownloader();

			//}
		}
		
		public function updateList():void
		{
			if(loadNextEpisodes.getPage() < loadNextEpisodes.getMaxPages())
			{
				var mediapackage:Object = 
					"<mediapackage id='update_button' type='episode'><code>update_view</code></mediapackage>";
				
				var xml:XML = new XML(mediapackage);
				
				publicVideos.addItem(xml);
			}
		}
				
		public function imageDownloader():void 
		{
			if (index < xmlVideos.length)
			{
				var xmlElement:XML = xmlVideos.getItemAt(index) as XML;
				
				var thumb:String = xmlElement.attachments.attachment[1].url; 
				
				var r:RegExp = /\//g;
				var r2:RegExp = /\:/g;
				var s:String = thumb.replace(r, "");
				s = s.replace(r, "");
				
				imageName = s.replace(r2, "");
				imageName = "mh2go_thumb/" + imageName;
				
				var file:File;
				
				if(!File.userDirectory.resolvePath(imageName).exists) 
				{
					file = File.userDirectory.resolvePath(imageName);
					
					downLoader = new DownloadEpisodeThumbnails();
					
					downLoader.addEventListener(EpisodeThumbnailLoadedEvent.DOWNLOAD_COMPLETE, createNewElement);
					
					downLoader.download(thumb, file, "", "", index);
				}
				else
				{
					file = File.userDirectory.resolvePath(imageName);
					buildElement(index, file.url);
				}
			}
			else
			{
				var allxmlLoaded:AllVideosLoadedEvent = new AllVideosLoadedEvent(AllVideosLoadedEvent.ALLVIDEOSLOADED);
				dispatchEvent(allxmlLoaded);
			}
		}
		
		public function notConnected(event:FaultEvent):void 
		{
			initLoad = true;
			index = 0;
			thumbnail_index = 0;
			
			var notConnected:NotConnectedEvent = new NotConnectedEvent(NotConnectedEvent.NOTCONNECTED);
			dispatchEvent(notConnected);
		}
		
		public function createNewElement(e:EpisodeThumbnailLoadedEvent):void
		{
			downLoader.removeEventListener(EpisodeThumbnailLoadedEvent.DOWNLOAD_COMPLETE, createNewElement);

			buildElement(e.index, e.file.url);
		}
		
		public function buildElement(i:uint, path:String):void
		{
			var xpath:XMLHandler = new XMLHandler();
			
			var xml:XML = xmlVideos.getItemAt(i) as XML;
			
			var mediapackage:Object = 
				"<mediapackage id='"+xml.@id+"'>" +
					"<title>"+xmlVideos.getItemAt(i).title+"</title>" +
					"<author>"+xmlVideos.getItemAt(i).creators.creator+"</author>" +
					"<date>"+xmlVideos.getItemAt(i).@start+"</date>" +
					"<thumbnail>"+path+"</thumbnail>" +
				"</mediapackage>";
			
			xml = new XML(mediapackage);
			
			if(newSearch)
			{
				publicVideos = new XMLListCollection();
				newSearch = false;
			}
			
			publicVideos.addItem(xml);
			
			thumbnail_index = thumbnail_index + 1;
			
			if(thumbnail_index == xmlVideos.length)
			{
				updateList();
			}
			
			var xmlLoaded:VideosLoadedEvent = new VideosLoadedEvent(VideosLoadedEvent.VIDEOSLOADED);
			dispatchEvent(xmlLoaded);
			
			index = index + 1;
			
			imageDownloader();
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
					if(URLClass.getInstance().getURL() != 'http://lernfunk.de/plug-ins/lernfunk-matterhorn-search-proxy/proxy.py/search/')
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
			sId = s+'&lfunk=1';
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