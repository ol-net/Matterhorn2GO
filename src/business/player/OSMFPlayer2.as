package business.player
{	
	import flash.filesystem.File;
	
	import mx.core.UIComponent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetLoader;
	
	public class OSMFPlayer2
	{		
		//URI of the media
		protected var progressive_path:String;
		protected var progressive_path2:String;
		
		public var container_one:StrobeMediaContainer;
		public var container_two:StrobeMediaContainer;
		
		public var player:MediaPlayer;
		
		//public var container_two:MediaContainer;
		
		protected var parallelElement:ParallelElement;
		
		protected var height_size:Number = 0;
		protected var width_size:Number = 0;
		
		private var firstElement:VideoElement;
		private var secondElement:VideoElement;
		
		private var oProxyElementTwo:OProxyElement;
		
		public function OSMFPlayer2(video:String, video2:String)
		{
			this.progressive_path = video;
			this.progressive_path2 = video2;
			
			// Create the left upper Media Element to play the presenter
			// and apply the meta-data
			
			if(progressive_path.search("mh2go") != -1) 
			{
				var _url:String = File.documentsDirectory.resolvePath(progressive_path).nativePath; 
				//progressive_path = "file:///" + _url;
			}
			//trace(progressive_path);
			firstElement = new VideoElement(new URLResource(progressive_path), new NetLoader());
			
			if(progressive_path2 != "")
			{
				if(progressive_path2.search("mh2go") != -1) 
				{
					_url = File.documentsDirectory.resolvePath(progressive_path2).nativePath;   
					//progressive_path2 = "file:///" + _url;
				}
				
				// Create the down side Media Element to play the
				// presentation and apply the meta-data		
				secondElement = new VideoElement(new URLResource(progressive_path2), new NetLoader());
				
				oProxyElementTwo = new OProxyElement(secondElement);
				
				addParallelElementToContainer();
			}
			else
			{
				addSingleElementToContainer();
			}
		}
		
		public function setSize(h_size:Number, w_size:Number):void
		{
			height_size = h_size;
			width_size = w_size;
			
			addSingleElementToContainer();
		}
		
		public function addSingleElementToContainer():void
		{
			//the container for managing display and layout
			container_one = new StrobeMediaContainer();
			container_one.addMediaElement(firstElement);
			
			container_one.width = width_size;
			container_one.height = height_size;	
			
			player = new MediaPlayer(firstElement);
			player.autoPlay = true;
		}
		
		public function addParallelElementToContainer():void
		{	
			//createParallelElement();
			
			// Create the ParallelElement and add the left and right
			// elements to it
			parallelElement = new ParallelElement();
			parallelElement.addChild(firstElement);	
			parallelElement.addChild(oProxyElementTwo);
			
			//the container for managing display and layout
			container_one = new StrobeMediaContainer();
			container_one.addMediaElement(firstElement);
			
			container_two = new StrobeMediaContainer();
			container_two.addMediaElement(oProxyElementTwo);
			
			container_one.width = width_size;
			container_one.height = height_size;	
			
			container_two.width = width_size;
			container_two.height = height_size;	
			
			//the simplified api controller for media
			player = new MediaPlayer();
			player.media = parallelElement;
		}
		
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
			var component:UIComponent = new UIComponent();
			component.addChild(container_one);
			
			return component;
		}
		
		public function getContainerTwo():UIComponent
		{
			var component:UIComponent = new UIComponent();
			component.addChild(container_two);	
			
			return component;
		}	
	}
}