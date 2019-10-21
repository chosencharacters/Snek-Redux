package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxExtendedSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.addons.effects.FlxTrail;
import flixel.effects.particles.*;
import flixel.util.FlxColor;

/**
 * ...
 * @author Squidly
 */
class MrMunch extends FlxSprite
{
	var speed:Int = 2;
	var door:FlxSprite;
	var axe:FlxSprite;
	public static var onboard:Bool = false;
	public static var killed:Bool = false;
	public static var living:Bool = false;

	public function new(?X:Float = 0, ?Y:Float = 0, px:Float = 0, py:Float = 0 ) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.MrMunch__png, true, 28, 24);
		animation.add("walk", [0, 1], 4);
		animation.play("walk");
		PlayState.enemies.add(this);
		
		door = new FlxSprite(px+128-4, py);
		door.makeGraphic(8, 76);
		PlayState.doors.add(door);
		
		axe = new FlxSprite(px+100, py+32);
		axe.loadGraphic(AssetPaths.axe__png);
		PlayState.extra.add(axe);
		
		onboard = true;
		trail = new FlxTrail(this, AssetPaths.MrMunchTrail__png, 4, Math.floor(PlayState.rate/2), .3);
		PlayState.trails.add(trail);
		
		active = true;
		
		color = FlxColor.WHITE;
	}
	
	var trail:FlxTrail;

	var up:Bool = true;
	var tick:Int = 0;
	override public function update(elapsed:Float):Void 
	{
		tick++;
		if (Math.floor(tick%(PlayState.rate/2))==0){
			if (up){
				y -= speed;
			}else{
				y += speed;
			}
			if (y<5){
				up = false;
			}
			if (y+height>FlxG.height-5){
				up = true;
			}
			trail.color = color;
		}
		if (FlxG.overlap(axe, PlayState.snake.members[PlayState.snake.length - 1])){
			PlayState.makeWord(x+width/2, y+height/2, "gg");
			SoundPlayer.axe();
			killed = true;
			kill();
			PlayState.checkpoint = "Cave";
			return;
		}
		super.update(elapsed);
	}
	
	override function kill(){
		PlayState.enemies.remove(this);
		PlayState.doors.remove(door, true);
		PlayState.extra.remove(axe, true);
		var e:FlxEmitter = new FlxEmitter(x+2, y+2);
		for (i in 0...10){
			var p:FlxParticle = new FlxParticle();
			p.makeGraphic(2, 2, 0xFF+color);
			e.add(p);
			if (MenuState.retro){
				p.makeGraphic(2, 2, FlxColor.BLACK);
			}
		}
		PlayState.emitter.add(e);
		e.allowCollisions = FlxObject.ANY;
		e.start(true);
		trail.kill();
		killed = true;
		super.kill();
	}
	
	public static function resetThis(){
		killed = false;
		onboard = false;
		living = false;
	}
	
}