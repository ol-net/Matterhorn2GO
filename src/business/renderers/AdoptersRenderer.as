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
	import business.datahandler.CheckForPublicVideo;
	import business.datahandler.URLClass;
	import business.datahandler.XMLHandler;
	
	import events.VideoAvailableEvent;
	
	import flash.display.DisplayObject;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.collections.XMLListCollection;
	
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.primitives.BitmapImage;
	import spark.primitives.Graphic;
	
	public class AdoptersRenderer extends BaseRenderer
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
		
		protected var radioButton:RadioButton;
		protected var radioButtonGroup:RadioButtonGroup = new RadioButtonGroup();
		
		protected var xpathValue:Object = new XMLHandler();
		
		//--------------------------------------------------------------------------
		//  Contructor
		//--------------------------------------------------------------------------
		
		public function AdoptersRenderer():void
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
			titleField.autoSize = "left";
			
			addChild(titleField);
			
			radioButton = new RadioButton();
			radioButton.group = radioButtonGroup;
			
			addChild(radioButton);
			
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
				radioButton.x = paddingLeft + 10;
				radioButton.y = paddingTop;
				
				titleField.x = radioButton.x + 30 + horizontalGap;
				titleField.y = paddingTop + 5;
				titleField.width = unscaledWidth - paddingLeft - paddingRight - 30 - horizontalGap;

				layoutHeight = Math.max( titleField.y + paddingBottom + titleField.textHeight, 30 + paddingBottom + paddingTop );

				background.width = unscaledWidth;
				background.height = layoutHeight;
				
				separator.width = unscaledWidth;
				separator.y = layoutHeight - separator.height;
		}
		
		override protected function measure():void
		{
			measuredHeight = Math.max( titleField.y + paddingBottom, radioButton.height + paddingBottom + paddingTop);
		}
		
		override public function getLayoutBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
			return layoutHeight;
		}
		
		override protected function setValues():void
		{			
			titleField.text = String(data.AdopterName);
			var tmp:String = String(data.AdopterURL);
			var tmp2:String = String(URLClass.getInstance().getURL());
			
			if(tmp == tmp2)
			{
				radioButton.selected = true;
				//trace(data.AdopterURL)
			}
			else
			{
				radioButton.enabled = false;
			}
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