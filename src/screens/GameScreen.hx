package screens;
import components.Ball;
import components.Explosion;
import components.SimpleButton;
import js.html.Event;
import js.Browser;
import models.BallModel;
import models.WorldModel;
import nape.callbacks.CbType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;
import pixi.core.math.Point;
import pixi.core.textures.Texture;
import pixi.core.sprites.Sprite;
import pixi.plugins.app.Application;
import pixi.interaction.EventTarget;
import pixi.loaders.Loader;
import haxe.Timer;
import utils.AnimationManager;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;
import nape.phys.Material;
import nape.constraint.PivotJoint;
import nape.callbacks.InteractionType;

import haxe.Json;

/**
 * ...
 * @author PervertPrayer
 */
class GameScreen extends Container
{
	private var dragData:EventTarget = null;
	private var dragJoint:PivotJoint;
	
	private var wallCollisionType:CbType;
	
	private var background:Graphics = null;
	
	private var worldModel:WorldModel;
	
	private var animationManager:AnimationManager;
	
	private var isExplosionsEnabled:Bool = false;
	
	private var funButton:SimpleButton;

	public function new() 
	{
		super();
		
		drawBackground();
		
		animationManager = AnimationManager.getInstance();
		
		setUpPhysics();
		initBalls();
		
		funButton = new SimpleButton();
		funButton.x = funButton.y = 0;
		addChild(funButton);
		
		initListeners();
	}
	
	private function initBalls():Void {		
		var storedState:String = Browser.window.sessionStorage.getItem('worldState');
		
		if (storedState != null) { //world restore case
			worldModel.fromJson(storedState, function(ballModel:BallModel) {
				spawnBall(ballModel);
			});
			
		} else { //new world case
			
			for (i in 0...10) {
				spawnBall();
			}
		}
	}
	
	private function initListeners():Void {
		
		worldModel.space.listeners.add(new PreListener(
				InteractionType.COLLISION,
				wallCollisionType,
				CbType.ANY_BODY,
				wallCollisionHandler,
				0,
				true
		));
		
		funButton.on('mousedown', toggleFunMode);
		funButton.on('touchstart', toggleFunMode);
	}
	
	public function toggleFunMode(e:EventTarget):Void {		
		isExplosionsEnabled = !isExplosionsEnabled;
		funButton.toggle();
		
		worldModel.space.gravity = isExplosionsEnabled ? Vec2.weak(0, Main.getCurrentHeight()) : Vec2.weak(0, 0);
		
		var displayObjectCollection:Array<DisplayObject> = this.children;
		var currentItem:Dynamic;
		
		for (i in 0 ... displayObjectCollection.length) {
			currentItem = displayObjectCollection[i];
			if (Reflect.hasField(currentItem, 'model')) {
				currentItem.toggleTexture(isExplosionsEnabled);
			}
		}
	}
	
	

	public function update(elapsedTime:Float) {
		worldModel.space.step(1 / 60);
		
		if (dragJoint.active) {
			if(dragData != null){
				var target:Ball = cast(dragData.target, Ball);
				var dragPoint:Point = dragData.data.getLocalPosition(target.parent);
				dragJoint.anchor1.setxy(dragPoint.x, dragPoint.y);
			}
		}
		
		worldModel.update();
	}
	
	private function drawBackground():Void {
		if(background == null){
			background = new Graphics();

			addChild(background);
		}

		background.beginFill(0x000000, 0.8);

		background.lineStyle(2, 0x000000);

		background.drawRect(Main.getCurrentWidth() / 2, 0, Main.getCurrentWidth() / 2, Main.getCurrentHeight());
	}

	private function setUpPhysics() {		
		worldModel = new WorldModel();
		
		var gravity = Vec2.weak(0, 0);
		worldModel.space = new Space(gravity);
		
		// Setup walls.
		
		wallCollisionType = new CbType();
		var border:Body = new Body(BodyType.STATIC);
		border.shapes.add(new Polygon(Polygon.rect(0, 0, Main.getCurrentWidth(), -1)));
		border.shapes.add(new Polygon(Polygon.rect(0, Main.getCurrentHeight(), Main.getCurrentWidth(), 1)));
		border.shapes.add(new Polygon(Polygon.rect(0, 0, -1, Main.getCurrentHeight())));
		border.shapes.add(new Polygon(Polygon.rect(Main.getCurrentWidth(), 0, 1, Main.getCurrentHeight())));
		border.shapes.add(new Polygon(Polygon.rect(Main.getCurrentWidth() / 2, 0, 1, Main.getCurrentHeight())));
		border.cbTypes.add(wallCollisionType);
		border.setShapeMaterials(Material.wood());
		border.space = worldModel.space;
		
		dragJoint = new PivotJoint(worldModel.space.world, null, Vec2.weak(), Vec2.weak());
		dragJoint.space = worldModel.space;
		dragJoint.active = false;		
		dragJoint.stiff = false;
	}

	private function spawnBall(ballModel:BallModel = null) {
		if (ballModel == null) {
			var padding:Float = 40;
			
			ballModel = new BallModel();
			ballModel.x = Std.random(cast (Main.getCurrentWidth() / 2 - padding)) + padding;
			ballModel.y = Main.getCurrentHeight() - padding;
			ballModel.rotation = 0;
		
			worldModel.addBall(ballModel);
		}
		
		
		var ball:Ball = new Ball(ballModel);
		
		ballModel.assignSpace(worldModel.space);
		
		ball.on('mousedown', onDragStart);
		ball.on('touchstart', onDragStart);
		ball.on('mouseup', onDragEnd);
        ball.on('mouseupoutside', onDragEnd);
        ball.on('touchend', onDragEnd);
        ball.on('touchendoutside', onDragEnd);
		
		addChild(ball);
		
		if (ballModel.x < Main.getCurrentWidth() / 2) {
			ball.freeze();
		}
	}
	
	private function onDragEnd(event:EventTarget = null):Void {
		if(dragData != null){
			var target:Ball = cast(dragData.target, Ball);
			dragData = null;
			target.stopDrag();
			dragJoint.active = false;
			
			if (target.x > Main.getCurrentWidth() / 2) {
				target.revive();
			} else {
				target.freeze();
			}
		}
	}
	
	private function onDragStart(event:EventTarget) {
		if (dragData != null) return;
		
		dragData = event;
		
		var target:Ball = cast(dragData.target, Ball);
		target.startDrag();
		
		var dragPoint:Point = dragData.data.getLocalPosition(target.parent);
		var mousePoint:Vec2 = Vec2.get(dragPoint.x, dragPoint.y);
		var targetBody:Body = target.getBody();
		
		dragJoint.body2 = targetBody;
		dragJoint.anchor2.set(targetBody.worldPointToLocal(mousePoint, true));
		dragJoint.active = true;
	}
	
	public function onGameExit(e:Event = null):String {
		Browser.window.sessionStorage.setItem('worldState', worldModel.toJson());
		
		return '';
	}
	
	private function wallCollisionHandler(callback:PreCallback):PreFlag {
		if (Math.random() > 0.5 && isExplosionsEnabled) {
			var targetPosition:Vec2 = callback.arbiter.body2.position;
			animationManager.explodeAt(targetPosition.x, targetPosition.y, this);
		}
		return PreFlag.ACCEPT;
	}
	
}