/*
The Matterhorn2Go Project
Copyright (C) 2011  University of Osnabrück; Part of the Opencast Matterhorn Project

This project is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 
USA 
*/
package business.renderers
{
	import business.datahandler.XMLHandler;
	
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.collections.XMLListCollection;
	
	import spark.primitives.BitmapImage;
	import spark.primitives.Graphic;
	
	public class SegmentRenderer extends BaseRenderer
	{
		protected var timeField:TextField;
		protected var avatar:BitmapImage;
		protected var avatarHolder:Graphic;
		protected var background:DisplayObject;
		protected var backgroundClass:Class;
		protected var separator:DisplayObject;
		
		protected var paddingLeft:int;
		protected var paddingRight:int;
		protected var paddingBottom:int;
		protected var paddingTop:int;
		protected var horizontalGap:int;
		protected var verticalGap:int;
		
		protected var min_Height:Number = 50;
		protected var fontFamily:String = "_sans";
		protected var fontSize:Number = 15;
		protected var fontSizeName:Number = 10;
		
		protected var xpath_values:XMLHandler;
		
		//--------------------------------------------------------------------------
		//  Contructor
		//--------------------------------------------------------------------------
		
		public function SegmentRenderer()
		{
			percentWidth = 100;
			xpath_values = new XMLHandler();
		}
		public function timerend(time:String):String
		{
			var newtime:String;
			var temp:Number;
			var hour:Number = 0;
			var tmp:int = int(time);
			if (time=="0"){
				return ("Time:  00:00:00  ");
			} else {
				newtime = "Time:  ";
				tmp = (tmp/1000);
				temp = (tmp%60);
				tmp = (tmp/60);
				while (tmp>60) {
					tmp-=60;
					hour++;
				}
				if (hour<10){
					newtime += "0";
				}
				newtime += String(hour);
				newtime += ":";
				if (tmp<10) {
					newtime += "0";
				}
				newtime += String(tmp);
				newtime += ":";
				if (temp<10) {
					newtime += "0";
				}
				newtime += String(temp);
			}
			
			return newtime;
		}
		
		//--------------------------------------------------------------------------
		//  Override Protected Methods
		//--------------------------------------------------------------------------
		
		
		//--------------------------------------------------------------------------
		
		override protected function createChildren():void
		{	
			readStyles();
			
			setBackground();
			
			[Embed(source='/assets/separator.png')]
			var separatorAsset:Class;
			
			if( separatorAsset )
			{
				separator = new separatorAsset();
				addChild( separator );
			}
			
			timeField = new TextField();
			timeField.defaultTextFormat = new TextFormat(fontFamily, fontSize);
			timeField.autoSize = "left";
			addChild(timeField);
			
			avatarHolder = new Graphic();
			avatar = new BitmapImage();
			avatar.fillMode = "clip";
			avatarHolder.width = 120;
			avatarHolder.height = 80;
			avatarHolder.addElement( avatar );
			addChild( avatarHolder );
			
			// if the data is not null, set the text
			if(data)
				setValues();
			
		}
		
		protected function setBackgroundImageUp():Class
		{
			[Embed(source='/assets/background_up.png', scaleGridLeft=10, scaleGridTop=20, scaleGridRight=11, scaleGridBottom=21 )]
			var backgrAssetU:Class;
			
			return backgrAssetU;
		}
		
		protected function setBackgroundImageDown():Class
		{
			[Embed(source='/assets/background_down.png', scaleGridLeft=50, scaleGridTop=20, scaleGridRight=51, scaleGridBottom=21 )]
			var backgrAssetD:Class;
			
			return backgrAssetD;
		}
		
		protected function setBackground():void
		{	
			var backgroundAsset:Class;
			
			if(currentCSSState == "selected")
			{
				backgroundAsset = setBackgroundImageDown();
			}
			else
			{
				backgroundAsset = setBackgroundImageUp();
			}
			
			if( backgroundAsset && backgroundClass != backgroundAsset )
			{
				if( background && contains( background ) )
					removeChild( background );
				
				backgroundClass = backgroundAsset;
				background = new backgroundAsset();
				addChildAt( background, 0 );
				if( layoutHeight && layoutWidth )
				{
					background.width = layoutWidth;
					background.height = layoutHeight;
				}
			}
		}
		
		//--------------------------------------------------------------------------
		
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			avatarHolder.x = paddingLeft;
			avatarHolder.y = paddingTop;
			avatarHolder.setLayoutBoundsSize( avatarHolder.getPreferredBoundsWidth(), avatarHolder.getPreferredBoundsHeight() );
			
			timeField.x = avatarHolder.x + avatarHolder.width + horizontalGap;
			timeField.y = 40;
			
			layoutHeight = Math.max(paddingBottom, avatarHolder.height + paddingBottom + paddingTop );
			
			background.width = unscaledWidth;
			background.height = layoutHeight;
			
			separator.width = unscaledWidth;
			separator.y = layoutHeight - separator.height;
		}
		
		override public function getLayoutBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
			return layoutHeight;
		}
		
		override protected function setValues():void
		{				
			timeField.text = String(timerend(data.@time));
			avatar.source = String(data.previews.preview);
		}
		
		override protected function updateSkin():void
		{
			currentCSSState = ( selected ) ? "selected" : "up";
			
			setBackground();
		}
		
		protected function readStyles():void
		{
			paddingTop = 15;
			paddingLeft = 10; 
			paddingRight = 10;
			paddingBottom = 15;
			horizontalGap = 10;
		}
	}
	
}