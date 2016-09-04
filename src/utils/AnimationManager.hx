package utils;
import components.Explosion;
import pixi.core.display.Container;

/**
 * ...
 * @author PervertPrayer
 */
class AnimationManager
{
	private var explosionPool:Array<Explosion>;
	private static var instance:AnimationManager = null;

	public function new() 
	{
		explosionPool = [];
	}
	
	public function explodeAt(x:Float, y:Float, container:Container):Void {
		var explosionInstance:Explosion = null;
		for (i in 0 ... explosionPool.length) {
			if (explosionPool[i].parent == null) {
				explosionInstance = explosionPool[i];
				break;
			}
		}
		
		if (explosionInstance == null) {
			explosionInstance = new Explosion();
			explosionPool.push(explosionInstance);
		}
		
		explosionInstance.x = x;
		explosionInstance.y = y;
		
		container.addChild(explosionInstance);
		
		explosionInstance.gotoAndPlay(0);
	}
	
	public static function getInstance():AnimationManager {
		if (instance == null) instance = new AnimationManager();
		
		return instance;
	}
	
}