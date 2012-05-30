package views.skins.menustyle
{
import flash.display.GradientType;
import flash.display.Graphics;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.IconPlacement;
import views.skins.menustyle.assets.ViewMenuItem_down;
import views.skins.menustyle.assets.ViewMenuItem_showsCaret;
import views.skins.menustyle.assets.ViewMenuItem_up;
import spark.skins.mobile.supportClasses.ButtonSkinBase;
import spark.skins.mobile.ButtonSkin;
import views.skins.menustyle.assets320.ViewMenuItem_down;
import views.skins.menustyle.assets320.ViewMenuItem_showsCaret;
import views.skins.menustyle.assets320.ViewMenuItem_up;

use namespace mx_internal;

/**
 *  Default skin for ViewMenuItem. Supports a label, icon and iconPlacement and draws a background.   
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */ 
public class CustomViewMenuItemSkin extends ButtonSkin
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function CustomViewMenuItemSkin()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                
                upBorderSkin = views.skins.menustyle.assets320.ViewMenuItem_up;
                downBorderSkin = views.skins.menustyle.assets320.ViewMenuItem_down;
                showsCaretBorderSkin = views.skins.menustyle.assets320.ViewMenuItem_showsCaret;
                
                layoutGap = 12;
                layoutPaddingLeft = 12;
                layoutPaddingRight = 12;
                layoutPaddingTop = 12;
                layoutPaddingBottom = 12;
                layoutBorderSize = 2;   
                
                
                break;
            }
            case DPIClassification.DPI_240:
            {   
                upBorderSkin = views.skins.menustyle.assets.ViewMenuItem_up;
                downBorderSkin = views.skins.menustyle.assets.ViewMenuItem_down;
                showsCaretBorderSkin = views.skins.menustyle.assets.ViewMenuItem_showsCaret;
                
                layoutGap = 8;
                layoutPaddingLeft = 8;
                layoutPaddingRight = 8;
                layoutPaddingTop = 8;
                layoutPaddingBottom = 8;
                layoutBorderSize = 1;
                
                break;
                
            }
            default:
            {
                upBorderSkin = views.skins.menustyle.assets.ViewMenuItem_up;
                downBorderSkin = views.skins.menustyle.assets.ViewMenuItem_down;
                showsCaretBorderSkin = views.skins.menustyle.assets.ViewMenuItem_showsCaret; 
                
                layoutGap = 6;
                layoutPaddingLeft = 6;
                layoutPaddingRight = 6;
                layoutPaddingTop = 6;
                layoutPaddingBottom = 6;
                layoutBorderSize = 1;
            }
        }
    }
	
	/**
	 *  @private
	 */
	override protected function createChildren():void
	{
		super.createChildren();
		
		// hide the labelDisplayShadow text
		labelDisplayShadow.visible = false;
	}
    
    /**
     *  Class to use for the border in the showsCaret state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     *       
     *  @default Button_down
     */ 
    protected var showsCaretBorderSkin:Class;
    
    /**
     *  @private
     */
    override protected function getBorderClassForCurrentState():Class
    {
        var borderClass:Class = super.getBorderClassForCurrentState();
        
        if (currentState == "showsCaret")
            borderClass = showsCaretBorderSkin;  
        
        return borderClass;
    }
	
	/**
	 *  @private 
	 */ 
	override public function set currentState(value:String):void
	{
		super.currentState = value;
		
		switch(value)
		{
			case "up":
				labelDisplay.textColor = 0xffffff;
				break;
			case "down":
			case "showsCaret":	
				labelDisplay.textColor = 0xffffff;
				break;
		}
	}
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var iconPlacement:String = getStyle("iconPlacement");
        useCenterAlignment = (iconPlacement == IconPlacement.LEFT)
            || (iconPlacement == IconPlacement.RIGHT);
        
        super.layoutContents(unscaledWidth, unscaledHeight);
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit background rendering in code and use FXG for background instead
    }
}
}