package;

import flixel.FlxSprite;
import flixel.addons.display.FlxNestedSprite;
import flixel.addons.effects.FlxTrail;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxRandom;

/**
 * ...
 * @author Squidly
 */
class Bullet extends FlxSprite
{
	var dir:String = "";
	var speed:Int = 2;
	var px:Float = 0;
	
	public function new(?X:Float=0, ?Y:Float=0, direction:String, pX:Float=-1) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.bullet__png);
		dir = direction;
		switch(dir){
			case "right":
				angle = 90;
			case "down":
				angle = 180;
			case "left":
				angle = 270;
			case "leftup":
				angle = 270;
			case "leftdown":
				angle = 270;
			case "rightdown":
				angle = 90;
			case "rightup":
				angle = 90;
			case "downright":
				angle = 180;
			case "downleft":
				angle = 180;
		}
		
		SoundPlayer.bullet();
		
	}
	
	var tick:Int = 0;
	
	override public function update(elapsed:Float):Void 
	{
		tick++;
		if (Math.floor(tick % (PlayState.rate/4)) == 0){
			switch(dir){
				case "up":
					y -= speed;
				case "down":
					y += speed;
				case "right":
					x += speed;
				case "left":
					x -= speed;
				case "rightup":
					x += speed;
					y -= speed;
				case "rightdown":
					x += speed;
					y += speed;
				case "leftup":
					x -= speed;
					y -= speed;
				case "leftdown":
					x -= speed;
					y += speed;
				case "downleft":
					x -= speed;
					y += speed/2;
				case "downright":
					x += speed;
					y += speed/2;
			}
		}
		var ran:FlxRandom = new FlxRandom();
		if(PlayState.ebullets.members.indexOf(this)!=-1){
			color = ran.color(0xFF8000, 0xFF0000);
		}else{
			color = ran.color(0xFFFF00, 0x00FF00);
		}
		super.update(elapsed);
	}
	
	public function silentKill(){
		force = true;
		kill();
	}
	
	var force:Bool = false;
	
	override public function kill():Void 
	{
		PlayState.bullets.remove(this, true);
		PlayState.ebullets.remove(this, true);
		if(!force){
			var e:FlxEmitter = new FlxEmitter(x+2, y+2);
			for (i in 0...10){
				var p:FlxParticle = new FlxParticle();
				p.makeGraphic(1, 1, FlxColor.BLUE);
				e.add(p);
				if (MenuState.retro){
					p.color = MenuState.retrocolor;
				}
			}
			PlayState.emitter.add(e);
			e.start(true);
		}
		trace(PlayState.ebullets.length);
		super.kill();
		destroy();
	}
	
}