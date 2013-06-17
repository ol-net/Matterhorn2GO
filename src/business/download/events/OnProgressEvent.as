package business.download.events
{
	import flash.events.Event;
	
	public class OnProgressEvent extends Event
	{
		public static const PROGRESS:String = "progress";
		
		public var percent:String = "";
		
		public function OnProgressEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}