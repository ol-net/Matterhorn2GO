package views.skins.actionbar {
	import spark.skins.mobile.ActionBarSkin;
	
	public class CustomActionBarSkin extends ActionBarSkin {
		
		public function CustomActionBarSkin() {
			super();
			//backgroundActionBar is the name of the FXG file
			borderClass = backgroundActionBar;
		}
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void {

		}
	}
}