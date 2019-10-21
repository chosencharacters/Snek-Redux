package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;

/**
 * ...
 * @author Squidly
 */
class Chalice extends FlxSprite
{
	var door:FlxSprite;
	public static var onboard:Bool = false;
	public static var spawns:Int = 0;
	public static var has:Int = 3;
	public static var holds:Bool = false;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		holds = false;
		onboard = true;
		loadGraphic(AssetPaths.chalice__png);
		PlayState.extra.add(this);
		spawns++;
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (FlxG.overlap(this, PlayState.snake.members[PlayState.snake.length - 1])){
			PlayState.makeWord(x, y, "chalice");
			PlayState.bonuslength = 5;
			has++;
			SoundPlayer.powerup();
			kill();
			holds = true;
			return;
		}
		super.update(elapsed);
	}
	
	override function kill(){
		PlayState.extra.remove(this, true);
		super.kill();
	}
	
	public static function resetThis(){
		has = 0;
		spawns = 0;
		onboard = false;
		holds = false;
	}
}