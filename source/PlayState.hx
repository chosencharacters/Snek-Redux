package;

import flash.desktop.Clipboard;
import flash.errors.Error;
import flixel.FlxBasic;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.addons.effects.FlxTrail;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxObject;
import flixel.util.FlxTimer.FlxTimerManager;

class PlayState extends FlxState
{
	public static var difficulty:Int = 5;
	
	public static var snake:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	public static var noms:FlxTypedGroup <FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var levels:FlxTypedGroup<FlxTilemap> = new FlxTypedGroup<FlxTilemap>();
	public static var emitter:FlxTypedGroup<FlxEmitter> = new FlxTypedGroup<FlxEmitter>();
	public static var expand:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	public static var extra:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	public static var enemies:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	public static var doors:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	public static var bullets:FlxTypedGroup<Bullet> =  new FlxTypedGroup<Bullet>();	
	public static var ebullets:FlxTypedGroup<Bullet> =  new FlxTypedGroup<Bullet>();
	public static var hbullets:FlxTypedGroup<HeartBullet> =  new FlxTypedGroup<HeartBullet>();
	public static var trails:FlxTypedGroup<FlxTrail> = new FlxTypedGroup<FlxTrail>();
	var bgmaze:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	public static var bulletUpgrade:Bool = false;
	
	public static var dead:Bool = false;
	
	public static var deaths:Int = 0;


	var trail:FlxTrail;
	var trailTarget:FlxSprite;
	var snakewidth:Int = 4;
	public static var rate:Int = 5;
	var load:FlxOgmoLoader;
	var bg:FlxSprite;
	var level:Int = 0;
	
	var snakeTimeActive:Bool = false;
	var snakeCharge:Float = 0;
	var snakeMax:Float = 60 * 5 * difficulty;
	var snakeMeter:FlxSprite;
	var gameOverBG:FlxSprite;
	public static var respawn:Bool = true;
	
	public static var bonuslength:Int = 0;
	public static var checkpoint:String = "Normal";
	
	public static var checkPointOn:Bool = true;
	
	//achievement records
	public static var topLength:Int = 0;
	public static var topLengthSession:Int = 0;
	public static var mrMunchHits:Int = 0;
	public static var galagaTime:Int = 0;
	public static var heartReflect:Int = 0;
	public static var totNoms:Int = 0;
	public static var playtimetotal:Int = 0;
	public static var playtime:Int = 0;
	public static var twitch:Bool = true;
	
	public static var makePieceFlag:Bool = false;
	
	var paused:Bool = false;
	
	var strictControl:Bool = false;

	
	
	override public function create():Void
	{
		Online.log("Speed " + difficulty);
		sHold = [];
		MenuState.loadGame();
		rate = difficulty;
		galagaTime=0;
		dead = false;
		endGame = false;
		
		Chalice.has = 0;
		
		
		if (checkPointOn && checkpoint == "Normal"||!checkPointOn){
			playtime = 0;
			twitch = true;
		}
		
		tick = 0;
		
		for(i in 0...3){
			var s = new FlxSprite(Math.round(FlxG.width/2 + i * snakewidth)-64, Math.round(FlxG.height/2));
			s.loadGraphic(AssetPaths.snake__png, true, 4, 4);
			s.animation.add("front", [0]); s.animation.add("middle", [1]); s.animation.add("back", [2]);
			snake.add(s);
		}
		snake.members[0].animation.play("back"); 
		snake.members[1].animation.play("middle");
		snake.members[2].animation.play("front");
		
		//make trail
		trailTarget = new FlxSprite(0, 0);
		trailTarget.makeGraphic(4, 4);
		trailTarget.alpha = 0;
		trail = new FlxTrail(trailTarget, AssetPaths.trail__png, 4, rate, .4);
		
		//background set
		bgmaze = new FlxTypedGroup<FlxSprite>();
		for (c in 0...9){
			var b:FlxSprite = new FlxSprite(c * 16, 0);
			b.loadGraphic(AssetPaths.menubg__png);
			b.color = FlxColor.BLACK;
			b.scrollFactor.set(0.1, 0.1);
			bgmaze.add(b);
		}
		
		bg = new FlxSprite();
		bg.makeGraphic(200, 200);
		bg.alpha = 0;
		
		st = new FlxText(FlxG.width, FlxG.height-10, 0, "sss", 8);
		
		//make gameoverbg
		gameOverBG = new FlxSprite();
		gameOverBG.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		gameOverBG.scrollFactor.set(0, 0);
		gameOverBG.alpha = .75;
		gameOverBG.visible = false;
		goText = new FlxText(0, 0, FlxG.width, "");
		goText.scrollFactor.set(0, 0);
		
		//make snake time meter
		snakeMeter = new FlxSprite();
		snakeMeter.makeGraphic(FlxG.width, 4);
		snakeMeter.scrollFactor.set(0, 0);
		snakeCharge = snakeMax;
		
		//add shit
		if (MenuState.bg == "full" || MenuState.bg == "simple"){
			add(bg);
		}
		if (MenuState.bg == "full"){
			add(bgmaze);
		}
		add(bullets);
		add(ebullets);
		add(snake);
		add(noms);
		if(MenuState.trails){
			add(trailTarget);
			add(trail);
			add(trails);
		}
		add(extra);
		add(enemies);
		add(hbullets);
		add(doors);
		add(levels);
		if(MenuState.particles){
			add(emitter);
		}
		add(expand);
		add(snakeMeter);
		add(gameOverBG);
		add(st);
		add(goText);
		
		px = snake.members[0].x - 64;
		FlxG.camera.minScrollX=px+64;
		load = new FlxOgmoLoader("assets/data/START.oel");
		makePiece();
		makePiece();
		makePiece();
		makePiece();
		
		SoundPlayer.pickMusic();
		
		super.create();
	}
	
	public static var tick:Int = 0;
	var dir:String = "right";

	override public function update(elapsed:Float):Void
	{
		Ctrl.control();
		FlxG.mouse.visible = endGame || dead || paused;
		Achievements.check();
		tick++;
		if (!dead){
			if(!endGame&&!paused){
				snakeTime();
				snakeControl();
				expandSFX();
				if(tick%rate==0){
					efficiency();
				}
				FlxG.worldBounds.set((px - 76 * 4), py, px * 4, 72);
				}else{
					end();
				}
				if (makePieceFlag){
					makePiece();
					makePieceFlag = false;
				}
				pauseCheck();
				playtimetotal++;
				playtime++;
		}else{
			if(!paused){
				expandSFX();
				gameOver();
			}else{
				pauseCheck();
			}
		}
		bgcolor();
		colorChange();
		scrollText();
		super.update(elapsed);
	}
	
	var prevdir:String = "";
	var damaged:Bool = false;
	
	function snakeControl(){
		if ((Ctrl.rightjust || Ctrl.right&&!Ctrl.downjust&&!Ctrl.leftjust&&!Ctrl.upjust)&&prevdir!="left"&&prevdir!="right"){
			dir = "right";
		}
		if ((Ctrl.leftjust || Ctrl.left&&!Ctrl.downjust&&!Ctrl.upjust&&!Ctrl.rightjust)&&prevdir!="right"&&prevdir!="left"){
			dir = "left";
		}
		if ((Ctrl.upjust || Ctrl.up&&!Ctrl.downjust&&!Ctrl.leftjust&&!Ctrl.rightjust)&&prevdir!="down"&&prevdir!="up"){
			dir = "up";
		}
		if ((Ctrl.downjust || Ctrl.down&&!Ctrl.upjust&&!Ctrl.leftjust&&!Ctrl.rightjust)&&prevdir!="up"&&prevdir!="down"){
			dir = "down";
		}
		FlxG.camera.follow(snake.members[snake.length-2], FlxCameraFollowStyle.TOPDOWN);
		FlxG.camera.maxScrollY = 72;
		FlxG.camera.minScrollY = 0;
		if (tick % rate == 0){
			//kill last one
			if (bonuslength < 1){
				snake.members[0].kill();
				snake.remove(snake.members[0], true);
				snake.length--;
			}else{
				bonuslength--;
			}
			trailTarget.x = snake.members[0].x; trailTarget.y = snake.members[0].y;
			//determine new snake position
			var sx:Int = 0;
			var sy:Int = 0;
			switch(dir){
				case "right": sx = snakewidth;
				case "left": sx = -snakewidth;
				case "down": sy = snakewidth;
				case "up": sy = -snakewidth;
			}
			//create new snake
			var s = new FlxSprite(snake.members[snake.length-1].x + sx, snake.members[snake.length-1].y + sy);
			s.loadGraphic(AssetPaths.snake__png, true, 4, 4);
			s.animation.add("front", [0]); s.animation.add("middle", [1]); s.animation.add("back", [2]);
			switch(dir){
				case "right": s.flipX = true;
				case "down": s.angle = 270;
				case "up": s.angle = 90;
			}
			//change other snake bits
			for (s in 0...snake.length){
				if (s > 0){
					snake.members[s].animation.play("middle");
				}
				if (s == 0){
					snake.members[s].animation.play("back");
				}
			}
			snake.add(s);
			//eat noms
			collect();
			//fire
			if (tick % (rate * 3) == 0&&bulletUpgrade&&!damaged){
				bullets.add(new Bullet(snake.members[snake.members.length-1].x, snake.members[snake.members.length-1].y, dir));
			}
			//collide check
			for (s in 0...snake.length-1){
				if (FlxG.overlap(snake.members[snake.members.length-1], snake.members[s])){
					damage();
				}
			}
			for (e in enemies){
				FlxG.overlap(snake, e, enemyCheck);
			}
			for (d in doors){
				if (FlxG.overlap(snake.members[snake.members.length-1], d)){
					damage();
				}
			}
			var c:Int = 0;
			for (ll in levels){
				c++;
				var l:FlxTilemap = cast(ll, FlxTilemap);
				if (l.x > snake.members[snake.members.length-1].x - l.width && l.x <= snake.members[snake.members.length-1].x){
					var tx:Int = Math.floor((snake.members[snake.members.length-1].x - l.x) / 4);
					var ty:Int = Math.floor((snake.members[snake.members.length-1].y - l.y) / 4);
					if (l.getTile(tx,ty)==1){
						damage();
						break;
					}
				}
			}
			//misc
			levelBoundsCheck();
			bg.x = camera.scroll.x;
			bg.y = camera.scroll.y;
			prevdir = dir;
			damaged = false;
			}
			for (eb in ebullets){
				if (FlxG.overlap(snake, eb)){ 
					damage();
					eb.kill();
					break;
				}
			}
			for (hb in hbullets){
				FlxG.overlap(snake, hb, reflectHeart);
			}
			if (snake.length - 3 > topLengthSession){
				topLengthSession = snake.length - 3;
			}
			if (topLengthSession > topLength){
				topLength = topLengthSession;
			}
	}
	
	function makeNom(l:FlxTilemap){
		var curx:Float = levels.members[levels.length - 1].x;
		var curwidth:Float = levels.members[levels.length - 1].width;
		var n:FlxSprite = new FlxSprite(Math.floor(Math.random()*curwidth/4)*4+curx, Math.floor(Math.random()*Math.round(FlxG.height/4))*4);
		for (s in snake){
			if (FlxG.overlap(s, n)){
				makeNom(l);
				n.destroy();
				return;
			}
		}
		var tx:Int = Math.round((n.x - l.x) / 4);
		var ty:Int = Math.round((n.y - l.y) / 4);
		if (l.getTile(tx, ty) == 1){
			makeNom(l);
			n.destroy();
			return;
		}
		for (no in noms){
			if (FlxG.pixelPerfectOverlap(no, n)){
				makeNom(l);
				n.destroy();
				return;
			}
		}
		n.loadGraphic(AssetPaths.nom__png);
		noms.add(n);
	}
	
	var bgstate:Int = 1;
	var bgdown:Bool = true;
	
	function colorChange(){
		if(tick%rate*4==0){
			var ran:FlxRandom = new FlxRandom();
			var rancolor:Int = ran.color(0x717EFF, 0x00149D);
			switch(MenuState.snekColor){
				case "red": rancolor = ran.color(0xDF0000, 0xFF0000);
				case "green": rancolor = ran.color(0x008000, 0x00FF00);
				case "white": rancolor = ran.color(0xC0C0C0, 0xFFFFFF);
				case "gold": rancolor = ran.color(0xFCD703, 0xFFFF00);
				case "rainbow": rancolor = ran.color(0x000000, 0xFFFFFF);
			}
			trail.color = rancolor;
			for (s in snake){
				colorCheck(s, rancolor);
			}
			rancolor=ran.color(0xFFFFFF, 0xF960ED);
			for (ex in extra){
				colorCheck(ex, rancolor);
			}
			rancolor=ran.color(0xFF0000, 0xFF8000);
			for (n in noms){
				colorCheck(n, rancolor);
			}
			rancolor = ran.color(0x80FF00, 0x00FF00);
			if (prev.indexOf("CAVE") != -1&&MrMunch.killed||Galaga.living){
				rancolor = ran.color(0x9F0078, 0xD900A3);
			}
			if (prev.indexOf("GEAR") != -1&&Galaga.killed||Heart.living){
				rancolor = ran.color(0x7A7A7A, 0x696969);
			}
			for (l in levels){
				colorCheckTile(l, rancolor);
			}
			
			rancolor=ran.color(0xFFFF00, 0xFFB300);
			for (d in doors){
				colorCheck(d, rancolor);
			}
			rancolor=ran.color(0xFFFFFF, 0xFF0000);
			for (e in enemies){
				colorCheck(e, rancolor);
			}
			if (MenuState.retro){
				trail.color = FlxColor.BLACK;
			}
		}
	}
	
	function colorCheck(v:FlxSprite, rancolor:Int){
		if (v != null){
			v.color = rancolor;
			if (MenuState.retro){
				v.color = FlxColor.BLACK;
			}
		}
	}
	
	function colorCheckTile(v:FlxTilemap, rancolor:Int){
		if (v != null){
			v.color = rancolor;
			if (MenuState.retro){
				v.color = FlxColor.BLACK;
			}
		}
	}
	
	var killOnce:Bool = false;
	var goText:FlxText;
	
	function gameOver(){
		if (!killOnce){
			if (checkPointOn && checkpoint != "Normal"){
				respawn = true;
			}
			killOnce = true;
			for (s in snake){
				var e:FlxEmitter = new FlxEmitter(s.x+2, s.y+2);
				for (i in 0...15){
					var p:FlxParticle = new FlxParticle();
					p.makeGraphic(1, 1, FlxColor.WHITE);
					p.allowCollisions = FlxObject.ANY;
					e.add(p);
					if (MenuState.retro){
						p.makeGraphic(1, 1, FlxColor.BLACK);
					}
				}
				emitter.add(e);
				e.allowCollisions = FlxObject.ANY;
				e.start(true);
				s.kill();
			}
			remove(trail);
			remove(st);
			FlxG.camera.zoom = 1;
			gameOverBG.visible = true;
			SoundPlayer.gameover();
			bullets = new FlxTypedGroup<Bullet>();
			ebullets = new FlxTypedGroup<Bullet>();
			deaths++;
			var go:String = "GAME OVER :(\n";
			var adds:String = "";
			switch(Math.floor(Math.random() * 100)+1){
				case 1: adds = "Consider fine tuning your difficulty";
				case 2: adds = "Use SPACE/SHIFT to use Snek Time";
				case 3: adds = "Noms recharge your Snek Meter faster";
				case 4: adds = "Get all 3 Chalices for a surprise!";
				case 5: adds = "You don't have to get every nom";
				case 6: adds = "Risk management is an important skill";
				case 7: adds = "Are you enjoying your snek?";
				case 8: adds = "You can set speed in the main menu";
				case 9: adds = "You can enable/disable checkpoints";
				case 10: adds = "Use Snake Time for tricky turns";
				case 11: adds = "Noms are a good source of Vitamin S";
				case 12: adds = "Crashing into yourself is a bad idea";
				case 13: adds = "Try avoiding the walls!";
				case 14: adds = "Chalices are bonuses, not necessities";
				case 15: adds = "Maze - Cave - Gear";
				case 16: adds = "Are you snek enough?";
				case 17: adds = "You can disable bgs, but that's no fun";
				case 18: adds = "This game is highly costumizable!";
				case 19: adds = "Sometimes you just need a break";
				case 20: adds = "Stuck? Check out the wiki!";
				case 21: adds = "This isn't really like snake";
				case 22: adds = "Rumor has it that this game has secrets";
				case 23: adds = "Can you speedrun this?";
				case 24: adds = "Save your Snek Time for the tough parts";
				case 25: adds = "You can use Snek Time in Chalice mazes";
				case 26: adds = "Chalices give you length";
				case 27: adds = "Your length is your health!";
				case 28: adds = "Don't get trapped in dead ends!";
				case 29: adds = "You can mute music in options";
				case 30: adds = "Mr. Munch is very grumpy";
				case 31: adds = "Ram into the Heart's Discs to reflect them!";
				case 32: adds = "How do you do?";
				case 33: adds = "#2snek4me";
				case 34: adds = "You can always try again";
				case 35: adds = "There is no limit on checkpoint restarts";
				case 36: adds = "Save time by skipping out of the way noms";
				case 37: adds = "Length is a blessing and a curse :/";
				case 38: adds = "The missile upgrade lets you shoot!";
				case 39: adds = "Grab Mr. Munch's axe to defeat him!";
				case 40: adds = "Go for the axe when Mr. Munch is farthest away";
				case 41: adds = "I don't think this is how snake's actually work";
				case 42: adds = "Mini LD 64 is a good time";
				case 43: adds = "You can always go back to the options menu";
				case 44: adds = "You can pause whenever with P";
				case 45: adds = "Have you ever seen a real snek?";
				case 46: adds = "Sneks make for good spirit animals";
				case 47: adds = "Noms are sneks' favorite food";
				case 48: adds = "u ded";
				case 49: adds = "What does a snek do with chalices anyways?";
				case 50: adds = "Snek is the one true spelling";
				case 51: adds = "Pray to RNGesus";
				case 52: adds = "Kinda intense, isn't it?";
				case 53: adds = "You'll get it eventually";
				case 54: adds = "This is slightly harder than other snek-based games";
				case 55: adds = ":( :( :(";
				case 56: adds = "Everything happens for a reason";
				case 57: adds = "How do you do this again?";
				case 58: adds = "Levels keep getting harder, use checkpoints";
				case 59: adds = "Try running through the game slowly the first time";
				case 60: adds = "Go hard or go home";
				case 61: adds = "Checkpoints follow every boss battle";
				case 62: adds = "Save your Snek Time for the hard parts";
				case 63: adds = "Snek? Snek?!? Sneeeeeeeek!";
				case 64: adds = "The Heart is watching";
				case 65: adds = "Heart Discs can be reflected";
				case 66: adds = "<Laughs in Snek>";
				case 67: adds = "Turn up the music, yo";
				case 68: adds = "You can do it!";
				case 69: adds = "This is very upsetting";
				case 70: adds = "So close :/";
				case 71: adds = "Keep at it!";
				case 72: adds = "There is no impossible!";
				case 73: adds = "Whelp.";
				case 74: adds = "Don't turn your back on Snek";
				case 75: adds = "Kinda addicting, huh?";
				case 76: adds = "If at first you don't succeed...";
				case 77: adds = "Have you seen any secrets lying around?";
				case 78: adds = "Never surrender!";
				case 79: adds = "Slither quietly and carry a big snek";
				case 80: adds = "Is it snek or Snek???";
				case 81: adds = "ERROR: MISSING SNEK";
				case 82: adds = "Ever wonder what Noms taste like?";
				case 83: adds = "Hungry? Try a Nom";
				case 84: adds = "You're different when you're hungry";
				case 85: adds = "Small sneks don't go far :(";
				case 86: adds = "Oh snap!";
				case 87: adds = "Don't snek and drive";
				case 88: adds = "Walls and sneks don't get along";
				case 89: adds = "You got out-mazed :/";
				case 90: adds = "The endless labryith :O";
				case 91: adds = "Check out the wiki for help!";
				case 92: adds = "Don't you die on me, snek";
				case 93: adds = "RIP m8";
				case 94: adds = "Improve your reflexes";
				case 95: adds = "snek'd";
				case 96: adds = "thou art dead";
				case 97: adds = "x_x";
				case 98: adds = "http://tinyurl.com/snekwiki";
				case 99: adds = "How many chalices did you get?";
				case 100: adds = "Snek and let snek";
			}
			go = go + "\n" + adds + "\n\nSPACE/SHIFT to Reset\nP for Menu";
			
			goText.text = go;
			goText.scrollFactor.set(0, 0);
			MenuState.saveGame();
		}
		if (Ctrl.st||Ctrl.pause){
			resetThings();
			if (Ctrl.st){
				FlxG.resetState();
			}
			if (Ctrl.pause){
				FlxG.switchState(new MenuState());
			}
		}
	}
	
	function damage(back:Bool=false){
		if (snake.length > 3){
			damaged = true;
			if(!back){
				snake.members[snake.length - 2].angle = snake.members[snake.length - 1].angle;
				snake.members[snake.length - 2].flipX = snake.members[snake.length - 1].flipX;
				snake.members[snake.length - 1].kill();
				snake.members[snake.length - 2].animation.play("front");
				snake.remove(snake.members[snake.length - 1],true);
				FlxG.camera.stopFX();
				//FlxG.camera.flash(FlxColor.WHITE, 0.2);
				snake.length--;
				var e:FlxEmitter = new FlxEmitter(snake.members[snake.length - 1].x, snake.members[snake.length - 1].y);
				if (dir == "up"){
					e.x += 2;
					e.y += 2;
				}
				if (dir == "right"){
					e.x -= 2;
				}
				for (i in 0...5){
					var p:FlxParticle = new FlxParticle();
					p.makeGraphic(1, 1, FlxColor.WHITE);
					p.allowCollisions = FlxObject.ANY;
					e.add(p);
					if (MenuState.retro){
						p.makeGraphic(1, 1, FlxColor.BLACK);
					}
				}
				emitter.add(e);
				e.allowCollisions = FlxObject.ANY;
				e.start(true);
			}else{
				snake.members[1].angle = snake.members[0].angle;
				snake.members[1].flipX = snake.members[0].flipX;
				snake.members[0].kill();
				snake.members[1].animation.play("back");
				snake.remove(snake.members[1],true);
				FlxG.camera.stopFX();
				//FlxG.camera.flash(FlxColor.WHITE, 0.2);
				snake.length--;
				var e:FlxEmitter = new FlxEmitter(snake.members[1].x+2, snake.members[1].y+2);
				for (i in 0...5){
					var p:FlxParticle = new FlxParticle();
					p.allowCollisions = FlxObject.ANY;
					p.makeGraphic(1, 1, FlxColor.WHITE);
					e.add(p);
					if (MenuState.retro){
						p.makeGraphic(1, 1, FlxColor.BLACK);
					}
				}
				emitter.add(e);
				e.allowCollisions = FlxObject.ANY;
				e.start(true);
			}
			SoundPlayer.hit();
		}else{
			dead = true;
		}
	}
	
	var prev:String = "UU1";
	var lint:String = "0"; //last integer
	
	var px:Float = 0;
	var py:Float = 0;
	var startpiece:Bool = true;
	var finishpiece:Bool = false;
	
	function makePiece(){
		var p:String = prev.charAt(1);
		px += 64;
		var next:String = p + "D";
		if (Math.random() < 0.5){
			next = p + "U";
		}
		if (MrMunch.onboard && !Galaga.onboard){
			next = next + "CAVE";
		}
		if (Galaga.onboard){
			next = next + "GEAR";
		}
		var nint:String = Std.string(Math.floor(Math.random() * 5) + 1);
		while (next+nint == prev){
			nint=Std.string(Math.floor(Math.random() * 5) + 1);
		}
		next = next + nint;
		prev = next;
		if (startpiece){
			next = "START";
			prev = "UU1";
			startpiece = false;
			if (checkpoint=="Cave" && checkPointOn){
				MrMunch.onboard = true;
				MrMunch.killed = true;
				Chalice.spawns = 1;
			}
			if (checkpoint=="Gear" && checkPointOn){
				MrMunch.onboard = true;
				Galaga.onboard = true;
				Galaga.killed = true;
				MrMunch.killed = true;
				Chalice.spawns = 2;
			}
		}		
		if (Heart.onboard&&prev!="GAMEEND"){
			next = "GAMEEND";
			prev = "GAMEEND";
		}
		if (Trophy.onboard){
			next = "TRUEBOSS";
			prev = "TRUEBOSS";
		}
		//generate chalices
		if(next.indexOf("CAVE") == -1 && next.indexOf("GEAR") == -1){
			if (next.charAt(0) == "D" && Chalice.spawns == 0 && level > 5){
				next = "DUSPECIAL";
				prev = next;
			}
			if (next.charAt(0) == "U" &&  Chalice.spawns == 1 && !MrMunch.onboard && level>10){
				next = "UDBOSS1";
				prev = next;
				level = 0;
			}
		}
		if(next.indexOf("CAVE")!=-1){
			if (next.charAt(0) == "U" &&  Chalice.spawns == 1 && level>3){
				next = "UUCAVESPECIAL";
				prev = next;
			}
			if (next.charAt(0) == "D" &&  Chalice.spawns == 2 && level>7){
				next = "DDCAVEBOSS1";
				prev = next;
				level = 0;
			}
		}
		if(next.indexOf("GEAR")!=-1){
			if (next.charAt(0) == "D" && Chalice.spawns == 2 && level>3){
				next = "DUGEARSPECIAL";
				prev = next;
			}
			if (next.charAt(0) == "U" && Chalice.spawns == 3 && level>7){
				next = "UDGEARBOSS1";
				prev = next;
				level = 0;
			}
		}
		if (next.indexOf("BOSS")!=-1){
			bx = px;
		}
		load = new FlxOgmoLoader("assets/data/" + next + ".oel");
		var lvl:FlxTilemap = load.loadTilemap(AssetPaths.tiles__png, 4, 4, "tiles");
		lvl.x = px;
		load.loadEntities(placeEntities, "entities");
		levels.add(lvl);
		if (next == "START"){
			px += 64;
		}
		for (s in 0...3+Math.floor(Math.random()*3)){
			if (!Heart.killed){
				makeNom(lvl);
			}
		}
		trace(next);
		level++;
	}
	
	var lx:Float = 0;
	
	function levelBoundsCheck(){
		FlxG.camera.minScrollX = FlxG.camera.scroll.x;
		var c:Int = 0;
		for (ll in levels){
			c++;
			var l:FlxTilemap = cast(ll, FlxTilemap);
			if (l.x > snake.members[snake.members.length - 1].x - l.width && l.x < snake.members[snake.members.length - 1].x){
				lx = l.x;
				if (FlxG.camera.minScrollX < l.x-FlxG.camera.width){
					FlxG.camera.minScrollX = l.x;
				}
				if (l.width > 64 && (MrMunch.onboard&&!MrMunch.killed||Galaga.onboard&&!Galaga.killed||Heart.onboard&&!Heart.killed||Demon.spawned)){
					FlxG.camera.maxScrollX = l.x + l.width;
					if (Galaga.onboard && !Galaga.killed && checkpoint=="Cave"){
						galagaTime++;
					}
				}else{
					FlxG.camera.maxScrollX = null;
				}
				if (c == 4){
					for (n in noms){
						if (n.x < levels.members[0].x + levels.members[0].width){
							n.kill();
							noms.remove(n, true);
						}
					}
					levels.members[0].kill();
					levels.remove(levels.members[0],true);
					makePiece();
				}
			}
			if (FlxG.camera.minScrollX > snake.members[snake.members.length - 1].x && dir=="left"){
				damage();
			}
			for (b in bullets){
				if (b.x < FlxG.camera.minScrollX|| b.x > px + l.width||b.y>FlxG.height||b.y<0){
					b.silentKill();
				}
			}
			for (b in ebullets){
				if (b.x < FlxG.camera.minScrollX|| b.x > px + l.width||b.y>FlxG.height||b.y<0){
					b.silentKill();
				}
			}
			for (b in hbullets){
				if (b.x < bx+4|| b.x > px + l.width||b.y>FlxG.height||b.y<0){
					b.silentKill();
				}
			}
		}
	}
	
	function expandSFX(){
		for (e in expand){
			e.scale.set(e.scale.x * 1.05, e.scale.y * 1.05);
			e.alpha -= 0.05;
			if (e.scale.x>60){
				e.kill();
				expand.remove(e, true);
				expand.length--;
			}
		}
	}
	
	var bx:Float = 0;
	
	function placeEntities(entityName:String, entityData:Xml){
		var xx:Int = Std.parseInt(entityData.get("x"));
		var yy:Int = Std.parseInt(entityData.get("y"));
		switch(entityName){
			case "key":
				var key:Key = new Key(xx + px, yy + py, px, py);
			case "chalice":
				var key:Chalice = new Chalice(xx + px, yy + py);
			case "boss":
				switch(entityData.get("name")){
					case "boss1":
						var m:MrMunch = new MrMunch(xx + px, yy + py, px, py);
						px += 64;
					case "galaga":
						var m:Galaga = new Galaga(xx + px, yy + py, px, py);
						px += 64;
					case "heart":
						var m:Heart = new Heart(xx + px, yy + py);
						px += 64;
					case "demon":
						if (!Demon.onboard && Chalice.has==3){
							var m:Demon = new Demon(xx + px-12, yy + py, px, py);
						}
						px += 64;
				}
			case "trophy":
				var key:Trophy = new Trophy(xx + px, yy + py, px, py);
				px += 64;
		}
	}
	
	function collect(){
		for (n in noms){
			if (FlxG.overlap(snake.members[snake.length - 1], n)||n.x==snake.members[snake.length - 1].x&&n.y==snake.members[snake.length - 1].y){
				bonuslength++;
				n.kill();
				var ntxt:FlxText = new FlxText(n.x, n.y);
				if (MenuState.retro){
					ntxt.color = 0x509F00;
				}
				ntxt.text = Std.string(snake.length - 2);
				expand.add(ntxt);
				var newn:FlxSprite = new FlxSprite(n.x, n.y);
				newn.scale.set(.5, .5);
				newn.loadGraphic(AssetPaths.nom__png);
				expand.add(newn);
				SoundPlayer.nom();
				snakeCharge+= 60 * difficulty;
				totNoms++;
			}
		}
		noms.forEachDead(deleteThis);
	}
	
	function deleteThis(s:FlxSprite){
		noms.remove(s, true);
	}
	
	public static function makeWord(xx:Float,yy:Float,s:String){
		var ntxt:FlxText = new FlxText(xx, yy);
		if (MenuState.retro){
			ntxt.color = 0x509F00;
		}
		ntxt.text = s;
		expand.add(ntxt);
	}
	
	function bgcolor(){
		if (bgdown){
			bg.alpha -= 0.025;
			if (bg.alpha <= 0){
				bgdown = false;
				bgstate++;
				switch(bgstate){
					case 1:bg.color = 0xFF2B2055; //0xFF513DA3
					case 2:bg.color = 0xFF5E0D2F; //FF7B113F
				}
				if (bgstate > 1){
					bgstate = 0;
				}
			}
		}else{
			bg.alpha += 0.025;
			if (bg.alpha >= .4){
				bgdown = true;
			}
		}
		if(tick%rate==1){
			for (b in bgmaze){
				if (b.getScreenPosition().x <= -16){
					b.x += FlxG.width + 16;
				}
				if (MenuState.retro){
					b.color = 0x98C043;
				}
			}
		}
		if (MenuState.retro){
			bg.alpha = 0;
			bgColor = 0xFF9CC24A;
			trace("retro");
		}else{
			bgColor = 0x000000;
		}
	}
	
	static var st:FlxText;
	static var stext:String = "";
	static var sHold:Array<String> = [];
	
	public static function setText(s:String){
		if (stext != ""){
			if (s.indexOf("Achievement") ==-1){
				if (st.text.indexOf("Achievement") ==-1){
					stext = s;
				}else{
					var found:Bool = false;
					for (n in 0...sHold.length){
						if (sHold[n].indexOf("Achievement") == -1){
							sHold[n] = s;
							found = true;
						}
					}
					if (!found){
						sHold[sHold.length] = s;
					}
				}
			}else{
				sHold[sHold.length] = s;
			}
		}else{
			stext = s;
			if (stext.indexOf("Achievement") !=-1){
				SoundPlayer.achievement();
			}
		}
	}
	
	function scrollText(){
		if (stext != "" && st.text == ""){
			st.x = FlxG.width; 
			st.text = stext;
			st.scrollFactor.set(0, 0);
			st.alignment = "RIGHT";
			st.visible = true;
		}
		if (st.text != ""){
			st.x--;
			st.text = stext;
			if (st.x < -st.width*2){
				st.text = "";
				stext = "";
				st.visible = false;
				if (sHold.length > 0){
					setText(sHold[0]);
					sHold.remove(sHold[0]);
				}
			}
		}
		if (MenuState.retro){
			st.color = 0x509F00;
		}
	}
	
	function enemyCheck(v:FlxSprite, e:FlxSprite){
		if (FlxG.pixelPerfectOverlap(v, e)){
			damage(true);
			if (MrMunch.onboard && !MrMunch.killed){
				mrMunchHits++;
			}
		}
	}
	
	static var zSpeed:Float = 0.01;
	
	function snakeTime(){
		//snake time
		if (Ctrl.stjust&&snakeCharge>60||snakeTimeActive&&Ctrl.st&&snakeCharge>0){
			snakeTimeActive = true;
			if(FlxG.camera.zoom<1.1){
				FlxG.camera.zoom += zSpeed;
			}
			snakeCharge-=difficulty;
			rate = difficulty*2;
			SoundPlayer.snakeTime(true);
			twitch = false;
		}else{
			if (FlxG.camera.zoom > 1){
				FlxG.camera.zoom -= zSpeed;
			}
			snakeTimeActive = false;
			rate = difficulty;
			snakeCharge+= difficulty/4;
			SoundPlayer.snakeTime(false);
		}
		var fill:Int = Math.round((snakeCharge / snakeMax)*FlxG.width);
		snakeMeter.setGraphicSize(fill, 2);
		snakeMeter.y = -2;
		snakeMeter.visible = snakeCharge > 0;
		if (snakeTimeActive){
			snakeMeter.setGraphicSize(fill, 4);
			snakeMeter.y = 0;
		}
		if (snakeCharge > snakeMax){
			snakeCharge = snakeMax;
		}
	}
	
	function reflectHeart(s:FlxSprite, b:HeartBullet){
		if(b.team==2){
			if(s!=snake.members[snake.members.length-1]&&s!=snake.members[snake.members.length-2]){
				damage();
				b.kill();
			}else{
				b.reflect();
			}
		}
	}
	
	var lastX:Float = -1;
	
	function efficiency(){
		if (FlxG.camera.scroll.x == lastX){
			return;
		}else{
			lastX=FlxG.camera.scroll.x;
		}
		for (n in noms){
			n.active = false;
			n.visible = !(n.x > FlxG.camera.scroll.x + FlxG.camera.width) && !(n.x<FlxG.camera.scroll.x);
		}
		for (n in levels){
			n.active = false;
			n.visible = n.x < FlxG.camera.scroll.x + FlxG.camera.width && n.x + n.width > FlxG.camera.scroll.x;
		}
		for (n in doors){
			n.active = false;
			n.visible = n.x < FlxG.camera.scroll.x + FlxG.camera.width && n.x + n.width > FlxG.camera.scroll.x;
		}
		for (s in snake){
			s.active = false;
		}
		bg.active = false;
		bgmaze.active = false;
	}
	
	static function achievement(s:String){
		setText(s);
	}
	
	static var endGame:Bool = false;
	var endTimer:Int = 0;
	
	public static function victory(){
		endGame = true;
	}
	
	function end(){
		if (!endGame){
			endTimer = 0;
			return;
		}
		if (endTimer < 60){
			FlxG.camera.minScrollX = lx;
			FlxG.camera.scroll.x = lx;
			if(FlxG.camera.zoom<1.25){
				FlxG.camera.zoom += zSpeed*2;
			}
		}else{
			if (FlxG.keys.anyJustPressed(["SPACE", "SHIFT"])){
				MenuState.saveGame();
				resetThings();
				FlxG.switchState(new MenuState());
			}
		}
		rate = difficulty * 2;
		endTimer++;
		goText.visible = true;
		if (endTimer == 60){
			goText.scrollFactor.set(0, 0);
			FlxG.camera.zoom = 1;
			gameOverBG.visible = true;
			var goadd:String = "";
			switch(Math.floor(Math.random() * 7)+1){
				case 1: goadd = "You did it!";
				case 2: goadd = "A winner is you!";
				case 3: goadd = "Top snek!";
				case 4: goadd = "Boom!";
				case 5: goadd = "Awesome!";
				case 6: goadd = "That's a wrap!";
				case 7: goadd = "Victory!";
			}
			var gotext:String = "";
			gotext = gotext + goadd+"\n";
			gotext = gotext + "\nFinal Time: " + Math.floor((playtime / (60 * 60)) % 60) + "m " + Math.floor((playtime / 60)%60) + "s";
			gotext = gotext + "\nFinal Length: " + (snake.length-3);
			gotext= gotext + "\nTop Length: " + topLengthSession;
			gotext = gotext + "\n\nSPACE/SHIFT to continue";
			goText.text = gotext;
		}
	}
	
	function resetThings(){
		snake = new FlxTypedGroup<FlxSprite>();
		noms = new FlxTypedGroup<FlxSprite>();
		levels = new FlxTypedGroup<FlxTilemap>();
		expand = new FlxTypedGroup<FlxSprite>();
		extra = new FlxTypedGroup<FlxSprite>();
		enemies = new FlxTypedGroup<FlxSprite>();
		doors = new FlxTypedGroup<FlxSprite>();
		bullets = new FlxTypedGroup<Bullet>();
		ebullets = new FlxTypedGroup<Bullet>();
		hbullets = new FlxTypedGroup<HeartBullet>();
		trails = new FlxTypedGroup<FlxTrail>();
		emitter = new FlxTypedGroup<FlxEmitter>();
		bonuslength = 0;
		bulletUpgrade = false;
		Chalice.resetThis();
		MrMunch.resetThis();
		Heart.resetThis();
		Galaga.resetThis();
		Demon.resetThis();
		Trophy.resetThis();
		MenuState.saveGame();
	}
	
	function pauseCheck(){
		if (endGame){
			return;
		}
		if (FlxG.keys.anyJustPressed(["P"])){
			paused = !paused;
			gameOverBG.visible = paused;
			goText.text = "Snek is Paused :/\n\n\n\n\nPress P to unpause\nSPACE/SHIFT for Menu";
			if (!paused){
				goText.text = "";
			}
		}
		if (paused){
			if (FlxG.keys.anyJustPressed(["SPACE", "SHIFT"])){
				resetThings();
				FlxG.switchState(new MenuState());
			}
		}
	}
}
