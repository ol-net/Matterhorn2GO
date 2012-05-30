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
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.core.IChildList;
	import mx.core.IRawChildrenContainer;
	import mx.core.IUITextField;
	import mx.styles.*;
	import mx.utils.NameUtil;
	
	import spark.core.SpriteVisualElement;
	
	//SpriteVisualElement
	
	public class StyleClient extends SpriteVisualElement implements IStyleClient, IChildList, IAdvancedStyleClient
	{
		protected var layoutWidth:Number;
		protected var layoutHeight:Number;
		protected var measuredWidth:Number;
		protected var measuredHeight:Number;
		protected var explicitWidth:Number;
		protected var explicitHeight:Number;
		protected var creationComplete:Boolean;
		protected var declarations:Dictionary = new Dictionary();
		protected var stateDeclaraion:CSSStyleDeclaration;
		
		protected var _styleParent:IAdvancedStyleClient
		
		/**
		 *  The parent of this <code>IAdvancedStyleClient</code>..
		 *
		 *  Typically, you do not assign this property directly.
		 *  It is set by the <code>addChild, addChildAt, removeChild, and
		 *  removeChildAt</code> methods of the
		 *  <code>flash.display.DisplayObjectContainer</code> and  the
		 *  <code>mx.core.UIComponent.addStyleClient()</code>  and
		 *  the <code>mx.core.UIComponent.removeStyleClient()</code> methods.
		 *
		 *  If it is assigned a value directly, without calling one of the
		 *  above mentioned methods the instance of the class that implements this
		 *  interface will not inherit styles from the UIComponent or DisplayObject.
		 *  Also if assigned a value directly without, first removing the
		 *  object from the current parent with the remove methods listed above,
		 *  a memory leak could occur.
		 **/ 
		public function get styleParent():IAdvancedStyleClient
		{
			return  parent as IAdvancedStyleClient;;
		}
		public function set styleParent( value:IAdvancedStyleClient ):void
		{
			_styleParent = value;
		}
		
		public function get className():String
		{
			return NameUtil.getUnqualifiedClassName(this);
		}
		
		/**
		 *  The state to be used when matching CSS pseudo-selectors. By default
		 *  this is the currentState.
		 */ 
		private var _currentCSSState:String;
		
		public function get currentCSSState():String
		{
			return _currentCSSState;
		}
 
		public function set currentCSSState( value:String ):void
		{
			_currentCSSState = value;
			
			setStateDeclaration();
		}
		
		public function hasCSSState():Boolean
		{
			if(_currentCSSState != "")
			{
				return true;
			}
			
			return false;
		}
		
		public function stylesInitialized():void
		{
			if( !creationComplete )
			{
				createChildren();
				creationComplete = true;
				measure()
			}	
		}

		public function matchesCSSState(cssState:String):Boolean
		{
			return currentCSSState == cssState;
		}
		
		public function matchesCSSType(cssType:String):Boolean
		{
			return StyleProtoChain.matchesCSSType(this, cssType);
		}
		
		/**
		 *  Storage for the inheritingStyles property.
		 */
		private var _inheritingStyles:Object = StyleProtoChain.STYLE_UNINITIALIZED;
		
		[Inspectable(environment="none")]
		
		/**
		 *  The beginning of this component's chain of inheriting styles.
		 *  The <code>getStyle()</code> method simply accesses
		 *  <code>inheritingStyles[styleName]</code> to search the entire
		 *  prototype-linked chain.
		 *  This object is set up by <code>initProtoChain()</code>.
		 *  Developers typically never need to access this property directly.
		 */
		public function get inheritingStyles():Object
		{
			return _inheritingStyles;
		}
		
		public function set inheritingStyles(value:Object):void
		{
			_inheritingStyles = value;
		}
		
		/**
		 *  Storage for the nonInheritingStyles property.
		 */
		private var _nonInheritingStyles:Object = StyleProtoChain.STYLE_UNINITIALIZED;
		
		[Inspectable(environment="none")]
		
		/**
		 *  The beginning of this component's chain of non-inheriting styles.
		 *  The <code>getStyle()</code> method simply accesses
		 *  <code>nonInheritingStyles[styleName]</code> to search the entire
		 *  prototype-linked chain.
		 *  This object is set up by <code>initProtoChain()</code>.
		 *  Developers typically never need to access this property directly.
		 */
		public function get nonInheritingStyles():Object
		{
			return _nonInheritingStyles;
		}
		
		public function set nonInheritingStyles(value:Object):void
		{
			_nonInheritingStyles = value;
		}
		
		
		private var _styleDeclaration:CSSStyleDeclaration;
		public function get styleDeclaration():CSSStyleDeclaration
		{
			return _styleDeclaration;
		}
		
		public function set styleDeclaration( value:CSSStyleDeclaration ):void
		{
			_styleDeclaration = value
		}
		
		/**
		 *  Returns the StyleManager instance used by this component.
		 */
		public function get styleManager():IStyleManager2
		{
			return StyleManager.getStyleManager(moduleFactory);
		}
		
		
		public function getStyle(styleProp:String):*
		{
			return styleManager.inheritingStyles[styleProp] ? _inheritingStyles[styleProp] : _nonInheritingStyles[styleProp];
		}
		
		public function setStyle(styleProp:String, newValue:*):void
		{
			StyleProtoChain.setStyle(this, styleProp, newValue);
		}
		
		public function clearStyle(styleProp:String):void
		{
			setStyle(styleProp, undefined);
		}
		
		public function getClassStyleDeclarations():Array
		{
			return StyleProtoChain.getClassStyleDeclarations( this );
		}
		
		public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
		{
			var n:int = numChildren;
			for (var i:int = 0; i < n; i++)
			{
				var child:ISimpleStyleClient = getChildAt(i) as ISimpleStyleClient;
				
				if (child)
				{
					child.styleChanged(styleProp);
					
					// Always recursively call this function because of my
					// descendants might have a styleName property that points
					// to this object.  The recursive flag is respected in
					// Container.notifyStyleChangeInChildren.
					if (child is IStyleClient) {
						IStyleClient(child).notifyStyleChangeInChildren(styleProp, recursive);
					}
				}
			}
			stylesInitialized();
		}
		
		public function regenerateStyleCache(recursive:Boolean):void
		{
			StyleProtoChain.initProtoChain(this);
			stylesInitialized();
			
			var childList:IChildList = this is IRawChildrenContainer ? IRawChildrenContainer( this ).rawChildren : IChildList(this);
			
			// Recursively call this method on each child.
			var n:int = childList.numChildren;
			
			for (var i:int = 0; i < n; i++)
			{
				var child:Object = childList.getChildAt(i);
				
				if (child is IStyleClient)
				{
					// Does this object already have a proto chain?
					// If not, there's no need to regenerate a new one.
					IStyleClient( child ).regenerateStyleCache( recursive );
					
				}
				else if (child is IUITextField)
				{
					// Does this object already have a proto chain?
					// If not, there's no need to regenerate a new one.
					if (IUITextField(child).inheritingStyles)
						StyleProtoChain.initTextField(IUITextField(child));
				}
			}
		}
		
		public function registerEffects(effects:Array):void
		{
			// not implemented
		}
		
		private var _styleName:Object
		public function get styleName():Object
		{
			return _styleName;
		}
		
		public function set styleName(value:Object):void
		{
			_styleName = value;
			if( creationComplete )
				StyleProtoChain.initProtoChain(this);
		}
		
		public function styleChanged(styleProp:String):void
		{
			//StyleProtoChain.styleChanged(this, styleProp);
			
			if (styleProp && (styleProp != "styleName"))
			{ 
				if (hasEventListener(styleProp + "Changed"))
					dispatchEvent(new Event(styleProp + "Changed"));
			}
			else 
			{
				if (hasEventListener("allStylesChanged"))
					dispatchEvent(new Event("allStylesChanged"));
			}
		}
		
		protected function setStateDeclaration():void
		{
			StyleProtoChain.initProtoChain(this);
		}
		
		protected function createChildren():void
		{
			
		}
		
		// updateDisplayList -------------------------------------------------------------------------
		/**
		 * Layout all the childrens
		 */
		protected function updateDisplayList( width:Number,  height:Number ):void
		{
			// To be implemented in sub classes
		}
		
		protected function measure():void
		{
			// To be implemented in sub classes
		}
		
		protected function invalidateDisplayList():void
		{
			//trace("updateList")
			if( layoutWidth && layoutHeight )
			{
				//trace("drin")
				updateDisplayList( layoutWidth, layoutHeight );
				
				setLayoutBoundsSize( layoutWidth, layoutHeight );
			}
		}
		
		override public function getLayoutBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
			return ( layoutHeight ) ? layoutHeight : super.getLayoutBoundsHeight( postLayoutTransform );
		}
		
		override public function getLayoutBoundsWidth(postLayoutTransform:Boolean=true):Number
		{
			return ( layoutWidth ) ? layoutWidth : super.getLayoutBoundsWidth( postLayoutTransform );
		}
		

		override public function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number
		{
			return ( measuredWidth ) ? measuredWidth : super.getPreferredBoundsWidth( postLayoutTransform );
		}
		

		override public function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number
		{
			return ( measuredHeight ) ? measuredHeight : super.getPreferredBoundsHeight( postLayoutTransform );
		}
		
		override public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void
		{
			if ( isNaN( width ) )
				width = getPreferredBoundsWidth( postLayoutTransform );
			
			if ( isNaN( height ) )
				height = getPreferredBoundsHeight( postLayoutTransform );
			
			layoutWidth = width;
			layoutHeight = height;
			
			updateDisplayList( width, height );
		}
	}
}