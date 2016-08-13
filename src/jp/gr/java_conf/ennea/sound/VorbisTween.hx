package jp.gr.java_conf.ennea.sound;

import flash.Lib.getTimer;
import org.osflash.signals.Signal;

/**
 * VorbisTween can Fade control...
 * 
 * @author Tudurao Jin
 */
class VorbisTween
{
	public var startTime:Int;
	public var startVolume:Float;
	public var endVolume:Float;
	public var duration:Float;
	public var sound:VorbisInstance;
	
	public var isComplete(default,null):Bool;
	private var _isMasterFade:Bool;
	
	public var ended:Signal;
	public var stopAtZero:Bool;
	
	public function new(si:VorbisInstance, endVolume:Float, duration:Float, isMasterFade:Bool = false) {
		if(si != null){
			sound = si;
			startVolume = sound.volume;
		}
		
		ended = new Signal(VorbisInstance);
		this._isMasterFade = isMasterFade;
		init(startVolume, endVolume, duration);
	}
	
	public function init(startVolume:Float, endVolume:Float, duration:Float):Void {
		this.startTime = getTimer();
		this.startVolume = startVolume;
		this.endVolume = endVolume;
		this.duration = duration;
		isComplete = false;
	}
	
	/**
	 * update of time processing.
	 * @param	t
	 * @return	true when fade is completed.
	 */
	public function update(t:Int):Bool {
		if (isComplete){ return isComplete; }
		
		if (_isMasterFade){
			if (t - startTime < duration){
				VorbisAS.masterVolume = easeOutQuad(t - startTime, startVolume, endVolume - startVolume, duration);
			}else{
				VorbisAS.masterVolume = endVolume;
			}
			isComplete = VorbisAS.masterVolume == endVolume;
		} else {
			if (t - startTime < duration){
				sound.volume = easeOutQuad(t - startTime, startVolume, endVolume - startVolume, duration);
			}else{
				sound.volume = endVolume;
			}
			isComplete = sound.volume == endVolume;
		}
		
		return isComplete;
	}
	
	/** 
	 * End the fade and dispatch ended signal. Optionally, apply the end volume as well. 
	 */
	public function end(applyEndVolume:Bool = false):Void
	{
		isComplete = true;
		if (!_isMasterFade){
			if (applyEndVolume){
				sound.volume = endVolume;
			}
			if (stopAtZero && sound.volume == 0){
				sound.stop();
			}
		}
		ended.dispatch(this.sound);
		ended.removeAll();
	}
	
	/**
	 * End the fade silently, will not send 'ended' signal
	 */
	public function kill():Void {
		isComplete = true;
		ended.removeAll();
	}
	
	/**
	 * Equations from the man Robert Penner, see here for more:
	 * http://www.dzone.com/snippets/robert-penner-easing-equations
	 */
	private static function easeOutQuad(position:Float, startValue:Float, change:Float, duration:Float):Float 
	{
		return -change *(position/=duration)*(position-2) + startValue;
	};
	
	private static function easeInOutQuad(position:Float, startValue:Float, change:Float, duration:Float):Float {
		if ((position/=duration/2) < 1){
			return change/2*position*position + startValue;
		}
		return -change/2 * ((--position)*(position-2) - 1) + startValue;
	}
	
}