package views
{
	import flash.display.StageAspectRatio;
	import spark.preloaders.SplashScreenImage;
	import spark.preloaders.SplashScreenImageSource;
	
	public class DynamicSplashScreenImage extends SplashScreenImage
	{
		
		protected var s1:SplashScreenImageSource = new SplashScreenImageSource()
		protected var s2:SplashScreenImageSource = new SplashScreenImageSource();
		protected var s3:SplashScreenImageSource = new SplashScreenImageSource();
		
		
		[Embed(source='assets/Default.png')]
		protected var s1Source:Class;
		
		[Embed(source="assets/Default@2x.png")]
		protected var s2Source:Class;
		
		[Embed(source='assets/Default-568h@2x.png')]
		protected var s3Source:Class;
		
		public function DynamicSplashScreenImage()
		{
			super();
		}
		
		
		override public function getImageClass(aspectRatio:String, dpi:Number, resolution:Number):Class
		{
			
			var splashClass:Class;
			
			s1.source = s1Source;
			
			s2.source = s2Source;
			s2.minResolution = 920;
			s2.aspectRatio = flash.display.StageAspectRatio.PORTRAIT
			
			s3.source = s3Source;
			s3.minResolution = 1096;
			s3.aspectRatio = flash.display.StageAspectRatio.PORTRAIT
			
			switch(resolution){
				
				// iphone 5
				case 1096:
					
					splashClass = s3Source;
					break;
				
				// iPhone 4
				case 920:
					
					splashClass = s2Source;        
					break;
				
				//iPhone 3
				default:
					
					splashClass = s1Source;
					break;
				
			}
			
			return splashClass;
		}
	}
}