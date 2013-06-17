package business.player.events
{
	import flash.events.Event;
	
	public class SeekTimeLoadetEvent extends Event
	{
		public static const SEEKTIMELOADED: String = "seektimeloadedevent";
		
		public function SeekTimeLoadetEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}