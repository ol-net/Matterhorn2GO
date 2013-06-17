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
package business.auth.dbaccess
{
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	
	public class SQLAuthViewHandler extends EventDispatcher
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
		
		import business.auth.events.AuthLoadedEvent;
		
		private var selectStatement:SQLStatement;
		private var result:SQLResult;
		private var resultXML:XML;
		private var con:SQLConnectionHandler;
		private var elem:Object;
		private var videos:XMLListCollection;
		
		private var adopterURL:String;
		
		private var historyEmpty:Boolean = true;
		
		static private var instance:SQLAuthViewHandler;
		
		private var videoInside:Boolean;
		
		private var seekTime:String = "";
		
		private var user:String;
		private var pass:String;
		private var conValue:String;
		
		static public function getInstance():SQLAuthViewHandler
		{
			if (instance == null) 
			{
				instance = new SQLAuthViewHandler();
			}
			
			return instance;
		}
		
		public function initSQLAuth():void
		{		
			historyEmpty = true;
			
			adopterURL = URLClass.getInstance().getURLNoSearch();
			
			con = SQLConnectionHandler.getInstance();
			
			selectStatement = new SQLStatement();	
			selectStatement.sqlConnection = con.getSQLConncection();
			
			if(adopterURL != null || adopterURL == "")
			{
				selectStatement.text = "SELECT user, pass, conValue FROM mh2goAuth WHERE adopter=:adopter ORDER BY id DESC";
				selectStatement.parameters[":adopter"]=adopterURL;
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
					this.user = String(row.user);
					this.pass = String(row.pass);
					this.conValue = String(row.conValue);
				} 
			}
			
			var eCon:AuthLoadedEvent = new AuthLoadedEvent(AuthLoadedEvent.AUTHLOADED);
			this.dispatchEvent(eCon);
		}
		
		public function errorHandler(event:SQLErrorEvent):void 
		{ 
			var eCon:AuthLoadedEvent = new AuthLoadedEvent(AuthLoadedEvent.AUTHLOADED);
			this.dispatchEvent(eCon);
		}
		
		public function getUser():String
		{
			return this.user;
		}
		
		public function getPass():String
		{
			return this.pass;
		}
		
		public function getConValue():String
		{
			return this.conValue;
		}
	}	
}