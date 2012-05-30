package business.datahandler
{
	import events.VideoAvailableEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	
	public class CheckForPublicVideo extends EventDispatcher
	{
		static private var instance:CheckForPublicVideo;
		
		private var serviceObj:HTTPService;
		
		private var lernfunkUrl:String;
		
		private var vAvailable:Boolean = true;

		private var url:String = "http://vm083.rz.uos.de/release/webservices/lernfunk";
		
		private var count:int = 0;
		
		public function CheckForPublicVideo()
		{
			this.serviceObj = new HTTPService();
			
			var username:String = 'matterhorn2go';
			var password:String = 'muser2011';
			
			var base64:Base64Encoder = new Base64Encoder()
			base64.encode(username + ":" + password);
			var auth:String = "Basic " + base64.toString(); 
			
			serviceObj.headers = {Authorization:auth};  
			
			serviceObj.resultFormat = 'text';
			serviceObj.method = 'GET';
			serviceObj.requestTimeout = 15;
			serviceObj.useProxy = false;
			serviceObj.addEventListener(ResultEvent.RESULT, processResultLernfunk);			
		}
		
		static public function getInstance():CheckForPublicVideo 
		{
			if (instance == null) instance = new CheckForPublicVideo();
			
			return instance;
		}
		
		public function checkForPublicVideo(id:String):void
		{                           
			this.lernfunkUrl = url+'/?path=/mediaobject&format=xml&filter=<eq k="lrs_object_id" v="'+id+'"/>';
			serviceObj.url = lernfunkUrl;
			serviceObj.send();
		}
		
		// The result processing function
		public function processResultLernfunk(response:ResultEvent):void
		{
			var XMLResults:XML = new XML(response.result);
			//trace("LernfunkID: " + XMLResults.elem.lrs_object_id.text()[1])
			
			if(XMLResults.elem.lrs_object_id.text()[1] == undefined)
			{
				vAvailable = false;
			}
			else
			{
				vAvailable = true;
			}
			
			var videoAvailable:VideoAvailableEvent = new VideoAvailableEvent(VideoAvailableEvent.VIDEOAVAILABLE);
			dispatchEvent(videoAvailable);	
		}
		
		public function getVideoStatus():Boolean
		{
			return vAvailable;
		}
	}
}