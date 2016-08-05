package jp.gr.java_conf.ennea.sound;

import flash.media.SoundTransform;
import haxe.io.Bytes;
import org.osflash.signals.Signal;
import stb.format.vorbis.flash.VorbisSound;

/**
 * VorbisAS is static manager class...
 * this class have property and functions same to VorbisManager.
 * you can invoke everywhere as instantly sound manager.
 * 
 * @author Tudurao Jin
 */
class VorbisAS
{
	/**
	 * static VotbisManager instance.
	 * you can directly access to static manager, through this property.
	 */
	public static var manager(default,null):VorbisManager = new VorbisManager();
	
	// private constructor
	private function new(){}
	
	// static accessor and functions //
	
	public static var groups(get, never):Array<VorbisManager>;
	private static function get_groups():Array<VorbisManager>	{	return manager.groups;	}
	//private static function set_groups( value:Array<VorbisManager> ):Array<VorbisManager>	{	return manager.groups = value;	}
	
	public static var loadCompleted(get, never):Signal;
	private static function get_loadCompleted():Signal	{	return manager.loadCompleted;	}
	//private static function set_loadCompleted( value:Signal ):Signal	{	return manager.loadCompleted = value;	}
	
	public static var loadFailed(get, never) :Signal;
	private static function get_loadFailed():Signal	{	return manager.loadFailed;	}
	//private static function set_loadFailed( value:Signal ):Signal	{	return manager.loadFailed = value;	}
	
	public static var parent:VorbisManager;
	private static function get_parent():VorbisManager{	return manager.parent;	}
	private static function set_parent( value:VorbisManager ):VorbisManager {	return manager.parent = value;	}
	
	public static function play(type:String, volume:Float = 1, startTime:Float = 0, loops:Int = 0, allowMultiple:Bool = false, allowInterrupt:Bool = true ):VorbisInstance {
		return manager.play(type, volume, startTime, loops, allowMultiple, allowInterrupt );
	}
	
	public static function playLoop(type:String, volume:Float = 1, startTime:Float = 0 ):VorbisInstance {
		return manager.playLoop(type, volume, startTime );
	}
	
	public static function playFx(type:String, volume:Float = 1, startTime:Float = 0, loops:Int = 0):VorbisInstance {
		return manager.playFx(type, volume, startTime, loops);
	}
	
	public static function stopAll():Void {	manager.stopAll();	}
	public static function resume(type:String):VorbisInstance {	return manager.resume(type);	}
	public static function resumeAll():Void {	manager.resumeAll();	}
	public static function pause(type:String):VorbisInstance {	return manager.pause(type);	 }
	public static function pauseAll():Void {	manager.pauseAll();	 }

	public static function fadeTo(type:String, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance {
		return manager.fadeTo(type, endVolume, duration, stopAtZero);
	}
	
	public static function fadeAllTo(endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		manager.fadeAllTo(endVolume, duration, stopAtZero);
	}
	
	public static function fadeMasterTo(endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		manager.fadeMasterTo(endVolume, duration, stopAtZero);
	}
	
	public static function fadeFrom(type:String, startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance {
		return manager.fadeFrom(type, startVolume, endVolume, duration, stopAtZero);
	}
	
	public static function fadeAllFrom(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		manager.fadeAllFrom(startVolume, endVolume, duration, stopAtZero);
	}
	
	public static function fadeMasterFrom(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		manager.fadeMasterFrom(startVolume, endVolume, duration, stopAtZero);
	}
	
	public static var mute(get, set):Bool;
	private static function get_mute():Bool	{	return manager.mute;	}
	private static function set_mute( value:Bool ):Bool	{	return manager.mute = value;	}
	
	public static var volume(get, set):Float;
	private static function get_volume():Float	{	return manager.volume;	}
	private static function set_volume( value:Float ):Float	{	return manager.volume = value;	}
	
	public static var pan(get, set):Float;
	private static function get_pan():Float	{	return manager.pan;	}
	private static function set_pan( value:Float ):Float	{	return manager.pan = value;	}
	
	public static var soundTransform(never, set):SoundTransform;
	private static function set_soundTransform(value:SoundTransform):SoundTransform { return manager.soundTransform = value;	}
	
	public static function getSound(type:String, forceNew:Bool = false):VorbisInstance { return manager.getSound(type, forceNew);	}
	public static function loadSound(url:String, type:String, buffer:Int = 100):Void { manager.loadSound(url, type, buffer);	}
	public static function addSound(type:String, sound:VorbisSound):Void {	manager.addSound(type, sound);	}
	public static function addSoundBytes(type:String, bytes:Bytes):Void {	manager.addSoundBytes(type, bytes);	}
	public static function removeSound(type:String):Void {	manager.removeSound(type);	}
	public static function removeAll():Void {	manager.removeAll(); }
	
	public static var masterVolume(get, set):Float;
	private static function get_masterVolume():Float	{	return manager.masterVolume;	}
	private static function set_masterVolume( value:Float ):Float	{	return manager.masterVolume = value;	}

	public static function group(name:String):VorbisManager {	return manager.group(name);	}
	
	public static function addTween(type:String, startVolume:Float, endVolume:Float , duration:Float, stopAtZero:Bool):VorbisTween {
		return manager.addTween(type, startVolume, endVolume, duration, stopAtZero);
	}
	
	public static var tickEnabled(get, set):Bool;
	private static function get_tickEnabled():Bool	{	return manager.tickEnabled;	}
	private static function set_tickEnabled( value:Bool ):Bool	{	return manager.tickEnabled = value;	}
}
