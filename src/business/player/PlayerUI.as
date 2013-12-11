package business.player
{
	import business.player.buttons.BackViewButton;
	import business.player.buttons.NextPlayButton;
	import business.player.buttons.ParallelViewButton;
	import business.player.buttons.PauseButton;
	import business.player.buttons.PlayButton;
	import business.player.buttons.PresentationViewButton;
	import business.player.buttons.PresenterViewButton;
	import business.player.buttons.PrevPlayButton;
	
	import com.danielfreeman.madcomponents.UIButton;
	import com.danielfreeman.madcomponents.UILabel;
	import com.danielfreeman.madcomponents.UISlider;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.Capabilities;
	import flash.text.TextFormat;
	import flash.utils.Timer;
			
	public class PlayerUI extends Sprite
	{
		private var play_button:PlayButton;
		private var pause_button:PauseButton;
		private var prev_button:PrevPlayButton;
		private var next_button:NextPlayButton;
		
		private var parallel_button:ParallelViewButton;
		private var presenter_button:PresenterViewButton;
		private var presentation_button:PresentationViewButton;
		private var back_button:BackViewButton;
	
		private var slider:UISlider;
		
		private var time_label:UILabel;
		private var of_label:UILabel;
		private var duration_label:UILabel;
		
		private var updateSeekBar:Boolean;
		
		private var myTimer:Timer;
		
		private var steps:Number;
		
		public function PlayerUI()
		{
			createPlayerView();
		}
		
		public function createPlayerView():void 
		{
			time_label = new UILabel(this, 20, 17, "00:00:00", new TextFormat("Times",22,0xCCCCCC,false));
			time_label.visible = true;
			
			of_label = new UILabel(this, 107, 17, "of", new TextFormat("Times",22,0xCCCCCC,false));
			of_label.visible = true;
			
			duration_label = new UILabel(this, 132, 17, "00:00:00", new TextFormat("Times",22,0xCCCCCC,false));
			duration_label.visible = true;
			
			slider = new UISlider(this, 20, 295, new <uint>[], false, true);
			slider.value = 0;
			slider.alpha = 0.9;
			slider.visible = true;
			slider.x = 40;
			slider.height = 70;
			slider.alpha = 0.7;
			
			play_button = new PlayButton();
			play_button.visible = false;
			this.addChild(play_button);
			
			pause_button = new PauseButton();
			pause_button.visible = true;
			this.addChild(pause_button);
			
			next_button = new NextPlayButton();
			this.addChild(next_button);
			
			prev_button = new PrevPlayButton();
			this.addChild(prev_button);
			
			parallel_button = new ParallelViewButton();
			this.addChild(parallel_button);
			
			presenter_button = new PresenterViewButton();
			this.addChild(presenter_button);
			
			presentation_button = new PresentationViewButton();
			this.addChild(presentation_button);
			
			back_button = new BackViewButton();
			this.addChild(back_button);
		}
		
		public function setButtonPosition():void 
		{
			// slider
			var dpi:Number = Capabilities.screenDPI;
			
			if (dpi < 200) {
				if (stage.stageWidth < stage.stageHeight) {
					//trace("low")
					slider.y = stage.fullScreenHeight - 140
						
					prev_button.x = slider.x + stage.fullScreenWidth / 2 - 135;
					prev_button.y = slider.y + 80;
					
					play_button.x = slider.x + stage.fullScreenWidth / 2 - 65;
					play_button.y = slider.y + 80;
					
					pause_button.x = slider.x + stage.fullScreenWidth / 2 - 65;
					pause_button.y = slider.y + 80;
					
					next_button.x = slider.x + stage.fullScreenWidth / 2 + 5;
					next_button.y = slider.y + 80;
					
					presenter_button.x = slider.x + stage.fullScreenWidth / 2 - 168;
					presenter_button.y = 60;
					
					presentation_button.x = slider.x + stage.fullScreenWidth / 2 - 98;
					presentation_button.y = 60;
					
					parallel_button.x = slider.x + stage.fullScreenWidth / 2 - 28;
					parallel_button.y = 60;
					
					back_button.x = slider.x + stage.fullScreenWidth / 2 + 38;
					back_button.y = 60;	
				} else {
					slider.y = stage.fullScreenHeight - 140
						
					prev_button.x = slider.x + stage.fullScreenWidth / 2 - 135;
					prev_button.y = slider.y + 70;
					
					play_button.x = slider.x + stage.fullScreenWidth / 2 - 65;
					play_button.y = slider.y + 70;
					
					pause_button.x = slider.x + stage.fullScreenWidth / 2 - 65;
					pause_button.y = slider.y + 70;
					
					next_button.x = slider.x + stage.fullScreenWidth / 2 + 5;
					next_button.y = slider.y + 70;
					
					presenter_button.x = slider.x + stage.fullScreenWidth / 2 - 168;
					presenter_button.y = 60;
					
					presentation_button.x = slider.x + stage.fullScreenWidth / 2 - 98;
					presentation_button.y = 60;
					
					parallel_button.x = slider.x + stage.fullScreenWidth / 2 - 28;
					parallel_button.y = 60;
					
					back_button.x = slider.x + stage.fullScreenWidth / 2 + 38;
					back_button.y = 60;
				}
				
			} else if (dpi >= 200 && dpi < 280) {
				//trace("middle")
				if (stage.stageWidth < stage.stageHeight) {
					slider.y = stage.fullScreenHeight - 270
						
					prev_button.x = slider.x + stage.fullScreenWidth / 2 - 155;
					prev_button.y = slider.y + 80;
					
					play_button.x = slider.x + stage.fullScreenWidth / 2 - 75;
					play_button.y = slider.y + 80;
					
					pause_button.x = slider.x + stage.fullScreenWidth / 2 - 75;
					pause_button.y = slider.y + 80;
					
					next_button.x = slider.x + stage.fullScreenWidth / 2 + 5;
					next_button.y = slider.y + 80;
					
					presenter_button.x = slider.x + stage.fullScreenWidth / 2 - 195;
					presenter_button.y = 60;
					
					presentation_button.x = slider.x + stage.fullScreenWidth / 2 - 115;
					presentation_button.y = 60;
					
					parallel_button.x = slider.x + stage.fullScreenWidth / 2 - 35;
					parallel_button.y = 60;
					
					back_button.x = slider.x + stage.fullScreenWidth / 2 + 45;
					back_button.y = 60;	
				} else {
					slider.y = stage.fullScreenHeight - 180
						
					prev_button.x = slider.x + stage.fullScreenWidth / 2 - 165;
					prev_button.y = slider.y + 80;
					
					play_button.x = slider.x + stage.fullScreenWidth / 2 - 85;
					play_button.y = slider.y + 80;
					
					pause_button.x = slider.x + stage.fullScreenWidth / 2 - 85;
					pause_button.y = slider.y + 80;
					
					next_button.x = slider.x + stage.fullScreenWidth / 2 - 5;
					next_button.y = slider.y + 80;
					
					presenter_button.x = slider.x + stage.fullScreenWidth / 2 - 205;
					presenter_button.y = 60;
					
					presentation_button.x = slider.x + stage.fullScreenWidth / 2 - 125;
					presentation_button.y = 60;
					
					parallel_button.x = slider.x + stage.fullScreenWidth / 2 - 45;
					parallel_button.y = 60;
					
					back_button.x = slider.x + stage.fullScreenWidth / 2 + 35;
					back_button.y = 60;	
				}
				
			} else if (dpi >= 280) {
				//trace("full")
				if (stage.stageWidth < stage.stageHeight) {
					slider.y = stage.fullScreenHeight - 260
						
					prev_button.x = slider.x + stage.fullScreenWidth / 2 - 190;
					prev_button.y = slider.y + 70;
					
					play_button.x = slider.x + stage.fullScreenWidth / 2 - 85;
					play_button.y = slider.y + 70;
					
					pause_button.x = slider.x + stage.fullScreenWidth / 2 - 85;
					pause_button.y = slider.y + 70;
					
					next_button.x = slider.x + stage.fullScreenWidth / 2 + 20;
					next_button.y = slider.y + 70;
					
					presenter_button.x = slider.x + stage.fullScreenWidth / 2 - 245;
					presenter_button.y = 60;
					
					presentation_button.x = slider.x + stage.fullScreenWidth / 2 - 140;
					presentation_button.y = 60;
					
					parallel_button.x = slider.x + stage.fullScreenWidth / 2 - 35;
					parallel_button.y = 60;
					
					back_button.x = slider.x + stage.fullScreenWidth / 2 + 70;
					back_button.y = 60;	
				} else {
					slider.y = stage.fullScreenHeight - 200;
					
					prev_button.x = slider.x + stage.fullScreenWidth / 2 - 200;
					prev_button.y = slider.y + 70;
					
					play_button.x = slider.x + stage.fullScreenWidth / 2 - 95;
					play_button.y = slider.y + 70;
					
					pause_button.x = slider.x + stage.fullScreenWidth / 2 - 95;
					pause_button.y = slider.y + 70;
					
					next_button.x = slider.x + stage.fullScreenWidth / 2 + 10;
					next_button.y = slider.y + 70;
					
					presenter_button.x = slider.x + stage.fullScreenWidth / 2 - 255;
					presenter_button.y = 60;
					
					presentation_button.x = slider.x + stage.fullScreenWidth / 2 - 150;
					presentation_button.y = 60;
					
					parallel_button.x = slider.x + stage.fullScreenWidth / 2 - 45;
					parallel_button.y = 60;
					
					back_button.x = slider.x + stage.fullScreenWidth / 2 + 60;
					back_button.y = 60;
				}
			} 
			
			slider.fixwidth = stage.fullScreenWidth - 80;
		}
		
		public function timerend(time:Number):String
		{
			var newtime:String = "";
			var temp:Number;
			var hour:Number = 0;
			var tmp:int = int(time);
			
			if (time==0)
			{
				return ("00:00:00");
			} 
			else 
			{
				tmp = (tmp/1000);
				temp = (tmp%60);
				tmp = (tmp/60);
				
				while (tmp>=60) 
				{
					tmp-=60;
					hour++;
				}
				if (hour<10)
				{
					newtime += "0";
				}
				newtime += String(hour);
				newtime += ":";
				
				if (tmp<10) 
				{
					newtime += "0";
				}
				newtime += String(tmp);
				newtime += ":";
				
				if (temp<10) 
				{
					newtime += "0";
				}
				newtime += String(temp);
			}
			return newtime;
		}
		
		public function getUISlider():UISlider
		{
			return slider;
		}
		
		public function getTimeLabel():UILabel 
		{
			return time_label;
		}
		
		public function getOfLabel():UILabel 
		{
			return of_label;
		}
		
		public function getDurationLabel():UILabel
		{
			return duration_label;
		}
		
		public function getPlayButton():PlayButton
		{
			return play_button;
		}
		
		public function getPauseButton():PauseButton
		{
			return pause_button;
		}
		
		public function getNextButton():NextPlayButton
		{
			return next_button;
		}
		
		public function getPrevButton():PrevPlayButton
		{
			return prev_button;
		}
		
		public function getParallelButton():ParallelViewButton
		{
			return parallel_button;
		}
		
		public function getPresenterButton():PresenterViewButton
		{
			return presenter_button;
		}
		
		public function getPresentationButton():PresentationViewButton
		{
			return presentation_button;
		}
		
		public function getBackButton():BackViewButton
		{
			return back_button;
		}
	}
}