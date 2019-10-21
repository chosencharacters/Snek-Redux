package;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.particles.*;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;

/**
 * ...
 * @author Squidly
 */
class HeartBullet extends FlxSprite
{
	var xSpeed:Int = 0;
	var ySpeed:Int = 0;
	public var team:Int = 2;
	static var dirCount:Int = 0;

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y, "");
		loadGraphic(AssetPaths.HeartDisc__png);
		dirCount++;
		switch(dirCount){
			case 1: ySpeed = 1; xSpeed = -1;
			case 2: ySpeed = -1; xSpeed = -1;
			case 3: ySpeed = -1; xSpeed = -1;
			case 4: ySpeed = 1; xSpeed = -1;
		}
		if (dirCount > 3){
			dirCount = 0;
		}
		SoundPlayer.bullet();
	}
	
	var tick:Int = 0;
	
	override public function update(elapsed:Float):Void 
	{
		
		tick++;
		if (Math.floor(tick % PlayState.rate/4) == 0){
			x += xSpeed;
			y += ySpeed;
		}
		if (y+4 >= FlxG.height || y-4 <= 0){
			bounce();
		}
		var ran:FlxRandom = new FlxRandom();
		if(team==2){
			color = ran.color(0xFF8000, 0xFF0000);
		}
		if (team == 1){
			color = FlxColor.BLUE;
		}
		super.update(elapsed);
	}
	
	function bounce(){
		ySpeed = -ySpeed;
		var e:FlxEmitter = new FlxEmitter(x+2, y+2);
		for (i in 0...4){
			var p:FlxParticle = new FlxParticle();
			p.makeGraphic(1, 1, color+0xFF);
			e.add(p);
		}
		PlayState.emitter.add(e);
		e.start(true);
	}
	
	var force:Bool = false;
	
	public function silentKill(){
		force = true;
		kill();
	}
	
	override public function kill():Void 
	{
		PlayState.hbullets.remove(this, true);
		if(!force){
			var e:FlxEmitter = new FlxEmitter(x+2, y+2);
			for (i in 0...10){
				var p:FlxParticle = new FlxParticle();
				p.makeGraphic(1, 1, FlxColor.RED);
				e.add(p);
			}
			PlayState.emitter.add(e);
			e.start(true);
		}
		super.kill();
	}
	
	public function reflect(){
		bounce();
		xSpeed =-xSpeed;
		team = 1;
		PlayState.heartReflect++;
		SoundPlayer.reflect();
	}
}