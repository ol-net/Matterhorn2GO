package business.download
{	
	import business.download.events.DownloadEvent;
	
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
	
	public class DownloadThumbnails extends EventDispatcher
	{
		[Event(name="DownloadComplete", type="events.DownloadEvent")]
		
		private var file:File;
		private var url:String;
		private var urlStream:URLStream = new URLStream();
		
		private var vName:String;
		private var tPath:String;
		
		private var index:uint;
		
		private var dataFile:File;
		
		public function DownloadThumbnails()
		{
			urlStream = new URLStream();
			urlStream.addEventListener(ProgressEvent.PROGRESS, onProgressEvent); 
			urlStream.addEventListener(Event.COMPLETE, onCompleteEvent);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, loadDefaultImage);
		}
		
		public function download(formUrl:String, toFile:File, videoName:String, thumbnailPath:String, index:uint):void 
		{
			this.vName = videoName;
			this.tPath = thumbnailPath;
			this.url = formUrl;
			this.file = toFile;
			this.index = index;

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
		}
		
		private function onCompleteEvent(event:Event):void 
		{	
			urlStream.removeEventListener(Event.COMPLETE, onCompleteEvent);
			urlStream.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR, loadDefaultImage);
			
			//dispatchEvent(event.clone());
			
			// dispatch additional DownloadEvent
			dispatchEvent(new DownloadEvent(DownloadEvent.DOWNLOAD_COMPLETE, url, file, index));
			
			urlStream.close();
		}
		
		private function loadDefaultImage(event:IOErrorEvent):void
		{
			urlStream.removeEventListener(Event.COMPLETE, onCompleteEvent);
			urlStream.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR, loadDefaultImage);

			if(File.userDirectory.resolvePath(this.file.url).exists)
				File.userDirectory.resolvePath(this.file.url).deleteFileAsync();
				
			var thumb:String = "assets/splashscreen/nothumb.png";
			var imageName:String = "mh2go_thumb/assetssplashscreennothumb.png";
			
			var file:File;
			
			if(!File.userDirectory.resolvePath(imageName).exists) 
			{	
				file = File.userDirectory.resolvePath(imageName);
				download(thumb, file, "", "", index)
			}
			else
			{
				file = File.userDirectory.resolvePath(imageName);
				dispatchEvent(new DownloadEvent(DownloadEvent.DOWNLOAD_COMPLETE, thumb, file, index));
			}
			
			urlStream.close();
		}
	}
}