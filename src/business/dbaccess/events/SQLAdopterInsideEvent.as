package business.dbaccess.events
{
	import flash.events.Event;
	
	public class SQLAdopterInsideEvent extends Event
	{
		public static const SELECTCOMPLETE: String = "selectioncomplete";
		
		public function SQLAdopterInsideEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}