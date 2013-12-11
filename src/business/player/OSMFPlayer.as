package business.player
{
	import business.player.buttons.PauseButton;
	import business.player.buttons.PlayButton;
	import business.player.events.ClosePlayerEvent;
	
	import com.danielfreeman.madcomponents.UIButton;
	import com.danielfreeman.madcomponents.UILabel;
	import com.danielfreeman.madcomponents.UISlider;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import mx.core.mx_internal;
	import mx.events.ResizeEvent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetLoader;
		
	import business.core.GetVideoPathHandler;

	[SWF(backgroundColor="#000000")]
	public class OSMFPlayer extends Sprite {
		
		private var mediaPlayer:MediaPlayer;
		
		private var updateSeekBar:Boolean;
		
		private var container:Sprite = new Sprite();
		
		private var mediaContainer:MediaContainer;
		
		private var maxsize:Number;
		
		protected var myTimer:Timer;
		
		private var steps:Number;
		
		private var videoHeight:Number;
		private var videoWidth:Number;
		
		private var resize:Boolean = false;
		
		private var parallelElement:ParallelElement;
		private var oProxyElement:OProxyElement;
		
		private var mediaContainer2nd:MediaContainer;
		
		private var presenter:Boolean = false;
		private var presentation:Boolean = false;
		private var parallel:Boolean = false;
		
		private var playerUI:PlayerUI = new PlayerUI();
		
		private var videoPath:String;
		private var videoPath2nd:String;
		
		private var singleVideo:Boolean;
				
		public function OSMFPlayer()
		{
			var getVideo:GetVideoPathHandler = GetVideoPathHandler.getInstance();
			
			//this.videoPath = "http://video2.virtuos.uni-osnabrueck.de:1935/matterhorn-14/mp4:dozent.mp4/playlist.m3u8";
			//this.videoPath2nd ="http://video2.virtuos.uni-osnabrueck.de:1935/matterhorn-14/mp4:vga.mp4/playlist.m3u8";
			
			//this.videoPath = "http://video2.virtuos.uni-osnabrueck.de:1935/matterhorn-14/mp4:dozent.mp4/playlist.m3u8";
			//this.videoPath2nd = "";//"http://video2.virtuos.uni-osnabrueck.de:1935/matterhorn-14/mp4:vga.mp4/playlist.m3u8";
			
			//videoPath = "http://video2.virtuos.uni-osnabrueck.de:1935/matterhorn-14/mp4:video.m4v/playlist.m3u8"; 
			
			this.videoPath = getVideo.path1;
			this.videoPath2nd = getVideo.path2;
			
			//trace(videoPath)
			//trace(videoPath2nd)
		}
			
		public function startVideo():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			setTimer();

			if (videoPath2nd == "") {
				singleVideo = true;
				parallel = false;
				presenter = true;
				presentation = false;
				loadSingleView(videoPath);
				
				playerUI.getParallelButton().visible = false;
				playerUI.getPresenterButton().visible = false;
				playerUI.getPresentationButton().visible = false;
				
			} else {
				singleVideo = false;
				parallel = true;
				presenter = false;
				presentation = false;
				loadParallelView(videoPath, videoPath2nd);
			}
			
			playerUI.getUISlider().addEventListener(MouseEvent.MOUSE_DOWN, stopUpdate);
			playerUI.getUISlider().addEventListener(MouseEvent.MOUSE_UP, startUpdate);
			playerUI.getUISlider().addEventListener(MouseEvent.MOUSE_MOVE, updateTime);
			
			playerUI.getPlayButton().addEventListener(MouseEvent.CLICK, play);
			playerUI.getPauseButton().addEventListener(MouseEvent.CLICK, pause);
			playerUI.getParallelButton().addEventListener(MouseEvent.CLICK, setParallelView);
			playerUI.getPresenterButton().addEventListener(MouseEvent.CLICK, setPresenterView);
			playerUI.getPresentationButton().addEventListener(MouseEvent.CLICK, setPresentationView);
			playerUI.getBackButton().addEventListener(MouseEvent.CLICK, popView);
			playerUI.getNextButton().addEventListener(MouseEvent.CLICK, nextPlay);
			playerUI.getPrevButton().addEventListener(MouseEvent.CLICK, prevPlay);
						
			this.addChild(container);
			this.addEventListener(MouseEvent.MOUSE_UP, getButtonPanel);
			
			resizeHandler(null);
		
			stage.addEventListener(MouseEvent.CLICK, getButtonPanel);
			stage.addEventListener(Event.RESIZE, resizeHandler);
		}
		
		public function loadSingleView(videoPath:String):void {
			
			var net:NetLoader = new NetLoader();
			net.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, readyToGo);
			
			var resource:URLResource = new URLResource(videoPath);
			
			var element:VideoElement = new VideoElement(resource, net);
			
			mediaPlayer = new MediaPlayer();
			mediaPlayer.media = element;
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChangeHandler);
			
			mediaContainer= new MediaContainer();
			mediaContainer.addMediaElement(element);
			
			container.addChild(mediaContainer);
			container.addChild(playerUI);
		}
		
		public function loadParallelView(videoPath:String, videoPath2nd:String):void {
			
			var net:NetLoader = new NetLoader();
			net.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, readyToGo);
			
			var net2nd:NetLoader = new NetLoader();
			net2nd.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, readyToGo2);
			
			var resource:URLResource = new URLResource(videoPath);
			var resource2nd:URLResource = new URLResource(videoPath2nd);
			
			var element:VideoElement = new VideoElement(resource, net);
			var element2nd:VideoElement = new VideoElement(resource2nd, net2nd);
			oProxyElement = new OProxyElement(element2nd);
			
			// Create the ParallelElement and add the left and right elements to it
			parallelElement = new ParallelElement();
			parallelElement.addChild(element);	
			parallelElement.addChild(oProxyElement);
			
			mediaPlayer = new MediaPlayer();
			mediaPlayer.media = parallelElement;
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChangeHandler);
			
			mediaContainer= new MediaContainer();
			mediaContainer.addMediaElement(element);
			
			mediaContainer2nd= new MediaContainer();
			mediaContainer2nd.addMediaElement(oProxyElement);
			
			container.addChild(mediaContainer);
			container.addChild(mediaContainer2nd);
			container.addChild(playerUI);
		}
		
		public function play(e:MouseEvent):void 
		{
			playerUI.getPlayButton().visible = false;
			playerUI.getPauseButton().x = playerUI.getPlayButton().x;
			playerUI.getPauseButton().visible = true;
			
			if (mediaPlayer != null) {
				if (mediaPlayer.paused)
					mediaPlayer.play();
			}
		}
		
		public function pause(e:MouseEvent):void 
		{
			playerUI.getPlayButton().visible = true;
			playerUI.getPlayButton().x = playerUI.getPauseButton().x;
			playerUI.getPauseButton().visible = false;
			
			if (mediaPlayer != null) {
				if (mediaPlayer.playing)
					mediaPlayer.pause();
			}
		}
		
		public function prevPlay(e:MouseEvent):void
		{
			mediaPlayer.seek(playerUI.getUISlider().value / steps - 5);
		}
		
		public function nextPlay(e:MouseEvent):void
		{
			mediaPlayer.seek(playerUI.getUISlider().value / steps + 5);
		}
		
		public function resizeHandler(e:Event):void {

			if (parallel) {
				setParallelContainer();
			} else if (presenter) {
				setPresenterContainer();
			} else if (presentation) {
				setPresentationContainer();
			}
			
			if (playerUI != null)
				playerUI.setButtonPosition();
		}
		
		public function setParallelContainer():void {
			
			if (stage != null) {
				if (stage.stageWidth < stage.stageHeight) {
					mediaContainer.height = stage.fullScreenHeight / 2;
					mediaContainer.width = stage.fullScreenWidth;
					
					mediaContainer2nd.height = stage.fullScreenHeight / 2;
					mediaContainer2nd.width = stage.fullScreenWidth;
					mediaContainer2nd.x = 0;
					mediaContainer2nd.y = stage.fullScreenHeight / 2;
				} else {
					mediaContainer.height = stage.fullScreenHeight;
					mediaContainer.width = stage.fullScreenWidth / 2;
					
					mediaContainer2nd.height = stage.fullScreenHeight;
					mediaContainer2nd.width = stage.fullScreenWidth / 2;
					mediaContainer2nd.x = stage.fullScreenWidth / 2;
					mediaContainer2nd.y = 0;
				}
			}
		}
		
		public function setPresenterContainer():void {
			
			if (stage != null) {
				mediaContainer.height = stage.fullScreenHeight;
				mediaContainer.width = stage.fullScreenWidth;
				
				if (mediaContainer2nd != null) {
					mediaContainer2nd.height = 0;
					mediaContainer2nd.width = 0;
				}
			}
		}
		
		public function setPresentationContainer():void {
			
			if (stage != null) {
				mediaContainer2nd.height = stage.fullScreenHeight;
				mediaContainer2nd.width = stage.fullScreenWidth;
				mediaContainer2nd.x = 0;
				mediaContainer2nd.y = 0;
				
				if (mediaContainer != null) {
					mediaContainer.height = 0;
					mediaContainer.width = 0;
				}
			}
		}
		
		public function setParallelView(e:MouseEvent):void
		{
			parallel = true;
			presenter = false;
			presentation = false;
			setParallelContainer();
		}
		
		public function setPresenterView(e:MouseEvent):void
		{
			parallel = false;
			presenter = true;
			presentation = false;
			setPresenterContainer();
		}
		
		public function setPresentationView(e:MouseEvent):void
		{
			parallel = false;
			presenter = false;
			presentation = true;
			setPresentationContainer();
		}
		
		public function popView(e:MouseEvent):void
		{
			mediaPlayer.stop();
			
			playerUI.getUISlider().removeEventListener(MouseEvent.MOUSE_DOWN, stopUpdate);
			playerUI.getUISlider().removeEventListener(MouseEvent.MOUSE_UP, startUpdate);
			playerUI.getUISlider().removeEventListener(MouseEvent.MOUSE_MOVE, updateTime);
			
			playerUI.getPlayButton().removeEventListener(MouseEvent.CLICK, play);
			playerUI.getPauseButton().removeEventListener(MouseEvent.CLICK, pause);
			playerUI.getParallelButton().removeEventListener(MouseEvent.CLICK, setParallelView);
			playerUI.getPresenterButton().removeEventListener(MouseEvent.CLICK, setPresenterView);
			playerUI.getPresentationButton().removeEventListener(MouseEvent.CLICK, setPresentationView);
			playerUI.getBackButton().removeEventListener(MouseEvent.CLICK, popView);
			playerUI.getNextButton().removeEventListener(MouseEvent.CLICK, nextPlay);
			playerUI.getPrevButton().removeEventListener(MouseEvent.CLICK, prevPlay);
			
			this.removeEventListener(MouseEvent.MOUSE_UP, getButtonPanel);
			
			stage.removeEventListener(MouseEvent.CLICK, getButtonPanel);
			stage.removeEventListener(Event.RESIZE, resizeHandler);
			
			var closePlayer:ClosePlayerHandler = ClosePlayerHandler.getInstance();
			closePlayer.close();
			
			this.parent.removeChild(this);
		}
		
		public function readyToGo(event:LoaderEvent):void {
			
			if(event.newState == 'ready') {
				mediaPlayer.play();
			}
		}
		
		public function readyToGo2(event:LoaderEvent):void {
			
			if(event.newState == 'ready') {
				mediaPlayer.play();
			}
		}
		
		public function getButtonPanel(event:MouseEvent):void
		{
			if(myTimer.running)
				myTimer.reset();
			
			myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timer);
			
			playerUI.getUISlider().visible = true;
			playerUI.getTimeLabel().visible = true;
			playerUI.getOfLabel().visible = true;
			playerUI.getDurationLabel().visible = true;
			
			if (!playerUI.getPlayButton().visible && !playerUI.getPauseButton().visible) {
				if (!mediaPlayer.playing) {
					playerUI.getPlayButton().visible = true;
				} else {
					playerUI.getPauseButton().visible = true;
				}
			}
			
			playerUI.getNextButton().visible = true;
			playerUI.getPrevButton().visible = true;
			
			if (singleVideo) {
				playerUI.getParallelButton().visible = false;
				playerUI.getPresenterButton().visible = false;
				playerUI.getPresentationButton().visible = false;
			} else {
				playerUI.getParallelButton().visible = true;
				playerUI.getPresenterButton().visible = true;
				playerUI.getPresentationButton().visible = true;
			}
			playerUI.getBackButton().visible = true;
			setTimer();
		}
		
		public function timer(event:TimerEvent):void
		{
			if (!updateSeekBar) {		
				myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timer);
				
				playerUI.getUISlider().visible = false;
				playerUI.getTimeLabel().visible = false;
				playerUI.getPlayButton().visible = false;
				playerUI.getPauseButton().visible = false;
				playerUI.getOfLabel().visible = false;
				playerUI.getDurationLabel().visible = false;
				playerUI.getNextButton().visible = false;
				playerUI.getPrevButton().visible = false;
				playerUI.getParallelButton().visible = false;
				playerUI.getPresenterButton().visible = false;
				playerUI.getPresentationButton().visible = false;
				playerUI.getBackButton().visible = false;
			}
		}
		
		public function setTimer():void
		{
			myTimer = new Timer(6000, 1); 
			myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timer);
			myTimer.start();
		}
		
		private function updateTime(e:MouseEvent):void
		{
			playerUI.getTimeLabel().text = playerUI.timerend(playerUI.getUISlider().value / steps * 1000);
		}
		
		private function onCurrentTimeChangeHandler(e:TimeEvent):void
		{	
			var cT:Number = Math.round(mediaPlayer.currentTime);
			var dT:Number = Math.round(mediaPlayer.duration);
			
			if(cT >= dT)
			{				
				playerUI.getTimeLabel().text == "00:00:00";
				mediaPlayer.seek(0);
				playerUI.getUISlider().value = 0;
				return;
			}
			
			if(playerUI.getTimeLabel().text == "00:00:00" && !updateSeekBar)
			{
				playerUI.getDurationLabel().text = playerUI.timerend(mediaPlayer.duration * 1000);
				maxsize = mediaPlayer.duration - 1;
				steps = 1 / maxsize;
			}
			
			if(updateSeekBar) {
				onSeek(playerUI.getUISlider().value);
			} else {		
				playerUI.getUISlider().value = e.time * steps;
				playerUI.getTimeLabel().text = playerUI.timerend(e.time * 1000);
			}
		}
		
		private function onSeek(loc:Number):void 
		{  	
			mediaPlayer.seek(loc / steps);
		}
		
		private function stopUpdate(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateTime);
			stage.addEventListener(MouseEvent.MOUSE_UP, startUpdate);
			
			if(myTimer.running) {
				myTimer.stop();
			}
			
			this.removeEventListener(TimerEvent.TIMER_COMPLETE, timer);
			
			updateSeekBar = true;
		}
		
		private function startUpdate(e:MouseEvent):void
		{	
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateTime);
			stage.removeEventListener(MouseEvent.MOUSE_UP, startUpdate);
			
			updateSeekBar = false;
			setTimer();
		}
	}
} 	