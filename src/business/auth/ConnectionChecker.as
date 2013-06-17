package business.auth
{
	import business.auth.events.ConnectionCheckerEvent;
	import business.auth.dbaccess.SQLAuthViewHandler;
	import business.auth.events.AccessDeniedEvent;
	import business.auth.events.AccessOkEvent;
	import business.datahandler.URLClass;
	import business.datahandler.EpisodesDataHandler;
	import business.datahandler.SeriesDataHandler;
	import flash.events.EventDispatcher;
	
	public class ConnectionChecker extends EventDispatcher
	{
		private var authUSE:Boolean = false;
		
		static private var instance:ConnectionChecker;

		static public function getInstance():ConnectionChecker 
		{
			if (instance == null) 
				instance = new ConnectionChecker();
			
			return instance;
		}
		
		public function checkConnection(connectionInfo:String):void
		{
			var connectionOK:ConnectionCheckerEvent;
			
			var conInfo:String = connectionInfo;
			//trace(conInfo)
			var pAnonymUser:RegExp = /ROLE_ANONYMOUS/g;
			var pAdmin:RegExp = /ROLE_ADMIN/g;
			var pUser:RegExp = /ROLE_OAUTH_USER/g;
			var pAuthUser:RegExp = /ROLE_USER/g;
			
			if((String(conInfo.match(pAdmin)) != "") || 
				(String(conInfo.match(pUser)) != "") || 
				(String(conInfo.match(pAuthUser)) != ""))
			{
				//trace("auth ok ")
				connectionOK = new ConnectionCheckerEvent(ConnectionCheckerEvent.CONNECTIONCHECKED);
				dispatchEvent(connectionOK);
			}
			else if((String(connectionInfo.match(pAnonymUser)) != "") && 
				((String(conInfo.match(pAdmin)) == "") || 
				(String(conInfo.match(pUser)) == "") || 
				(String(conInfo.match(pAuthUser)) == "")) )
			{
				//trace("auth nicht ok")
				var sqlSelectAuth:SQLAuthViewHandler = SQLAuthViewHandler.getInstance();
				
				var user:String = sqlSelectAuth.getUser();
				var pass:String = sqlSelectAuth.getPass();
				
				if(user != "" && pass != "")
				{
					var auth:Auth = Auth.getInstance();
					auth.addEventListener(AccessOkEvent.ACCESSOK, loadWithAccess);
					auth.addEventListener(AccessDeniedEvent.ACCESSDENIED, loadWithOutAccess);
					auth.login(URLClass.getInstance().getURLNoSearch(), user, pass);
				}
			}
			else
			{
				//trace("auth ok ")
				connectionOK = new ConnectionCheckerEvent(ConnectionCheckerEvent.CONNECTIONCHECKED);
				dispatchEvent(connectionOK);
			}
		}
		
		public function loadWithAccess(e:AccessOkEvent):void
		{
			loadContent();
		}
		
		public function loadWithOutAccess(e:AccessDeniedEvent):void
		{
			loadContent();
		}
		
		public function loadContent():void
		{
			var episode:EpisodesDataHandler = EpisodesDataHandler.getInstance();
			episode.init();
			
			var series:SeriesDataHandler = SeriesDataHandler.getInstance();
			series.init();
		}
		
		public function setAuthUSE(aUSE:Boolean):void
		{
			this.authUSE = aUSE;
		}
		
		public function getAuthUSE():Boolean
		{
			return this.authUSE;
		}
	}
	
}