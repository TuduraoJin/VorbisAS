package stb.format.vorbis.flash;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import haxe.io.BytesOutput;
import stb.format.vorbis.VorbisDecoder;

/**
 * VorbisSoundChannel is control audio playback and SoundTransform.
 * instance create by VorbisSound.
 * 
 * @author Tudurao Jin
 */
class VorbisSoundChannel implements IEventDispatcher {
	
	/**
	 * flash.media.SoundChannel instance.
	 */
    public var channel(default, null):SoundChannel;
	
	#if (swc || as3)
    @:extern public var leftPeak:Float;
	#else
    public var leftPeak(get, never):Float;
	#end
	
    #if (swc || as3)
	@:getter(leftPeak)
	#end
	function get_leftPeak():Float {
        return channel.leftPeak;
    }

	/**
	 * playing position (MilliSecond)
	 */
	#if (swc || as3)
    @:extern public var position:Float;
	#else
    public var position(get, never):Float;
	#end
    #if (swc || as3)
	@:getter(position)
	#end
    function get_position():Float {
        //return reader.currentMillisecond;	// return Illegal value( about Actual time + 500ms). in my case.
        return channel.position;
    }

    public var rightPeak(get, never):Float;
    #if (swc || as3)
	@:getter(rightPeak)
	#end
    function get_rightPeak():Float {
        return channel.rightPeak;
    }

	/**
	 * SoundTransform. access to volume and pan.
	 */
    #if (swc || as3)
	@:extern public var soundTransform:SoundTransform;
	#else
    public var soundTransform(get, set):SoundTransform;
	#end
	
    #if (swc || as3)
	@:getter(soundTransform)
	#end
    function get_soundTransform():SoundTransform {
        return channel.soundTransform;
    }
    #if (swc || as3)
	@:setter(soundTransform)
	#end
    function set_soundTransform(value:SoundTransform):SoundTransform {
        return channel.soundTransform = value;
    }
	
	/**
	 * current loop count. value change to loop - 1 from 0.
	 */
    public var currentLoop(default, null):Int;
	
	/**
	 * Specified loop count.
	 */
    public var loop:Int;

	/**
	 * OggVorbis decoder.
	 */
    private var _reader:Reader;
    private var _loopReader:Reader;
    private var _loopEnd:Int;

	/**
	 * initialize.
	 * @param	reader
	 * @param	startSample
	 * @param	loop
	 * @param	loopStartSample
	 * @param	loopEndSample
	 */
    function new (reader:Reader, startSample:Int, loop:Int, loopStartSample:Int, loopEndSample:Int) {
        this._reader = reader;
        this.loop = loop;
        this._loopEnd = loopEndSample;

        currentLoop = 0;
        reader.currentSample = startSample;

        if (loop > 1) {
            _loopReader = reader.clone();
            _loopReader.currentSample = loopStartSample;
        }
    }

	/**
	 * play sound.
	 * this static function create new instance.
	 * @param	sound	use SampleDataEvent.SAMPLE_DATA event instanse.
	 * @param	reader	OggVorbis decoder.
	 * @param	startSample	start sample in Reader.
	 * @param	loop	Specified loop count.
	 * @param	loopStartSample	start position when loop.
	 * @param	loopEndSample
	 * @param	soundTransform
	 */
    static public function play(sound:Sound, reader:Reader, startSample:Int, loop:Int, loopStartSample:Int, loopEndSample:Int, ?soundTransform:SoundTransform) {
        var vorbisChannel = new VorbisSoundChannel(
            reader,
            startSample,
            loop,
            loopStartSample,
            loopEndSample
        );

        sound.addEventListener(SampleDataEvent.SAMPLE_DATA, vorbisChannel.onSampleData);
        var channel = sound.play(reader.sampleToMillisecond(startSample), loop, soundTransform);
        if (channel == null) {
            return null;
        } else {
            vorbisChannel.channel = channel;
            return vorbisChannel;
        }
    }
	
	/**
	 * stop sound.
	 */
    public function stop():Void {
        channel.stop();
    }
	
	/**
	 * SampleDataEvent handler.
	 * decoding data pass to sampling event.
	 * @param	event
	 */
    function onSampleData(event:SampleDataEvent):Void {
        var output:BytesOutput = new BytesOutput();
        untyped output.b = event.data;
		
        var n = 0;
        for (i in 0...8192) {
            var k = 8192 - n;
            if (k > _loopEnd - _reader.currentSample) {
                k = _loopEnd - _reader.currentSample;
            }
            if (k < 1){
                k = 1;
            }
            n += _reader.read(output, k, 2, 44100, true);
            if (n < 8192) {
                if (currentLoop < loop - 1) {
                    currentLoop++;
                    _reader = _loopReader.clone();
                } else {
                    break;
                }
            } else {
                break;
            }
        }
    }

    // EventListener
    public function addEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void
    {
        channel.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    public function removeEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false):Void
    {
        channel.removeEventListener(type, listener, useCapture);
    }

    public function dispatchEvent(event:Event):Bool
    {
        return channel.dispatchEvent(event);
    }

    public function hasEventListener(type:String):Bool
    {
        return channel.hasEventListener(type);
    }

    public function willTrigger(type:String):Bool
    {
        return channel.willTrigger(type);
    }
}
