package business.player.buttons
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.system.Capabilities;
	
	public class PresentationViewButton extends SimpleButton 
	{
		private var dpi:Number = Capabilities.screenDPI;
		
		public function PresentationViewButton(upState : DisplayObject = null, overState : DisplayObject = null, downState : DisplayObject = null, hitTestState : DisplayObject = null)
		{
			upState = new ButtonImageState(getUpImage());
			overState = new ButtonImageState(getDownImage());
			downState = new ButtonImageState(getDownImage());
			hitTestState = new ButtonImageState(getUpImage());
			
			super(upState, overState, downState, hitTestState);
		}
		
		public function getUpImage():String {
			
			if (dpi < 200) {
				return "business/player/assets/presentation/slides48x48.png";
			} else if (dpi >= 200 && dpi < 280) {
				return "business/player/assets/presentation/slides72x72.png";
			} else if (dpi >= 280) {
				return "business/player/assets/presentation/slides96x96.png";
			} else {
				return "business/player/assets/presentation/slides96x96.png";
			}
		}
		
		public function getDownImage():String {
			
			if (dpi < 200) {
				return "business/player/assets/presentation/slides48x48_active.png";
			} else if (dpi >= 200 && dpi < 280) {
				return "business/player/assets/presentation/slides72x72_active.png";
			} else if (dpi >= 280) {
				return "business/player/assets/presentation/slides96x96_active.png";
			} else {
				return "business/player/assets/presentation/slides96x96_active.png";
			}
		}
	}
}