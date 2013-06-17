package business.dbaccess
{
	import flash.events.EventDispatcher;
	
	public class SQLHistoryEditHandler
	{
		import flash.data.SQLStatement;
		import flash.data.SQLResult;
		import flash.events.SQLEvent;
		import flash.events.SQLErrorEvent;
		import business.datahandler.URLClass;
		
		private var insertStatement:SQLStatement;
		private var updateStatement:SQLStatement;
		private var deleteStatement:SQLStatement;
		
		private var result:SQLResult;
		private var con:SQLConnectionHandler;
		
		static private var instance:SQLHistoryEditHandler;
		
		static public function getInstance():SQLHistoryEditHandler
		{
			if (instance == null) 
			{
				instance = new SQLHistoryEditHandler();
			}
			
			return instance;
		}
		
		public function insertVideo(m:String, t:String, a:String, d:String, s:String, desc:String, pre:String, presen:String, th:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			insertStatement = new SQLStatement();	
			insertStatement.sqlConnection = con.getSQLConncection();
			
			insertStatement.text = "insert into mh2goHistory (mpid, title, author, date, series, desc, presenter, presentation, thumbnail, seektime, download, adopter) " +
				"values (:mpid, :title, :author, :date, :series, :desc, :presenter, :presentation, :thumbnail, :seektime, :download, :adopter)";
			
			insertStatement.parameters[":mpid"] = m;
			insertStatement.parameters[":title"] = t;
			insertStatement.parameters[":author"] = a;
			insertStatement.parameters[":date"] = d;
			insertStatement.parameters[":series"] = s;
			insertStatement.parameters[":desc"] = desc;
			insertStatement.parameters[":presenter"] = pre;
			insertStatement.parameters[":presentation"] = presen;
			insertStatement.parameters[":thumbnail"] = th;
			insertStatement.parameters[":seektime"] = "";
			insertStatement.parameters[":download"] = "false";
			insertStatement.parameters[":adopter"] = URLClass.getInstance().getURLNoSearch();
			insertStatement.execute();
		}
		
		public function updateVideoTime(id:String, time:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			updateStatement = new SQLStatement();	
			updateStatement.sqlConnection = con.getSQLConncection();
			
			updateStatement.text = "update mh2goHistory set seektime = :seektime where mpid = :mpid";
			
			updateStatement.parameters[":mpid"] = id;
			updateStatement.parameters[":seektime"] = time;
			
			updateStatement.execute();
		}
		
		public function updateDownload(id:String, download:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			updateStatement = new SQLStatement();	
			updateStatement.sqlConnection = con.getSQLConncection();
			
			updateStatement.text = "update mh2goHistory set download = :download where mpid = :mpid";
			
			updateStatement.parameters[":mpid"] = id;
			updateStatement.parameters[":download"] = download;
			
			updateStatement.execute();
		}
		
		public function deleteVideos():void
		{
			con = SQLConnectionHandler.getInstance();
			
			deleteStatement = new SQLStatement();	
			deleteStatement.sqlConnection = con.getSQLConncection();
			deleteStatement.text = "delete from mh2goHistory where adopter = :adopter";
			deleteStatement.parameters[":adopter"] = URLClass.getInstance().getURLNoSearch();
			deleteStatement.execute();
		}
		
		public function deleteVideo(mpid:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			deleteStatement = new SQLStatement();	
			deleteStatement.sqlConnection = con.getSQLConncection();
			deleteStatement.text = "delete from mh2goHistory where mpid = :mpid";
			deleteStatement.parameters[":mpid"] = mpid;
			deleteStatement.execute();
		}
	}
}