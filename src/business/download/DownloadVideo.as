package business.download
{	
	import business.download.events.DownloadEvent;
	import business.download.events.OnProgressEvent;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.collections.XMLListCollection;
	
	public class DownloadVideo extends EventDispatcher
	{
		[Event(name="DownloadComplete", type="events.DownloadEvent")]
		
		private var file:File;
		private var url:String;
		private var urlStream:URLStream;
		
		private var vName:String;
		private var vID:String;
		private var vType:String;
		
		private var dataFile:File;
		
		private var index:uint;
		
		private var xmlList:XMLListCollection = new XMLListCollection();
		
		private var downloadingProcess:Boolean;
		
		static private var instance:DownloadVideo;
		
		static public function getInstance():DownloadVideo
		{
			if (instance == null) 
			{
				instance = new DownloadVideo();
			}
			return instance;
		}
		
		/*
		public function DownloadVideo()
		{

		}
		*/
		
		private function stopDownload(event:IOErrorEvent):void
		{
			//trace("fail")
		}
		
		private var xml:XML;
		
		public function download(formUrl:String, videoID:String, videoName:String, vType:String):void 
		{
			if(xmlList.length == 0)
			{
				downloadingProcess = true;
			}
			
			var download:Object = 
				"<download>" +
					"<url>"+formUrl+"</url>" +
					"<id>"+videoID+"</id>" +
					"<video>"+videoName+"</video>" +
					"<type>"+vType+"</type>" +
				"</download>";
			
			xml = new XML(download);
			xmlList.addItem(xml);
			
			if(downloadingProcess)
			{
				downloading();
				downloadingProcess = false;
			}
		}
		
		private function downloading():void
		{
			urlStream = new URLStream();
			urlStream.addEventListener(ProgressEvent.PROGRESS, onProgressEvent); 
			urlStream.addEventListener(Event.COMPLETE, onCompleteEvent);			
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, stopDownload);
			
			this.url = xmlList.getItemAt(0).url; //formUrl;
			this.vID = xmlList.getItemAt(0).id;//videoPath;
			this.vName = xmlList.getItemAt(0).video;//videoName;
			this.vType = xmlList.getItemAt(0).type;//vType; 
			
			this.file = File.userDirectory.resolvePath(vName);
			
			urlStream.load(new URLRequest(url));
		}
		
		private function onProgressEvent(event:ProgressEvent):void 
		{	
			var loader:URLStream = event.target as URLStream;
			
			var bytes:ByteArray = new ByteArray();
			
			loader.readBytes(bytes);
			
			var writer:FileStream = new FileStream();
			
			writer.open(this.file, FileMode.APPEND);
			
			writer.writeBytes(bytes);
			writer.close();

			var pro:OnProgressEvent = new OnProgressEvent(OnProgressEvent.PROGRESS);
			pro.percent = String(uint(event.bytesLoaded/event.bytesTotal * 100));
			dispatchEvent(pro);
		}
		
		private function onCompleteEvent(event:Event):void 
		{	
			urlStream.removeEventListener(Event.COMPLETE, onCompleteEvent);
			urlStream.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			
			urlStream.close();
			
			xmlList.removeItemAt(0);
			
			if(xmlList.length > 0)
			{
					downloading();
			}
			else
			{
				// dispatch additional DownloadEvent
				dispatchEvent(new DownloadEvent(DownloadEvent.DOWNLOAD_COMPLETE, url, file, 0));
			}
		
			downloadingProcess = true;
		}
	}
}