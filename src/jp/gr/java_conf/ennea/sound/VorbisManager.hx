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
	private var _instances:Array<VorbisInstance>;
	private var _instancesBySound:Map<VorbisSound, VorbisInstance>;
	private var _instancesByType:Map<String, VorbisInstance>;
	private var _groupsByName:Map<String, VorbisManager>;
	
	
	/**
	 * grouped manager Array.
	 */
	public var groups:Array<VorbisManager>;
	
	private var _activeTweens:Array<VorbisTween>;
	private var _ticker:Shape;
	private var _masterTween:VorbisTween;
	private var _searching:Bool;
	
	/**
	 * Dispatched when an external Sound has completed loading. 
	 */
	public var loadCompleted:Signal;
	
	/**
	 * Dispatched when an external Sound has failed loading. 
	 */
	public var loadFailed:Signal;
	
	/**
	 * parent manager.
	 */
	public var parent:VorbisManager;
	
	
	/**
	 * Mute all instances.
	 */
	#if (swc || as3)
	@:extern public var mute:Bool;
	#else
	public var mute(get, set):Bool;
	#end
	
	private var _mute:Bool;
	
	#if (swc || as3)
	@:getter(mute)
	#end
	private function get_mute():Bool {	return this._mute;	 }
	#if (swc || as3)
	@:setter(mute)
	#end
	private function set_mute(value:Bool):Bool {
		_mute = value;
		for ( si in _instances ){
			si.mute = _mute;
		}
		return _mute;
	}
	
	/**
	 * Set volume on all instances
	 */
	#if (swc || as3)
	@:extern public var volume:Float;
	#else
	public var volume(get, set):Float;
	#end
	
	private var _volume:Float;
	
	#if (swc || as3)
	@:getter(volume)
	#end
	private function get_volume():Float {	return this._volume;	 }
	#if (swc || as3)
	@:setter(volume)
	#end
	private function set_volume(value:Float):Float {
		if ( value < 0 ){ value = 0; } else if ( 1 < value || Math.isNaN(value) ){ value = 1; }
		_volume = value;
		
		for ( si in _instances ){
			si.volume = _volume;
		}
		return _volume;
	}
	
	/**
	 * Set master volume, which will me multiplied on top of all existing volume levels.
	 */
	#if (swc || as3)
	@:extern public var masterVolume:Float;
	#else
	public var masterVolume(get, set):Float;
	#end
	
	private var _masterVolume:Float;
	
	#if (swc || as3)
	@:getter(masterVolume)
	#end
	private function get_masterVolume():Float {		return this._masterVolume;	 }
	#if (swc || as3)
	@:setter(masterVolume)
	#end
	private function set_masterVolume(value:Float):Float {
		if ( value < 0 ){ value = 0; } else if ( 1 < value || Math.isNaN(value) ){ value = 1; }
		_masterVolume = value;
		
		var sound:VorbisInstance;
		for ( si in _instances ){
			sound = si;
			sound.volume = sound.volume; //update SoundInstance mixedVolume.
		}
		return _masterVolume;
	}
	
	/**
	 * Set pan on all instances
	 */
	#if (swc || as3)
	@:extern public var pan:Float;
	#else
	public var pan(get, set):Float;
	#end
	
	private var _pan:Float;
	
	#if (swc || as3)
	@:getter(pan)
	#end
	private function get_pan():Float {	return this._pan;	 }
	#if (swc || as3)
	@:setter(pan)
	#end
	private function set_pan(value:Float):Float {
		_pan = value;
		for ( si in _instances ){
			si.pan = _pan;
		}
		return _pan;
	}
	
	#if (swc || as3)
	@:extern public var soundTransform:SoundTransform;
	#else
	public var soundTransform(never, set):SoundTransform;
	#end
	
	/**
	 * Set soundTransform on all instances. 
	 * always return null.
	 */
	#if (swc || as3)
	@:setter(soundTransform)
	#end
	private function set_soundTransform(value:SoundTransform):SoundTransform {
		if ( Lambda.empty(_instances) ){		return null;	}
		for ( si in _instances ){
			si.soundTransform = value;
		}
		return null;
	}
	
	// -----------------------------------------------
	
	public function new() {
		//Create external signals
		init();
		loadCompleted = new Signal(VorbisInstance);
		loadFailed = new Signal(VorbisInstance);
		_volume = 1;
		_pan = 0;
		_masterVolume = 1;
		_masterTween = new VorbisTween(null, 0, 0, true);
	}
	
	private function init():Void {
		//Init collections
		_instances = new Array<VorbisInstance>();
		_instancesBySound = new Map<VorbisSound, VorbisInstance>();
		_instancesByType = new Map<String, VorbisInstance>();
		_groupsByName = new Map<String, VorbisManager>();
		_activeTweens = new Array<VorbisTween>();
	}

	/**
	 * Play audio by type.
	 * It must already be loaded into memory using the loadSound() or addSound() or addSoundBytes APIs. 
	 * @param type	specified sound name.
	 * @param volume	sound play volume.
	 * @param startTime Starting time in milliseconds
	 * @param loops Number of times to loop audio, pass -1 to loop forever.
	 * @param allowMultiple Allow multiple, overlapping instances of this Sound (useful for SoundFX)
	 * @param allowInterrupt If this sound is currently playing, interrupt it and start at the specified StartTime. Otherwise, just update the Volume.
	 */
	public function play(type:String, volume:Float = 1, startTime:Float = 0, loops:Int = 0, allowMultiple:Bool = false, allowInterrupt:Bool = true ):VorbisInstance {
		var si:VorbisInstance = getSound(type);
		
		if ( si == null ){
			trace( "[VorbisAS] Sound with type '" + type+"' does not appear to be loaded." ); 
			throw ( new Error("[VorbisAS] Sound with type '"+type+"' does not appear to be loaded.")); 
		}
		
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
		for ( si in _instances ){
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
		for ( si in _instances ){
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
		for ( si in _instances ){
			si.pause();
		}
	}

	/** 
	 * Fade specific sound starting at the current volume
	 */
	public function fadeTo(type:String, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance {
		//return getSound(type).fadeTo(endVolume, duration, stopAtZero);
		return addTween(type, -1, endVolume, duration, stopAtZero).sound;
	}
	
	/**
	 * Fade all sounds starting from their current Volume
	 */
	public function fadeAllTo(endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void{
		for ( si in _instances ){
			//si.fadeTo(endVolume, duration, stopAtZero);
			addTween(si.type, -1, endVolume, duration, stopAtZero).sound;
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
		//return getSound(type).fadeFrom(startVolume, endVolume, duration, stopAtZero);
		return addTween(type, startVolume, endVolume, duration, stopAtZero).sound;
	}
	
	/**
	 * Fade all sounds specifying both the StartVolume and EndVolume.
	 */
	public function fadeAllFrom(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		for ( si in _instances ) {
			//si.fadeFrom(startVolume, endVolume, duration, stopAtZero);
			addTween(si.type, startVolume, endVolume, duration, stopAtZero).sound;
		}
	}
	
	/** 
	 * Fade master volume specifying both the StartVolume and EndVolume.
	 */
	public function fadeMasterFrom(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		addMasterTween(startVolume, endVolume, duration, stopAtZero);
	}
	
	/**
	 * Returns a SoundInstance for a specific type.
	 * @param	type	specified sound name.
	 * @param	forceNew create new Instance.
	 * @return	VorbisInstance, return null when not found.
	 */
	public function getSound(type:String, forceNew:Bool = false):VorbisInstance {
		if (_searching){ return null; }
		if(type == null){ return null; }
		
		var si:VorbisInstance = _instancesByType[type];
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
			if(si != null && !Lambda.has(_instances,si) ){
				addInstance(si);
			}
		}
		
		if (si == null){
			trace("[VorbisManager] getSound() Sound with type '"+type+"' some error caused.");
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
	 * @param type	 specific sound's name.
	 */
	public function loadSound(url:String, type:String):Void {
		var si:VorbisInstance = _instancesByType[type];
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
	 * @param	type  specific sound's name.
	 * @param	sound   VorbisSound instance.
	 * 
	 */
	public function addSound(type:String, sound:VorbisSound):Void {
		var si:VorbisInstance;
		//If the type is already mapped, inject sound into the existing SoundInstance.
		if( _instancesByType.exists(type) ){
			si = _instancesByType[type];
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
	 * @param	type	specific sound's name.
	 * @param	bytes OggVorbis format binary.
	 */
	public function addSoundBytes(type:String, bytes:Bytes):Void
	{
		var si:VorbisInstance;
		var s:VorbisSound;
		//If the type is already mapped, inject sound into the existing SoundInstance.
		if( _instancesByType.exists(type) ){
			si = _instancesByType[type];
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
	 * @param	type	specified sound name.
	 */
	public function removeSound(type:String):Void {
		if( !_instancesByType.exists(type) ){ return; }
		
		var i:Int = _instances.length - 1;
		while ( i >= 0 )
		{
			if(_instances[i].type == type){
				_instancesBySound[_instances[i].sound] = null;
				_instances[i].destroy();
				_instances.splice(i, 1);
			}
			i--;
		}
		
		_instancesByType[type] = null;
	}
	
	/**
	 * Unload all Sound instances.
	 */
	public function removeAll():Void 
	{
		for ( si in _instances ){
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
	 * Return a specific group , create one if it doesn't exist.
	 * @param	name	group name.
	 * @return	VorbisManager.
	 */
	public function group(name:String):VorbisManager {
		if ( _groupsByName[name] == null ){ 
			var vm:VorbisManager = new VorbisManager();
			vm.parent = this;
			_groupsByName[name] = vm;
			if( groups == null ){ groups = new Array<VorbisManager>(); }
			groups.push( vm );
		}
		return _groupsByName[name];
	}
	
	
	private function addMasterTween(startVolume:Float, endVolume:Float, duration:Float, stopAtZero:Bool):Void 
	{
		//if( _masterTween == null ){ _masterTween = new VorbisTween(null, 0, 0, true); }
		_masterTween.init(startVolume, endVolume, duration);
		_masterTween.stopAtZero = stopAtZero;
		_masterTween.update(0);
		//Only add masterTween if it isn't already active.
		if(_activeTweens.indexOf(_masterTween) == -1){
			_activeTweens.push(_masterTween);
		}
		tickEnabled = true;
	}
	
	public function addTween(type:String, startVolume:Float, endVolume:Float , duration:Float, stopAtZero:Bool):VorbisTween 
	{
		var si:VorbisInstance = getSound(type);
		var tween:VorbisTween = si.fade;
		var stvol:Float = startVolume >= 0? startVolume : si.volume;
		tween.init(stvol, endVolume, duration);
		tween.stopAtZero = stopAtZero;
		tween.update(tween.startTime);
		
		//Add new tween
		_activeTweens.push(tween);
		
		tickEnabled = true;
		return tween;
	}
	
	private function addInstance(si:VorbisInstance):Void {
		si.mute = _mute;
		si.manager = this;
		if( !Lambda.has(_instances,si) ){ _instances.push(si); }
		_instancesBySound[si.sound] = si;
		_instancesByType[si.type] = si;
	}
	
	#if (swc || as3)
	@:extern public var tickEnabled:Bool;
	#else
	public var tickEnabled(get, set):Bool;
	#end
	private var _tickEnabled:Bool;
	
	
	#if (swc || as3)
	@:getter(tickEnabled)
	#end
	private function get_tickEnabled():Bool {	return this._tickEnabled;	 }
	
	#if (swc || as3)
	@:setter(tickEnabled)
	#end
	private function set_tickEnabled(value:Bool):Bool {
		if(value == _tickEnabled){ return _tickEnabled; }
		_tickEnabled = value;
		if(_tickEnabled){
			if( _ticker == null ){ _ticker = new Shape(); }
			_ticker.addEventListener(Event.ENTER_FRAME, onTick);
		} else {
			_ticker.removeEventListener(Event.ENTER_FRAME, onTick); 
		}
		return _tickEnabled;
	}

	private function onTick(event:Event):Void {
		var t:Int = getTimer();
		var i:Int = _activeTweens.length - 1;
		while ( i >= 0 ){
			if(_activeTweens[i].update(t)){
				_activeTweens[i].end();
				_activeTweens.splice(i, 1);
			}
			i--;
		}
		tickEnabled = (_activeTweens.length > 0);
	}
	
	private function onSoundLoadComplete(event:Event):Void {
		var sound:VorbisSound = cast (event.target ,VorbisSound);
		loadCompleted.dispatch(_instancesBySound[sound]);	
	}
	
	private function onSoundLoadProgress(event:ProgressEvent):Void { }
	
	private function onSoundLoadError(event:IOErrorEvent):Void {
		var sound:VorbisInstance = _instancesBySound[ cast (event.target, VorbisSound) ];
		loadFailed.dispatch(sound);
		trace("[VorbisSoundAS] ERROR: Failed Loading Sound '"+sound.type+"' @ "+sound.url);
	}
	
}