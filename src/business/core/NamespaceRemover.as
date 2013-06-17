package business.core
{
	public class NamespaceRemover
	{
		//Constructor
		public function NamespaceRemover(){}
		
		//PUBLIC FUNCTIONS searchTime="1" total="508" limit="999999" offset="0"
		public static function remove(xml:XML):XML{
			
			var attr:String = getAttributes(xml.@*);
			var theXML:XML;
			
			theXML = new XML("<"+xml.localName()+attr+"></"+xml.localName()+">");
			
			if(xml.elements().length() > 0){
				var a:Number;
				for(a=0;a<xml.elements().length();a++){
					//trace(xml.elements()[a])
					var nsRemoved:XML = remove(xml.elements()[a]);
					//trace(xml.elements()[a])
					theXML.appendChild(nsRemoved);
					//theXML.appendChild(xml.elements()[a]);
				}
			} else {
				theXML = xml;
			}
			return theXML;
			//trace(theXML)
			//return removeDefaultNamespaceFromXML(theXML);
		}
		
		public static function removeDefaultNamespaceFromXML(xml:XML):XML
		{
			var rawXMLString:String = xml.toXMLString();
			
			/* Define the regex pattern to remove the default namespace from the 
			String representation of the XML result. */
			var xmlnsPattern:RegExp = //new RegExp("xmlns=\"http://mediapackage.opencastproject.org\"", "gi");
					new RegExp("xmlns=[^\"]*\"[^\"]*\"", "gi");
			
			/* Replace the default namespace from the String representation of the 
			result XML with an empty string. */
			var cleanXMLString:String = rawXMLString.replace(xmlnsPattern, "");
			//trace(cleanXMLString)
			// Create a new XML Object from the String just created
			return new XML(cleanXMLString);
		}
		
		//PRIVATE FUNCTIONS
		public static function getAttributes(attr:XMLList):String{
			//trace(attr)
			var attrString:String = " ";
			//trace(attr)
			if(attr.length() == 0){
				//trace("l "+attrString)
				return attrString;
			}
			var b:Number;
			for(b=0;b<attr.length();b++){
				attrString += attr[b].localName()+"='"+attr[b]+"' ";
				//trace("e "+attrString)
			}
			return attrString;
		}
	}
}