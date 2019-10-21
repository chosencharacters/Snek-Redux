package;
import flash.display.JointStyle;
import flixel.FlxG;

/**
 * ...
 * @author Squidly
 */
class Achievements
{
	public static var cave:Bool = false;
	public static var gear:Bool = false;
	public static var gamewon:Bool = false;
	public static var chalice1:Bool = false;
	public static var chalice2:Bool = false;
	public static var chalice3:Bool = false;
	public static var small:Bool = false;
	public static var medium:Bool = false;
	public static var long:Bool = false;
	public static var xl:Bool = false;

	public static var herozero:Bool = false;
	public static var mrmunch:Bool = false;
	public static var galagus:Bool = false;
	public static var heart:Bool = false;
	public static var twitch:Bool = false;
	public static var nom100:Bool = false;
	public static var nom250:Bool = false;
	public static var nom500:Bool = false;
	public static var nom999:Bool = false;
	
	public static var die1:Bool = false;
	public static var die10:Bool = false;
	public static var die25:Bool = false;
	public static var die50:Bool = false;
	public static var die100:Bool = false;
	public static var onelife:Bool = false;
	public static var onelifehard:Bool = false;
	public static var speedrun:Bool = false;
	public static var trueending:Bool = false;
	public static var trueendinghard:Bool = false;
	public static var social:Bool = false;
	
	public static var acount:Int = 0;
	
	public function new() 
	{
		
	}
	
	public static function check(){
		check1();
		check2();
		check3();
	}
	
	static function check1(){
		if (!cave && PlayState.checkpoint == "Cave"){
			cave = true;
			text("NEStalgic");
		}
		if (!gear && PlayState.checkpoint == "Gear"){
			gear = true;
			text("Shoot em' Up");
		}
		if (!gamewon && Heart.killed){
			gamewon = true;
			text("Flatline");
		}
		if (!chalice1 && Chalice.holds && Chalice.spawns == 1){
			chalice1 = true;
			text("Adventure!");
		}
		if (!chalice2 && Chalice.holds && Chalice.spawns == 2){
			chalice2 = true;
			text("Adventure!!!");
		}
		if (!chalice3 && Chalice.holds && Chalice.spawns == 3){
			chalice3 = true;
			text("Adventure!!!!!");
		}
		if (!small && PlayState.snake.length > 9+3){
			small = true;
			text("lil snek");
		}
		if (!medium && PlayState.snake.length > 19+3){
			medium = true;
			text("med snek");
		}
		if (!long && PlayState.snake.length > 29+3){
			long = true;
			text("long snek");
		}
		if (!xl && PlayState.snake.length > 39+3){
			xl = true;
			text("snek XL");
		}
	}
	
	static function check2(){
		if (!herozero && PlayState.topLengthSession >= 40 && PlayState.dead){
			herozero = true;
			text("Hero to Zero");
		}
		if (!mrmunch && PlayState.mrMunchHits > 10){
			mrmunch = true;
			text("Munch Munch Munch");
		}
		if (!galagus && PlayState.galagaTime < 10*60 && PlayState.galagaTime > 0 && Galaga.killed){
			galagus = true;
			text("New! Space Action");
		}
		if (!heart && PlayState.heartReflect > 29){
			heart = true;
			text("Tourian Air Hockey");
		}
		if (!twitch && PlayState.twitch && Heart.killed){
			twitch = true;
			text("Twitch Reflexes");
		}
		if (!nom100 && PlayState.totNoms>100){
			nom100 = true;
			text("Om Nom Nom");
		}
		if (!nom250 && PlayState.totNoms>250){
			nom250 = true;
			text("You Can Stop Now");
		}
		if (!nom500 && PlayState.totNoms>500){
			nom500 = true;
			text("It Goes to Your Thighs");
		}
		if (!nom999 && PlayState.totNoms>999){
			nom999 = true;
			text("Addict");
		}
	}
	
	static function check3(){
		if (!PlayState.dead){
			if (!die1 && PlayState.deaths>1){
				die1 = true;
				text("Das Ende");
			}
			if (!die10 && PlayState.deaths>10){
				die10 = true;
				text("Recurring Theme");
			}
			if (!die25 && PlayState.deaths>=25){
				die25 = true;
				text("Persistent");
			}
			if (!die50 && PlayState.deaths>=50){
				die50 = true;
				text("*Throws Keyboard*");
			}
			if (!die100 && PlayState.deaths>=100){
				die100 = true;
				text("Acceptance");
			}
		}
		if (!social && MenuState.socClicked){
			social = true;
			text("Social Butterfly");
		}
		if (!onelife && PlayState.checkpoint == "Win" && !PlayState.respawn){
			onelife = true;
			text("Pro");
		}
		if (!onelifehard && PlayState.checkpoint == "Win" && PlayState.difficulty == 3 && !PlayState.respawn){
			onelifehard = true;
			text("Pro EX++");
		}
		if (!speedrun && Trophy.taken && PlayState.playtime < 60*150){
			speedrun = true;
			text("Snek Games Done Quick");
		}
		if (!trueending && Demon.killed){
			trueending = true;
			text("IRL Hero");
		}
		if (!trueendinghard && Demon.killed && PlayState.difficulty==3){
			trueendinghard = true;
			text("You Done It");
		}
	}
	
	static function text(s:String){
		acount++;
		Online.medal(s);
		if (Std.is(FlxG.state, PlayState)){
			PlayState.setText("Achievement - " + s);
		}
		if (Std.is(FlxG.state, MenuState)){
			MenuState.setText("Achievement - " + s);
		}
	}
	
	static function cheats(){
		
	}
	
	static var checkc:Int = 0;
	static var tick:Int=0;
	public static function recheck(){
		tick++;
		if (tick % 180 == 1){
			checkc++;
			switch(checkc){
				case 1:
					if (onelife){
						Online.medal("Pro");
					}
					if (onelifehard){
						Online.medal("Pro Ex++");
					}
					if (speedrun){
						Online.medal("Snek Games Done Quick");
					}
					if (trueending){
						Online.medal("IRL Hero");
					}
					if (trueendinghard){
						Online.medal("You Done It");
					}
				case 2:
					if (cave){
						Online.medal("NEStalgic");
					}
					if (gear){
						Online.medal("Shoot em' Up");
					}
					if (gamewon){
						Online.medal("Flatline");
					}
				case 3:
					if (chalice1){
						Online.medal("Adventure!");
					}
					if (chalice2){
						Online.medal("Adventure!!!");
					}
					if (chalice3){
						Online.medal("Adventure!!!!!");
					}
				case 4:
					if (nom100){
						Online.medal("Om Nom Nom");
					}
					if (nom250){
						Online.medal("You Can Stop Now");
					}
					if (nom500){
						Online.medal("It Goes to Your Thighs");
					}
					if (nom999){
						Online.medal("Addict");
					}
				case 5:
					if (small){
						Online.medal("lil snek");
					}
					if (medium){
						Online.medal("med snek");
					}
					if (long){
						Online.medal("long snek");
					}
					if (xl){
						Online.medal("snek xl");
					}
				case 6:
					if (herozero){
						Online.medal("Hero to Zero");
					}
					if (die1){
						Online.medal("Das Ende");
					}
					if (die10){
						Online.medal("Recurring Theme");
					}
					if (die25){
						Online.medal("Persistent");
					}
					if (die50){
						Online.medal("*Throws Keyboard*");
					}
				case 7:
					if (die100){
						Online.medal("Acceptance");
					}
					if (social){
						Online.medal("Social Butterfly");
					}
					if (mrmunch){
						Online.medal("Munch Munch Munch");
					}
					if (galagus){
						Online.medal("New! Space Action");
					}
					if (heart){
						Online.medal("Tourian Air Hockey");
					}
					if (twitch){
						Online.medal("Twitch Reflexes");
					}
			}
		}
	}
	
}