package;
import flixel.system.FlxSound;
import flixel.FlxG;

/**
 * ...
 * @author Squidly
 */
class SoundPlayer
{
	static var song1:FlxSound;
	public static var mute:Bool = false;
	public static var musicMute:Bool = false;
	static var vol2:Float = 1;
	public function new() 
	{
		
	}
	
	public static function pickMusic(){
		switch(Math.floor(Math.random()*8)+1){
			case 1:
				music("NaiKee - Journey");
			case 2:
				music("Mortar - Ignite");
			case 3:
				music("Thomas VX - Sunrise");
			case 4:
				music("TheFatRat - Unity");
			case 5:
				music("Danek - Gate D52");
			case 6:
				music("Tobu - Higher");
			case 7:
				music("Gaden Rhoss - Zero Magnitude");
			case 8:
				music("NaiKee - Your Lips");
		}
	}
	
	static var prevmusic:String="";
	
	public static function music(name:String) {
		if (prevmusic == name){
			pickMusic();
			return;
		}
		prevmusic = name;
		FlxG.sound.playMusic("assets/music/" + name+".mp3", 1, true);
		if(Std.is(FlxG.state,PlayState)){
			PlayState.setText(name);
		}
		if(Std.is(FlxG.state,MenuState)){
			MenuState.setText(name);
		}
		if (musicMute){
			FlxG.sound.music.volume = 0;
		}
	}
	
	public static function snakeTime(b:Bool){
		if (mute || FlxG.sound.music==null){
			return;
		}
		if (b){
			FlxG.sound.volume = 0.5;
		}else{
			FlxG.sound.volume = 1;
		}
	}
	
	var hits:FlxSound;
	public static function hit(){
		if (mute) {
			return;
		}
		var hits:FlxSound = FlxG.sound.load("assets/sounds/hit.wav");
		hits.volume = vol2;
		hits.play();
	}
	
	public static function ehit(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/hit.wav");
		sound.volume = vol2;
		sound.play();
	}

	
	public static function nom(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/nom.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function powerup(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/powerup.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function axe(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/axe.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function missile(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/missiles.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function bullet(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/bullet.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function heartbeat(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/heartbeat.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function reflect(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/reflect.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function achievement(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/achievement.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function gameover(){
		if (mute || FlxG.sound.music==null){
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/gameover.wav");
		sound.volume = vol2;
		sound.play();
		FlxG.sound.music.stop();
	}
	
	public static function menu(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/select.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function octo(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/shoot.wav");
		sound.volume = vol2;
		sound.play();
	}
	
	public static function cheat(){
		if (mute) {
			return;
		}
		var sound:FlxSound = FlxG.sound.load("assets/sounds/solved.wav");
		sound.volume = vol2;
		sound.play();
	}
	
}