package business.download.events
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.media.Sound;
	
	public class DownloadEvent extends Event
	{
		public static const DOWNLOAD_COMPLETE:String = "DownloadComplete";
		
		public var url:String;
		public var file:File;
		public var index:uint;
		
		public function DownloadEvent(type:String, url:String, file:File, index:uint)
		{
			super(type, true);
			this.url = url;
			this.file = file;
			this.index = index;
		}
		
		override public function toString():String{
			return super.toString() + ": "+ url + " -> "+file.url;
		}
	}
}