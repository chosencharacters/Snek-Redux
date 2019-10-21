package;
import haxe.Json;
import haxe.Http;
import StringTools;
import openfl.display.LoaderInfo;
import openfl.display.Loader;
import openfl.display.Stage;
import flixel.FlxG;
/**
 * ...
 * @author ...
 */
class Online
{
	
	static var h:Http;
	public function new() 
	{
	}
	
	public static function create(){
		h = new Http('https://www.newgrounds.io/gateway_v3.php');
		sessionID = FlxG.stage.loaderInfo.parameters.ngio_session_id;
	}
	
	static var mid:Int = 0;
	static var sessionID:String = "";
	static var userID:String = "";
	static var load:Loader;
	
	public static function medal(s:String){
		trace("Attempting to Send Medal: "+s);
		medalid(s);
		var o = {
			component: "Medal.unlock",
			 parameters: {
			 id: mid
			}
		};
		var crypt:NgCrypto = new NgCrypto("XXX");
		var ob = {
		{
		"app_id": "XXX",
		"session_id": sessionID,
			"call": {
				"secure": crypt.encrypt(Json.stringify(o)),
			}
		}
		};
		h.setPostData("input=" + StringTools.urlEncode(Json.stringify(ob)));
		h.onData = function(data){ trace("sent:" + Json.stringify(ob)); trace("recieved: " + data); };
		h.onData = function(data){ trace("sent:" + Json.stringify(o)); trace("recieved: " + data); };
		h.onError = function(msg){ trace("error: "+msg); };
		h.onStatus = function(status){ trace("status: " + status); };
		h.request(true);
	}

	public static function check(){
		create();
		var o = {
    	app_id: "XXX",
    	session_id: sessionID,
    	call: {
    		component: "App.checkSession",
    	}
		};
		h.setPostData("input="+StringTools.urlEncode(Json.stringify(o)));
		h.onData = function(data){
			/*trace("//////////////////////////////\nsessionID: " + sessionID + "\n//////////////////////////////");
			trace("data: " + data);*/
		};
		h.onError = function(msg){ trace("error: "+msg); };
		h.onStatus = function(status){ trace("status: " + status); };
		h.request(true);
	}
	
	public static function log(s:String){
    	var o = {
		"app_id": "XXX",
    	"session_id": sessionID,
		"call": {
			"component": "Event.logEvent",
			"parameters": {
				"event_name": s,
				"host": "www.newgrounds.com"
			}
		}};
		h.setPostData("input=" + StringTools.urlEncode(Json.stringify(o)));
		h.onData = function(data){ trace(s); };
		h.onError = function(msg){ trace("error: "+msg); };
		h.onStatus = function(status){ trace("status: " + status); };
		h.request(true);
	}
	
	static function medalid(s:String){
		switch(s){
			case "*Throws Keyboard*": mid = 47275;
			case "Acceptance": mid = 47276;
			case "Addict": mid = 47271;
			case "Das Ende": mid = 47272;
			case "Social Butterfly": mid = 47267;
			case "Hero to Zero": mid = 47262;
			case "It Goes to Your Thighs": mid = 47269;
			case "lil snek": mid = 47258;
			case "long snek": mid =47260;
			case "med snek": mid = 47259;
			case "Om Nom Nom": mid = 47268;
			case "Persistent": mid = 47274;
			case "Recurring Theme": mid = 47273;
			case "snek XL": mid = 47261;
			case "You Can Stop Now": mid = 47270;
			case "Adventure!": mid =47255;
			case "Adventure!!!": mid = 47256;
			case "Adventure!!!!!": mid = 47257;
			case "Munch Munch Munch": mid = 47263;
			case "NEStalgic": mid = 47252;
			case "New! Space Action": mid = 47264;
			case "Shoot em' Up": mid = 47253;
			case "Tourian Air Hockey": mid = 47265;
			case "Flatline": mid = 47254;
			case "Pro": mid = 47277;
			case "Twitch Reflexes": mid = 47266;
			case "IRL Hero": mid = 47280;
			case "Pro EX++": mid = 47278;
			case "Snek Games Done Quick": mid = 47279;
			case "You Done It": mid = 47281;
		}
	}
	
	public static function startApp(){
		create();
		var o = {
    	app_id: "XXX",
    	session_id: sessionID,
    	call: {
    		component: "App.startSession",
    	}
		};
		h.setPostData("input="+StringTools.urlEncode(Json.stringify(o)));
		h.onData = function(data){
			sessionID = h.responseData.substring(h.responseData.indexOf("\"id\":\"") + 6, h.responseData.indexOf("\",\"user"));
			trace("//////////////////////////////\nsessionID: " + sessionID+"\n//////////////////////////////");
			trace("data: " + data);
			
		};
		h.onError = function(msg){ trace("error: "+msg); };
		h.onStatus = function(status){ trace("status: " + status); };
		h.request(true);
	}
	
	
}