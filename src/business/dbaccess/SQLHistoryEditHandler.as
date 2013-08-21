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
		
		public function insertVideo(m:String, t:String, a:String, d:String, s:String, pre:String, presen:String, desc:String, th:String, preDown:String, presenDown:String, downloadState:String, seek:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			insertStatement = new SQLStatement();	
			insertStatement.sqlConnection = con.getSQLConncection();
			
			insertStatement.text = "insert into mh2goHistory (mpid, title, author, date, series, desc, presenter, presentation, presenterDownload, presentationDownload, thumbnail, seektime, download, adopter) " +
				"values (:mpid, :title, :author, :date, :series, :desc, :presenter, :presentation, :presenterDownload, :presentationDownload, :thumbnail, :seektime, :download, :adopter)";
			
			insertStatement.parameters[":mpid"] = m;
			insertStatement.parameters[":title"] = t;
			insertStatement.parameters[":author"] = a;
			insertStatement.parameters[":date"] = d;
			insertStatement.parameters[":series"] = s;
			insertStatement.parameters[":desc"] = desc;
			insertStatement.parameters[":presenter"] = pre;
			insertStatement.parameters[":presentation"] = presen;
			insertStatement.parameters[":presenterDownload"] = preDown;
			insertStatement.parameters[":presentationDownload"] = presenDown;
			insertStatement.parameters[":thumbnail"] = th;
			insertStatement.parameters[":seektime"] = seek;
			insertStatement.parameters[":download"] = downloadState;
			insertStatement.parameters[":adopter"] = URLClass.getInstance().getURLNoSearch();
			insertStatement.execute();
		}
		
		public function updateVideoTime(id:String, time:String):void
		{
			trace(time)
			con = SQLConnectionHandler.getInstance();
			
			updateStatement = new SQLStatement();	
			updateStatement.sqlConnection = con.getSQLConncection();
			
			updateStatement.text = "update mh2goHistory set seektime = :seektime where mpid = :mpid";
			
			updateStatement.parameters[":mpid"] = id;
			updateStatement.parameters[":seektime"] = time;
			
			updateStatement.execute();
		}
		
		public function updateDownload(id:String, download:String, presenter:String, presentation:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			updateStatement = new SQLStatement();	
			updateStatement.sqlConnection = con.getSQLConncection();
			
			updateStatement.text = "update mh2goHistory set download = :download, presenter = :presenter, presentation = :presentation where mpid = :mpid";
			
			updateStatement.parameters[":mpid"] = id;
			updateStatement.parameters[":presenter"] = presenter;
			updateStatement.parameters[":presentation"] = presentation;
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