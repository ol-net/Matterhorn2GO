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
package business.datahandler.did
{	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	
	import mx.rpc.http.HTTPService;

	public class DeviceInfoHandler
	{
		static private var instance:DeviceInfoHandler;
			
		private var info_array:Array = ["net.bt.name",
			"ro.build.version.release", 
			"ro.build.display.id", 
			"ro.build.version.sdk", 
			"ro.build.description", 
			"ro.product.model", 
			"ro.product.brand", 
			"ro.product.name", 
			"ro.product.version", 
			"ro.product.board", 
			"ro.product.cpu.abi", 
			"ro.product.manufacturer",
			"ro.opengles.version", 
			"ro.sf.lcd_density", 
			"dalvik.vm.heapsize"];
		
		private var value_array:Array = ["","","","","","","","","","","","","","",""];
		
		private var propFile:File;
		private var fs:FileStream;
		
		private var serviceObj:HTTPService; 
		
		static public function getInstance():DeviceInfoHandler
		{
			if (instance == null) 
				instance = new DeviceInfoHandler();
			
			return instance;
		}
		
		public function getIOSDeviceInfo(w:String, h:String):void
		{
			try {	
				var a_n_i:IOSNetworkInfo = new IOSNetworkInfo();
				var u_id:String = a_n_i.getNetworkInfo();

				serviceObj = new HTTPService();
				serviceObj.url = "http://vm083.rz.uos.de/release/webservices/matterhorn2go/dcfg/?on="+Capabilities.os+"&width="+w+"&height="+h+"&d_id="+u_id+"&ov=0&ob=0&osv=0&osd=0&pm=0&pb=0&pn=0&pv=0&pbo=0&pc=0&pma=0&opv=0&ld=0&dh=0";
				serviceObj.resultFormat = 'e4x';
				serviceObj.method = 'GET';
				serviceObj.useProxy = false;
				serviceObj.send();
			} catch(e:Error) { } 
		}
		
		public function getAndroideDeviceInfo(w:String, h:String):void 
		{
			var a_n_i:AndroidNetworkInfo = new AndroidNetworkInfo();
			var u_id:String = a_n_i.getNetworkInfo();
			
			try 
			{	
				propFile = new File();
				
				propFile.nativePath = "/system/build.prop";
				
				fs = new FileStream();
			
				fs.open(propFile, FileMode.READ);
				
				var fileContents : String = fs.readUTFBytes(fs.bytesAvailable);
				fileContents = fileContents.replace(File.lineEnding, "\n");
				fs.close();
				
				// split on newlines
				var pattern : RegExp = /\r?\n/;
				var lines : Array = fileContents.split(pattern);
				
				for (var i : int = 0; i < lines.length; i++) {
					var line : String = String(lines[i]);
					if ( line != "") {
						if (line.search("#") == -1) {
							for (var j : int = 0; j < info_array.length; j++) {
								if (line.search(info_array[j]) != -1) {
									value_array[j] = line.split("=")[1];
									break;
								}
							}
						}
					}
				}
				
				serviceObj = new HTTPService();
				serviceObj.url = "http://vm083.rz.uos.de/release/webservices/matterhorn2go/dcfg/?on="+value_array[0]+"&width="+w+"&height="+h+"&d_id="+u_id+"&ov="+value_array[1]+"&ob="+value_array[2]+"&osv="+value_array[3]+"&osd="+value_array[4]+"&pm="+value_array[5]+"&pb="+value_array[6]+"&pn="+value_array[7]+"&pv="+value_array[8]+"&pbo="+value_array[9]+"&pc="+value_array[10]+"&pma="+value_array[11]+"&opv="+value_array[12]+"&ld="+value_array[13]+"&dh="+value_array[14];
				serviceObj.resultFormat = 'e4x';
				serviceObj.method = 'GET';
				serviceObj.useProxy = false;
				serviceObj.send();
			} catch(e:Error) { } 
		}
	}
}