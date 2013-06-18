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
package business.dbaccess
{
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	
	public class SQLHistoryViewHandler extends EventDispatcher
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
		
		private var selectStatement:SQLStatement;
		private var result:SQLResult;
		private var resultXML:XML;
		private var con:SQLConnectionHandler;
		private var elem:Object;
		private var videos:XMLListCollection;
		
		private var adopterURL:String;
		
		private var historyEmpty:Boolean = true;
		
		static private var instance:SQLHistoryViewHandler;
		
		private var videoInside:Boolean;
		
		private var seekTime:String = "";
		
		static public function getInstance():SQLHistoryViewHandler
		{
			if (instance == null) 
			{
				instance = new SQLHistoryViewHandler();
			}
			
			return instance;
		}
		
		public function initSQLViewVideos():void
		{		
			historyEmpty = true;
			
			adopterURL = URLClass.getInstance().getURLNoSearch();
			
			con = SQLConnectionHandler.getInstance();
			
			selectStatement = new SQLStatement();	
			selectStatement.sqlConnection = con.getSQLConncection();
			
			if(adopterURL != null || adopterURL == "")
			{
				selectStatement.text = "SELECT mpid, title, author, date, thumbnail FROM mh2goHistory WHERE adopter=:adopter ORDER BY id DESC";
				selectStatement.parameters[":adopter"]=adopterURL;
			}
			else
			{
				selectStatement.text = "SELECT mpid, title, author, date, thumbnail FROM mh2goHistory ORDER BY id DESC";
			}
			
			selectStatement.addEventListener(SQLEvent.RESULT, resultHandlerSelect); 
			selectStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler); 
			
			selectStatement.execute();
		}
		
		public function getSeekTime(id:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			selectStatement = new SQLStatement();	
			selectStatement.sqlConnection = con.getSQLConncection();
			
			selectStatement.text = "SELECT seektime FROM mh2goHistory WHERE mpid=:mpid";
			selectStatement.parameters[":mpid"]=id;
			
			selectStatement.addEventListener(SQLEvent.RESULT, seekTimeResultComplete); 
			selectStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler); 
			
			selectStatement.execute();
		}
		
		public function getVideoDesc(id:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			selectStatement = new SQLStatement();	
			selectStatement.sqlConnection = con.getSQLConncection();
			
			selectStatement.text = "SELECT * FROM mh2goHistory WHERE mpid=:mpid";
			selectStatement.parameters[":mpid"]=id;
			
			selectStatement.addEventListener(SQLEvent.RESULT, videoResultComplete); 
			selectStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler); 
			
			selectStatement.execute();
		}
		
		public function videoResultComplete(e:SQLEvent):void
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
				
				var ad:Object = "";
				
				for (var i:int = 0; i < numResults; i++) 
				{ 
					var row:Object = result.data[i]; 
					var mpid:String = String(row.mpid);
					var title:String = row.title;
					var author:String = row.author;
					var date:String = row.date;
					var series:String = row.series;
					var presenter:String = row.presenter;
					var presentation:String = row.presentation;
					var presenterDownload:String = row.presenterDownload;
					var presentationDownload:String = row.presentationDownload;
					var desc:String = row.disc;
					var seektime:String = row.seektime;
					
					var download:String = row.download;
					var thumbnail:String = row.thumbnail;
					ad = "<mediapackage id='"+mpid+"'>" +
						"<title>"+title+"</title>" +
						"<author>"+author+"</author>" +
						"<date>"+date+"</date>" +
						"<series>"+series+"</series>" +
						"<desc>"+desc+"</desc>" +
						"<presenter>"+presenter+"</presenter>" +
						"<presentation>"+presentation+"</presentation>" +
						"<presenterDownload>"+presenterDownload+"</presenterDownload>" +
						"<presentationDownload>"+presentationDownload+"</presentationDownload>" +
						"<download>"+download+"</download>" +
						"<seektime>"+seektime+"</seektime>" +
						"<thumbnail>"+thumbnail+"</thumbnail>" +
						"</mediapackage>";
					videos.addItem(new XML(ad));
					seekTime = row.seektime;
				} 
			}
			
			var eCon:SQLHistoryLoadedEvent = new SQLHistoryLoadedEvent(SQLHistoryLoadedEvent.HISTORYLOADED);
			this.dispatchEvent(eCon);
		}
		
		public function seekTimeResultComplete(e:SQLEvent):void
		{
			result = selectStatement.getResult(); 
			
			var rArr:Array = result.data;
			
			if(result)
			{
				if(result.data != null)
				{
					var row:Object = result.data[0]; 
					seekTime = row.seektime;
				}
			}
			
			var sTime:SeekTimeLoadetEvent = new SeekTimeLoadetEvent(SeekTimeLoadetEvent.SEEKTIMELOADED);
			this.dispatchEvent(sTime);
		}
		
		public function selectSQLViewVideos(t:String, a:String):void
		{					
			adopterURL = URLClass.getInstance().getURLNoSearch();

			con = SQLConnectionHandler.getInstance();
			
			selectStatement = new SQLStatement();	
			selectStatement.sqlConnection = con.getSQLConncection();
			
			if(t != "")
			{
				if(adopterURL != null || adopterURL == "")
				{
					selectStatement.text = "SELECT mpid, title, author, date, thumbnail FROM mh2goHistory WHERE adopter=:adopter AND title LIKE :title OR author LIKE :author ORDER BY id DESC";
					
					selectStatement.parameters[":title"]="%"+t+"%";
					selectStatement.parameters[":author"]="%"+a+"%";
					selectStatement.parameters[":adopter"]=URLClass.getInstance().getURLNoSearch();
				} 
				else
				{
					selectStatement.text = "SELECT mpid, title, author, date, thumbnail FROM mh2goHistory WHERE title LIKE :title OR author LIKE :author ORDER BY id DESC";
					
					selectStatement.parameters[":title"]="%"+t+"%";
					selectStatement.parameters[":author"]="%"+a+"%";
				}
			}
			else
			{
				return;
			}
			
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
					var mpid:String = String(row.mpid);
					var title:String = row.title;
					var author:String = row.author;
					var date:String = row.date;
					var series:String = row.series;
					var presenter:String = row.presenter;
					var presentation:String = row.presentation;
					var presenterDownload:String = row.presenterDownload;
					var presentationDownload:String = row.presentationDownload;
					var desc:String = row.disc;
					var seektime:String = row.seektime;
					
					var download:String = row.download;
					var thumbnail:String = row.thumbnail;
					ad = "<mediapackage id='"+mpid+"'>" +
						"<title>"+title+"</title>" +
						"<author>"+author+"</author>" +
						"<date>"+date+"</date>" +
						"<series>"+series+"</series>" +
						"<desc>"+desc+"</desc>" +
						"<presenter>"+presenter+"</presenter>" +
						"<presentation>"+presentation+"</presentation>" +
						"<presenterDownload>"+presenterDownload+"</presenterDownload>" +
						"<presentationDownload>"+presentationDownload+"</presentationDownload>" +
						"<download>"+download+"</download>" +
						"<thumbnail>"+thumbnail+"</thumbnail>" +
						"<seektime>"+seektime+"</seektime>" +
						"</mediapackage>";
					videos.addItem(new XML(ad));
				} 
			}
			
			var eCon:SQLHistoryLoadedEvent = new SQLHistoryLoadedEvent(SQLHistoryLoadedEvent.HISTORYLOADED);
			this.dispatchEvent(eCon);
		}
		
		public function checkVideo(mpId:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			selectStatement = new SQLStatement();	
			selectStatement.sqlConnection = con.getSQLConncection();
			
			selectStatement.addEventListener(SQLEvent.RESULT, resultHandlerForVideo); 
			selectStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler); 
			
			selectStatement.text = "SELECT id FROM mh2goHistory WHERE mpid=:mpid";
			
			selectStatement.parameters[":mpid"] = mpId;
			
			selectStatement.execute();
		}
		
		public function resultHandlerForVideo(event:SQLEvent):void
		{
			result = selectStatement.getResult(); 
			
			var rArr:Array = result.data;
			
			if(result)
			{      			
				var numResults:int = 0;
				
				if(result.data != null)
				{
					numResults = result.data.length; 
					videoInside = true;
				}
				else
				{
					videoInside = false;
				}
			} 
			else
			{
				videoInside = false;
			}
			
			var eCon:SQLVideoInsideEvent = new SQLVideoInsideEvent(SQLVideoInsideEvent.SELECTVIDEOCOMPLETE);
			this.dispatchEvent(eCon);
		}
		
		public function getVideoXML():XMLListCollection
		{
			return videos;
		}
		
		public function getVideoInsideStatus():Boolean
		{
			return videoInside;
		}
		
		public function getHistoryEmptyStatus():Boolean
		{
			return historyEmpty;
		}
		
		public function errorHandler(event:SQLErrorEvent):void 
		{ 
		}
		
		public function setSeekTime():void
		{	
			seekTime = "0";
		}
		
		public function returnSeekTime():String
		{	
			return seekTime;
		}
	}
}