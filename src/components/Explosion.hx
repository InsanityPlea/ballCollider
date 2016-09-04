package components;
import pixi.extras.MovieClip;
import pixi.core.textures.Texture;

/**
 * ...
 * @author PervertPrayer
 */
class Explosion extends MovieClip
{
	private var explosionTextures:Array<Texture> = [];

	public function new() 
	{
		for (i in 0 ... 26) {
			var texture = Texture.fromFrame('Explosion_Sequence_A ' + (i+1) + '.png');
			explosionTextures.push(texture);
		}
		
		super(explosionTextures);
		
		animationSpeed = 0.5;
		loop = false;
		onComplete = onAnimationFinish;
		
		anchor.set(0.5, 0.5);
	}
	
	private function onAnimationFinish():Void {
		stop();
		if (parent != null) {
			parent.removeChild(this);
		}
	}
	
}