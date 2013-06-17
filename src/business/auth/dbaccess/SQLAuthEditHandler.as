package business.auth.dbaccess
{
	import flash.events.EventDispatcher;
	
	public class SQLAuthEditHandler
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
		
		static private var instance:SQLAuthEditHandler;
		
		static public function getInstance():SQLAuthEditHandler
		{
			if (instance == null) 
			{
				instance = new SQLAuthEditHandler();
			}
			return instance;
		}
		
		public function insertAuth(host:String, user:String, pass:String, conValue:String):void
		{
			con = SQLConnectionHandler.getInstance();
			
			insertStatement = new SQLStatement();	
			insertStatement.sqlConnection = con.getSQLConncection();
			
			insertStatement.text = "insert into mh2goAccess (user, pass, adopter, conValue) values (:user, :pass, :adopter, :conValue)";
			
			insertStatement.parameters[":user"] = user;
			insertStatement.parameters[":pass"] = pass;
			insertStatement.parameters[":adopter"] = host;
			insertStatement.parameters[":conValue"] = conValue;
			
			insertStatement.execute();
		}
		
		public function updateAuth(id:String, textName:String, textAdopter:String, conValue:String):void
		{
			trace(conValue)

			con = SQLConnectionHandler.getInstance();
			
			updateStatement = new SQLStatement();	
			updateStatement.sqlConnection = con.getSQLConncection();
			
			updateStatement.text = "update mh2goAccess set user = :user, pass = :pass, conValue = :conValue where adopter = :adopter";
			
			updateStatement.parameters[":user"] = id;
			updateStatement.parameters[":pass"] = textName;
			updateStatement.parameters[":adopter"] = textAdopter;
			insertStatement.parameters[":conValue"] = conValue;
			
			updateStatement.execute();
		}
	}
}