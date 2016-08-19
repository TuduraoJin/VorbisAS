package jp.gr.java_conf.ennea.sound;

import flash.errors.Error;
import flash.events.Event;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import org.osflash.signals.Signal;
import stb.format.vorbis.flash.VorbisSound;
import stb.format.vorbis.flash.VorbisSoundChannel;
	

/**
 * Vorbis Instance supported OggVorbis playback control and channel management.
 * you can use easily normal playback, multiple fx playback, and fadeIn/Out.
 * 
 * @author Tudurao Jin
 */
class VorbisInstance
{
	/**
	 * this instance is registered to manager. default is VorbisAS.
	 */
	public var manager:VorbisManager;
	
	/**
	 * Specified name for this Sound
	 */
	public var type:String;
	
	/**
	 * URL this sound was loaded from.
	 * When This is null, the sound was not loaded or loaded from Bytes.
	 */
	public var url:String;
	
	/**
	 * Current instance of Sound object
	 */
	public var sound:VorbisSound;
	
	/**
	 * Current playback channel
	 */
	public var channel:VorbisSoundChannel;
	
	/**
	 * Dispatched when playback has completed
	 */
	public var soundCompleted:Signal;

	/**
	 * Allow multiple concurrent instances of this Sound. If false, only one instance of this sound will ever play.
	 */
	public var allowMultiple:Bool;
	
	/**
	 * Orphaned channels that are in the process of playing out. These will only exist when: allowMultiple = true
	 */
	public var oldChannels:Array<VorbisSoundChannel>;
	
	private var _pauseTime:Float;
	
	/**
	 * use to Infinitely Loop.
	 */
	public static inline var LOOP_MAX:Int = 2147483647;
	
	/**
	 * Float of times to loop this sound.
	 * 0 or 1 is no loop. (play Once)
	 * 2...X is play X times.
	 * -1 is infinitely loop.
	 */
	
	#if (swc || as3)
	@:extern public var loops:Int;
	#else
	public var loops(get, set):Int;
	#end
	
	private var _loops:Int;
	
	#if (swc || as3)
	@:getter(loops)
	#end
	function get_loops():Int {	return this._loops;	}
	#if (swc || as3)
	@:setter(loops)
	#end
	function set_loops( value:Int ):Int {
		var val:Int = value;
		if ( val < 0 ){	val = LOOP_MAX;	}
		if ( this.channel != null ){	this.channel.loop = val;	}
		return this._loops = value;
	}
	
	
	/**
	 * Loops remaining, this will auto-decrement each time the sound loops.
	 * It will equal 0 when the sound is completed, or not looping at all. 
	 * It will equal -1 if the sound is looping infinitely.
	 */
	#if (swc || as3)
	@:extern public var loopsRemaining:Int;
	#else
	public var loopsRemaining(get, never):Int;
	#end
	#if (swc || as3)
	@:getter(loopsRemaining)
	#end
	private function get_loopsRemaining():Int {
		if ( this.channel != null )
		{
			// is INFINITE LOOP?
			if ( channel.loop == LOOP_MAX ){	return -1;	}
			// return loops remaining.
			return (channel.loop - channel.currentLoop);
		}else{
			return 0;
		}
	}
	
	
	/**
	 * fade control property.
	 * if you want to check fade complete, use fade.ended signal.
	 */
	public var fade:VorbisTween;
	
	/**
	 * Mute current sound.
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
	private function get_mute():Bool {		return _mute;	}
	#if (swc || as3)
	@:setter(mute)
	#end
	private function set_mute(value:Bool):Bool {
		_mute = value;
		if(channel != null){
			channel.soundTransform = _mute? new SoundTransform(0) : soundTransform;
			updateOldChannels();
		}
		return _mute;
	}
	
	
	/**
	 * Indicates whether this sound is currently playing.
	 */
	#if (swc || as3)
	@:extern public var isPlaying:Bool;
	#else
	public var isPlaying(get, never):Bool;
	#end
	
	private var _isPlaying:Bool;
	#if (swc || as3)
	@:getter(isPlaying)
	#end
	private function get_isPlaying():Bool{	return this._isPlaying;	}
	
	/**
	 * Indicates whether this sound is currently paused.
	 */
	#if (swc || as3)
	@:extern public var isPaused:Bool;
	#else
	public var isPaused(get, never):Bool;
	#end
	
	#if (swc || as3)
	@:getter(isPaused)
	#end
	private function get_isPaused():Bool {
		return channel != null && sound != null && _pauseTime > 0 && _pauseTime < sound.length;
	}
	
	/**
	 * position of sound in milliseconds
	 * if set new value, restart channel.
	 */
	
	#if (swc || as3)
	@:extern public var position:Float;
	#else
	public var position(get, set):Float;
	#end
	
	#if (swc || as3)
	@:getter(position)
	#end
	private function get_position():Float { return (channel != null)? channel.position : 0; }
	#if (swc || as3)
	@:setter(position)
	#end
	private function set_position(value:Float):Float {
		if(channel != null){ 
			stopChannel(channel);
		}
		channel = sound.play(value, _loops);
		channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		//return channel.position;
		return value;
	}
	
	/**
	 * Value between 0 and 1. You can call this while muted to change volume, and it will not break the mute.
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
	private function get_volume():Float {	return _volume; }
	#if (swc || as3)
	@:setter(volume)
	#end
	private function set_volume(value:Float):Float {
		//Update the voume value, but respect the mute flag.
		if(value < 0){ value = 0; } else if(value > 1 || Math.isNaN(value)){ value = 1; }
		_volume = value;
		soundTransform.volume = mixedVolume;
		if(!_mute && channel != null){
			channel.soundTransform = soundTransform;
			updateOldChannels();
		}
		return _volume;
	}
	
	#if (swc || as3)
	@:extern public var masterVolume:Float;
	#else
	public var masterVolume(get, set):Float;
	#end
	
	#if (swc || as3)
	@:getter(masterVolume)
	#end
	private function get_masterVolume():Float { return manager.masterVolume; }
	
	/**
	 * Sets the master volume (the volume of the manager)
	 * Note : this will affect all sounds managed by the same manager
	 */
	#if (swc || as3)
	@:setter(masterVolume)
	#end
	private function set_masterVolume(value:Float):Float {
		return manager.masterVolume = value;
	}
	
	/**
	 * Combined masterVolume and volume levels
	 */
	#if (swc || as3)
	@:extern public var mixedVolume:Float;
	#else
	public var mixedVolume(get, never):Float;
	#end
	
	#if (swc || as3)
	@:getter(mixedVolume)
	#end
	private function get_mixedVolume():Float {
		return _volume * manager.masterVolume;
	}

	
	/**
	 * The left-to-right panning of the sound, ranging from -1 (full pan left) to 1 (full pan right).
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
	private function get_pan():Float {	return this._pan; }
	#if (swc || as3)
	@:setter(pan)
	#end
	private function set_pan(value:Float):Float 
	{
		//Update the voume value, but respect the mute flag.
		if ( Math.isNaN(_volume) ) value = 0;
		if (value < -1){ value = -1; } else if (value > 1){ value = 1; }
		_pan = soundTransform.pan = value;
		if(!_mute && channel != null){
			channel.soundTransform = soundTransform;
			updateOldChannels();
		}
		return _pan;
	}
	

	#if (swc || as3)
	@:extern public var soundTransform:SoundTransform;
	#else
	public var soundTransform(get, set):SoundTransform;
	#end
	
	private var _soundTransform:SoundTransform;
	
	#if (swc || as3)
	@:getter(soundTransform)
	#end
	private function get_soundTransform():SoundTransform {
		//if( _soundTransform == null ){ _soundTransform = new SoundTransform(mixedVolume, _pan); }
		return _soundTransform;
	}
	
	#if (swc || as3)
	@:setter(soundTransform)
	#end
	private function set_soundTransform(value:SoundTransform):SoundTransform 
	{
		if(value.volume > 0){ _mute = false; } 
		else if(value.volume == 0){ _mute = true; }
		channel.soundTransform = value;
		updateOldChannels();
		return channel.soundTransform;
	}
	
	//----------------------------------------
	
	/**
	 * initialize.
	 * @param	sound	VorbisSound.
	 * @param	type	Specified name for this Sound
	 */
	public function new(?sound:VorbisSound, ?type:String)	{
		this.sound = sound;
		this.type = type;
		manager = VorbisAS.manager;
		_pauseTime = 0;
		_volume = 1;	
		_pan = 0;
		_soundTransform = new SoundTransform();
		soundCompleted = new Signal(VorbisInstance);
		oldChannels = new Array<VorbisSoundChannel>();
		fade = new VorbisTween(this, 1, 1000);
	}
	
	/**
	 * Play this Sound. 
	 * @param volume	volume of sound.
	 * @param startTime Start position in milliseconds
	 * @param loops Number of times to loop Sound. Pass -1 to loop forever.
	 * @param allowMultiple Allow multiple concurrent instances of this Sound
	 */
	public function play(volume:Float = 1, startTime:Float = 0, loops:Int = 0, allowMultiple:Bool = true):VorbisInstance
	{
		this.loops = loops;
		
		//If loops == -1, switch it to loop infinitely
		var setLoopValue:Int = (loops < 0)? LOOP_MAX : loops;
		
		this.allowMultiple = allowMultiple;
		if(allowMultiple){
			//Store old channel, so we can still stop it if requested.
			if(channel != null){
				oldChannels.push(channel);
			}
			channel = sound.play(startTime, setLoopValue);
		} else {
			if(channel != null){ 
				stopChannel(channel);
			}
			channel = sound.play(startTime, setLoopValue);
		}
		if(channel != null){ 				
			channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_isPlaying = true;
		}
		_pauseTime = 0; //Always reset pause time on play
		
		this.volume = volume;
		this.mute = this._mute; // call getter
		return this;
	}
	
	/**
	 * Pause currently playing sound. Use resume() to continue playback. Pause / resume is supported for single sounds only.
	 */
	public function pause():VorbisInstance {
		if(channel == null){ return this; }
		_isPlaying = false;
		_pauseTime = channel.position;
		stopChannel(channel);
		stopOldChannels();
		return this;
	}

	/**
	 * Resume from previously paused time. Optionally start over if it's not paused.
	 */
	public function resume(forceStart:Bool = false):VorbisInstance {
		if(isPaused || forceStart){
			play(_volume, _pauseTime, _loops, allowMultiple);
		} 
		return this;
	}
	
	/**
	 * Stop the currently playing sound and set it's position to 0
	 */
	public function stop():VorbisInstance {
		_pauseTime = 0;
		stopChannel(channel);
		channel = null;
		stopOldChannels();
		_isPlaying = false;
		return this;
	}
	
	
	/**
	 * Fade using the current volume as the Start Volume
	 */
	public function fadeTo(endVolume:Float, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance {
		manager.addTween(type, -1, endVolume, duration, stopAtZero);
		return this;
	}
	
	/**
	 * Fade and specify both the Start Volume and End Volume.
	 */
	public function fadeFrom(startVolume:Float, endVolume:Float, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance {
		manager.addTween(type, startVolume, endVolume, duration, stopAtZero);
		return this;
	}

	/**
	 * Create a duplicate of this SoundInstance
	 */
	public function clone():VorbisInstance {
		var si:VorbisInstance = new VorbisInstance(sound, type);
		return si;
	}
	
	/**
	 * Unload sound from memory.
	 */
	public function destroy():Void {
		fade.kill();
		fade = null;
		stopChannel(channel);
		channel = null;
		soundCompleted.removeAll();
		try{
			sound.close();
		}catch(e:Error){}
		sound = null;
		_soundTransform = null;
	}
	
	/**
	 * Dispatched when Sound has finished playback
	 */
	private function onSoundComplete(event:Event):Void {
		var channel:SoundChannel = cast (event.target, SoundChannel);
		channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		
		if ( this.channel != null ){
			if(channel == this.channel.channel){ 
				this.channel = null;
				_pauseTime = 0;
				_isPlaying = false;
			}
		}
		
		//Clear out any old channels...
		var idx:Int = oldChannels.length -1;
		var ch:VorbisSoundChannel;
		while ( 0 <= idx ){
			ch = oldChannels[idx];
			if ( ch.channel == channel ){
				stopChannel( ch );
				oldChannels.splice( idx, 1);
				break;
			}
			idx--;
		}
		
		// dispatch signal
		soundCompleted.dispatch(this);
	}

	/**
	 * Stop the currently playing channel.
	 */
	private function stopChannel(channel:VorbisSoundChannel):Void {
		if(channel == null){ return; }
		channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		try {
			channel.stop(); 
		} catch(e:Error){};
	}
	
	/**
	 * Kill all orphaned channels
	 */
	private function stopOldChannels():Void {
		if( Lambda.empty(oldChannels) ){ return; }
		for ( ch in oldChannels ){
			stopChannel(ch);
		}
		oldChannels.splice(0, oldChannels.length);
	}
	
	/**
	 * Keep orphaned channels in sync with current volume
	 */
	private function updateOldChannels():Void {
		if(channel == null){ return; }
		for ( ch in oldChannels ){
			ch.soundTransform = channel.soundTransform;
		}
	}
	
}