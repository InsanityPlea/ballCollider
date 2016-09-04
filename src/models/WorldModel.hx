package models;
import haxe.Constraints.Function;
import nape.space.Space;
import pixi.core.display.DisplayObject;
import pixi.interaction.EventEmitter;
import haxe.Json;

/**
 * ...
 * @author PervertPrayer
 */
class WorldModel extends DisplayObject
{
	private var ballCollection:Array<BallModel>;
	
	public var space:Space;

	public function new() 
	{
		super();
		ballCollection = [];
	}
	
	public function update():Void {
		for (i in 0 ... ballCollection.length) {
			ballCollection[i].update();
		}
	}
	
	public function addBall(ballModel:BallModel):Void {
		ballCollection.push(ballModel);
	}
	
	public function toJson():String {
		var serializedCollection:Array<Dynamic> = [];
		
		for (i in 0 ... ballCollection.length) {
			serializedCollection.push(ballCollection[i].toObject());
		}
		
		return Json.stringify(serializedCollection);
	}
	
	public function fromJson(jsonData:String, componentBuilder:Function) {
		var serializedCollection:Array<Dynamic> = Json.parse(jsonData);
		var model:BallModel;
		
		ballCollection = [];
		
		for (i in 0 ... serializedCollection.length) {
			model = BallModel.fromState(serializedCollection[i]);
			ballCollection.push( model );
			componentBuilder( model );
		}
	}
	
}