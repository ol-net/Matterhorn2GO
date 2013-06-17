package business.auth
{
	import business.auth.ConnectionChecker;
	import business.auth.events.AccessDeniedEvent;
	import business.auth.events.AccessOkEvent;
	import business.datahandler.XMLHandler;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import business.core.NamespaceRemover;	
	
	public class Auth extends EventDispatcher
	{
		private var serviceObj:HTTPService;
		
		private var host:String;
		private var user:String;
		private var password:String;
		
		static private var instance:Auth;
		
		public static function getInstance():Auth
		{
			if (instance == null) instance = new Auth();
			
			return instance;
		}
		
		public function login(host:String, user:String, password:String):void
		{
			this.host = host;
			this.user = user;
			this.password = password;
			
			connect();
		}
		
		private function connect():void
		{
			var postdata:URLVariables = new URLVariables(); 
				
			postdata.j_username = String(this.user);  
			postdata.j_password = String(this.password);  
			postdata.submit = "Login";
			
			trace(user+" "+password+" "+host)
			
			serviceObj = new HTTPService();
			
			serviceObj.contentType="application/x-www-form-urlencoded";
			serviceObj.resultFormat = 'text';
			serviceObj.method = 'POST';
			serviceObj.useProxy = false;
			serviceObj.url = this.host+"/j_spring_security_check";
			//serviceObj.url = "http://lernfunk.de/plug-ins/lernfunk-matterhorn-search-proxy-test/proxy.py/j_spring_security_check";

			serviceObj.addEventListener(ResultEvent.RESULT, responseHandler);
			serviceObj.addEventListener(FaultEvent.FAULT, errorHandler);
			
			serviceObj.send(postdata);

		}
		
		/** 
		 * Handles error events from URLLoaders
		 */
		private function errorHandler(e:FaultEvent):void 
		{
			trace("DDD "+e)
			serviceObj.removeEventListener(ResultEvent.RESULT, responseHandler);
			serviceObj.removeEventListener(FaultEvent.FAULT, errorHandler);
			
			var faild:AccessDeniedEvent = new AccessDeniedEvent(AccessDeniedEvent.ACCESSDENIED);
			dispatchEvent(faild);
		}
		
		/** 
		 * Handles complete events from URLLoaders.
		 */
		private function responseHandler(e:ResultEvent):void 
		{			
			serviceObj.url = this.host+"/search/episode.xml?&limit=1";
			serviceObj.resultFormat = 'e4x';
			serviceObj.method = 'GET';
			
			serviceObj.removeEventListener(ResultEvent.RESULT, responseHandler);	
			serviceObj.addEventListener(ResultEvent.RESULT, getAuthStatus);
			
			serviceObj.send();
		}
		
		public function getAuthStatus(e:ResultEvent):void
		{
			serviceObj.removeEventListener(FaultEvent.FAULT, errorHandler);
			serviceObj.removeEventListener(ResultEvent.RESULT, getAuthStatus);
			
			var xml:XMLHandler = new XMLHandler();
			
			var XMLResults:XML = e.result as XML;
			XMLResults = NamespaceRemover.remove(XMLResults);
			
			var connectionInfo:String = xml.getResult("//query", XMLResults);//String(e.result.query);
			
			var pAnonymUser:RegExp = /ROLE_ANONYMOUS/g;
			var pAdmin:RegExp = /ROLE_ADMIN/g;
			var pUser:RegExp = /ROLE_OAUTH_USER/g;
			var pAuthUser:RegExp = /ROLE_USER/g;
			
			var con:AccessOkEvent;
			
			if((String(connectionInfo.match(pAdmin)) != "") || 
				(String(connectionInfo.match(pUser)) != "") || 
				(String(connectionInfo.match(pAuthUser)) != ""))
			{
				var conCheck:ConnectionChecker = ConnectionChecker.getInstance();
				conCheck.setAuthUSE(true);
				
				con = new AccessOkEvent(AccessOkEvent.ACCESSOK);
				dispatchEvent(con);
			}
			else if((String(connectionInfo.match(pAnonymUser)) != "") && 
				((String(connectionInfo.match(pAdmin)) == "") || 
				(String(connectionInfo.match(pUser)) == "") || 
				(String(connectionInfo.match(pAuthUser)) == "")))
			{
				var faild:AccessDeniedEvent = new AccessDeniedEvent(AccessDeniedEvent.ACCESSDENIED);
				dispatchEvent(faild);
			}
			else
			{
				con = new AccessOkEvent(AccessOkEvent.ACCESSOK);
				dispatchEvent(con);
			}
			
			return;
		}
	}
}