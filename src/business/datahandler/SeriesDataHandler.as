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
	import business.download.DownloadSeriesThumbnails;
	import business.core.LoadNextSeries;
	import business.auth.Auth;
	import business.auth.ConnectionChecker;
	import business.auth.dbaccess.SQLAuthViewHandler;
	import business.auth.events.AccessDeniedEvent;
	import business.auth.events.AccessOkEvent;
	
	import business.auth.events.ConnectionCheckerEvent;
	import business.download.events.DownloadEvent;
	import business.datahandler.events.NotConnectedEvent;
	import business.download.events.SeriesThumbnailLoadedEvent;
	import business.datahandler.events.VideoAvailableEvent;
	import business.datahandler.events.VideoNotFoundEvent;
	import business.datahandler.events.SeriesLoadedEvent;
	import business.datahandler.events.AllSeriesLoadedEvent;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	
	import spark.events.IndexChangeEvent;
	
	import business.core.NamespaceRemover;	
	
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
		
		private var imageName:String = "";
		
		private var downLoader:DownloadSeriesThumbnails;
		
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
				serviceObj2.addEventListener(ResultEvent.RESULT, imageResultHandler);
				//serviceObj2.url = URLClass.getInstance().getURL()+'episode.xml?q=""&limit=1&offset=1';
				//serviceObj2.send();	
			}
		}
		
		private var res:ResultEvent;
		
		// The result processing function
		public function processResult(response:ResultEvent):void
		{		
			this.res = response;
			
			var xml:XMLHandler = new XMLHandler();
			
			var XMLResults:XML = response.result as XML;
			XMLResults = NamespaceRemover.remove(XMLResults);
			XMLResults = NamespaceRemover.removeDefaultNamespaceFromXML(XMLResults);
			
			var connectionInfo:String = XMLResults.query;//String(e.result.query);

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
			
			if (total == 0)
			{	
				initLoad = true;
				
				var videoNotFound:VideoNotFoundEvent = new VideoNotFoundEvent(VideoNotFoundEvent.VIDEOSNOTFOUND);
				dispatchEvent(videoNotFound);
				
				var allseriesLoaded:AllSeriesLoadedEvent = new AllSeriesLoadedEvent(AllSeriesLoadedEvent.ALLSERIESLOADED);
				dispatchEvent(allseriesLoaded);
				
				return;
			}
			
			this.loadNextSeries = LoadNextSeries.getInstance();
			
			xmlSeries = new XMLListCollection(XMLResults.result);
			
			index = 0;
			
			getImage(xmlSeries.getItemAt(index).@id);
			//buildElement(index, "")
		}
		
		// The result processing function
		public function imageResultHandler(response:ResultEvent):void
		{
			initThumbnail = true;
			
			var XMLResults:XML = response.result as XML;
			
			XMLResults = NamespaceRemover.remove(XMLResults);
			XMLResults = NamespaceRemover.removeDefaultNamespaceFromXML(XMLResults);
			
			this.urlThumbnail = XMLResults.result.mediapackage.attachments.attachment.url[0];
			
			if(urlThumbnail == null)
			{
				this.urlThumbnail = "assets/splashscreen/nothumb.png";
			}
			
			if(xmlSeries != null)
			{
				//var imagePath:String = "mediapackage/attachments/attachment[1]/url";
				
				//var thumb:String = xmlVideos.getItemAt(thumbnail_index).thumbnail;
				var thumb:String = this.urlThumbnail;
				
				var r:RegExp = /\//g;
				var r2:RegExp = /\:/g;
				var s:String = thumb.replace(r, "");
				s = s.replace(r, "");
				
				imageName = s.replace(r2, "");
				imageName = "mh2go_thumb/" + imageName;
				
				var file:File;
				
				if(!File.userDirectory.resolvePath(imageName).exists) 
				{
					downLoader = new DownloadSeriesThumbnails();
					downLoader.addEventListener(SeriesThumbnailLoadedEvent.DOWNLOAD_COMPLETE, createNewElement);
					
					file = File.userDirectory.resolvePath(imageName);
					downLoader.download(thumb, file, "", "", index);
				}
				else
				{
					file = File.userDirectory.resolvePath(imageName);
					buildElement(index, file.url);
				}
			}
		}
		
		public function createNewElement(e:SeriesThumbnailLoadedEvent):void
		{
			downLoader.removeEventListener(SeriesThumbnailLoadedEvent.DOWNLOAD_COMPLETE, createNewElement);

			buildElement(e.index, e.file.url);
		}
	
		public function buildElement(i:uint, path:String):void
		{			
			if(index < xmlSeries.length)
			{
				//trace(index + " " + xmlSeries.getItemAt(i).@id)
				var mediapackage:Object = 
					"<mediapackage id='"+xmlSeries.getItemAt(i).@id+"'>" +
					"<title>"+xmlSeries.getItemAt(i).dcTitle+"</title>" +
					"<author>"+xmlSeries.getItemAt(i).dcCreator+"</author>" +
					"<contributer>"+xmlSeries.getItemAt(i).dcContributer+"</contributer>"+
					"<date>"+xmlSeries.getItemAt(i).dcCreated+"</date>"+
					"<thumbnail>"+path+"</thumbnail>"+
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
				
				var seriesLoaded:SeriesLoadedEvent = new SeriesLoadedEvent(SeriesLoadedEvent.SERIESLOADED);
				dispatchEvent(seriesLoaded);
			}
			else
			{
				initLoad = true;
				
				if(loadNextSeries.getPage() < loadNextSeries.getMaxPages())
				{
					mediapackage = 
						"<mediapackage id='update_button' type='series'><code>update_view</code></mediapackage>";
					
					xml = new XML(mediapackage);
					
					publicSeries.addItem(xml);
				}
				var allseriesLoaded:AllSeriesLoadedEvent = new AllSeriesLoadedEvent(AllSeriesLoadedEvent.ALLSERIESLOADED);
				dispatchEvent(allseriesLoaded);
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
		
		public function notConnected(event:FaultEvent):void 
		{	
			initLoad = true;
			initThumbnail = true;
			index = 0;
			xmlSeries = null;
			
			var notConnected:NotConnectedEvent = new NotConnectedEvent(NotConnectedEvent.NOTCONNECTED);
			dispatchEvent(notConnected);
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