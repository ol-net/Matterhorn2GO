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
package business.core
{
	//import business.datahandler.did.DeviceInfoHandler;
	//import business.datahandler.did.AndroidNetworkInfo;

	import business.core.events.FileReaderCompleteEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.*;
	import flash.net.FileReference;
	
	public class ToolTipReader extends EventDispatcher 
	{	
		private var fileStream:FileStream;
		
		private var status:String = "nein";
		
		static private var instance:ToolTipReader;
		
		//private var device_info:DeviceInfoHandler;
		
		private var width:String = "0";
		private var height:String = "0";
		
		static public function getInstance():ToolTipReader 
		{
			if (instance == null) 
			{
				instance = new ToolTipReader();
			}
			
			return instance;
		}
		
		/** 
		 * Get a FileStream for reading or writing the save file.
		 *  
		 * @param write If true, we will write to the file. If false, we will read. 
		 * @param sync If true, we do synchronous writes. If false, asynchronous. 
		 * @return A FileStream instance we can read or write with. Don't forget to close it! 
		 */ 
		private function getSaveStream(write:Boolean, sync:Boolean = true):FileStream 
		{ 
			// The data file lives in the app storage directory, per iPhone guidelines. 
			var f:File = File.applicationStorageDirectory.resolvePath("tooltip.cfg"); 

			// Try creating and opening the stream. 
			var fs:FileStream = new FileStream(); 
			
			try { 
				// If we are writing asynchronously, openAsync. 
				if(write && !sync) 
				{
					//device_info = DeviceInfoHandler.getInstance();
					//device_info.getIOSDeviceInfo(width, height);
					//device_info.getAndroideDeviceInfo(width, height);
					fs.openAsync(f, FileMode.WRITE); 
				}
				else
				{ 
					// For synchronous write, or all reads, open synchronously. 
					fs.open(f, write ? FileMode.WRITE : FileMode.READ); 
				} 
			} catch(e:Error) 
			{ 
				// On error, simply return null. 
				return null; 
			} 
			return fs; 
		}
		
		public function readFile():void 
		{ 
			// Get the stream and read from it. 
			var fs:FileStream = getSaveStream(false); 
			
			if(fs) 
			{
				try { 
					status = fs.readUTFBytes(fs.bytesAvailable);
					fs.close(); 
				} catch(e:Error){} 
			} 
		}
		
		public function setFile():void 
		{ 
			// Get stream and write to it – asynchronously, to avoid hitching. 
			var fs:FileStream = getSaveStream(true, false); 
			fs.writeUTFBytes("ja");
			fs.close(); 
		}
		
		public function getStatus():Boolean
		{
			if(status == "ja") 
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function setDisplay(w:String, h:String):void
		{
			this.width = w;
			this.height = h;
		}
	}
}