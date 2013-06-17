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
package business.download.dbaccess
{
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	
	public class SQLDownloadViewHandler extends EventDispatcher
	{
		import flash.data.SQLStatement;
		import flash.data.SQLResult;
		import flash.events.SQLEvent;
		import flash.events.SQLErrorEvent;
		import mx.collections.ArrayCollection;
		import business.dbaccess.events.SQLHistoryLoadedEvent;
		import business.dbaccess.events.SQLVideoInsideEvent;
		import business.player.events.SeekTimeLoadetEvent;
		import business.datahandler.URLClass;
		import business.dbaccess.SQLConnectionHandler;
		
		import business.download.events.DownloadedVideoLoadedEvent;
		
		private var selectStatement:SQLStatement;
		private var result:SQLResult;
		private var resultXML:XML;
		private var con:SQLConnectionHandler;
		private var elem:Object;
		private var videos:XMLListCollection;
		
		private var adopterURL:String;
		
		private var historyEmpty:Boolean = true;
		
		static private var instance:SQLDownloadViewHandler;
		
		private var videoInside:Boolean;
		
		private var seekTime:String = "";
		
		private var video:String = "";
		private var videoname:String = "";
		private var type:String = "";
		
		private var video2:String = "";
		private var videoname2:String = "";
		private var type2:String = "";
		
		static public function getInstance():SQLDownloadViewHandler
		{
			if (instance == null) 
			{
				instance = new SQLDownloadViewHandler();
			}
			
			return instance;
		}
		
		public function initDownloads(id:String):void
		{	
			video = "";
			videoname = "";
			type = "";
			
			video2 = "";
			videoname2 = "";
			type2 = "";
			
			con = SQLConnectionHandler.getInstance();
			
			selectStatement = new SQLStatement();	
			selectStatement.sqlConnection = con.getSQLConncection();
			
			selectStatement.text = "SELECT video, type FROM mh2goDownloads WHERE video=:video ORDER BY id DESC";
			selectStatement.parameters[":video"]=id;
			
			selectStatement.addEventListener(SQLEvent.RESULT, resultHandlerSelect); 
			selectStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler); 
			
			selectStatement.execute();
		}
		
		public function resultHandlerSelect(event:SQLEvent):void
		{ 
			result = selectStatement.getResult(); 
			
			if(result)
			{    
				var rArr:Array = result.data;
				
				videos = new XMLListCollection();
				
				var numResults:int = 0;
				
				if(result.data != null)
				{
					historyEmpty = false;
					
					numResults = result.data.length;
				}
				else
				{
				}
				
				var ad:Object = "";
				
				for (var i:int = 0; i < numResults; i++) 
				{ 
					var row:Object = result.data[i]; 
					if(i == 0)
					{
						this.video = String(row.video);
						this.type = String(row.type);
						this.videoname = String(row.videoname);
					}
					else if(i == 1)
					{
						this.video2 = String(row.video);
						this.type2 = String(row.type);
						this.videoname2 = String(row.videoname);
					}
				} 
			}
			
			var eCon:DownloadedVideoLoadedEvent = new DownloadedVideoLoadedEvent(DownloadedVideoLoadedEvent.VIDEOLOADED);
			this.dispatchEvent(eCon);
		}
		
		public function errorHandler(event:SQLErrorEvent):void 
		{ 
			var eCon:DownloadedVideoLoadedEvent = new DownloadedVideoLoadedEvent(DownloadedVideoLoadedEvent.VIDEOLOADED);
			this.dispatchEvent(eCon);
		}
		
		public function getVideo():String
		{
			return this.video;
		}
		
		public function getType():String
		{
			return this.type;
		}
		
		public function getVideoName():String
		{
			return this.videoname;
		}
		
		public function getVideo2():String
		{
			return this.video2;
		}
		
		public function getType2():String
		{
			return this.type2;
		}
		
		public function getVideoName2():String
		{
			return this.videoname2;
		}
	}	
}