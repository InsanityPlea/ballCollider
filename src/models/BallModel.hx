package models;
import nape.phys.Body;
import nape.shape.Circle;
import nape.space.Space;
import pixi.core.display.DisplayObject;
import pixi.interaction.EventTarget;
import nape.phys.Material;
import nape.phys.BodyType;
import eventemitter3.EventEmitter;
import nape.geom.Vec2;

/**
 * ...
 * @author PervertPrayer
 */
class BallModel extends EventEmitter
{
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var rotation(get, set):Float;
	public var isCollisionEnabled(get, set):Bool;
	
	private var _isCollisionEnabled:Bool = true;
	
	private var body:Body;
	private var shape:Circle;
	
	private var currentSpace:Space;

	public function new() 
	{
		super();
		
		body = new Body(BodyType.DYNAMIC);
		
		shape = new Circle(25);
		
		body.shapes.add(shape);
		body.angularVel = 0;
		body.allowRotation = true;

		body.setShapeMaterials(Material.rubber());
	}
	
	public function assignSpace(space:Space) {
		currentSpace = space;
		body.space = currentSpace;
	}
	
	public function getBody():Body {
		return body;
	}
	
	public function freeze():Void {
		body.rotation = 0;
		body.angularVel = 0;
		body.velocity = new Vec2(0, 0);
		body.space = null;
	}
	
	public function revive():Void {
		body.position.x = x;
		body.position.y = y;
		body.rotation = rotation;
		
		if (body.space == null) {
			assignSpace(currentSpace);
		}
	}
	
	public function toObject():Dynamic {
		return { 
			x: x / Main.getCurrentWidth(),
			y: y / Main.getCurrentHeight(),
			rotation: rotation
		};
	}
	
	public function update():Void {
		emit('change');
	}
	
	public function get_x():Float {
		return body.position.x;
	}
	
	public function get_y():Float {
		return body.position.y;
	}
	
	public function get_rotation():Float {
		return body.rotation;
	}
	
	public function set_x(val:Float) {
		body.position.x = val;
		return val;
	}
	
	public function set_y(val:Float) {
		body.position.y = val;
		return val;
	}
	
	public function set_rotation(val:Float) {
		body.rotation = val;
		return val;
	}
	
	public function set_isCollisionEnabled(val:Bool) {
		_isCollisionEnabled = val;
		
		shape.filter.collisionMask = val ? -1 : 0;
		
		return val;
	}
	
	public function get_isCollisionEnabled():Bool {
		return _isCollisionEnabled;
	}
	
	public static function fromState(state:Dynamic):BallModel {
		var model:BallModel = new BallModel();
		
		if (state.x > 1) state.x = 0.9;
		if (state.y > 1) state.y = 0.9;
		
		model.x = state.x * Main.getCurrentWidth();
		model.y = state.y * Main.getCurrentHeight();
		model.rotation = state.rotation;
		
		return model;
	}
	
	public function setColliderRadius(radius:Float):Void {
		shape.radius = radius;
	}
	
}