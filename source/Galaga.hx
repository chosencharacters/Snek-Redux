package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxExtendedSprite;
import flixel.addons.effects.FlxTrail;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * ...
 * @author Squidly
 */
class Galaga extends FlxSprite
{
	var speed:Int = 2;
	var door:FlxSprite;
	var bullet:FlxSprite;
	var pX:Float = 0;
	public static var onboard:Bool = false;
	public static var killed:Bool = false;
	public static var living:Bool = false;

	public function new(?X:Float = 0, ?Y:Float = 0, px:Float = 0, py:Float = 0 ) 
	{
		super(X, Y);
		trace("I'm here");
		health = 7;
		loadGraphic(AssetPaths.Galaga__png);
		animation.add("walk", [0], 4);
		animation.play("walk");
		PlayState.enemies.add(this);
		
		door = new FlxSprite(px+128-4, py);
		door.makeGraphic(8, 76);
		PlayState.doors.add(door);
		
		bullet = new FlxSprite(px+60, py+60);
		bullet.loadGraphic(AssetPaths.BulletUpgrade__png);
		PlayState.extra.add(bullet);
		
		onboard = true;
		pX = px;
		
		trail = new FlxTrail(this, AssetPaths.Galaga__png, 4, Math.floor(PlayState.rate/2), .3);
		PlayState.trails.add(trail);
		
		living = true;
		
		color = FlxColor.WHITE;
	}
	
	var right:Bool = true;
	var tick:Int = 0;
	var trail:FlxTrail;
	var detected:Bool = false;
	override public function update(elapsed:Float):Void 
	{
		if (PlayState.dead){
			return;
		}
		if (getDistance(PlayState.snake.members[0].getMidpoint(), getMidpoint()) < 144){
			detected = true;
		}
		if (!detected){
			return;
		}
		tick++;
		if (Math.floor(tick % (PlayState.rate / 2)) == 0){
			trail.color = color;
			if (right){
				x += speed;
			}else{
				x -= speed;
			}
			if (x<=pX+4){
				right = true;
			}
			if (x+width>=pX+72*2-18){
				right = false;
			}
			for (b in PlayState.bullets){
				if (FlxG.overlap(b, this)){
					health--;
					b.kill();
					var e:FlxEmitter = new FlxEmitter(x+2, y+2);
					for (i in 0...5){
						var p:FlxParticle = new FlxParticle();
						p.makeGraphic(1, 1, 0xFF+color);
						e.add(p);
						if (MenuState.retro){
							p.makeGraphic(2, 2, FlxColor.BLACK);
						}
					}
					PlayState.emitter.add(e);
					e.allowCollisions = FlxObject.ANY;
					e.start(true);
					if (health <= 0){
						kill();
						PlayState.checkpoint = "Gear";
						return;
					}
				}
			}
			if (tick % (PlayState.rate * 3) == 0&&health>5||tick % (PlayState.rate * 2) == 0&&health<=5){
				PlayState.ebullets.add(new Bullet(x+4, y+4, "down"));
			}
		}
		if (FlxG.overlap(bullet, PlayState.snake.members[PlayState.snake.length - 1])){
			PlayState.makeWord(bullet.x-bullet.width/2, bullet.y-bullet.height/2, "missiles");
			SoundPlayer.missile();
			bullet.kill();
			PlayState.extra.remove(bullet, true);
			PlayState.bulletUpgrade = true;
			return;
		}
		super.update(elapsed);
	}
	
	override function kill(){
		PlayState.enemies.remove(this);
		PlayState.doors.remove(door, true);
		PlayState.extra.remove(bullet, true);
		var e:FlxEmitter = new FlxEmitter(x+2, y+2);
		for (i in 0...20){
			var p:FlxParticle = new FlxParticle();
			p.makeGraphic(1, 1, 0xFF+color);
			e.add(p);
			if (MenuState.retro){
				p.color = MenuState.retrocolor;
			}
		}
		PlayState.emitter.add(e);
		e.start(true);
		trail.kill();
		PlayState.makeWord(x + width / 2, y + height / 2, "gg");
		killed = true;
		PlayState.bulletUpgrade = false;
		SoundPlayer.axe();
		super.kill();
	}
	
	public static function resetThis(){
		killed = false;
		onboard = false;
		living = false;
	}
	
	function getDistance(P1:FlxPoint, P2:FlxPoint):Float
	{
		var XX:Float = P2.x - P1.x;
		var YY:Float = P2.y - P1.y;
		return Math.sqrt( XX * XX + YY * YY );
	}
	
}