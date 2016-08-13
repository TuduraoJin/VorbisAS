package ;
import flash.Lib;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.errors.Error;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.Lib.getTimer;
import haxe.Timer;
import jp.gr.java_conf.ennea.sound.VorbisAS;
import jp.gr.java_conf.ennea.sound.VorbisInstance;
import jp.gr.java_conf.ennea.sound.VorbisManager;

/**
 * ...
 * @author tj
 */
class VorbisASTest extends Sprite
{
	// assets
	public static inline var ASSETS_PATH:String = "../test/assets/";
	public static inline var FILE_CLICK:String = "Click.ogg";
	public static inline var FILE_LOOP:String = "Loop.ogg";
	public static inline var FILE_MUSIC:String = "Music.ogg";
	public static inline var FILE_SOLO1:String = "Solo1.ogg";
	public static inline var FILE_SOLO2:String = "Solo2.ogg";
	
	// main
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// Entry point
		
		var asTest:VorbisASTest = new VorbisASTest();
		stage.addChild(asTest);
	}
	
	public function new() 
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	
	private function init(e:Event):Void
	{
		trace("init");
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		
		// initialize VorbisAS
		VorbisAS.initialize();
		
		//Load sound from an external file
		VorbisAS.loadSound(ASSETS_PATH + FILE_CLICK, FILE_CLICK);
		VorbisAS.loadSound(ASSETS_PATH + FILE_MUSIC, FILE_MUSIC);
		VorbisAS.loadSound(ASSETS_PATH + FILE_LOOP,  FILE_LOOP);
		VorbisAS.loadSound(ASSETS_PATH + FILE_SOLO1, FILE_SOLO1);
		VorbisAS.loadSound(ASSETS_PATH + FILE_SOLO2, FILE_SOLO2);
		
		var file_count:Int = 5;
		VorbisAS.loadCompleted.add( function( si:VorbisInstance ):Void{
			trace(" sound loaded. url=" + si.url);
			if ( --file_count <= 0 ){
				// setup keyboard input
				this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				
				// setup mouse input
				// click = SE multiple test
				this.stage.addEventListener(MouseEvent.CLICK, 
					function(e:MouseEvent){
						var click:VorbisInstance = VorbisAS.playFx( FILE_SOLO1 ,mvolume );
						trace("Click.oldChannels.length = " + click.oldChannels.length);
					}
				);
				
				trace( "test setup complete");
				trace( "---------------------------");
				trace( "please click stage or press any key to test.");
				trace( "key [1] Play / Stop Test.");
				trace( "key [2] Pause / Resume Test.");
				trace( "key [3] Fade Test.");
				trace( "key [4] MultiChannelMute Test.");
				trace( "key [5] SeamlessLoop Test.");
				trace( "key [6] Group Test.");
				trace( "key [7] Sound Mssing Test.");
				trace( "key [8] some property Test.");
				trace( "key [9] loop Test.");
				trace( "---------------------------");
				
				trace( FILE_CLICK , "length", VorbisAS.getSound(FILE_CLICK).sound.length);
				trace( FILE_MUSIC , "length", VorbisAS.getSound(FILE_MUSIC).sound.length);
				trace( FILE_LOOP , "length", VorbisAS.getSound(FILE_LOOP).sound.length);
				trace( FILE_SOLO1 , "length", VorbisAS.getSound(FILE_SOLO1).sound.length);
				trace( FILE_SOLO2 , "length", VorbisAS.getSound(FILE_SOLO2).sound.length);
				
			}
		});
		
	}
	
	public var mvolume:Float = 1.0;
	
	// process keyboard input
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		trace("key down " + e.keyCode );
		
		switch(e.keyCode){
			case Keyboard.NUMBER_1:	testPlayStop();
			case Keyboard.NUMBER_2:	testPauseResume();
			case Keyboard.NUMBER_3:	testFade();
			case Keyboard.NUMBER_4:	testMultiChannelMute();
			case Keyboard.NUMBER_5:	testSeamlessLoop();
			case Keyboard.NUMBER_6:	testGroups();
			case Keyboard.NUMBER_7:	testSoundMissingError();
			case Keyboard.NUMBER_8:	testIsPlayed();
			case Keyboard.NUMBER_9:	testLoopRemainng();
			
			case Keyboard.T:	performanceFade();
			
			case Keyboard.Z:	mvolume += 0.1;
				if (mvolume < 0) mvolume = 0;
				else if ( mvolume > 1 ) mvolume = 1;
				VorbisAS.masterVolume = mvolume;
				trace("UP mastervolume=" + mvolume);
			case Keyboard.X:	mvolume -= 0.1;
				if (mvolume < 0) mvolume = 0;
				else if ( mvolume > 1 ) mvolume = 1;
				VorbisAS.masterVolume = mvolume;
				trace("DOWN mastervolume=" + mvolume);
			default:
		}
	}
	
	private function testPlayStop():Void
	{
		trace("Testing PLAY: Play / Stop / PlayMultiple / StopMultiple");
		// play
		VorbisAS.playLoop( FILE_MUSIC  );
		trace("play "," isPlaying:", VorbisAS.getSound(FILE_MUSIC).isPlaying);
		
		// stop
		Timer.delay( function():Void{
				VorbisAS.getSound(FILE_MUSIC).stop();
				trace("stop ", " isPlaying:", VorbisAS.getSound(FILE_MUSIC).isPlaying);
				},
			3000);
		
		// play multiple
		Timer.delay( function():Void{
				trace("playMultiple");
				VorbisAS.playFx( FILE_SOLO1 );
				VorbisAS.playFx( FILE_SOLO2 );
				},
			4000);
		
		// stopAll
		Timer.delay( function():Void{
				trace("stopAll");
				VorbisAS.stopAll();
				},
			5500);
	}
	
	private function testPauseResume():Void
	{
		trace("PAUSE: Pause / Resume, soundcomplete -> PauseAll / ResumeAll");
		//play
		VorbisAS.playFx(FILE_MUSIC, 60000);
		
		// pause
		Timer.delay( function():Void{
				trace("pause");
				VorbisAS.pause(FILE_MUSIC);
				},
			2000);
		
		// resume -> pauseAll -> resumeAll
		Timer.delay(
			function():Void{
				trace("resume and waiting playComplete.");
				VorbisAS.resume(FILE_MUSIC).soundCompleted.addOnce(
					function( si:VorbisInstance ):Void{
						VorbisAS.playFx(FILE_SOLO1,1,0,3);
						VorbisAS.playFx(FILE_SOLO2,1,0,3);
						Timer.delay( function():Void{
							VorbisAS.pauseAll();
							trace("pauseAll");
						}, 1500);
						
						Timer.delay( function():Void{
							VorbisAS.resumeAll();
							trace("resumeAll");
						}, 2000);
					}
				);
			},
		3000);
	}
	
	
	private function testFade():Void
	{
		trace("FADES: fade, fadeMultiple, fadeMaster");
		// fade in
		VorbisAS.playLoop(FILE_MUSIC);
		VorbisAS.fadeFrom(FILE_MUSIC, 0, 1);
		trace("fadeIn 0 -> 1");
		
		// fade out
		Timer.delay( function():Void{
			VorbisAS.fadeTo(FILE_MUSIC, 0);
			trace("fadeOut 1 -> 0");
			},
		3000);
		
		// fadeAllfrom
		Timer.delay( function():Void{
			VorbisAS.playLoop(FILE_MUSIC,0);
			VorbisAS.playFx(FILE_SOLO1,0);
			VorbisAS.playFx(FILE_SOLO2,0);
			VorbisAS.fadeAllFrom(0, 1, 1000);
			trace("fadeAllFrom 3 sounds volume 0 -> 1");
		}, 5000);
		
		
		Timer.delay( function():Void{
			VorbisAS.fadeAllTo(0, 1000);
			trace("fadeAllTo 3 sounds volume  -> 0");
		}, 7000);
		
		Timer.delay( function():Void{
			VorbisAS.play(FILE_MUSIC);
			VorbisAS.fadeMasterFrom(0);
			trace("fadeMasterFrom 0 -> 1");
		}, 8500);
		
		
		Timer.delay( function():Void{
			VorbisAS.fadeMasterTo(0);
			trace("fadeMasterTo 1 -> 0");
		}, 10500);
		
		Timer.delay( function():Void{
			VorbisAS.masterVolume = mvolume;
			VorbisAS.stopAll();
		}, 12000);
		
	}
	
	private function testMultiChannelMute():Void
	{
		trace("MULITPLE CHANNELS: play 3 music + 1 solo loop, muteAll, unmuteAll, 20% volumeAll, stopAll");
		VorbisAS.playFx(FILE_MUSIC, .5, 0,100);
		VorbisAS.playFx(FILE_MUSIC, .5, 2000,100);
		VorbisAS.playFx(FILE_MUSIC, .5, 4000,100);
		VorbisAS.playLoop(FILE_SOLO1);
		
		Timer.delay( function():Void{
			trace("mute");
			VorbisAS.mute = true;
		}, 2000);
		
		
		Timer.delay( function():Void{
			trace("un-mute");
			VorbisAS.mute = false;
		}, 3000);
		
		Timer.delay( function():Void{
			trace("volume=.2");
			VorbisAS.volume = .2;
		}, 4000);

		Timer.delay( function():Void{
			trace("stopAll");
			VorbisAS.stopAll();
		}, 6000);
	}
	
	private var loopCount:Int = 0;
	private var solo:VorbisInstance;
	
	private function testSeamlessLoop():Void
	{
		trace("LOOPING: Loop solo 2 times, pause halfway each time. Shows workaround for the 'loop bug': http://www.stevensacks.net/2008/08/07/as3-sound-channel-bug/ ");
		loopCount = 0;
		if ( solo != null ){	solo.stop();	}
		
		solo = VorbisAS.play(FILE_SOLO1, 1, 0, 0);
		solo.soundCompleted.add(playPause);
		playPause(solo);
	}
	
	function playPause(si:VorbisInstance):Void
	{
		if(++loopCount == 3){ 
			trace("INFINITE LOOP: 5 seconds of repeating Clicks");
			var startTime:Int = getTimer();
			var click:VorbisInstance = VorbisAS.play(FILE_CLICK, 1, 0, -1, false, false);
			Timer.delay( function():Void{
				trace("stop Clicks");
				click.stop();
				click.soundCompleted.removeAll();
				solo.soundCompleted.removeAll();
			}, 5000);
		} 
		else {
			VorbisAS.play(FILE_SOLO1, 1, 0, 0);
			Timer.delay( function():Void{
				solo.pause();
				trace("pause");
			}, 500);
			Timer.delay( function():Void{
				solo.resume();
				trace("resume");
			}, 1000);
		}
	}
	
	
	private function testGroups():Void
	{
		trace("GROUPS: MUSIC and SOLOS. Pause solos. Resume solos. FadeOut music, FadeIn music. Set volume music. Mute solos. unMute solos. ");
		
		// setup group manager
		var music:VorbisManager = VorbisAS.group("music");
		var solos:VorbisManager = VorbisAS.group("solos");
		
		// play sound
		music.playLoop(FILE_MUSIC);
		
		solos.playLoop(FILE_SOLO1);
		solos.playLoop(FILE_SOLO2);
		
		// pause solos after 1000ms
		Timer.delay( function():Void{
			trace("pause solos");
			solos.pauseAll();
		}, 1000);
		
		// resume solos after 2000ms
		Timer.delay( function():Void{
			trace("resume solos");
			solos.resumeAll();
		}, 2000);
		
		// fade music to 0 after 2500
		Timer.delay( function():Void{
			trace("fadeOut Music");
			//music.fadeAllTo(0);
			music.fadeAllTo(0,1000,false);
		}, 2500);
		
		// fadeIn music to 1 after 4000
		Timer.delay( function():Void{
			trace("fadeIn Music");
			music.fadeAllTo(1, 350);
		}, 4000);
		
		// music volume change to 0.2 after 5000
		Timer.delay( function():Void{
			trace("Music Volume = .2");
			music.volume = .2;
		}, 5000);
		
		// mute solos after 6000
		Timer.delay( function():Void{
			trace("Mute Solos");
			solos.mute = true;
		}, 6000);
		
		// unmute solos after 7000
		Timer.delay( function():Void{
			trace("Unmute Solos");
			solos.mute = false;
		}, 7000);
		
		
		// stop all group sound solos after 9000
		Timer.delay( function():Void{
			trace("STOP ALL!");
			var i:Int = VorbisAS.groups.length - 1;
			while ( 0 <= i ){
				VorbisAS.groups[i].stopAll();
				i--;
			}
		}, 9000);
	}
	
	
	private function testSoundMissingError():Void
	{
		trace("GROUPS: MUSIC and SOLOS. Should throw a sound missing error instead of a Stack overflow.");
		var music:VorbisManager = VorbisAS.group("music");
		var solos:VorbisManager = VorbisAS.group("solos");
		try{
			VorbisAS.play("missing", 1);
		}catch (e:Error){
			trace("catch error");
			trace(e);
		}
	}
	
	
	private function testIsPlayed():Void
	{
		trace("isPlaying / isPaused");
		VorbisAS.play(FILE_SOLO2);
		VorbisAS.getSound(FILE_SOLO2).soundCompleted.addOnce(
			function( vi:VorbisInstance ):Void{
					trace(" sound complete. isPlayed=", vi.isPlaying); // not dispatch
			});
		
		Timer.delay( function():Void{
			trace("play.  isPlayed=",VorbisAS.getSound(FILE_SOLO2).isPlaying);
		}, 20);
		
		Timer.delay( function():Void{
			VorbisAS.getSound(FILE_SOLO2).pause();
			trace("pause.  isPaused=", VorbisAS.getSound(FILE_SOLO2).isPaused);
		}, 1000);
		
		Timer.delay( function():Void{
			VorbisAS.getSound(FILE_SOLO2).resume();
			trace("resume.  isPaused=", VorbisAS.getSound(FILE_SOLO2).isPaused);
		}, 2000);
		
		// check stopAtZero 
		// if stopAtZero is true when do fadeIn/Out, not dispatch onComplete signal.
		// use fade.ended signal. (fade is SoundTween)
		
		Timer.delay( function():Void{
			var vi:VorbisInstance = VorbisAS.play(FILE_LOOP);
			vi = vi.fadeTo(0);
			vi.fade.stopAtZero = true;
			trace("fade. stopAtZero ", vi.fade.stopAtZero );
			
			vi.soundCompleted.addOnce(function(vi:VorbisInstance):Void{
				trace(" sound complete. isPlayed=", vi.isPlaying); // not dispatch
			});
			
			vi.fade.ended.addOnce(function(vi:VorbisInstance):Void{
				trace(" soundTween ended. isPlayed=", vi.isPlaying); // dispatch
			});

		}, 4000);
	}
	
	
	public function testLoopRemainng():Void
	{
		trace("LoopRemaining check");
		
		// no loop -------------------
		
		var vi:VorbisInstance = VorbisAS.play(FILE_LOOP, 1, 0, 0); // no loop
		trace( "play, loop = 0"," LoopRemaining ",vi.loopsRemaining , " / loop ", vi.loops);
		vi.soundCompleted.add( function( vi:VorbisInstance ):Void{
			trace("onComplete");
			trace( "play, loop = " + vi.loops , " LoopRemaining " , vi.loopsRemaining , " / loop ", vi.loops);
		});
		
		// 1 loop ( no loop ) -------------------
		// 
		Timer.delay( function():Void {
			vi = VorbisAS.play(FILE_LOOP, 1, 0, 1); // 1 loop
			trace( "play, loop = 1"," LoopRemaining ",vi.loopsRemaining , " / loop ", vi.loops);
		}, 10000);
		
		// 2 loop -------------------
		
		Timer.delay( function():Void{
			vi = VorbisAS.play(FILE_LOOP, 1, 0, 2); // 2 loop
			trace( "play, loop = 2"," LoopRemaining ",vi.loopsRemaining , " / loop ", vi.loops);
			Timer.delay(function():Void{
				trace( "play, loop = 2"," LoopRemaining ",vi.loopsRemaining , " / loop ", vi.loops);
			}, 10000);
		}, 20000);
		
		// infinity loop -------------------
		
		Timer.delay( function():Void{
			vi = VorbisAS.play(FILE_LOOP, 1, 0, -1); // infinity loop
			trace( "play, loop = -1(Infinity)", " LoopRemaining ", vi.loopsRemaining , " / loop ", vi.loops);
			
			Timer.delay(function():Void{
				trace( "play, loop = -1(Infinity)", " LoopRemaining ", vi.loopsRemaining , " / loop ", vi.loops);
			}, 10000);
			
			Timer.delay(function():Void{
				trace( "play, loop = -1(Infinity)", " LoopRemaining ", vi.loopsRemaining , " / loop ", vi.loops);
			}, 20000);
			
			Timer.delay(function():Void{
				trace( "play, loop = -1(Infinity)", " LoopRemaining ", vi.loopsRemaining , " / loop ", vi.loops);
				vi.stop();
				trace("stop loop");
			}, 25000);
		}, 40000);
		
	}
	
}