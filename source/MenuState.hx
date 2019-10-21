package;

import flash.display3D.Context3DStencilAction;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxExtendedSprite;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxTrailEffect;
import flixel.addons.text.FlxTextField;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;
import flixel.util.FlxSave;
import openfl.display.Stage;
import openfl.text.TextFormat;
import flash.display.StageQuality;
import openfl.Lib;
import openfl.net.URLRequest;
import openfl.display.StageDisplayState;

class MenuState extends FlxState
{
	var logo:FlxSprite;
	var menu:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var menuBGLines:FlxTypedGroup<FlxSprite>;
	var menuBG:FlxSprite;
	var pos:Int = 0;
	var tick:Int = 0;
	var state:String = "";
	var logot:FlxTrail;
	var logof:FlxSprite;
	var dmeter:FlxSprite;
	var ach:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var stats:FlxText;
	var fullscreen:FlxButton;

	//options
	public static var trails:Bool = true;
	public static var bg:String = "full";
	public static var particles:Bool = true;
	public static var retro:Bool = false;
	public static var retrocolor:Int = FlxColor.BLACK;
	
	//achievement stuff
	public static var returning:Bool = false;
	
	var fb:FlxSprite;
	var twitter:FlxSprite;
	var tumblr:FlxSprite;
	public static var socClicked:Bool = false;
	
	override public function create():Void
	{
		//FlxG.stage.quality = StageQuality.LOW;
		retro = false;
		PlayState.bonuslength = 0;
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeDownKeys = null;
		FlxG.sound.volumeUpKeys = null;
		//FlxG.log.redirectTraces = true;
		FlxG.mouse.load(AssetPaths.cursor__png, 4, 0, 0);
		Online.check();
		sHold = [];
		PlayState.checkpoint = "Normal";
		loadGame();
		menuBGLines = new FlxTypedGroup<FlxSprite>();
		for (r in 0...8){
			var b:FlxSprite = new FlxSprite(r*16, 0);
			b.loadGraphic(AssetPaths.menubg__png);
			b.color = FlxColor.BLACK;
			menuBGLines.add(b);
		}
		menuBG = new FlxSprite(0, 0);
		menuBG.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		
		logo = new FlxSprite(27, 1);
		logo.loadGraphic(AssetPaths.Logo__png);
		
		logof = new FlxSprite(27, 1);
		logof.loadGraphic(AssetPaths.Logo__png);
		logof.visible = false;
		
		logot = new FlxTrail(logof, AssetPaths.Logo__png, 5, 5, 0.3, 0.1);
		
		st = new FlxText(FlxG.width, FlxG.height-10, 0, "", 8);
		
		//achievement stuff
		
		for (r in 0...3){
			for (c in 0...10){
				var a:FlxSprite = new FlxSprite(c * 12 + 6, r * 10 + 36);
				a.loadGraphic(AssetPaths.achievementmini__png, true, 8, 8);
				a.animation.add("lock", [0]);
				a.animation.add("unlock", [1]);
				a.animation.play("lock");
				a.color = FlxColor.GRAY;
				ach.add(a);
			}
		}
		aBig = new FlxSprite(56, 18);
		aBig.loadGraphic(AssetPaths.achievements__png, true, 16, 16);
		aBig.animation.add("lock", [30]);
		aBig.animation.play("lock");
		
		atitle = new FlxText(0, -2, FlxG.width);
		atitle.alignment = "center";
		
		atext = new FlxText(-12, atitle.y+atitle.height-6, FlxG.width+24);
		atext.alignment = "center";
		
		atitle.visible = false;
		atext.visible = false;
		aBig.visible = false;
		ach.visible = false;
		
		if (bg!="full"&&bg!="simple"){
			menuBG.visible = false;
		}
		
		if (bg!="full"){
			menuBGLines.visible = false;
		}
		
		if (!trails){
			logot.visible = false;
		}
		
		atitle.text="Stats";
		stats = new FlxText(0,4,FlxG.width);
		stats.visible = false;
		
		createDMeter();
		dmeter.visible = false;
		
		twitter = new FlxSprite(0, FlxG.height - 9, AssetPaths.twitter__png);
		fb = new FlxSprite(twitter.x + 10, twitter.y, AssetPaths.facebook__png);
		tumblr = new FlxSprite(fb.x + 10, fb.y, AssetPaths.tumblr__png);
		
		fullscreen = new FlxButton(FlxG.width-43, FlxG.height - 9, "", fullscreenSwitch);
		fullscreen.loadGraphic(AssetPaths.fullscreen__png);
		makeMainMenu();
		
		add(menuBG);
		add(menuBGLines);
		add(menu);
		add(twitter);
		add(fb);
		add(tumblr);
		add(fullscreen);
		add(logot);
		add(logof);
		add(logo);
		add(dmeter);
		add(st);
		add(ach);
		add(aBig);
		add(atext);
		add(atitle);
		add(stats);
		
		
		PlayState.respawn = false;
		
		SoundPlayer.pickMusic();
		
		FlxG.camera.fade(FlxColor.BLACK, 1, true);
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		tick++;
		Ctrl.control();
		Achievements.recheck();
		Achievements.check();
		socMedia();
		scrollText();
		menuControl();
		cheat();
		if (Ctrl.stjust&&!achievements){
			SoundPlayer.menu();
			switch(menu.members[pos].text){
				case "Play":
					makeDifficultyMenu();
				case "Start":
					FlxG.switchState(new PlayState());
				case "Options":
					makeOptionsMenu();
				case "Graphics Settings":
					makeSFXMenu();
				case "Achievements/Extras":
					makeAchievementsExtraMenu();
				case "Return":
					switch(state){
						case "stats": makeAchievementsExtraMenu();
						case "achievementsextra": makeMainMenu();
						case "achievements": makeAchievementsExtraMenu();
						case "sfx": makeOptionsMenu();
						case "options": makeMainMenu();
						case "extra": makeAchievementsExtraMenu();
					}
				case "Trails ON":
					menu.members[pos].text = "Trails OFF";
					trails = false;
					logot.visible = false;
				case "Trails OFF":
					menu.members[pos].text = "Trails ON";
					trails = true;
					logot.visible = true;
				case "Background FULL":
					menu.members[pos].text = "Background SIMPLE";
					bg = "simple";
					menuBGLines.visible = false;
				case "Background SIMPLE":
					menu.members[pos].text = "Background OFF";
					bg = "off";
					menuBG.visible = false;
				case "Background OFF":
					menu.members[pos].text = "Background FULL";
					bg = "full";
					menuBG.visible = true;
					menuBGLines.visible = true;
				case "Music ON":
					menu.members[pos].text = "Music OFF";
					SoundPlayer.musicMute = true;
					FlxG.sound.music.volume = 0;
				case "Music OFF":
					menu.members[pos].text = "Music ON";
					SoundPlayer.musicMute = false;
					FlxG.sound.music.volume = 100;
				case "Sound ON":
					menu.members[pos].text = "Sound OFF";
					SoundPlayer.mute = true;
				case "Sound OFF":
					menu.members[pos].text = "Sound ON";
					SoundPlayer.mute = false;
				case "Particles ON":
					menu.members[pos].text = "Particles OFF";
					particles = false;
				case "Particles OFF":
					menu.members[pos].text = "Particles ON";
					particles = true;
				case "Checkpoints ON":
					menu.members[pos].text = "Checkpoints OFF";
					PlayState.checkPointOn = false;
				case "Checkpoints OFF":
					menu.members[pos].text = "Checkpoints ON";
					PlayState.checkPointOn = true;
				case "Difficulty":
					PlayState.difficulty--;
					if (PlayState.difficulty < 3){
						PlayState.difficulty = 9;
					}
					var nd:Int = 9 - PlayState.difficulty;
					dmeter.animation.play(Std.string(nd));
				case "Achievements":
					ach.visible = true;
					makeAchievementsMenu();
				case "Stats":
					makeStatsMenu();
				case "Clear Data":
					makeDeleteMenu();
				case "No":
					makeStatsMenu();
				case "Yes":
					clearData();
					makeStatsMenu();
				case "Extras":
					makeExtrasMenu();
				case "Default Snek":
					snekColor = "default";
					FlxG.camera.flash(FlxColor.WHITE,0.2);
				case "Red Snek":
					snekColor = "red";
					FlxG.camera.flash(FlxColor.WHITE,0.2);
				case "White Snek":
					snekColor = "white";
					FlxG.camera.flash(FlxColor.WHITE,0.2);
				case "Green Snek":
					snekColor = "green";
					FlxG.camera.flash(FlxColor.WHITE,0.2);
				case "Gold Snek":
					snekColor = "gold";
					FlxG.camera.flash(FlxColor.WHITE,0.2);
				case "Rainbow Snek":
					snekColor = "rainbow";
					FlxG.camera.flash(FlxColor.WHITE, 0.2);
				case "Classic Mode":
					retro = !retro;
					FlxG.camera.flash(FlxColor.WHITE,0.2);
			}
			saveGame();
		}
		if (Ctrl.leftjust&&menu.members[pos].text=="Difficulty"){
			PlayState.difficulty++;
			SoundPlayer.menu();
		}
		if (Ctrl.rightjust&&menu.members[pos].text=="Difficulty"){
			PlayState.difficulty--;
			SoundPlayer.menu();
		}
		
		if (PlayState.difficulty < 3){
			PlayState.difficulty = 9;
		}
		if (PlayState.difficulty > 9){
			PlayState.difficulty = 3;
		}
		var nd:Int = 9 - PlayState.difficulty;
		dmeter.animation.play(Std.string(nd));
		
		if (tick % 5 == 1){
			var ran:FlxRandom = new FlxRandom();
			var rancolor:Int = ran.color(0x060006, 0x1A001A);
			menuBG.color = rancolor;
			
			rancolor = ran.color(0x000000, 0xFFFFFF);
			logof.x = logo.x+Math.round(Math.random() * 6) - 3;
			logof.y = logo.y + Math.round(Math.random() * 6) - 3;
			logot.color = rancolor;
		}
		
		achievementControl();
		super.update(elapsed);
	}
	
	function menuControl(){
		if (achievements){
			return;
		}
		if (Ctrl.upjust || Ctrl.leftjust && state == "stats"){
			pos--;
			SoundPlayer.menu();
			if (pos < 0){
				pos = menu.length-1;
			}
		}
		if (Ctrl.downjust||Ctrl.rightjust && state == "stats"){
			pos++;
			SoundPlayer.menu();
			if (pos >= menu.length){
				pos = 0;
			}
		}
		for (i in 0...menu.length){
			if (i != pos){
				menu.members[i].color = FlxColor.GRAY;
				if (menu.members[i].text == "Difficulty"){
					dmeter.color = FlxColor.GRAY;
				}
			}else{
				menu.members[i].color = FlxColor.WHITE;
				if (menu.members[i].text == "Difficulty"){
					dmeter.color = FlxColor.WHITE;
				}
			}
		}
	}
	
	function makeMainMenu(){
		clearMenu();
		twitter.visible = true;
		fb.visible = true;
		tumblr.visible = true;
		fullscreen.visible = true;
		state = "main";
		for (i in 0...3){
			var txt:FlxText = new FlxText(0, logo.y+logo.height+4+i * 12, FlxG.width);
			var s:String = "";
			switch(i){
				case 0: s = "Play";
				case 1: s = "Achievements/Extras";
				case 2: s = "Options";
			}
			txt.text = s;
			txt.alignment = FlxTextAlign.CENTER;
			menu.add(txt);
		}
	}
	
	function makeOptionsMenu(){
		clearMenu();
		state = "options";
		for (i in 0...4){
			var txt:FlxText = new FlxText(0, logo.y+logo.height+2+i * 11, FlxG.width);
			var s:String = "";
			switch(i){
				case 0: 
					s = "Music ON";
					if (SoundPlayer.musicMute){
						s = "Music OFF";
					}
				case 1:
					s = "Sound ON";
					if (SoundPlayer.mute){
						s = "Sound OFF";
					}
				case 2: s = "Graphics Settings";
				case 3: s = "Return";
			}
			txt.text = s;
			txt.alignment = FlxTextAlign.CENTER;
			menu.add(txt);
		}
	}
	
	function makeSFXMenu(){
		clearMenu();
		state = "sfx";
		for (i in 0...4){
			var txt:FlxText = new FlxText(0, logo.y+logo.height+2+i * 11, FlxG.width);
			var s:String = "";
			switch(i){
				case 0: 
					s = "Trails OFF";
					if (trails){
						s = "Trails ON";
					}
				case 1: 
					s = "Particles OFF";
					if (particles){
						s = "Particles ON";
					}
				case 2: 
					switch(bg){
						case "full": s = "Background FULL";
						case "simple": s = "Background SIMPLE";
						case "off": s = "Background OFF";
					}
				case 3: s = "Return";
			}
			txt.text = s;
			txt.alignment = FlxTextAlign.CENTER;
			menu.add(txt);
		}
	}
	
	function makeDifficultyMenu(){
		clearMenu();
		state = "difficulty";
		for (i in 0...3){
			var txt:FlxText = new FlxText(0, logo.y+logo.height+4+i * 14, FlxG.width);
			var s:String = "";
			switch(i){
				case 0: 
					s = "Difficulty";
					txt.visible = false;
					dmeter.visible = true;
				case 1: 
					s = "Checkpoints OFF";
					if (PlayState.checkPointOn){
						s = "Checkpoints ON";
					}
				case 2: s = "Start";
			}
			txt.text = s;
			txt.alignment = FlxTextAlign.CENTER;
			menu.add(txt);
		}
	}
	
	function makeAchievementsExtraMenu(){
		clearMenu();
		state = "achievementsextra";
		for (i in 0...4){
			var txt:FlxText = new FlxText(0, logo.y+logo.height+2+i * 11, FlxG.width);
			var s:String = "";
			switch(i){
				case 0: 
					s = "Achievements";
				case 1: 
					s = "Extras";
				case 2: 
					s = "Stats";
				case 3: 
					s = "Return";
			}
			txt.text = s;
			txt.alignment = FlxTextAlign.CENTER;
			menu.add(txt);
		}
	}
	
	public static var snekColor:String = "default";
	
	function makeExtrasMenu(){
		clearMenu();
		state = "extra";
		logo.visible = false;
		logot.visible = false;
		for (i in 0...7){
			var txt:FlxText = new FlxText(0, i * 10-1, FlxG.width);
			var s:String = "";
			switch(i){
				case 0:
					s = "Default Snek";
				case 1: 
					if(Achievements.acount>=5){
						s = "Red Snek";
					}else{
						s = "Get 5 Achievements";
					}
				case 2: 
					if(Achievements.acount>=10){
						s = "Green Snek";
					}else{
						s = "Get 10 Achievements";
					}
				case 3: 
					if(Achievements.acount>=15){
						s = "White Snek";
					}else{
						s = "Get 15 Achievements";
					}
				case 4: 
					if(Achievements.acount>=20){
						s = "Gold Snek";
					}else{
						s = "Get 20 Achievements";
					}
				case 5: 
					if(Achievements.acount>=30){
						s = "Rainbow Snek";
					}else{
						s = "Get 30 Achievements";
					}
				case 6:
					s = "Return";
			}
			txt.text = s;
			txt.alignment = FlxTextAlign.CENTER;
			menu.add(txt);
		}
	}
	
	var achievements:Bool = false;
	
	
	function makeAchievementsMenu(){
		clearMenu();
		ach.visible = true;
		achievements = true;
		logo.visible = false;
		logot.visible = false;
		atext.visible = true;
		atitle.visible = true;
		aBig.visible = true;
		state = "achievements";
		
		for (i in 0...1){
			var txt:FlxText = new FlxText(0, 62, FlxG.width);
			var s:String = "";
			switch(i){
				case 0: 
					s = "Return";
			}
			txt.text = s;
			txt.alignment = FlxTextAlign.CENTER;
			menu.add(txt);
		}
	}
	
	function makeStatsMenu(){
		clearMenu();
		state = "stats";
		atitle.visible = true;
		stats.visible = true;
		logo.visible = false;
		logot.visible = false;
		stats.y = 4;
		stats.text = "\nDeaths: " + PlayState.deaths + "\nNoms Eaten: " + PlayState.totNoms + "\nTotal Playtime: " + Math.floor((PlayState.playtimetotal / (60 * 60)) % 60) + "m " + Math.floor((PlayState.playtimetotal / 60)%60) + "s\nCompletion: "+(Math.round(Achievements.acount/ 30*1000)/10)+"%";
		atitle.text = "Stats";
		for (i in 0...2){
			var txt:FlxText = new FlxText(0, 60, FlxG.width);
			var s:String = "";
			switch(i){
				case 0: 
					s = "Return";
					txt.x += 4;
				case 1: 
					s = "Clear Data";
					txt.x -= 4;
					txt.alignment = FlxTextAlign.RIGHT;
			}
			txt.text = s;
			menu.add(txt);
		}
	}
	
	function makeDeleteMenu(){
		clearMenu();
		state = "stats";
		atitle.visible = true;
		stats.visible = true;
		logo.visible = false;
		logot.visible = false;
		stats.y = 8;
		stats.text = "Are you SURE you want to clear data?\nThere is NO going back!\nAll achievements will be gone too!";
		for (i in 0...2){
			var txt:FlxText = new FlxText(0, 60, FlxG.width);
			var s:String = "";
			switch(i){
				case 0: 
					s = "No";
					txt.x += 4;
				case 1: 
					s = "Yes";
					txt.x -= 4;
					txt.alignment = FlxTextAlign.RIGHT;
			}
			txt.text = s;
			menu.add(txt);
		}	
	}
	
	function clearMenu(){
		apos = 0;
		achievements = false;
		ach.visible = false;
		logo.visible = true;
		atext.visible = false;
		atitle.visible = false;
		aBig.visible = false;
		stats.visible = false;
		twitter.visible = false;
		fb.visible = false;
		tumblr.visible = false;
		fullscreen.visible = false;
		if (trails){
			logot.visible = true;
		}
		for (m in menu){
			m.kill();
		}
		menu.clear();
		pos = 0;
	}
	
	function createDMeter(){
		dmeter = new FlxSprite(37, 32);
		dmeter.loadGraphic(AssetPaths.difficulty__png, true, 54, 7);
		for (i in 0...8){
			dmeter.animation.add(Std.string(i), [i]);
		}
		var nd:Int = 9 - PlayState.difficulty;
		dmeter.animation.play(Std.string(nd));
	}
	
	static var st:FlxText;
	static var stext:String="";
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
	}
	
	var apos:Int = 0;
	var aReturn:FlxText;
	var aCol:Int = 0;
	
	function achievementControl(){
		if (achievements){
			if (Ctrl.rightjust&&apos<29){
				apos++;
			}
			if (Ctrl.leftjust&&apos<30){
				apos--;
			}
			if (Ctrl.downjust){
				if (apos < 30){
					aCol = apos;
					apos += 10;
				}
				if (apos > 29){
					apos = 30;
				}
			}
			if (Ctrl.upjust){
				if(apos>9&&apos!=30){
					apos -= 10;
				}
				if (apos == 30){
					apos = aCol;
				}
			}
			if (apos > 30){
				apos = 30;
			}
			if (apos < 0){
				apos = 0;
			}
			for (a in ach){
				a.color = FlxColor.GRAY;
			}
			menu.members[0].color = FlxColor.GRAY;
			if(apos<30){
				ach.members[apos].color = FlxColor.WHITE;
			}else{
				menu.members[0].color = FlxColor.WHITE;
			}
			if (Ctrl.stjust && apos == 30){
				makeAchievementsExtraMenu();
			}
			achievementsHide();
		}
	}
	
	var aUnlock:Array<Bool> = [];
	var atitle:FlxText;
	var atext:FlxText;
	var aBig:FlxSprite;
	
	function achievementsHide(){
		var show:Bool = false;
		for (i in 0...30){
			switch(i){
				case 0: show = Achievements.cave;
				case 1: show = Achievements.gear;
				case 2: show = Achievements.gamewon;
				case 3: show = Achievements.chalice1;
				case 4: show = Achievements.chalice2;
				case 5: show = Achievements.chalice3;
				case 6: show = Achievements.nom100;
				case 7: show = Achievements.nom250;
				case 8: show = Achievements.nom500;
				case 9: show = Achievements.nom999;
				case 10: show = Achievements.small;
				case 11: show = Achievements.medium;
				case 12: show = Achievements.long;
				case 13: show = Achievements.xl;
				case 14: show = Achievements.herozero;
				case 15: show = Achievements.die1;
				case 16: show = Achievements.die10;
				case 17: show = Achievements.die25;
				case 18: show = Achievements.die50;
				case 19: show = Achievements.die100;
				case 20: show = Achievements.social;
				case 21: show = Achievements.mrmunch;
				case 22: show = Achievements.galagus;
				case 23: show = Achievements.heart;
				case 24: show = Achievements.twitch;
				case 25: show = Achievements.onelife;
				case 26: show = Achievements.onelifehard;
				case 27: show = Achievements.speedrun;
				case 28: show = Achievements.trueending;
				case 29: show = Achievements.trueendinghard;
			}
			aUnlock[i] = show;
			if (show){
				ach.members[i].animation.play("unlock");
			}else{
				ach.members[i].animation.play("lock");
				
			}
			aUnlock[i] = show;
		}
		atitle.text = "";
		atext.text = "";
		switch(apos){
			case 0: atitle.text = "NEStalgic"; atext.text = "Reach the Caves";
			case 1: atitle.text = "Shoot em' Up"; atext.text = "Reach the Machine";
			case 2: atitle.text = "Flatline"; atext.text = "Beat the game";
			case 3: atitle.text = "Adventure!"; atext.text = "Get the Maze Chalice";
			case 4: atitle.text = "Adventure!!!"; atext.text = "Get the Cave Chalice";
			case 5: atitle.text = "Adventure!!!!!"; atext.text = "Get the Machine Chalice";
			case 6: atitle.text = "Om Nom Nom"; atext.text = "Eat 100 noms total";
			case 7: atitle.text = "You Can Stop Now"; atext.text = "Eat 250 noms total";
			case 8: atitle.text = "It Goes to Your Thighs"; atext.text = "Eat 500 noms total";
			case 9: atitle.text = "Addict"; atext.text = "Eat 999 noms total";
			case 10: atitle.text = "lil snek"; atext.text = "Reach length 10";
			case 11: atitle.text = "med snek"; atext.text = "Reach length 20";
			case 12: atitle.text = "long snek"; atext.text = "Reach length 30";
			case 13: atitle.text = "snek XL"; atext.text = "Reach length 40";
			case 14: atitle.text = "Hero to Zero"; atext.text = "Reach length 40 then die";
			case 15: atitle.text = "Das Ende"; atext.text = "Die";
			case 16: atitle.text = "Recurring Theme"; atext.text = "Die 10 times";
			case 17: atitle.text = "Persistent"; atext.text = "Die 25 times";
			case 18: atitle.text = "*Throws Keyboard*"; atext.text = "Die 50 times";
			case 19: atitle.text = "Acceptance"; atext.text = "Die 100 times";
			case 20: atitle.text = "Social Butterfly"; atext.text = "Check out a social link :)";
			case 21: atitle.text = "Munch Munch Munch"; atext.text = "Lose 10 hp to Mr Munch";
			case 22: atitle.text = "New! Space Action"; atext.text = "Beat Galagus in 10s";
			case 23: atitle.text = "Tourian Air Hockey"; atext.text = "Reflect 30 discs total";
			case 24: atitle.text = "Twitch Reflexes"; atext.text = "Win without Snek Time";
			case 25: atitle.text = "Pro"; atext.text = "Beat the game in one life";
			case 26: atitle.text = "Pro EX++"; atext.text = "Ditto, at max speed";
			case 27: atitle.text = "Snek Games Done Quick"; atext.text = "Win in 2m30s";
			case 28: atitle.text = "IRL Hero"; atext.text = "Get the true ending";
			case 29: atitle.text = "You Done It";	atext.text = "Ditto, at max speed";		
		}
		if(apos<30){
			if (aUnlock[apos]){
				aBig.animation.add("big", [apos]);
				aBig.animation.play("big");
			}else{
				aBig.animation.play("lock");
			}
		}else{
			aBig.animation.play("lock");
		}
	}
	
	
	public static function saveGame(){
		FlxG.save.data.trails = trails;
		FlxG.save.data.bg = bg;
		FlxG.save.data.particles = particles;
		FlxG.save.data.mute = SoundPlayer.mute;
		FlxG.save.data.musicMute = SoundPlayer.musicMute;
		FlxG.save.data.save = true;
		FlxG.save.data.deaths = PlayState.deaths;
		FlxG.save.data.totNoms = PlayState.totNoms;
		FlxG.save.data.playtimetotal = PlayState.playtimetotal;
		FlxG.save.data.heartReflect = PlayState.heartReflect;
		FlxG.save.data.snekColor = snekColor;
		FlxG.save.data.acount = Achievements.acount;
		saveAchievements();
		FlxG.save.flush();
	}
	
	public static function loadGame(){
		if (FlxG.save.data.save != null){
			trails = FlxG.save.data.trails;
			bg = FlxG.save.data.bg;
			particles = FlxG.save.data.particles;
			SoundPlayer.musicMute = FlxG.save.data.musicMute;
			SoundPlayer.mute = FlxG.save.data.mute;
			PlayState.deaths = FlxG.save.data.deaths;
			PlayState.totNoms = FlxG.save.data.totNoms;
			PlayState.heartReflect = FlxG.save.data.heartReflect;
			PlayState.playtimetotal = FlxG.save.data.playtimetotal;
			PlayState.heartReflect = FlxG.save.data.heartReflect;
			Achievements.acount = FlxG.save.data.acount;
			snekColor = FlxG.save.data.snekColor;
			loadAchievements();
		}
	}
	
	function clearData(){
		PlayState.deaths = 0;
		PlayState.totNoms = 0;
		PlayState.heartReflect = 0;
		PlayState.playtimetotal = 0;
		Achievements.acount = 0;
		FlxG.save.data.save = false;
		snekColor = "default";
		saveGame();
		clearAchievements();
		saveAchievements();
	}
	
	static function saveAchievements(){
		FlxG.save.data.cave = Achievements.cave;
		FlxG.save.data.gear = Achievements.gear;
		FlxG.save.data.gamewon = Achievements.gamewon;
		FlxG.save.data.chalice1 = Achievements.chalice1;
		FlxG.save.data.chalice2 = Achievements.chalice2;
		FlxG.save.data.chalice3 = Achievements.chalice3;
		FlxG.save.data.small = Achievements.small;
		FlxG.save.data.medium = Achievements.medium;
		FlxG.save.data.long = Achievements.long;
		FlxG.save.data.xl = Achievements.xl;
		FlxG.save.data.herozero = Achievements.herozero;
		FlxG.save.data.mrmunch = Achievements.mrmunch;
		FlxG.save.data.galagus = Achievements.galagus;
		FlxG.save.data.heart = Achievements.heart;
		FlxG.save.data.twitch = Achievements.twitch;
		FlxG.save.data.social = Achievements.social;
		FlxG.save.data.nom100 = Achievements.nom100;
		FlxG.save.data.nom250 = Achievements.nom250;
		FlxG.save.data.nom500 = Achievements.nom500;
		FlxG.save.data.nom999 = Achievements.nom999;
		FlxG.save.data.die1 = Achievements.die1;
		FlxG.save.data.die10 = Achievements.die10;
		FlxG.save.data.die25 = Achievements.die25;
		FlxG.save.data.die50 = Achievements.die50;
		FlxG.save.data.die100 = Achievements.die100;
		FlxG.save.data.onelife = Achievements.onelife;
		FlxG.save.data.onelifhard = Achievements.onelifehard;
		FlxG.save.data.speedrun = Achievements.speedrun;
		FlxG.save.data.trueending = Achievements.trueending;
		FlxG.save.data.truendinghard = Achievements.trueendinghard;
	}
	
	static function loadAchievements(){
		Achievements.cave = FlxG.save.data.cave;
		Achievements.gear = FlxG.save.data.gear;
		Achievements.gamewon = FlxG.save.data.gamewon;
		Achievements.chalice1 = FlxG.save.data.chalice1;
		Achievements.chalice2 = FlxG.save.data.chalice2;
		Achievements.chalice3 = FlxG.save.data.chalice3;
		Achievements.small = FlxG.save.data.small;
		Achievements.medium = FlxG.save.data.medium;
		Achievements.long = FlxG.save.data.long;
		Achievements.xl = FlxG.save.data.xl;
		Achievements.herozero = FlxG.save.data.herozero;
		Achievements.mrmunch = FlxG.save.data.mrmunch;
		Achievements.galagus = FlxG.save.data.galagus;
		Achievements.heart = FlxG.save.data.heart;
		Achievements.twitch = FlxG.save.data.twitch;
		Achievements.social = FlxG.save.data.social;
		Achievements.nom100 = FlxG.save.data.nom100;
		Achievements.nom250 = FlxG.save.data.nom250;
		Achievements.nom500 = FlxG.save.data.nom500;
		Achievements.nom999 = FlxG.save.data.nom999;
		Achievements.die1 = FlxG.save.data.die1;
		Achievements.die10 = FlxG.save.data.die10;
		Achievements.die25 = FlxG.save.data.die25;
		Achievements.die50 = FlxG.save.data.die50;
		Achievements.die100 = FlxG.save.data.die100;
		Achievements.onelife = FlxG.save.data.onelife;
		Achievements.onelifehard = FlxG.save.data.onlifehard;
		Achievements.speedrun = FlxG.save.data.speedrun;
		Achievements.trueending = FlxG.save.data.trueending;
		Achievements.trueendinghard = FlxG.save.data.truendinghard;
	}
	
	static function clearAchievements(){
		Achievements.cave = false;
		Achievements.gear = false;
		Achievements.gamewon = false;
		Achievements.chalice1 = false;
		Achievements.chalice2 = false;
		Achievements.chalice3 = false;
		Achievements.small = false;
		Achievements.medium = false;
		Achievements.long = false;
		Achievements.xl = false;
		Achievements.herozero = false;
		Achievements.mrmunch = false;
		Achievements.galagus = false;
		Achievements.heart = false;
		Achievements.twitch = false;
		Achievements.social = false;
		Achievements.nom100 = false;
		Achievements.nom250 = false;
		Achievements.nom500 = false;
		Achievements.nom999 = false;
		Achievements.die1 = false;
		Achievements.die10 = false;
		Achievements.die25 = false;
		Achievements.die50 = false;
		Achievements.die100 = false;
		Achievements.onelife = false;
		Achievements.onelifehard = false;
		Achievements.speedrun = false;
		Achievements.trueending = false;
		Achievements.trueendinghard = false;
		socClicked = false;
	}
	
	function socMedia(){
		if (FlxG.mouse.justPressed){
			if (click(fb)) {
				Lib.getURL(new URLRequest ("https://www.facebook.com/Snek-REDUX-1714216318853151"));
				Online.log("Facebook");
				socClicked = true;
			}
			if (click(twitter)) {
				Lib.getURL(new URLRequest ("https://twitter.com/OctosoftUS"));
				Online.log("Twitter");
				socClicked = true;
			}
			if (click(tumblr)) {
				Lib.getURL(new URLRequest ("http://www.octosoft.us"));
				Online.log("Tumblr");
				socClicked = true;
			}
		}
	}
	
	function click(s:FlxSprite):Bool{
		return FlxG.mouse.x >= s.x && FlxG.mouse.x <= s.x + s.width && FlxG.mouse.y <= s.y+s.height && FlxG.mouse.y >= s.y;
	}
	
	var cheatText:String = "";
	var octoCheat:Bool = false;
	function cheat(){
		if (FlxG.keys.firstJustPressed() !=-1){
			cheatText = cheatText + FlxG.keys.getKey(FlxG.keys.firstJustPressed()).ID;
		}else{
			return;
		}
		if(octoCheat){
			SoundPlayer.octo();
		}
		if (cheatText.length > 60){
			cheatText=cheatText.substring(60, cheatText.length);
		}
		cheatText = cheatText.toLowerCase();
		trace(cheatText);
		if (cheatText.indexOf("threethreeonezero") !=-1){
			retro = true;
			FlxG.camera.flash();
			SoundPlayer.music("TheFatRat - Unity");
			cheatText = "";
			Online.log("Cheat - 3310");
		}
		if (cheatText.indexOf("veryupsetting") !=-1){
			cheatText = "";
			SoundPlayer.cheat();
			FlxG.camera.flash();
			Online.log("Cheat - Very Upsetting");
			octoCheat = true;
		}
		if (cheatText.indexOf("upupdowndownleftrightleftrightbaenter") !=-1){
			PlayState.bonuslength = 30;
			SoundPlayer.cheat();
			FlxG.camera.flash();
			cheatText = "";
			Online.log("Cheat - Konami Code");
		}
		if (cheatText.indexOf("finale") !=-1){
			SoundPlayer.music("daPlaque - Minigun");
			cheatText = "";
			Online.log("Cheat - Finale");
		}
	}
	
	function fullscreenSwitch(){
		if(fullscreen.visible){
			if (Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE){
				Lib.current.stage.displayState = StageDisplayState.NORMAL;
			}else{
				Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
		}
	}
}
