package business.player
{
	import business.player.OProxyElement;
	import business.player.StrobeMediaContainer;
	
	import mx.core.FlexSprite;
	import mx.core.UIComponent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetLoader;
	import org.osmf.net.MulticastNetLoader;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	
	import flash.events.EventDispatcher;
	
	import flash.filesystem.File;
	
	import business.player.events.PlayerLoadedEvent;
	
	//Sets the size of the SWF
	public class OSMFPlayer extends EventDispatcher
	{
		import org.osmf.media.URLResource;
		
		private var component:UIComponent;
		private var component2:UIComponent;
		
		//URI of the media
		protected var progressive_path:String;
		protected var progressive_path2:String;
		//public var play:MediaPlayer;
		public var player:MediaPlayer;

		public var container_one:StrobeMediaContainer;
		public var container_two:StrobeMediaContainer;

		//public var container_one:MediaContainer;
		//public var container_two:MediaContainer;
		
		public var mediaFactory:DefaultMediaFactory;
		
		protected var parallelElement:ParallelElement;
		
		protected var height_size:Number = 0;
		protected var width_size:Number = 0;
		
		private var firstElement:VideoElement;
		private var secondElement:VideoElement;
		
		private var track:FlexSprite;
		private var progress:FlexSprite;
		
		private var progressbarContainer:FlexSprite;	
		
		private var oProxyElementTwo:OProxyElement;
		
		public function OSMFPlayer(video:String, video2:String)
		{
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.align = StageAlign.TOP_LEFT;
			//NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate, false, 0, true);

			//this.height_size = h;
			//this.width_size = w;
			
			this.progressive_path = video;
			this.progressive_path2 = video2;
			
			// Create a mediafactory instance
			//mediaFactory = new DefaultMediaFactory();
			
			// Create the left upper Media Element to play the presenter
			// and apply the meta-data
			//firstElement = mediaFactory.createMediaElement(new URLResource(progressive_path));
			//firstElement.addEventListener(MediaElementEvent.METADATA_ADD, loadFirstElement);

			//var resource:URLResource = new URLResource(progressive_path);
			//var mediaElement:VideoElement = mediaFactory.createMediaElement(resource);
			
			var net:NetLoader = new NetLoader();
			// Set the stream reconnect properties
			//net.reconnectTimeout = 2;
		
			//var nett:RTMPDynamicStreamingNetLoader = new RTMPDynamicStreamingNetLoader();
			//var url:DynamicStreamingResource = new DynamicStreamingResource(progressive_path);
			
			//firstElement = new VideoElement(new URLResource(progressive_path));
						
			if(progressive_path.search("mh2go") != -1) 
			{
				var _url:String = File.userDirectory.resolvePath(progressive_path).nativePath;   
				_url = "file:///" + _url;
				firstElement = new VideoElement(new URLResource( _url ), net);
			}
			else
			{ 
				firstElement = new VideoElement(new URLResource( progressive_path ), net);
			}
			
			//mediaFactory = new DefaultMediaFactory();
			//firstElement = mediaFactory.createMediaElement( new URLResource( progressive_path ));
			
			//firstElement.resource = new StreamingURLResource(progressive_path,StreamType.LIVE,NaN,NaN,null,false);
		
			//addSingleElementToContainer();
			
			if(progressive_path2 != "")
			{
				addParallelElementToContainer();
			}
			else
			{
				addSingleElementToContainer();
			}
		}
		
		public function addParallelElementToContainer():void
		{	
			createParallelElement();
			
			//the container for managing display and layout
			container_one = new StrobeMediaContainer();
			container_one.addMediaElement(firstElement);
			component = new UIComponent();
			component.addChild(container_one);	
			
			container_two = new StrobeMediaContainer();
			container_two.addMediaElement(oProxyElementTwo);
			component2 = new UIComponent();
			component2.addChild(container_two);	
			
			//the simplified api controller for media
			player = new MediaPlayer();
			player.media =  parallelElement;
		}
		
		public function addSingleElementToContainer():void
		{
			//the container for managing display and layout
			container_one = new StrobeMediaContainer();
						
			container_one.width = width_size;
		 	container_one.height = height_size;	
			container_one.addMediaElement(firstElement);
			
			component = new UIComponent();
			component.addChild(container_one);
			
			player = new MediaPlayer();
			player.media =  firstElement;
		}
		
		public function createParallelElement():void
		{
			// Create the down side Media Element to play the
			// presentation and apply the meta-data		
			//var secoundVideoElement:MediaElement = mediaFactory.createMediaElement( new URLResource( progressive_path_two ));
			
			var net2:NetLoader = new NetLoader();
			
			if(progressive_path2.search("mh2go") != -1) 
			{
				var _url:String = File.userDirectory.resolvePath(progressive_path2).nativePath;   
				_url = "file:///" + _url;
				secondElement = new VideoElement(new URLResource(_url), net2);
			}
			else
			{ 
				secondElement = new VideoElement(new URLResource( progressive_path2 ), net2);
			}
			
			oProxyElementTwo = new OProxyElement(secondElement);
			
			// Create the ParallelElement and add the left and right
			// elements to it
			parallelElement = new ParallelElement();
			parallelElement.addChild(firstElement);	
			parallelElement.addChild(oProxyElementTwo);
		}
		
		/*
		public function setSize(h_size:Number, w_size:Number):void
		{
			height_size = h_size;
			width_size = w_size;
			
			addSingleElementToContainer();
		}
		*/
		
		public function setContainerOneSize(width_size:Number, height_size:Number):void
		{
			container_one.width = width_size;
			container_one.height = height_size;	
		}
		
		public function setContainerTwoSize(width_size:Number, height_size:Number):void
		{
			container_two.width = width_size;
			container_two.height = height_size;	
		}
		
		public function getContainerOne():UIComponent
		{
			return component;
		}
		
		public function getContainerTwo():UIComponent
		{
			return component2;
		}	
		
		public function removeAll():void
		{
			// Und nun wieder entladen		
			//var loadTrait:LoadTrait = firstElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			//loadTrait.unload();
			
			//container_one.removeMediaElement(firstElement);
			//container_two.removeMediaElement(oProxyElementTwo);
		}
	}
}