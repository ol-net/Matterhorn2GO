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
package business.datahandler.renderers
{	
	import business.datahandler.XMLHandler;
	
	import flash.display.DisplayObject;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.collections.XMLListCollection;
	
	import spark.primitives.BitmapImage;
	import spark.primitives.Graphic;
	
	import business.datahandler.URLClass;
	
	import business.datahandler.events.VideoAvailableEvent;
	
	public class SeriesItemRenderer extends BaseRenderer
	{
		//--------------------------------------------------------------------------
		//  Protected properties
		//--------------------------------------------------------------------------
		
		protected var titleField:TextField;
		protected var nameField:TextField;
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
		
		protected var xpathValue:Object = new XMLHandler();
		
		//--------------------------------------------------------------------------
		//  Contructor
		//--------------------------------------------------------------------------
		
		public function SeriesItemRenderer()
		{
			percentWidth = 100;
		}
		
		//--------------------------------------------------------------------------
		//  Override Protected Methods
		//--------------------------------------------------------------------------
		
		
		//--------------------------------------------------------------------------
		
		override protected function createChildren():void
		{	
			[Embed(source='/assets/separator.png')]
			var separatorAsset:Class;
			
			readStyles();
			
			setBackground();
			
			if( separatorAsset )
			{
				separator = new separatorAsset();
				addChild( separator );
			}
			
			titleField = new TextField();
			titleField.wordWrap = true;
			titleField.multiline = true;
			titleField.defaultTextFormat = new TextFormat(fontFamily, fontSize);
			titleField.textColor = 0x861B1D;
			titleField.autoSize = "left";
			
			addChild(titleField);
			
			nameField = new TextField();
			nameField.defaultTextFormat = new TextFormat(fontFamily, fontSizeName);
			nameField.autoSize = "left";
			
			addChild( nameField );
			
			avatarHolder = new Graphic();
			avatar = new BitmapImage();
			avatar.fillMode = "clip";
			avatarHolder.width = 50;
			avatarHolder.height = 37;
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
			
			titleField.x = avatarHolder.x + avatarHolder.width + horizontalGap;
			titleField.y = paddingTop;
			titleField.width = unscaledWidth - paddingLeft - paddingRight - avatarHolder.getLayoutBoundsWidth() - horizontalGap;
			
			nameField.x = avatarHolder.x + avatarHolder.width + horizontalGap;
			nameField.y = paddingTop + titleField.textHeight + verticalGap + 5;
			
			layoutHeight = Math.max( nameField.y + paddingBottom + nameField.textHeight, avatarHolder.height + paddingBottom + paddingTop );
			
			background.width = unscaledWidth;
			background.height = layoutHeight;
			
			separator.width = unscaledWidth;
			separator.y = layoutHeight - separator.height;
		}
		
		override protected function measure():void
		{
			measuredHeight = Math.max( nameField.y + paddingBottom + nameField.textHeight, avatarHolder.height + paddingBottom + paddingTop );
		}
		
		override public function getLayoutBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
			return layoutHeight;
		}
		
		override protected function setValues():void
		{			
			titleField.text = String(data.title);
			nameField.text = String(data.author);
			avatar.source = String(data.thumbnail);
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