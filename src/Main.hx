package;

import components.Ball;
import components.Explosion;
import js.html.Event;
import js.Browser;
import models.BallModel;
import models.WorldModel;
import nape.callbacks.CbType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import pixi.core.graphics.Graphics;
import pixi.core.math.Point;
import pixi.core.textures.Texture;
import pixi.core.sprites.Sprite;
import pixi.plugins.app.Application;
import pixi.interaction.EventTarget;
import pixi.loaders.Loader;
import haxe.Timer;
import screens.GameScreen;
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

class Main extends Application {
	
	private static var _instance:Main;
	private var currentScreen:GameScreen;

	public function new() {
		super();		
		loadAssets();
	}
	
	//ENTRY POINT
	static function main() {
		_instance = new Main();
	}
	
	private function loadAssets():Void {
		var loader:Loader = new Loader();
		loader.add('spritesheet', 'assets/mc.json');
		loader.load(onAssetsLoaded);
	}
	
	private function onAssetsLoaded():Void {
		init();		
		currentScreen = new GameScreen();
		stage.addChild(currentScreen);
		
		onUpdate = currentScreen.update;
	}

	private function init() {
		backgroundColor = 0x6699FF;
		autoResize = true;
		super.start();
		initListeners();
	}
	
	private function initListeners():Void {
		Browser.window.addEventListener('orientationchange', onOrientationChange, false);
		Browser.window.onbeforeunload = onGameExit;
	}
	
	private function onGameExit(e:Event):String {
		return currentScreen.onGameExit(e);
	}
	
	//TODO: smart active/static area resize mechanism
	private function onOrientationChange(e:Event):Void {
		Browser.window.location.reload();
	}
	
	public static function getCurrentWidth():Float {
		return _instance.width;
	}
	
	public static function getCurrentHeight():Float {
		return _instance.height;
	}
}