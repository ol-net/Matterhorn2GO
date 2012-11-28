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
		
		private var aConn:SQLConnection;
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
				
				sqlStatement.text = "create table if not exists mh2go " +
					"(id integer primary key autoincrement, " +
					"name TEXT NOT NULL, adopter TEXT NOT NULL)";
				
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