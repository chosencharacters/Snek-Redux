package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.pex.FlxPexParser.PexEmitterType;
import flixel.addons.effects.FlxTrail;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxColor;
/**
 * ...
 * @author Squidly
 */
 
class Trophy extends FlxSprite
{
	public static var key:Bool = false;
	var door:FlxSprite;
	var tf:FlxSprite;
	var trail:FlxTrail;
	
	public static var onboard = false;
	public static var taken = false;
	
	public function new(X:Float=0,Y:Float=0,px:Float,py:Float) 
	{
		super(X, Y);
		key = false;
		
		color = FlxColor.WHITE;
		
		tf = new FlxSprite(x, y);
		
		loadGraphic(AssetPaths.trophy__png);
		
		if (Chalice.has == 3){
			key = true;
			x -= 4;
			y += 6;
			loadGraphic(AssetPaths.bigkey__png);
			trail = new FlxTrail(tf, AssetPaths.bigkey__png, 4, Math.floor(PlayState.rate/2), .3);
		}else{
			trail = new FlxTrail(tf, AssetPaths.trophy__png, 4, Math.floor(PlayState.rate/2), .3);
		}
		
		PlayState.trails.add(trail);
		
		tf.makeGraphic(Math.round(width), Math.round(height));
		tf.visible = false;
		PlayState.extra.add(tf);
		
		door = new FlxSprite(px+128-4, py);
		door.makeGraphic(8, 76);
		PlayState.doors.add(door);
		PlayState.extra.add(this);
		
		onboard = true;
	}
	
	var tick:Int = 0;
	var tCount:Int = 0;
	
	override public function update(elapsed:Float):Void 
	{
		tick++;
		if (FlxG.overlap(this, PlayState.snake.members[PlayState.snake.length - 1])){
			//PlayState.makeWord(x, y, "winner");
			SoundPlayer.powerup();
			taken = true;
			kill();
			return;
		}
		if (Math.floor(tick % (PlayState.rate)) == 0){
			trail.color = color;
			//mess with the trail
			tCount++;
			switch(tCount){
				case 1: tf.x = x + 1;
				case 2: tf.y = y + 1;
				case 3: tf.x = x - 1;
				case 4: tf.y = y - 1;
				case 5: tf.x = x + 1; tf.y = y + 1;
				case 6: tf.x = x - 1; tf.y = y + 1;
				case 7: tf.x = x + 1;
			}
			if (tCount > 7){
				tCount = 0;
			}
		}
		super.update(elapsed);
	}
	
	override public function kill():Void 
	{
		var e:FlxEmitter = new FlxEmitter(x + width / 2, y + height / 2);
		for (i in 0...40){
			var p:FlxParticle = new FlxParticle();
			p.makeGraphic(2, 2, 0xFF+color);
			e.add(p);
		}
		PlayState.emitter.add(e);
		e.start(true);
		trail.visible = false;
		trail.kill();
		if (key){
			door.kill();
		}else{
			Online.log("Game Won " + PlayState.difficulty);
			PlayState.victory();
		}
		super.kill();
	}
	
	public static function resetThis(){
		taken = false;
		onboard = false;
		key = false;
	}
	
}