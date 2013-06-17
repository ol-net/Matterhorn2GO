package business.dbaccess.events
{
	import flash.events.Event;
	
	public class SQLHistoryLoadedEvent extends Event
	{		
		public static const HISTORYLOADED: String = "historyloadet";
		
		public function SQLHistoryLoadedEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}