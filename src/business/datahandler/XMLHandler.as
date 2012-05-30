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
	import memorphic.xpath.XPathQuery;
	
	public class XMLHandler
	{
		public function getResult(xpath:String, data:Object):String
		{
			// create the XPathQuery instance and parse the path
			var myQuery:XPathQuery = new XPathQuery(xpath);
			// execute the statement on an XML object and get the result
			var xml:XML = new XML(data);
		
			return myQuery.exec(xml);
		}
		
		public function getObjectResult(xpath:String, data:Object):Object
		{
			// create the XPathQuery instance and parse the path
			var myQuery:XPathQuery = new XPathQuery(xpath);
			// execute the statement on an XML object and get the result
			var xml:XML = new XML(data);
			
			return myQuery.exec(xml);
		}
		
		public function getXMLResult(xpath:String, data:XML):Object
		{
			// create the XPathQuery instance and parse the path
			var myQuery:XPathQuery = new XPathQuery(xpath);
			// execute the statement on an XML object and get the result
			//var xml:XML = new XML(data);
			
			return myQuery.exec(data);
		}
	}
}