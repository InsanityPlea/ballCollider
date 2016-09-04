package components;

import models.BallModel;
import nape.callbacks.CbType;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import nape.space.Space;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.phys.Material;
import nape.geom.Vec2;


/**
 * ...
 * @author PervertPrayer
 */
class Ball extends Sprite
{
	private var model:BallModel;

	public function new(model:BallModel) 
	{
		super(Texture.fromImage("assets/ball.png"));
		
		interactive = true;
		buttonMode = true;
		anchor.set(0.5, 0.5);
		
		model.addListener('change', update);
		
		this.model = model;
	}
	
	public function getBody():Body {
		return model.getBody();
	}
	
	public function update(e:Dynamic) {
		this.position.x = model.x;
		this.position.y = model.y;
		this.rotation = model.rotation;
		
	}
	
	public function startDrag():Void {
		model.isCollisionEnabled = false;
		
		revive();
	}
	
	public function freeze():Void {
		model.freeze();
	}
	
	public function revive():Void {
		model.revive();
	}
	
	public function stopDrag():Void {
		model.isCollisionEnabled = true;
	}
	
	public function toggleTexture(isFunMode:Bool):Void {
		texture = isFunMode ? Texture.fromImage("assets/bunny.png") : Texture.fromImage("assets/ball.png");
		model.setColliderRadius(isFunMode ? 10 : 25);
	}
	
}