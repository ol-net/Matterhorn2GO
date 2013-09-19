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
	import business.datahandler.XMLHandler;
	
	public class GetVideoPathHandler
	{
		static private var instance:GetVideoPathHandler;
		
		static public function getInstance():GetVideoPathHandler
		{
			if (instance == null) instance = new GetVideoPathHandler();
			
			return instance;
		}
		
		public var video1Offline:Boolean = false;
		public var video2Offline:Boolean = false;
		
		public var path1:String;
		public var path2:String;
	
		public function getPath(data:Object):Array
		{
			var xpathValue:XMLHandler = new XMLHandler();
			
			var object:Array = getVideoPath("presenter/delivery", "presentation/delivery", data);
			
			var videoPath:String = object[0];
			var videoPathTwo:String = object[1];
			
			if(xpathValue.getResult(videoPath, data) == "")
			{
				object = getVideoPath("presentation/delivery", "presenter/delivery", data);
				
				videoPath = object[0];
				videoPathTwo = object[1];
			}
			
			import flash.filesystem.File;

			var vPath:String;
			
			if(!video1Offline)
			{
				vPath = xpathValue.getResult(videoPath, data);
			}
			else
			{
				var _url1:String = "";
				
				if(path1 != "")
				{
					_url1 = File.userDirectory.resolvePath(path1).nativePath; 
					
					_url1 = "file:///" + _url1;
				}
				else
				{
					_url1 = "";
				}
				
				vPath = _url1;
			}
				
			var vPathTwo:String;
			
			if(!video2Offline)
			{
				vPathTwo = xpathValue.getResult(videoPathTwo, data);
			}
			else
			{
				var _url2:String = "";
				
				if(path2 != "")
				{
					_url2 = File.userDirectory.resolvePath(path2).nativePath;   
					
					_url2 = "file:///" + _url2;
				}
				else
				{
					_url2 = "";
				}
				
				vPathTwo = _url2;
			}
			
			return [vPath, vPathTwo];
		}
		
		public function getPathToDownload(data:Object):Array
		{
			var xpathValue:XMLHandler = new XMLHandler();
			
			var object:Array = getVideoPathToDownload("presenter/delivery", "presentation/delivery", data);
			
			var videoPath:String = object[0];
			var videoPathTwo:String = object[1];
			
			if(xpathValue.getResult(videoPath, data) == "")
			{
				object = getVideoPathToDownload("presentation/delivery", "presenter/delivery", data);
				
				videoPath = object[0];
				videoPathTwo = object[1];
			}
			
			import flash.filesystem.File;
			
			var vPath:String;
			
			if(!video1Offline)
			{
				vPath = xpathValue.getResult(videoPath, data);
			}
			else
			{
				var _url1:String = "";
				
				if(path1 != "")
				{
					_url1 = File.userDirectory.resolvePath(path1).nativePath;  
					
					_url1 = "file:///" + _url1;
				}
				else
				{
					_url1 = "";
				}
				
				vPath = _url1;
			}
			
			var vPathTwo:String;
			
			if(!video2Offline)
			{
				vPathTwo = xpathValue.getResult(videoPathTwo, data);
			}
			else
			{
				var _url2:String = "";
				
				if(path2 != "")
				{
					_url2 = File.userDirectory.resolvePath(path2).nativePath;  
					
					_url2 = "file:///" + _url2;
				}
				else
				{
					_url2 = "";
				}
				
				vPathTwo = _url2;
			}
			
			return [vPath, vPathTwo];
		}
		
		public function getVideoPath(deliveryFirst:String, deliverySecond:String, data:Object):Array
		{
			var xpathValue:XMLHandler = new XMLHandler();
			
			var videoPath:String = "mediapackage/media/track[@type='"+deliveryFirst+"'][tags/tag[2]='medium-quality'][2]/url"
			var videoPathTwo:String = "mediapackage/media/track[@type='"+deliverySecond+"'][tags/tag[2]='medium-quality'][2]/url";
			
			if(xpathValue.getResult(videoPath, data) != "")
			{
				return [videoPath, videoPathTwo];
			}
			
			videoPath = "mediapackage/media/track[@type='"+deliveryFirst+"'][tags/tag[2]='medium-quality'][1]/url"
			videoPathTwo = "mediapackage/media/track[@type='"+deliverySecond+"'][tags/tag[2]='medium-quality'][1]/url";
			
			if(xpathValue.getResult(videoPath, data) != "")
			{
				return [videoPath, videoPathTwo];
			}
			
			if(xpathValue.getResult("mediapackage/media/track[mimetype='video/x-flv']/url", data) != "")
			{
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][8]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][8]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][7]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][7]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][6]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][6]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][5]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][5]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
			
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][4]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][4]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
			
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][3]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][3]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][2]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][2]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][1]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][1]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
			}
			
			
			if(xpathValue.getResult("mediapackage/media/track[mimetype='video/mp4']/url", data) != "")
			{
				videoPath = "mediapackage/media/track[@type='"+deliveryFirst+"'][tags/tag[2]='low-quality'][2]/url"
				videoPathTwo = "mediapackage/media/track[@type='"+deliverySecond+"'][tags/tag[2]='low-quality'][2]/url";
				
				if(xpathValue.getResult(videoPath, data) != "")
				{
					return [videoPath, videoPathTwo];
				}
				// priority c
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][8]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][8]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][7]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][7]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][6]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][6]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][5]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][5]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][4]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][4]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][3]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][3]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][2]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][2]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][1]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][1]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
			}
			
			return [videoPath, videoPathTwo];
		}
		
		public function getVideoPathToDownload(deliveryFirst:String, deliverySecond:String, data:Object):Array
		{
			var xpathValue:XMLHandler = new XMLHandler();

			var videoPath:String = "mediapackage/media/track[@type='"+deliveryFirst+"'][tags/tag[2]='medium-quality'][1]/url"
			var videoPathTwo:String = "mediapackage/media/track[@type='"+deliverySecond+"'][tags/tag[2]='medium-quality'][1]/url";
			
			if(xpathValue.getResult(videoPath, data) != "")
			{
				return [videoPath, videoPathTwo];
			}
			
			if(xpathValue.getResult("mediapackage/media/track[mimetype='video/x-flv']/url", data) != "")
			{
			
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][1]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][1]/url";
				}			
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				// priority b
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][2]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][2]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
			}
			
			if(xpathValue.getResult("mediapackage/media/track[mimetype='video/mp4']/url", data) != "")
			{
				// priority c
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][1]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][1]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
			
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][2]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][2]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
			}
			
			return [videoPath, videoPathTwo];
		}
		
		public function getiOSPath(data:Object):Array
		{
			var xpathValue:XMLHandler = new XMLHandler();
			
			var object:Array = getVideoIOSPath("presenter/delivery", "presentation/delivery", data);
			
			var videoPath:String = object[0];
			var videoPathTwo:String = object[1];
			
			if(xpathValue.getResult(videoPath, data) == "")
			{
				object = getVideoIOSPath("presentation/delivery", "presenter/delivery", data);
				
				videoPath = object[0];
				videoPathTwo = object[1];
			}
			
			import flash.filesystem.File;
			
			var vPath:String;
			
			if(!video1Offline)
			{
				vPath = xpathValue.getResult(videoPath, data);
			}
			else
			{
				var _url1:String = "";
				
				if(path1 != "")
				{
					_url1 = File.userDirectory.resolvePath(path1).nativePath; 
					
					_url1 = "file:///" + _url1;
				}
				else
				{
					_url1 = "";
				}
				
				vPath = _url1;
			}
			
			var vPathTwo:String;
			
			if(!video2Offline)
			{
				vPathTwo = xpathValue.getResult(videoPathTwo, data);
			}
			else
			{
				var _url2:String = "";
				
				if(path2 != "")
				{
					_url2 = File.userDirectory.resolvePath(path2).nativePath;   
					
					_url2 = "file:///" + _url2;
				}
				else
				{
					_url2 = "";
				}
				
				vPathTwo = _url2;
			}
			
			return [vPath, vPathTwo];
		}
		
		public function getVideoIOSPath(deliveryFirst:String, deliverySecond:String, data:Object):Array
		{
			var xpathValue:XMLHandler = new XMLHandler();
			
			var videoPath:String = "mediapackage/media/track[@type='"+deliveryFirst+"'][tags/tag[2]='medium-quality'][1]/url"
			var videoPathTwo:String = "mediapackage/media/track[@type='"+deliverySecond+"'][tags/tag[2]='medium-quality'][1]/url";
			
			if(xpathValue.getResult(videoPath, data) != "")
			{
				return [videoPath, videoPathTwo];
			}
			
			if(xpathValue.getResult("mediapackage/media/track[mimetype='video/x-flv']/url", data) != "")
			{
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][1]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][1]/url";
				}			
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				// priority b
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliveryFirst+"'][2]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/x-flv'][@type='"+deliverySecond+"'][2]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
			}
			
			if(xpathValue.getResult("mediapackage/media/track[mimetype='video/mp4']/url", data) != "")
			{
				// priority c
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][1]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][1]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
				
				if(xpathValue.getResult(videoPath, data) == "")
				{
					videoPath = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliveryFirst+"'][2]/url"; 
					videoPathTwo = "mediapackage/media/track[mimetype='video/mp4'][@type='"+deliverySecond+"'][2]/url";
				}
				else
				{
					return [videoPath, videoPathTwo];
				}
			}
			
			return [videoPath, videoPathTwo];
		}
	}
}