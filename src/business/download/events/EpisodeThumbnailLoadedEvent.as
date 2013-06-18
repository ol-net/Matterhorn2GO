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
package business.download.events {
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.events.Event;
	
	public class  EpisodeThumbnailLoadedEvent extends Event 
	{
		public static const DOWNLOAD_COMPLETE:String = "DownloadComplete";
		
		public var url:String;
		public var file:File;
		public var index:uint;
		
		public function EpisodeThumbnailLoadedEvent(type:String, url:String, file:File, index:uint)
		{
			super(type, true);
			this.url = url;
			this.file = file;
			this.index = index;
		}
		
		override public function toString():String{
			return super.toString() + ": "+ url + " -> "+file.url;
		}
	}
}