package business.player
{
	import flash.events.EventDispatcher;
	
	import business.player.events.ClosePlayerEvent;

	public class ClosePlayerHandler extends EventDispatcher
	{
		static private var instance:ClosePlayerHandler;
		
		public static function getInstance():ClosePlayerHandler
		{
			if (instance == null) instance = new ClosePlayerHandler();
			
			return instance;
		}
		
		public function close():void 
		{
			var close:ClosePlayerEvent = new ClosePlayerEvent(ClosePlayerEvent.CLOSED);
			this.dispatchEvent(close);
		}
	}
}