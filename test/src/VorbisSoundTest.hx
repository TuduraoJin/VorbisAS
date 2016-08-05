package ;
import flash.Lib;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import haxe.Timer;
import haxe.io.Bytes;
import stb.format.vorbis.flash.VorbisSound;
import stb.format.vorbis.flash.VorbisSoundChannel;

/**
 * ...
 * @author tj
 */
class VorbisSoundTest
{

	private static inline var FILE_PATH:String = "../test/assets/";
	private static inline var SOUND_LOOP:String = "Loop.ogg";
	private static inline var SOUND_MUSIC:String = "Music.ogg";

	private var vs:VorbisSound;
	
	public function new() 
	{
	}
	
	// main
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// Entry point
		
		var vsTest:VorbisSoundTest = new VorbisSoundTest();
		vsTest.test();
	}
	
	public function test():Void
	{
		// VorbisSound test
		
		// load from url
		vs = new VorbisSound();
		vs.addEventListener( Event.COMPLETE, onComp );
		vs.addEventListener( ProgressEvent.PROGRESS, onProgress );
		vs.addEventListener( IOErrorEvent.IO_ERROR , onIOError );
		vs.load( FILE_PATH + SOUND_LOOP );
		trace( "sound load start");
	}
	
	private function onIOError(e:IOErrorEvent):Void 
	{
		trace(e);
	}
	
	private function onProgress(e:ProgressEvent):Void 
	{
		trace(e.bytesLoaded," / ",e.bytesTotal);
	}
	
	private function onComp(e:Event):Void 
	{
		trace( "sound complete ");
		
		// play
		var vch:VorbisSoundChannel = vs.play();
		trace( "play " + SOUND_LOOP );
		Timer.delay( function():Void{
			/// channel test
			// position
			trace( " channel position=" + vch.position );
			
			// volume , pan 
			var st:SoundTransform = vch.soundTransform;
			st.volume = 0.5;
			st.pan = 1;
			vch.soundTransform = st;
			
			trace( " change volume =" , vch.soundTransform.volume );
			trace( " change pan =" , vch.soundTransform.pan);
			
		}, 2000);
		
		Timer.delay( function():Void{
			// stop	
			vch.stop();
			trace( "stop" );
		}, 4000);
		
		// ------------------------------
		
		// load from byte test
		Timer.delay( function():Void{
			var us:URLStream = new URLStream();
			
			us.addEventListener(Event.COMPLETE, function (e:Event):Void{
				trace( "loading complete. loadFromBytes()");
				var ba:ByteArray = new ByteArray();
				us.readBytes(ba);
				var vsound:VorbisSound = new VorbisSound();
				vsound.loadFromBytes( Bytes.ofData( ba ) );
				
				//play
				vch = vsound.play();
				trace( "play " + SOUND_MUSIC );
				
				Timer.delay( function():Void{
					vch.stop();
					trace( "stop" );
					trace( "end test..." );
				}, 3000);
			});
			
			trace( "loading...");
			us.load( new URLRequest( FILE_PATH + SOUND_MUSIC ) );
		}, 5000);
		
	}
}