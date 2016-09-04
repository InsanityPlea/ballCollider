package components;
import pixi.core.graphics.Graphics;
import pixi.core.sprites.Sprite;
import pixi.core.text.Text;
import pixi.core.text.TextStyle;
import pixi.core.text.TextStyleObject;
import pixi.core.textures.Texture;

/**
 * ...
 * @author PervertPrayer
 */
class SimpleButton extends Graphics
{
	
	private var label:Text;
	private var isOn:Bool = false;

	public function new() 
	{
		super();
		
		var padding:Int = 20;
		
		interactive = true;
		buttonMode = true;
		
		var fontStyle:TextStyleObject = {
			fill: 0xFFFFFF
		};
		
		label = new Text('Fun mode: OFF', fontStyle);
		label.x = label.y = padding;
		addChild(label);
		
		this.beginFill(0xFF0000, 0.8);

		this.lineStyle(2, 0xFF0000);

		this.drawRect(0, 0, label.width + padding * 2, label.height + padding * 2);
	}
	
	public function toggle():Void {
		isOn = !isOn;
		label.text = 'Fun mode: ' + (isOn ? 'ON' : 'OFF');
	}
	
}