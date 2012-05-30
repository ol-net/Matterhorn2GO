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
	import flash.net.drm.AuthenticationMethod;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.collections.XMLListCollection;
	import mx.managers.LayoutManager;
	import mx.messaging.SubscriptionInfo;
	
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.TextArea;
	import spark.events.ViewNavigatorEvent;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	import spark.primitives.BitmapImage;
	import spark.primitives.Graphic;
	
	
	public class AnnotationRenderer extends BaseRenderer
	{		
		protected var separator:DisplayObject;
		
		protected var paddingLeft:int;
		protected var paddingRight:int;
		protected var paddingBottom:int;
		protected var paddingTop:int;
		protected var horizontalGap:int;
		protected var verticalGap:int;
		
		protected var min_Height:Number = 50;
		protected var fontFamily:String = "_sans";
		protected var fontSize:Number = 8;
		protected var fontSizeName:Number = 10;		
		
		protected var txtArea_Anno:TextArea;		
		protected var strName:String;
		protected var strAnno:String;
		protected var Text:Array;		
		protected var myPanel:Panel;		
		protected var xpath_values:XMLHandler;
		
		
		//--------------------------------------------------------------------------
		//  Contructor
		//--------------------------------------------------------------------------
		
		public function AnnotationRenderer()
		{			
			percentWidth = 100;	
			txtArea_Anno = new TextArea();
			
		}
		
		//--------------------------------------------------------------------------
		//  Override Protected Methods
		//--------------------------------------------------------------------------
		
		override protected function measure():void
		{
			measuredHeight = 150;
		}
		
		//--------------------------------------------------------------------------
		
		override protected function createChildren():void
		{				
			[Embed(source='/assets/separator.png')]
			var separatorAsset:Class;
			
			if( separatorAsset )
			{
				separator = new separatorAsset();
				addChild( separator );
			}	
			
			myPanel = new Panel();				
			myPanel.height = 150;			
			txtArea_Anno.height = 115;			
			txtArea_Anno.editable = false;			
			
			myPanel.addElement(txtArea_Anno);			
						
			addChild(myPanel);
			myPanel.percentWidth = 100;
			
			if(data)
				setValues();
			
		}	
		
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{			
			myPanel.width = unscaledWidth;
			txtArea_Anno.width = unscaledWidth;			
		} 
		
		override public function getLayoutBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
			return layoutHeight;
		}
		
		override protected function setValues():void
		{	
			var Zeit:String = String(data.created);			
			
			//currently name and comment are stored together at the comment-property of a video
			//and separeted by the string 'NameDelimiter'
			Text = String(data.value).split("NameDelimiter");			 
			if(Text.length != 2){				
					return;
			}			
			myPanel.title = Text[0]+", " +getDateString(Zeit);
			
			txtArea_Anno.text = Text[1];	
			
		}
		
		public function getDateString(datum:String):String{
			var dayAndYear:String;
			var time:String;
			var partStrings:Array= datum.split("T");
			
			var partDate:Array = String(partStrings[0]).split("-");
			var partTime:Array = String(partStrings[1]).split(".");
			
			dayAndYear = partDate[2]+"."+partDate[1]+"."+partDate[0];
			time = partTime[0];
			
			return dayAndYear +" "+time;
		}				
	}	
}