package business.dbaccess.events
{
	import flash.events.Event;
	
	public class SQLVideoInsideEvent extends Event
	{
		public static const SELECTVIDEOCOMPLETE: String = "selectionvideocomplete";
		
		public function SQLVideoInsideEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}