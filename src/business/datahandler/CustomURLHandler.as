/*
The Matterhorn2Go Project
Copyright (C) 2011  University of Osnabrück; Part of the Opencast Matterhorn Project

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
package business.datahandler
{	
	import mx.rpc.http.HTTPService;
	
	public class CustomURLHandler
	{
		static private var instance:CustomURLHandler;
		
		private var serviceObj:HTTPService; 
		
		private var url:String;
		
		static public function getInstance():CustomURLHandler
		{
			if (instance == null) 
				instance = new CustomURLHandler();
			
			return instance;
		}
		
		public function setCustomURL(u:String):void
		{
			/*
			this.url = u;
			serviceObj = new HTTPService();
			serviceObj.resultFormat = 'e4x';
			serviceObj.method = 'GET';
			serviceObj.useProxy = false;
			serviceObj.send();
			*/
		}
	}
}