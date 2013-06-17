package business.download.dbaccess
{
	import flash.events.EventDispatcher;
	
	public class SQLDownloadEditHandler
	{
		import flash.data.SQLStatement;
		import flash.data.SQLResult;
		import flash.events.SQLEvent;
		import flash.events.SQLErrorEvent;
		import business.dbaccess.SQLConnectionHandler;
		
		private var insertStatement:SQLStatement;
		private var updateStatement:SQLStatement;
		private var deleteStatement:SQLStatement;
		
		private var result:SQLResult;
		private var con:SQLConnectionHandler;
		
		static private var instance:SQLDownloadEditHandler;
		
		static public function getInstance():SQLDownloadEditHandler
		{
			if (instance == null) 
			{
				instance = new SQLDownloadEditHandler();
			}
			return instance;
		}
		
		public function insertDownload(videoname:String, type:String, video:String):void
		{
			
			con = SQLConnectionHandler.getInstance();
			
			insertStatement = new SQLStatement();	
			insertStatement.sqlConnection = con.getSQLConncection();
			
			insertStatement.text = "insert into mh2goDownloads (video, videoname, type) values (:video, :videoname, :type)";
			
			insertStatement.parameters[":video"] = video;
			insertStatement.parameters[":videoname"] = videoname;
			insertStatement.parameters[":type"] = type;
			
			insertStatement.execute();
		}
		
		public function deleteDownload(video:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			deleteStatement = new SQLStatement();	
			deleteStatement.sqlConnection = con.getSQLConncection();
			
			deleteStatement.text = "delete from mh2goDownloads where video = :video";
			deleteStatement.parameters[":video"] = video;
			
			deleteStatement.execute();
		}
		
		public function updateDownload(id:String, textName:String):void
		{
			
			con = SQLConnectionHandler.getInstance();
			
			updateStatement = new SQLStatement();	
			updateStatement.sqlConnection = con.getSQLConncection();
			
			//updateStatement.text = "update mh2goAccess set user = :user, pass = :pass, conValue = :conValue where adopter = :adopter";
			
			//updateStatement.parameters[":user"] = id;
			//updateStatement.parameters[":pass"] = textName;
			
			updateStatement.execute();
		}
	}
}