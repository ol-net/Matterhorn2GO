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
	import business.core.ConfigurationReader;
	
	public class URLClass
	{
		static private var instance:URLClass;
		
		//private static const MATTERHORNURL:String ="http://demo.opencastproject.org";
		
		//private static const MATTERHORNURL:String = "http://video.virtuos.uos.de:8080";
		
		//private static const MATTERHORNURL:String = "http://testallinone.usask.ca:8080";

		private static const MATTERHORNURL:String ="http://lernfunk.de/plug-ins/lernfunk-matterhorn-search-proxy/proxy.py";
		
		//declare if annotation service is supported
		private static const SUPPORTCOMMENTS:Boolean = false;
		  
		static public function getInstance():URLClass 
		{
			if (instance == null) 
				instance = new URLClass();
			
			return instance;
		}
		
		public function getURL():String
		{
			var fileReader:ConfigurationReader = ConfigurationReader.getInstance();
			fileReader.readFile();
			
			var matterhorn_url:String = fileReader.getURL();
			
			if(matterhorn_url != '')
			{
				return matterhorn_url+"/search/";
			}
			else
			{
				return MATTERHORNURL+"/search/";
			}
		}
		
		public function getURLNoSearch():String
		{
			var fileReader:ConfigurationReader = ConfigurationReader.getInstance();
			fileReader.readFile();
			
			var matterhorn_url:String = fileReader.getURL();
			
			if(matterhorn_url != '')
			{
					return matterhorn_url;
			}
			else
			{
				return MATTERHORNURL;
			}
		}

		static public function getCommentSupport():Boolean{
			return SUPPORTCOMMENTS;
		}
		
		public function getDefaultURL():String
		{
			return MATTERHORNURL;
		}
	}
}