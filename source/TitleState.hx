package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;
import flixel.FlxG;

/**
 * ...
 * @author ...
 */
class TitleState extends FlxState
{
	var bg:FlxSprite;
	var bgLines:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var logo:FlxSprite;
	var slide:Int = 0;
	
	override public function create():Void
	{
		Online.check();
		Online.log("Game Start");
		FlxG.mouse.hideCursor();
		FlxG.mouse.visible = false;
		bgLines = new FlxTypedGroup<FlxSprite>();
		for (r in 0...8){
			var b:FlxSprite = new FlxSprite(r*16, 0);
			b.loadGraphic(AssetPaths.menubg__png);
			b.color = FlxColor.BLACK;
			bgLines.add(b);
		}
		bg = new FlxSprite(0, 0);
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		logo = new FlxSprite(12,13);
		add(bg);
		add(bgLines);
		add(logo);
		newSlide();
		super.create();
	}
	
	var tick:Int = 0;
	
	override public function update(elapsed:Float):Void 
	{
		Ctrl.control();
		tick++;
		if (tick % 5 == 1){
			var ran:FlxRandom = new FlxRandom();
			var rancolor:Int = ran.color(0x060006, 0x1A001A);
			for (b in bgLines){
				b.color = rancolor;
			}
		}
		if (tick % 140==0){
			FlxG.camera.fade(FlxColor.BLACK, 1, false, newSlide);
		}
		super.update(elapsed);
	}
	
	function newSlide(){
		tick = 0;
		slide++;
		FlxG.camera.fade(FlxColor.BLACK, 1, true);
		switch(slide){
			case 1:
				logo.loadGraphic(AssetPaths.octosofttitle__png);
			case 2:
				logo.loadGraphic(AssetPaths.haxeflixellogo__png);
				logo.x = 24;
				logo.y = 12;
			case 3:
				logo.loadGraphic(AssetPaths.keyboardcontrols__png);
				logo.x = 4;
				logo.y = 3;
			case 4:
				logo.loadGraphic(AssetPaths.controller__png);
				logo.x = 0;
				logo.y = 0;
			case 5:
				FlxG.switchState(new MenuState());
		}
	}
	
}