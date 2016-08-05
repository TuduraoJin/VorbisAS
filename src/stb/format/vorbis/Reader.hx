package stb.format.vorbis;

import haxe.io.BytesOutput;
import haxe.io.Output;
import haxe.io.StringInput;
import stb.format.tools.Mdct;
import stb.format.vorbis.data.Floor;
import stb.format.vorbis.data.Mapping;
import stb.format.vorbis.data.Mode;
import stb.format.vorbis.data.Header;
import stb.format.vorbis.VorbisDecodeState;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Eof;
import haxe.io.Input;
import haxe.PosInfos;

#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;
#end

/**
 * public domain ogg reader.
 * @author shohei909
 */
class Reader {
    public var decoder(default, null):VorbisDecoder;

    public var header(get, never):Header;
    function get_header():Header {
        return decoder.header;
    }

    public var totalSample(get, never):Int;
    function get_totalSample():Int {
        return decoder.totalSample;
    }

    public var totalMillisecond(get, never):Float;

    function get_totalMillisecond():Float {
        return sampleToMillisecond(decoder.totalSample);
    }

    public var currentSample(get, set):Int;
    function get_currentSample():Int {
        return decoder.currentSample;
    }

    function set_currentSample(value:Int):Int {
        decoder.seek(seekFunc, inputLength, value);
        return decoder.currentSample;
    }

    public var currentMillisecond(get, set):Float;

    function get_currentMillisecond():Float
    {
        return sampleToMillisecond(currentSample);
    }

    function set_currentMillisecond(value:Float):Float {
        currentSample = millisecondToSample(value);
        return currentMillisecond;
    }

    public var loopStart:Null<Int>;
    public var loopLength:Null<Int>;

    var seekFunc:Int->Void;
    var inputLength:Int;

    function new (input:Input, seekFunc:Int->Void, inputLength:Int) {
        this.seekFunc = seekFunc;
        this.inputLength = inputLength;
        decoder = VorbisDecoder.start(input);
        decoder.setupSampleNumber(seekFunc, inputLength);
        loopStart = header.comment.loopStart;
        loopLength = header.comment.loopLength;
    }

    public static function openFromBytes(bytes:Bytes) {
        var input = new BytesInput(bytes);
        return new Reader(input, seekBytes.bind(input), bytes.length);
    }

    static function seekBytes(bytes:BytesInput, pos:Int) {
        bytes.position = pos;
    }

    #if sys
    public static function openFromFile(fileName:String):Reader {
        var file = File.read(fileName, true);
        var stat = FileSystem.stat(fileName);
        return new Reader(file, file.seek.bind(_, SeekBegin), stat.size);
    }
    #end

    public static function readAll(input:Input, output:Output, useFloat:Bool = false):Header {
        var decoder = VorbisDecoder.start(input);
        var header = decoder.header;
        var count = 0;
        while (true) {
            var n = decoder.read(output, 65536, header.channel, header.sampleRate, useFloat);
            if (n == 0) { break; }
            count += n;
        }
        return decoder.header;
    }

    public function read(output:Output, ?samples:Int, ?channels:Int, ?sampleRate:Int, useFloat:Bool = false) {
        decoder.ensurePosition(seekFunc);

        if (samples == null) {
            samples = decoder.totalSample;
        }
        if (channels == null) {
            channels = header.channel;
        }
        if (sampleRate == null) {
            sampleRate = header.sampleRate;
        }
        return decoder.read(output, samples, channels, sampleRate, useFloat);
    }

    public function clone():Reader {
        var reader = Type.createEmptyInstance(Reader);
        reader.seekFunc = seekFunc;
        reader.inputLength = inputLength;
        reader.decoder = decoder.clone(seekFunc);
        reader.loopStart = loopStart;
        reader.loopLength = loopLength;
        return reader;
    }


    public inline function sampleToMillisecond(samples:Int) {
        return samples / header.sampleRate * 1000;
    }

    public inline function millisecondToSample(millseconds:Float) {
        return Math.floor(millseconds / 1000 * header.sampleRate);
    }
}

private typedef InitData = {
    input:Input,
    seekFunc:Int->Void,
    inputLength:Int,
}
