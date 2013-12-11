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
	import business.core.LoadNextEpisodes;
	import business.core.LoadNextSeries;
	import business.core.StyleClient;
	import business.datahandler.EpisodesDataHandler;
	import business.datahandler.SeriesDataHandler;
	
	import business.datahandler.events.BusyIndicatorEventEpisode;
	import business.datahandler.events.BusyIndicatorEventSeries;

	import business.datahandler.events.VideoAvailableEvent;
	
	import mx.collections.XMLListCollection;
	
	import spark.components.IItemRenderer;
	
	public class BaseRenderer extends StyleClient implements IItemRenderer
	{
		//--------------------------------------------------------------------------
		//  Public Setters and Getters
		//--------------------------------------------------------------------------
		
		protected var _data:Object;
		
		protected var ok:Boolean = true;
		
		private var loadNextEpisodes:LoadNextEpisodes = LoadNextEpisodes.getInstance();
		
		private var loadNextSeries:LoadNextSeries = LoadNextSeries.getInstance();
		
		private var xmlEpisodeData:EpisodesDataHandler;
		private var xmlSeriesData:SeriesDataHandler;
		
		private var videos:XMLListCollection;
		
		public function set data( value:Object ):void
		{	
			if(value != null)
			{
				if(value.code == "update_view")
				{	
					if(value.@type == "episode")
					{							
						var indicatorLoaded:BusyIndicatorEventEpisode = new BusyIndicatorEventEpisode(BusyIndicatorEventEpisode.INDICATORLOADED);
						dispatchEvent(indicatorLoaded);
						
						xmlEpisodeData = EpisodesDataHandler.getInstance();
		
						loadNextEpisodes.nextPage(xmlEpisodeData.getText());
						
						videos = xmlEpisodeData.getXMLListCollection();
												
						if (videos.length > 0) {
							videos.removeItemAt(videos.length - 1);
						}
						
						xmlEpisodeData.setXMLListCollection(videos);
					}
					else if(value.@type == "series")
					{	
						var indicatorLoadedSeries:BusyIndicatorEventSeries = new BusyIndicatorEventSeries(BusyIndicatorEventSeries.INDICATORLOADEDS);
						dispatchEvent(indicatorLoadedSeries);
						
						xmlSeriesData = SeriesDataHandler.getInstance();
						
						loadNextSeries.nextPage(xmlSeriesData.getText());
						
						videos = xmlSeriesData.getXMLListCollection();
						
						if (videos.length > 0) {
							videos.removeItemAt(videos.length - 1);
						}
						
						xmlSeriesData.setXMLListCollection(videos);
					}
					
				}
				
				//if( _data == value || value.code == "update_view")
					//return;
			}else
			{
				return;
			}

			_data = value;
			
			if( creationComplete )
				setValues();
		}	
		
		public function get data():Object
		{
			return _data;
		}
		
		// selected-------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  storage for the selected property 
		 */    
		protected var _selected:Boolean = false;
		
		/**
		 *  @inheritDoc 
		 *
		 *  @default false
		 */
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void
		{
			if (value != _selected)
			{
				_selected = value;
				updateSkin();
			}
		}
		
		// dragging-------------------------------------------------------------------------
		/**
		 * Property not used but it is required by the interface IItemRenderer
		 */
		protected var _dragging:Boolean;
		public function set dragging( value:Boolean ):void
		{
			_dragging = value;
		}
		
		public function get dragging():Boolean
		{
			return _dragging;
		}
		// showsCaret-------------------------------------------------------------------------
		/**
		 * Property not used but it is required by the interface IItemRenderer
		 */
		protected var _showsCaret:Boolean;
		public function set showsCaret( value:Boolean ):void
		{
			_showsCaret = value;
		}
		
		public function get showsCaret():Boolean
		{
			return _showsCaret;
		}
		
		// itemIndex-------------------------------------------------------------------------
		protected var _itemIndex:int;
		public function set itemIndex( value:int ):void
		{
			_itemIndex = value;
		}
		
		public function get itemIndex():int
		{
			return _itemIndex;
		}
		
		// itemIndex-------------------------------------------------------------------------
		protected var _label:String;
		public function get label():String
		{
			return _label;
		}
		
		public function set label(value:String):void
		{
			_label = value;
		}
		
		protected function updateSkin():void
		{
			// To be implemented in children
		}
		
		protected function setValues():void
		{
			// To be implemented in children
		}
	}
}