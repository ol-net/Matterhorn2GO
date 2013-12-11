package business.player.events
{
	import flash.events.Event;
	
	public class ClosePlayerEvent extends Event
	{
		public static const CLOSED: String = "closeevent";
		
		public function ClosePlayerEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}