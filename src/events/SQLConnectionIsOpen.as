package events
{
	import flash.events.Event;
	
	public class SQLConnectionIsOpen extends Event
	{
		//public static const ERROR_EVENT:String   = "errorEvent";
		//public static const RESULT_EVENT:String  = "resultEvent";
		
		//public var data:*;

		public static const READERCOMPLETE: String = "readercomplete";
			
		public function SQLConnectionIsOpen(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}