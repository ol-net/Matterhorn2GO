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
package business
{
	import org.osmf.elements.ProxyElement;
    import org.osmf.media.MediaElement;
    import org.osmf.traits.MediaTraitType;
    import org.osmf.events.MediaElementEvent;
    import org.osmf.traits.AudioTrait;
	
	public class OProxyElement extends ProxyElement
    { 
        public function OProxyElement(proxiedElement:MediaElement=null)
        {
            super(proxiedElement);
            var blockedTraits:Vector.<String> = new Vector.<String>();
            blockedTraits.push(MediaTraitType.AUDIO);
            super.blockedTraits =  blockedTraits;
        }
        
        override public function set proxiedElement(value:MediaElement):void
        {

            super.proxiedElement = value;
               if (proxiedElement != null)
            {
                  var audioTrait:AudioTrait = proxiedElement.getTrait(MediaTraitType.AUDIO) as AudioTrait;

                  if (audioTrait != null)
                {

                     audioTrait.muted = true;
                }
                else
                {
                    // Wait for the trait to become available.
                    proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
                }
            }
        }
        
        private function onTraitAdd(event:MediaElementEvent):void
        {
            if (event.traitType == MediaTraitType.AUDIO)
               {
                proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD,  onTraitAdd);
                var audioTrait:AudioTrait =  proxiedElement.getTrait(MediaTraitType.AUDIO) as AudioTrait;
                audioTrait.volume = 0;
                audioTrait.muted = true;
            }
        }
    }
}