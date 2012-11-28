package business.dbaccess
{
	import flash.events.EventDispatcher;
	
	public class SQLEditHandler
	{
		import flash.data.SQLStatement;
		import flash.data.SQLResult;
		import flash.events.SQLEvent;
		import flash.events.SQLErrorEvent;
		
		private var insertStatement:SQLStatement;
		private var updateStatement:SQLStatement;
		private var deleteStatement:SQLStatement;
		
		private var result:SQLResult;
		private var con:SQLConnectionHandler;
		
		static private var instance:SQLEditHandler;
		
		static public function getInstance():SQLEditHandler
		{
			if (instance == null) 
			{
				instance = new SQLEditHandler();
			}
			
			return instance;
		}
		
		public function insertAdopter(textName:String, textAdopter:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			insertStatement = new SQLStatement();	
			insertStatement.sqlConnection = con.getSQLConncection();
			
			insertStatement.text = "insert into mh2go (name, adopter) values (:name, :adopter)";
			
			insertStatement.parameters[":name"] = textName;
			insertStatement.parameters[":adopter"] = textAdopter;
			
			insertStatement.execute();
		}
		
		public function updateAdopter(id:String, textName:String, textAdopter:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			updateStatement = new SQLStatement();	
			updateStatement.sqlConnection = con.getSQLConncection();
			
			updateStatement.text = "update mh2go set name = :name, adopter = :adopter where id = :id";
			
			updateStatement.parameters[":id"] = id;
			updateStatement.parameters[":name"] = textName;
			updateStatement.parameters[":adopter"] = textAdopter;
			
			updateStatement.execute();
		}
		
		public function deleteAdopter(id:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			deleteStatement = new SQLStatement();	
			deleteStatement.sqlConnection = con.getSQLConncection();
			
			deleteStatement.text = "delete from mh2go where id = :id";
			
			deleteStatement.parameters[":id"] = id;
			
			deleteStatement.execute();
		}
	}
}