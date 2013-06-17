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
package business.core
{
	import business.datahandler.SeriesDataHandler;
	
	import business.datahandler.events.VideosLoadedEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.events.IndexChangeEvent;
	
	public class LoadNextSeries
	{
		static private var instance:LoadNextSeries;
		
		private var total_value:int;
		private var limit_value:int;
		private var offset_value:int;
		
		private var max_pages:int;
		private var page:int;
		
		private var footer_text:String;
		
		private var xmlData:SeriesDataHandler;
		
		public function LoadNextSeries()
		{			
			xmlData = SeriesDataHandler.getInstance();
		}
		
		static public function getInstance():LoadNextSeries
		{
			if (instance == null) instance = new LoadNextSeries();
			
			instance.initPages();
			
			return instance;
		}
		
		public function initPages():void
		{
			var tmp:int = limit_value;
			
			total_value = xmlData.getTotal();
			limit_value = xmlData.getLimit();
			offset_value = xmlData.getOffset();
			
			if(tmp > limit_value) limit_value = tmp;
			
			page = offset_value / limit_value + 1;
			if(total_value == 1 && limit_value == 1)
			{
				max_pages = 1;
			}
			else 
			{
				limit_value = 20;
				
				var t2:Number = total_value;
				var t3:Number = limit_value;
				
				var t4:int = total_value/limit_value;
				var t5:Number = t2/t3;
				var t6:Number = t4;
				var t7:Number = t5-t6;
				if(t7 == 0)
				{
					max_pages = total_value / limit_value;
				}
				else
				{
					max_pages = total_value / limit_value + 1;
				}
			}
			
			footer_text = page+" of "+max_pages;
		}
		
		public function getFooter():String
		{
			return footer_text;
		}
		
		public function getMaxPages():int
		{
			return max_pages;
		}
		
		public function getPage():int
		{
			return page;
		}
		
		public function setPage():void
		{
			page = 0;
		}
		
		public function getTotal():int
		{
			return total_value;
		}
		
		public function nextPage(textinput_search:String):void
		{	
			if(offset_value + limit_value < xmlData.getTotal())
			{
				offset_value = offset_value + limit_value;
				xmlData.search(textinput_search, String(offset_value));
			}
		}
		
		public function backPage(textinput_search:String):void
		{	
			
			if(offset_value > 0)
			{
				offset_value = offset_value - limit_value;
				xmlData.search(textinput_search, String(offset_value));
			}
			else if(offset_value < 0)
			{
				offset_value = 0;				
			}			
		}
	}
}