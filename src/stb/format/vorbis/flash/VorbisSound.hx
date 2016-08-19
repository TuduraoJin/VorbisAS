package stb.format.vorbis.flash;

import flash.errors.ArgumentError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import stb.format.vorbis.Reader;

/**
 * VorbisSound can loading Vorbis file and create VorbisSoundChannel instance.
 * 
 * @author Tudurao Jin
 */
class VorbisSound implements IEventDispatcher{
    private var _rootReader:Reader;
	private var _us:URLStream;
	private var _ed:EventDispatcher;
	
	/**
	 * sound playback length (Millisecond)
	 */
    public var length(default, null):Float;
	
	/**
	 * loading URL. if loading from Bytes, value is null.
	 */
	public var url(default,null):String;
	
	/**
	 * @param	url(String) external OggVorbis file URL.  
	 * When pass the arguments, automaticaly start loading file.    
	 * it does not load when Void or null.
	 */
    public function new( ?url:String ) 
	{
		this.url = url;
		this.length = 0;
		this._us = new URLStream();
		this._ed = new EventDispatcher(this);
		
		if ( url != null ){	load( url );	}
	}
	
	/**
	 * play sound.
	 * create VorbisSoundChannel instance.
	 * @param	startMillisecond  start play position. default is 0.
	 * @param	loops  loop count. default is 0. (no loop)
	 * @param	sndTransform  If you want to set volume, pan, etc... when creating instance, pass SoundTransform. default is null. 
	 * @return	VorbisSoundChannel	if don't have loaded data, return null.
	 */
    public function play(startMillisecond:Float = 0, loops:Int = 0, ?sndTransform:SoundTransform):VorbisSoundChannel {
		if (_rootReader == null) return null;
		
        var sound = new Sound();
        var reader = _rootReader.clone();
        var startSample = reader.millisecondToSample(startMillisecond);
        //var loopStart = startSample;  // segment loop.
        var loopStart = 0;  // always looping start is position 0.
        var loopEnd = _rootReader.totalSample;

        if (_rootReader.loopStart != null) {
            loopStart = _rootReader.loopStart;
            if (_rootReader.loopLength != null) {
                loopEnd = _rootReader.loopStart + _rootReader.loopLength;
            }
        }
        return VorbisSoundChannel.play(sound, reader, startSample, loops, loopStart, loopEnd, sndTransform);
    }

	
	/**
	 * load from already loaded OggVorbis bytes.
	 * If you use any other file loader. use this function.
	 * this function don't dispatch complete event.
	 * because It initialize at once.
	 * @param	bytes OggVorbis binary. 
	 */
	public function loadFromBytes( bytes:Bytes ):Void{
        _rootReader = Reader.openFromBytes(bytes);
        length = _rootReader.totalMillisecond;
	}
	
	/**
	 * load from URL.
	 * dispatch event Event.COMPLETE when loading completed 
	 * 
	 * @param	url OggVorbis file URL.
	 * 
	 * @eventType	Event.COMPLETE	loading completed.  
	 * 
	 * @eventType	ProgressEvent.PROGRESS	loading processing.  
	 * 
	 * @eventType	IOErrorEvent.IO_ERROR	loading failed.  
	 * 
	 * @throws	ArgumentError	url is null.
	 */
	public function load( url:String ):Void
	{
		this.url = url;
		if ( url == null ){	
			throw new ArgumentError("[VorbisSound] load() url is null.");
			return;
		}
		_us.addEventListener( Event.COMPLETE , onComplete );
		_us.addEventListener( ProgressEvent.PROGRESS , onProgress );
		_us.addEventListener( IOErrorEvent.IO_ERROR , onIOError );
		_us.load( new URLRequest( url ) );
	}
	
	/**
	 * close loading stream and dispose already loaded data.
	 * if you want to cancel when loading. use this function.
	 */
	public function close():Void{
		_us.removeEventListener( Event.COMPLETE , onComplete );
		_us.removeEventListener( ProgressEvent.PROGRESS , onProgress );
		_us.removeEventListener( IOErrorEvent.IO_ERROR , onIOError );
		this.length = 0;
		this._rootReader = null;
		_us.close();
	}
	
	/**
	 * Loading complete handler.
	 */
	private function onComplete(e:Event):Void 
	{
		_us.removeEventListener( Event.COMPLETE , onComplete );
		_us.removeEventListener( ProgressEvent.PROGRESS , onProgress );
		_us.removeEventListener( IOErrorEvent.IO_ERROR , onIOError );
		
		var ba:ByteArray = new ByteArray();
		_us.readBytes( ba );
		loadFromBytes( Bytes.ofData( ba ) );
		dispatchEvent(e);
	}
	
	private function onProgress(e:ProgressEvent):Void { 	dispatchEvent(e);	}
	private function onIOError(e:IOErrorEvent):Void {	dispatchEvent(e);	}
	
	/* INTERFACE flash.events.IEventDispatcher */
	
	public function addEventListener(type:String, listener:Dynamic-> Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void 
	{
		_ed.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
	
	public function dispatchEvent(event:Event):Bool 
	{
		return _ed.dispatchEvent(event);
	}
	
	public function hasEventListener(type:String):Bool 
	{
		return _ed.hasEventListener(type);
	}
	
	public function removeEventListener(type:String, listener:Dynamic-> Void, useCapture:Bool = false):Void 
	{
		_ed.removeEventListener(type, listener, useCapture);
	}
	
	public function willTrigger(type:String):Bool 
	{
		return _ed.willTrigger(type);
	}

}
