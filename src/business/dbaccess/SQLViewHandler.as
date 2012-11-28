package business.dbaccess
{
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	
	public class SQLViewHandler extends EventDispatcher
	{
		import flash.data.SQLStatement;
		import flash.data.SQLResult;
		import flash.events.SQLEvent;
		import flash.events.SQLErrorEvent;
		import mx.collections.ArrayCollection;
		import events.SQLConnectionIsOpen;
		
		private var selectStatement:SQLStatement;
		private var result:SQLResult;
		private var resultXML:XML;
		private var con:SQLConnectionHandler;
		private var elem:Object;
		private var adopters:XMLListCollection;
		
		static private var instance:SQLViewHandler;
		
		static public function getInstance():SQLViewHandler
		{
			if (instance == null) 
			{
				instance = new SQLViewHandler();
			}
			
			return instance;
		}
		
		public function initSQLViewAdopters(ado:XMLListCollection):void
		{		
			con = SQLConnectionHandler.getInstance();
			
			adopters = ado;
			
			selectStatement = new SQLStatement();	
			selectStatement.sqlConnection = con.getSQLConncection();
			
			selectStatement.text = "SELECT id, name, adopter FROM mh2go ORDER BY id DESC";
			
			selectStatement.addEventListener(SQLEvent.RESULT, resultHandlerSelect); 
			selectStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler); 
			
			selectStatement.execute();
		}
		
		public function resultHandlerSelect(event:SQLEvent):void
		{ 
			result = selectStatement.getResult(); 
			
			var rArr:Array = result.data;
			
			if(result)
			{      				
				var numResults:int = 0;
				
				if(result.data != null)
				{
				  numResults = result.data.length; 
				}
				
				var ad:Object = "";
				
				for (var i:int = 0; i < numResults; i++) 
				{ 
					var row:Object = result.data[i]; 
					var id:String = row.id;
					var name:String = row.name;
					var adopter:String = row.adopter;
					ad = "<adopter><id>"+id+"</id><AdopterURL>"+adopter+"</AdopterURL><AdopterName>"+name+"</AdopterName></adopter>";
					
					adopters.addItem(new XML(ad));
				} 
			}
			
			var eCon:SQLConnectionIsOpen = new SQLConnectionIsOpen(SQLConnectionIsOpen.READERCOMPLETE);
			this.dispatchEvent(eCon);
		}
		
		public function getAdopterXML():XMLListCollection
		{
			return adopters;
		}
		
		public function errorHandler(event:SQLErrorEvent):void 
		{ 
		}
	}
}