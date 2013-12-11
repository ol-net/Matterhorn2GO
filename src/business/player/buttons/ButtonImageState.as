package business.player.buttons
{	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	
	public class ButtonImageState extends Sprite 
	{
		public function ButtonImageState(imagePath:String)
		{
			var loader : Loader = new Loader();
			loader.load(new URLRequest(imagePath));
			addChild(loader);
		}
	}
}