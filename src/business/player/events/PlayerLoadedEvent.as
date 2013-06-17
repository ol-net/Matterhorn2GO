package business.player.events
{
	import flash.events.Event;
	
	public class PlayerLoadedEvent extends Event
	{
		public static const PLAYERLOADED: String = "playerloadedevent";
		
		public function PlayerLoadedEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}