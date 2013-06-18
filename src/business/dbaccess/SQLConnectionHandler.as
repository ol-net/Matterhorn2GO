/*
The Matterhorn2Go Project
Copyright (C) 2011  University of OsnabrÃ¼ck; Part of the Opencast Matterhorn Project

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
	
	public class SQLConnectionHandler
	{
		import flash.data.SQLConnection;
		import flash.data.SQLStatement;
		import flash.data.SQLResult;
		import flash.events.SQLEvent;
		import flash.events.SQLErrorEvent;
		import flash.filesystem.File;
		
		private var aConn:SQLConnection = null;
		private var sqlStatement:SQLStatement;
		private var dbFile:File;
		
		static private var instance:SQLConnectionHandler;
		
		static public function getInstance():SQLConnectionHandler
		{
			if (instance == null) 
			{
				instance = new SQLConnectionHandler();
			}
			return instance;
		}
		
		public function initConnection():void
		{
			this.dbFile = File.applicationStorageDirectory.resolvePath("mh2go.db");
			
			this.aConn = new SQLConnection();
			this.aConn.addEventListener(SQLEvent.OPEN, onConnOpen);
			this.aConn.addEventListener(SQLErrorEvent.ERROR, onConnError);
			this.aConn.openAsync(dbFile);
			
			function onConnOpen(se:SQLEvent):void
			{
				aConn.removeEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.removeEventListener(SQLErrorEvent.ERROR, onConnError);					
				sqlStatement = new SQLStatement();	
				sqlStatement.sqlConnection = aConn;
				
				// create adopter table
				sqlStatement.text = "create table if not exists mh2go " +
					"(id integer primary key autoincrement, " +
					"name TEXT NOT NULL, adopter TEXT NOT NULL)";
				
				sqlStatement.execute();
				
				sqlStatement = new SQLStatement();	
				sqlStatement.sqlConnection = aConn;
				
				// create history table
				sqlStatement.text = "create table if not exists mh2goHistory " +
					"(id integer primary key autoincrement, " +
					"mpid TEXT NOT NULL, title TEXT NOT NULL, " +
					"author TEXT NOT NULL, date TEXT NOT NULL, " +
					"series TEXT NOT NULL, desc TEXT NOT NULL, " +
					"presenter TEXT NOT NULL, presentation TEXT NOT NULL, " +
					"presenterDownload TEXT NOT NULL, presentationDownload TEXT NOT NULL, " +
					"thumbnail TEXT NOT NULL, seektime TEXT NOT NULL, " +
					"download TEXT NOT NULL, adopter TEXT NOT NULL)";
				
				sqlStatement.execute();
				
				sqlStatement = new SQLStatement();	
				sqlStatement.sqlConnection = aConn;
				
				// create history table
				sqlStatement.text = "create table if not exists mh2goAccess " +
					"(id integer primary key autoincrement, " +
					"user TEXT NOT NULL, pass TEXT NOT NULL, " +
					"adopter TEXT NOT NULL, conValue TEXT NOT NULL)";
				
				sqlStatement.execute();
				
				sqlStatement = new SQLStatement();	
				sqlStatement.sqlConnection = aConn;
				
				// create history table
				sqlStatement.text = "create table if not exists mh2goDownloads " +
					"(id integer primary key autoincrement, " +
					"video TEXT NOT NULL, videoname TEXT NOT NULL, type TEXT NOT NULL)";
				
				sqlStatement.execute();
			}
			
			function onConnError(see:SQLErrorEvent):void
			{
				aConn.removeEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.removeEventListener(SQLErrorEvent.ERROR, onConnError);
			}
		}
		
		public function getSQLConncection():SQLConnection
		{
			return aConn;
		}
	}
}