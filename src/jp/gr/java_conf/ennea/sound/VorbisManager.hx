package jp.gr.java_conf.ennea.sound;

import flash.Lib.getTimer;
import flash.display.Shape;
import flash.errors.Error;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.SoundTransform;
import haxe.io.Bytes;
import org.osflash.signals.Signal;
import stb.format.vorbis.flash.VorbisSound;

/**
 * Controls playback and loading of a group of sounds.
 * VorbisAS references a global instance of VorbisManager,
 * but you are free to instanciate your own and use them in a modular fashion.
 * ...
 * @author Tudurao Jin
 */
class VorbisManager
{
	private var instances:Array<VorbisInstance>;
	private var instancesBySound:Map<VorbisSound, VorbisInstance>;
	private var instancesByType:Map<String, VorbisInstance>;
	private var groupsByName:Map<String, VorbisManager>;
	
	/**
	 * grouped manager Array.
	 */
	public var groups(default, null):Array<VorbisManager>;
	
	private var activeTweens:Array<VorbisTween>;
	private var ticker:Shape;
	private var _tickEnabled:Bool;
	private var _mute:Bool;
	private var _volume:Float;
	private var _pan:Float;
	private var _masterVolume:Float;
	private var _masterTween:VorbisTween;
	private var _searching:Bool;
	
	/**
	 * Dispatched when an external Sound has completed loading. 
	 */
	public var loadCompleted(default,null):Signal;
	
	/**
	 * Dispatched when an external Sound has failed loading. 
	 */
	public var loadFailed(default, null):Signal;
	
	/**
	 * parent manager.
	 */
	public var parent:VorbisManager;
	
	
	public function new() {
		init();
	}
	
	/**
	 * Play audio by type.
	 * It must already be loaded into memory using the loadSound() or addSound() or addSoundBytes APIs. 
	 * @param type
	 * @param volume
	 * @param startTime Starting time in milliseconds
	 * @param loops Number of times to loop audio, pass -1 to loop forever.
	 * @param allowMultiple Allow multiple, overlapping instances of this Sound (useful for SoundFX)
	 * @param allowInterrupt If this sound is currently playing, interrupt it and start at the specified StartTime. Otherwise, just update the Volume.
	 */
	public function play(type:String, volume:Float = 1, startTime:Float = 0, loops:Int = 0, allowMultiple:Bool = false, allowInterrupt:Bool = true ):VorbisInstance {
		var si:VorbisInstance = getSound(type);
		
		if ( si == null ){
			trace( "[VorbisSoundAS] Sound with type '" + type+"' does not appear to be loaded." ); 
			throw ( new Error("[VorbisSoundAS] Sound with type '"+type+"' does not appear to be loaded.")); 
		}
		
		//If we retrieved this instance from another manager, add it to our internal list of active instances.
		if( !Lambda.has(instances,si) ){  }
		
		//Sound is playing, and we're not allowed to interrupt it. Just set volume.
		if(!allowInterrupt && si.isPlaying){
			si.volume = volume;
		} 
		//Play sound
		else {
			si.play(volume, startTime, loops, allowMultiple);
		}
		return si;
	}

	/**
	 * Convenience function to play a sound that should loop forever.
	 */
	public function playLoop(type:String, volume:Float = 1, startTime:Float = 0):VorbisInstance {
		return play(type, volume, startTime, -1, false, true);
	}
	
	/**
	 * Convenience function to play a sound that can have overlapping instances (ie click or soundFx).
	 */
	public function playFx(type:String, volume:Float = 1, startTime:Float = 0, loops:Int = 0):VorbisInstance {
		return play(type, volume, startTime, loops, true);
	}
	
	/**
	 * Stop all sounds immediately.
	 */
	public function stopAll():Void {
		for ( si in instances ){
			si.stop();
		}
	}
	
	/**
	 * Resume specific sound 
	 */
	public function resume(type:String):VorbisInstance {
		return getSound(type).resume();
	}
	
	/**
	 * Resume all paused instances.
	 */
	public function resumeAll():Void {
		for ( si in instances ){
			si.resume();
		}
	}
	
	/** 
	 * Pause a specific sound 
	 */
	public function pause(type:String):VorbisInstance {
		return getSound(type).pause();
	}
	
	/**
	 * Pause all sounds
	 */
	public function pauseAll():Void {
		for ( si in instances ){
			si.pause();
		}
	}

	/** 
	 * Fade specific sound starting at the current volume
	 */
	public function fadeTo(type:String, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance {
		return getSound(type).fadeTo(endVolume, duration, stopAtZero);
	}
	
	/**
	 * Fade all sounds starting from their current Volume
	 */
	public function fadeAllTo(endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void{
		for ( si in instances ){
			si.fadeTo(endVolume, duration, stopAtZero);
		}
	}
	
	/** 
	 * Fade master volume starting at the current value
	 */
	public function fadeMasterTo(endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		addMasterTween(_masterVolume, endVolume, duration, stopAtZero);
	}
	
	/** 
	 * Fade specific sound specifying both the StartVolume and EndVolume.
	 */
	public function fadeFrom(type:String, startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance {
		return getSound(type).fadeFrom(startVolume, endVolume, duration, stopAtZero);
	}
	
	/**
	 * Fade all sounds specifying both the StartVolume and EndVolume.
	 */
	public function fadeAllFrom(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		for ( si in instances ) {
			si.fadeFrom(startVolume, endVolume, duration, stopAtZero);
		}
	}
	
	/** 
	 * Fade master volume specifying both the StartVolume and EndVolume.
	 */
	public function fadeMasterFrom(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		addMasterTween(startVolume, endVolume, duration, stopAtZero);
	}

	/**
	 * Mute all instances.
	 */
	public var mute(get, set):Bool;
	private function get_mute():Bool { return _mute; }
	private function set_mute(value:Bool):Bool {
		_mute = value;
		for ( si in instances ){
			si.mute = _mute;
		}
		return _mute;
	}
	
	/**
	 * Set volume on all instances
	 */
	public var volume(get, set):Float;
	private function get_volume():Float { return _volume; }
	private function set_volume(value:Float):Float {
		if ( value < 0 ){ value = 0; } else if ( 1 < value || Math.isNaN(value) ){ value = 1; }
		_volume = value;
		
		for ( si in instances ){
			si.volume = _volume;
		}
		return _volume;
	}
	
	/**
	 * Set pan on all instances
	 */
	public var pan(get, set):Float;
	private function get_pan():Float { return _pan; }
	private function set_pan(value:Float):Float {
		_pan = value;
		for ( si in instances ){
			si.pan = _pan;
		}
		return _pan;
	}
	
	public var soundTransform(never, set):SoundTransform;
	/**
	 * Set soundTransform on all instances. 
	 */
	private function set_soundTransform(value:SoundTransform):SoundTransform {
		for ( si in instances ){
			si.soundTransform = value;
		}
		if ( Lambda.empty(instances) ){
			return null;
		}
		return null;
	}
	
	/**
	 * Returns a SoundInstance for a specific type.
	 * @param	type
	 * @param	forceNew create new Instance.
	 * @return	VorbisInstance, return null when not found.
	 */
	public function getSound(type:String, forceNew:Bool = false):VorbisInstance {
		if (_searching){ return null; }
		if(type == null){ return null; }
		
		var si:VorbisInstance = instancesByType[type];
		_searching = true;
		//Try and retrieve instance from this manager.
		if(si == null ){
			//If instance was not found, check out parent manager;
			if(si == null && parent != null ){ si = parent.getSound(type); }
			//Still not found, check the children.
			if(si == null && groups != null ){
				for ( sm in groups ){
					si = sm.getSound(type);
					if (si != null){	break;	}
				}
			}
			//If we've found it, add it to our local instance list:
			if(si != null && !Lambda.has(instances,si) ){
				addInstance(si);
			}
		}
		
		if (si == null){
			trace("[VorbisSoundManager] getSound() Sound with type '"+type+"' some error caused.");
			_searching = false;
			return null;
		}
		
		if(forceNew){
			si = si.clone();
		}
		_searching = false;
		return si;
	}
	
	
	/**
	 * Preload a sound from a URL or Local Path
	 * @param url External file path to the sound instance.
	 * @param type 
	 * @param buffer not use.
	 */
	public function loadSound(url:String, type:String, buffer:Int = 100):Void {
		var si:VorbisInstance = instancesByType[type];
		if(si != null && si.url == url){ return; }
		
		si = new VorbisInstance(null, type);
		si.url = url; //Useful for looking in case of load error
		si.sound = new VorbisSound( url );
		si.sound.addEventListener(IOErrorEvent.IO_ERROR, onSoundLoadError, false, 0, true);
		//si.sound.addEventListener(ProgressEvent.PROGRESS, onSoundLoadProgress, false, 0, true);
		si.sound.addEventListener(Event.COMPLETE, onSoundLoadComplete, false, 0, true);
		addInstance(si);
	}
	
	
	/**
	 * Inject a sound that has already been loaded.
	 * @param	type
	 * @param	sound
	 */
	public function addSound(type:String, sound:VorbisSound):Void {
		var si:VorbisInstance;
		//If the type is already mapped, inject sound into the existing SoundInstance.
		if( instancesByType.exists(type) ){
			si = instancesByType[type];
			si.sound = sound;
		} 
			//Create a new SoundInstance
		else {
			si = new VorbisInstance(sound, type);
		}
		addInstance(si);
	}
	
	/**
	 * Inject a sound that has already been loaded.
	 * use OggVorbis format Binary.
	 * @param	type
	 * @param	bytes OggVorbis format binary.
	 */
	public function addSoundBytes(type:String, bytes:Bytes):Void
	{
		var si:VorbisInstance;
		var s:VorbisSound;
		//If the type is already mapped, inject sound into the existing SoundInstance.
		if( instancesByType.exists(type) ){
			si = instancesByType[type];
			si.sound.loadFromBytes(bytes);
		} else {
			//Create a new SoundInstance
			s = new VorbisSound();
			s.loadFromBytes(bytes);
			si = new VorbisInstance(s, type);
		}
		addInstance(si);
	}
	
	
	/**
	 * Remove a sound from memory.
	 * @param	type
	 */
	public function removeSound(type:String):Void {
		if( !instancesByType.exists(type) ){ return; }
		
		var i:Int = instances.length - 1;
		while ( i >= 0 )
		{
			if(instances[i].type == type){
				instancesBySound[instances[i].sound] = null;
				instances[i].destroy();
				instances.splice(i, 1);
			}
			i--;
		}
		
		instancesByType[type] = null;
	}
	
	/**
	 * Unload all Sound instances.
	 */
	public function removeAll():Void 
	{
		for ( si in instances ){
			si.destroy();
		}
		
		if( groups != null ){
			for ( g in groups ){
				g.removeAll();
			}
		}
		init();
	}
	
	/**
	 * Set master volume, which will me multiplied on top of all existing volume levels.
	 */
	public var masterVolume(get, set):Float;
	private function get_masterVolume():Float { return _masterVolume; }
	private function set_masterVolume(value:Float):Float {
		if ( value < 0 ){ value = 0; } else if ( 1 < value || Math.isNaN(value) ){ value = 1; }
		_masterVolume = value;
		
		var sound:VorbisInstance;
		for ( si in instances ){
			sound = si;
			sound.volume = sound.volume;
		}
		return _masterVolume;
	}
	
	/**
	 * Return a specific group , create one if it doesn't exist.
	 * @param	name
	 * @return	VorbisManager.
	 */
	public function group(name:String):VorbisManager {
		if( groupsByName[name] == null ){ 
			groupsByName[name] = new VorbisManager(); 
			cast (groupsByName[name], VorbisManager).parent = this;
			if( groups == null ){ groups = new Array<VorbisManager>(); }
			groups.push(groupsByName[name]);
		}
		return groupsByName[name];
	}
	
	
	private function init():Void {
		//Create external signals
		if( loadCompleted == null ){ loadCompleted = new Signal(VorbisInstance); }
		if( loadFailed == null ){ loadFailed = new Signal(VorbisInstance); }
		
		//Init collections
		_volume = 1;
		_pan = 0;
		_masterVolume = 1;
		instances = new Array<VorbisInstance>();
		instancesBySound = new Map<VorbisSound, VorbisInstance>();
		instancesByType = new Map<String, VorbisInstance>();
		groupsByName = new Map<String, VorbisManager>();
		activeTweens = new Array<VorbisTween>();
	}
	
	private function addMasterTween(startVolume:Float, endVolume:Float, duration:Float, stopAtZero:Bool):Void 
	{
		if( _masterTween == null ){ _masterTween = new VorbisTween(null, 0, 0, true); }
		_masterTween.init(startVolume, endVolume, duration);
		_masterTween.stopAtZero = stopAtZero;
		_masterTween.update(0);
		//Only add masterTween if it isn't already active.
		if(activeTweens.indexOf(_masterTween) == -1){
			activeTweens.push(_masterTween);
		}
		tickEnabled = true;
	}
	
	public function addTween(type:String, startVolume:Float, endVolume:Float , duration:Float, stopAtZero:Bool):VorbisTween 
	{
		var si:VorbisInstance = getSound(type);
		if(startVolume >= 0){ si.volume = startVolume; }
		
		//Kill any active fade, it will get removed the next time the tweens are updated.
		if(si.fade != null ){ si.fade.kill(); }
		
		var tween:VorbisTween = new VorbisTween(si, endVolume, duration);
		tween.stopAtZero = stopAtZero;
		tween.update(tween.startTime);
		
		//Add new tween
		activeTweens.push(tween);
		
		tickEnabled = true;
		return tween;
	}

	private function onTick(event:Event):Void {
		var t:Int = getTimer();
		var i:Int = activeTweens.length - 1;
		while ( i >= 0 ){
			if(activeTweens[i].update(t)){
				activeTweens[i].end();
				activeTweens.splice(i, 1);
			}
			i--;
		}
		tickEnabled = (activeTweens.length > 0);
	}
	
	private function addInstance(si:VorbisInstance):Void {
		si.mute = _mute;
		si.manager = this;
		if( !Lambda.has(instances,si) ){ instances.push(si); }
		instancesBySound[si.sound] = si;
		instancesByType[si.type] = si;
	}
	
	private function onSoundLoadComplete(event:Event):Void {
		var sound:VorbisSound = cast (event.target ,VorbisSound);
		loadCompleted.dispatch(instancesBySound[sound]);	
	}
	
	private function onSoundLoadProgress(event:ProgressEvent):Void { }
	
	private function onSoundLoadError(event:IOErrorEvent):Void {
		var sound:VorbisInstance = instancesBySound[ cast (event.target, VorbisSound) ];
		loadFailed.dispatch(sound);
		trace("[VorbisSoundAS] ERROR: Failed Loading Sound '"+sound.type+"' @ "+sound.url);
	}
	
	public var tickEnabled(get, set):Bool;
	private function get_tickEnabled():Bool { return _tickEnabled; }
	private function set_tickEnabled(value:Bool):Bool {
		if(value == _tickEnabled){ return _tickEnabled; }
		_tickEnabled = value;
		if(_tickEnabled){
			if( ticker == null ){ ticker = new Shape(); }
			ticker.addEventListener(Event.ENTER_FRAME, onTick);
		} else {
			ticker.removeEventListener(Event.ENTER_FRAME, onTick); 
		}
		return _tickEnabled;
	}
}