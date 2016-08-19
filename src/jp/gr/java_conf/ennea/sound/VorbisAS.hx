package jp.gr.java_conf.ennea.sound;

import flash.media.SoundTransform;
import haxe.io.Bytes;
import org.osflash.signals.Signal;
import stb.format.vorbis.flash.VorbisSound;

/**
 * VorbisAS is static manager class...
 * this class have property and functions same to VorbisMmanager.
 * you can invoke everywhere as instantly VorbisManager instance.
 * 
 * @author Tudurao Jin
 */
class VorbisAS
{
	/**
	 * static VotbisManager instance.
	 * you can directly access to static manager, through this property.
	 */
	public static var manager:VorbisManager;
	
	/**
	 * initialize static manager.
	 * you need call first on AS3. but need call after initSwc().
	 */
	public static function initialize():Void
	{
		manager = new VorbisManager();
	}
	
	/**
	 * private constructor
	 */ 
	private function new(){}
	
	// static accessor and functions //
	
	#if (swc || as3)
	@:extern public static var groups:Array<VorbisManager>;
	@:getter(groups) private static function get_groups():Array<VorbisManager>	{	return manager.groups;	}
	#else
	public static var groups(get, never):Array<VorbisManager>;
	private static function get_groups():Array<VorbisManager>	{	return manager.groups;	}
	#end
	
	#if (swc || as3)
	@:extern public static var loadCompleted:Signal;
	@:getter(loadCompleted) private static function get_loadCompleted():Signal	{	return manager.loadCompleted;	}
	#else
	public static var loadCompleted(get, never):Signal;
	private static function get_loadCompleted():Signal	{	return manager.loadCompleted;	}
	#end
	
	#if (swc || as3)
	@:extern public static var loadFailed:Signal;
	@:getter(loadFailed) private static function get_loadFailed():Signal	{	return manager.loadFailed;	}
	#else
	public static var loadFailed(get, never) :Signal;
	private static function get_loadFailed():Signal	{	return manager.loadFailed;	}
	#end
	
	#if (swc || as3)
	@:extern public static var parent:VorbisManager;
	@:getter(parent) private static function get_parent():VorbisManager{	return manager.parent;	}
	@:setter(parent) private static function set_parent( value:VorbisManager ):VorbisManager {	return manager.parent = value;	}
	#else
	public static var parent(get, set):VorbisManager;
	private static function get_parent():VorbisManager{	return manager.parent;	}
	private static function set_parent( value:VorbisManager ):VorbisManager {	return manager.parent = value;	}
	#end
	
	#if (swc || as3)
	@:extern public static var mute:Bool;
	@:getter(mute) private static function get_mute():Bool	{	return manager.mute;	}
	@:setter(mute) private static function set_mute( value:Bool ):Bool	{	return manager.mute = value;	}
	#else
	public static var mute(get, set):Bool;
	private static function get_mute():Bool	{	return manager.mute;	}
	private static function set_mute( value:Bool ):Bool	{	return manager.mute = value;	}
	#end
	
	#if (swc || as3)
	@:extern public static var volume:Float;
	@:getter(volume) private static function get_volume():Float	{	return manager.volume;	}
	@:setter(volume) private static function set_volume( value:Float ):Float	{	return manager.volume = value;	}
	#else
	public static var volume(get, set):Float;
	private static function get_volume():Float	{	return manager.volume;	}
	private static function set_volume( value:Float ):Float	{	return manager.volume = value;	}
	#end
	
	#if (swc || as3)
	@:extern public static var masterVolume:Float;
	@:getter(masterVolume) private static function get_masterVolume():Float	{	return manager.masterVolume;	}
	@:setter(masterVolume) private static function set_masterVolume( value:Float ):Float	{	return manager.masterVolume = value;	}
	#else
	public static var masterVolume(get, set):Float;
	private static function get_masterVolume():Float	{	return manager.masterVolume;	}
	private static function set_masterVolume( value:Float ):Float	{	return manager.masterVolume = value;	}
	#end
	
	#if (swc || as3)
	@:extern public static var pan:Float;
	@:getter(pan) private static function get_pan():Float	{	return manager.pan;	}
	@:setter(pan) private static function set_pan( value:Float ):Float	{	return manager.pan = value;	}
	#else
	public static var pan(get, set):Float;
	private static function get_pan():Float	{	return manager.pan;	}
	private static function set_pan( value:Float ):Float	{	return manager.pan = value;	}
	#end
	
	#if (swc || as3)
	@:extern public static var soundTransform:SoundTransform;
	@:setter(soundTransform) private static function set_soundTransform(value:SoundTransform):SoundTransform { return manager.soundTransform = value;	}
	#else
	public static var soundTransform(never, set):SoundTransform;
	private static function set_soundTransform(value:SoundTransform):SoundTransform { return manager.soundTransform = value;	}
	#end

	#if (swc || as3)
	@:extern public static var tickEnabled:Bool;
	@:getter(tickEnabled) private static function get_tickEnabled():Bool	{	return manager.tickEnabled;	}
	@:setter(tickEnabled) private static function set_tickEnabled( value:Bool ):Bool	{	return manager.tickEnabled = value;	}
	#else
	public static var tickEnabled(get, set):Bool;
	private static function get_tickEnabled():Bool	{	return manager.tickEnabled;	}
	private static function set_tickEnabled( value:Bool ):Bool	{	return manager.tickEnabled = value;	}
	#end
	
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
	
	public static function getSound(type:String, forceNew:Bool = false):VorbisInstance { return manager.getSound(type, forceNew);	}
	public static function loadSound(url:String, type:String, buffer:Int = 100):Void { manager.loadSound(url, type);	}
	public static function addSound(type:String, sound:VorbisSound):Void {	manager.addSound(type, sound);	}
	public static function addSoundBytes(type:String, bytes:Bytes):Void {	manager.addSoundBytes(type, bytes);	}
	public static function removeSound(type:String):Void {	manager.removeSound(type);	}
	public static function removeAll():Void {	manager.removeAll(); }

	public static function group(name:String):VorbisManager {	return manager.group(name);	}
	
	public static function addTween(type:String, startVolume:Float, endVolume:Float , duration:Float, stopAtZero:Bool):VorbisTween {
		return manager.addTween(type, startVolume, endVolume, duration, stopAtZero);
	}
	
}
