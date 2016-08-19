package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import jp.gr.java_conf.ennea.sound.VorbisAS;
	import jp.gr.java_conf.ennea.sound.VorbisInstance;
	import jp.gr.java_conf.ennea.sound.VorbisManager;
	/**
	 * ...
	 * @author tj
	 */
	public class VorbisASTestOnAS3 extends Sprite
	{
		
		public function VorbisASTestOnAS3() 
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		
		public static const ASSETS_PATH:String = "./assets/";
		public static const FILE_CLICK:String = "Click.ogg";
		public static const FILE_MUSIC:String = "Music.ogg";
		public static const FILE_LOOP:String = "Loop.ogg";
		public static const FILE_SOLO1:String = "Solo1.ogg";
		public static const FILE_SOLO2:String = "Solo2.ogg";
		
		
		private function onStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			
			// initialize haxe
			haxe.initSwc(new MovieClip() );
			
			// initialize VorbisAS
			VorbisAS.initialize();
			
			//Load sound from an external file
			VorbisAS.loadSound(ASSETS_PATH + FILE_CLICK, FILE_CLICK);
			VorbisAS.loadSound(ASSETS_PATH + FILE_MUSIC, FILE_MUSIC);
			VorbisAS.loadSound(ASSETS_PATH + FILE_LOOP,  FILE_LOOP);
			VorbisAS.loadSound(ASSETS_PATH + FILE_SOLO1, FILE_SOLO1);
			VorbisAS.loadSound(ASSETS_PATH + FILE_SOLO2, FILE_SOLO2);
			
			var file_count:int = 5;
			VorbisAS.loadCompleted.add( function( si:VorbisInstance ):void{
				trace(" sound loaded. url=" + si.url);
				if ( --file_count <= 0 ){
					setupTest();
				}
			});
			
		}
		
		public function setupTest():void
		{
			// setup keyboard input
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			// setup mouse input
			// click = SE multiple test
			stage.addEventListener(MouseEvent.CLICK, 
				function(e:MouseEvent):void{
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
			trace( "key [0] Accessor Test.");
			trace( "---------------------------");
		}
		
		
		public var mvolume:Number = 1.0;
		
		
		// process keyboard input
		private function onKeyDown(e:KeyboardEvent):void 
		{
			trace("key down " + e.keyCode );
			
			switch(e.keyCode){
				case Keyboard.NUMBER_1:	testPlayStop(); break;
				case Keyboard.NUMBER_2:	testPauseResume();  break;
				case Keyboard.NUMBER_3:	testFade();  break;
				case Keyboard.NUMBER_4:	testMultiChannelMute();  break;
				case Keyboard.NUMBER_5:	testSeamlessLoop();  break;
				case Keyboard.NUMBER_6:	testGroups();  break;
				case Keyboard.NUMBER_7:	testSoundMissingError();  break;
				case Keyboard.NUMBER_8:	testIsPlayed(); break;
				case Keyboard.NUMBER_9:	testLoopRemainng(); break;
				case Keyboard.NUMBER_0:	testAccessorOnAS3(); break;
				
				case Keyboard.Z:	mvolume += 0.1;
					if (mvolume < 0) mvolume = 0;
					else if ( mvolume > 1 ) mvolume = 1;
					VorbisAS.masterVolume = mvolume;
					trace("UP mastervolume=" + mvolume);
					break;
				case Keyboard.X:	mvolume -= 0.1;
					if (mvolume < 0) mvolume = 0;
					else if ( mvolume > 1 ) mvolume = 1;
					VorbisAS.masterVolume = mvolume;
					trace("DOWN mastervolume=" + mvolume);
					break;
				default:
					break;
			}
		}
		
		
		private function testPlayStop():void
		{
			trace("Testing PLAY: Play / Stop / PlayMultiple / StopMultiple");
			// play
			VorbisAS.playLoop( FILE_MUSIC  );
			trace("play "," isPlaying:", VorbisAS.getSound(FILE_MUSIC).isPlaying);
			
			// stop
			setTimeout(function():void{
					VorbisAS.getSound(FILE_MUSIC).stop();
					trace("stop ", " isPlaying:", VorbisAS.getSound(FILE_MUSIC).isPlaying);
					},
				3000);
			
			// play multiple
			setTimeout(function():void{
					trace("playMultiple");
					VorbisAS.playFx( FILE_SOLO1 );
					VorbisAS.playFx( FILE_SOLO2 );
					},
				4000);
			
			// stopAll
			setTimeout(function():void{
					trace("stopAll");
					VorbisAS.stopAll();
					},
				5500);
		}
		
		
		private function testPauseResume():void
		{
			trace("PAUSE: Pause / Resume, soundcomplete -> PauseAll / ResumeAll");
			//play
			VorbisAS.playFx(FILE_MUSIC, 60000);
			
			// pause
			setTimeout(function():void{
				trace("pause");
				VorbisAS.pause(FILE_MUSIC);
				},
			2000);
			
			// resume -> pauseAll -> resumeAll
			setTimeout(function():void{
				trace("resume and waiting playComplete.");
				VorbisAS.resume(FILE_MUSIC).soundCompleted.addOnce(
					function( si:VorbisInstance ):void{
						VorbisAS.playFx(FILE_SOLO1,1,0,3);
						VorbisAS.playFx(FILE_SOLO2,1,0,3);
						setTimeout(function():void{
							VorbisAS.pauseAll();
							trace("pauseAll");
						}, 1500);
						
						setTimeout(function():void{
							VorbisAS.resumeAll();
							trace("resumeAll");
						}, 2000);
					}
				);
			},3000);
		}
		
		
		private function testFade():void
		{
			trace("FADES: fade, fadeMultiple, fadeMaster");
			// fade in
			VorbisAS.playLoop(FILE_MUSIC);
			VorbisAS.fadeFrom(FILE_MUSIC, 0, 1);
			trace("fadeIn 0 -> 1");
			
			// fade out
			setTimeout(function():void{
				VorbisAS.fadeTo(FILE_MUSIC, 0);
				trace("fadeOut 1 -> 0");
				},
			3000);
			
			// fadeAllfrom
			setTimeout(function():void{
				VorbisAS.playLoop(FILE_MUSIC,0);
				VorbisAS.playFx(FILE_SOLO1,0);
				VorbisAS.playFx(FILE_SOLO2,0);
				VorbisAS.fadeAllFrom(0, 1, 500);
				trace("fadeAllFrom 3 sounds volume 0 -> 1");
			}, 5000);
			
			
			setTimeout(function():void{
				VorbisAS.fadeAllTo(0, 1000);
				trace("fadeAllTo 3 sounds volume  -> 0");
			}, 7000);
			
			setTimeout(function():void{
				VorbisAS.play(FILE_MUSIC);
				VorbisAS.fadeMasterFrom(0);
				trace("fadeMasterFrom 0 -> 1");
			}, 8500);
			
			
			setTimeout(function():void{
				VorbisAS.fadeMasterTo(0);
				trace("fadeMasterTo 1 -> 0");
			}, 10500);
			
			setTimeout(function():void{
				VorbisAS.masterVolume = mvolume;
				VorbisAS.stopAll();
			}, 12000);
			
		}
		
		
		private function testMultiChannelMute():void
		{
			trace("MULITPLE CHANNELS: play 3 music + 1 solo loop, muteAll, unmuteAll, 20% volumeAll, stopAll");
			VorbisAS.playFx(FILE_MUSIC, .5, 0,100);
			VorbisAS.playFx(FILE_MUSIC, .5, 2000,100);
			VorbisAS.playFx(FILE_MUSIC, .5, 4000,100);
			VorbisAS.playLoop(FILE_SOLO1);
			
			setTimeout(function():void{
				trace("mute");
				//VorbisAS.set_mute(true);
				VorbisAS.mute = true;
			}, 2000);
			
			
			setTimeout(function():void{
				trace("un-mute");
				//VorbisAS.set_mute(false);
				VorbisAS.mute = false;
			}, 3000);
			
			setTimeout(function():void{
				trace("volume=.2");
				//VorbisAS.set_volume(.2);
				VorbisAS.volume = .2;
			}, 4000);

			setTimeout(function():void{
				trace("stopAll");
				VorbisAS.stopAll();
			}, 6000);
		}
		
		
		private var loopCount:int = 0;
		private var solo:VorbisInstance;
		
		private function testSeamlessLoop():void
		{
			trace("LOOPING: Loop solo 2 times, pause halfway each time. Shows workaround for the 'loop bug': http://www.stevensacks.net/2008/08/07/as3-sound-channel-bug/ ");
			loopCount = 0;
			if ( solo != null ){	solo.stop();	}
			
			solo = VorbisAS.play(FILE_SOLO1, 1, 0, 0);
			solo.soundCompleted.add(playPause);
			playPause(solo);
		}
		
		private function playPause(si:VorbisInstance):void
		{
			if(++loopCount == 3){ 
				trace("INFINITE LOOP: 5 seconds of repeating Clicks");
				var startTime:int = getTimer();
				var click:VorbisInstance = VorbisAS.play(FILE_CLICK, 1, 0, -1, false, false);
				setTimeout(function():void{
					trace("stop Clicks");
					click.stop();
					click.soundCompleted.removeAll();
					solo.soundCompleted.removeAll();
				}, 5000);
			} 
			else {
				VorbisAS.play(FILE_SOLO1, 1, 0, 0);
				setTimeout(function():void{
					solo.pause();
					trace("pause");
				}, 500);
				setTimeout(function():void{
					solo.resume();
					trace("resume");
				}, 1000);
			}
		}
		
		
		private function testGroups():void
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
			setTimeout(function():void{
				trace("pause solos");
				solos.pauseAll();
			}, 1000);
			
			// resume solos after 2000ms
			setTimeout(function():void{
				trace("resume solos");
				solos.resumeAll();
			}, 2000);
			
			// fade music to 0 after 2500
			setTimeout(function():void{
				trace("fadeOut Music");
				//music.fadeAllTo(0);
				music.fadeAllTo(0,1000,false);
			}, 2500);
			
			// fadeIn music to 1 after 4000
			setTimeout(function():void{
				trace("fadeIn Music");
				music.fadeAllTo(1, 350);
			}, 4000);
			
			// music volume change to 0.2 after 5000
			setTimeout(function():void{
				trace("Music Volume = .2");
				music.volume = .2;
			}, 5000);
			
			// mute solos after 6000
			setTimeout(function():void{
				trace("Mute Solos");
				solos.mute = true;
			}, 6000);
			
			// unmute solos after 7000
			setTimeout(function():void{
				trace("Unmute Solos");
				solos.mute = false;
			}, 7500);
			
			
			// stop all group sound solos after 9000
			setTimeout(function():void{
				trace("STOP ALL!");
				var i:int = VorbisAS.groups.length - 1;
				while ( 0 <= i ){
					VorbisAS.manager.groups[i].stopAll();
					i--;
				}
			}, 11000);
		}
		
		
		private function testSoundMissingError():void
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
		
		
		private function testIsPlayed():void
		{
			trace("isPlaying / isPaused");
			VorbisAS.play(FILE_SOLO2);
			VorbisAS.getSound(FILE_SOLO2).soundCompleted.addOnce(function( vi:VorbisInstance ):void{
					trace(" sound complete. isPlayed=", vi.isPlaying); // not dispatch
			});
			
			setTimeout(function():void{
				trace("play.  isPlayed=",VorbisAS.getSound(FILE_SOLO2).isPlaying);
			}, 20);
			
			setTimeout(function():void{
				VorbisAS.getSound(FILE_SOLO2).pause();
				trace("pause.  isPaused=", VorbisAS.getSound(FILE_SOLO2).isPaused);
			}, 1000);
			
			setTimeout(function():void{
				VorbisAS.getSound(FILE_SOLO2).resume();
				trace("resume.  isPaused=", VorbisAS.getSound(FILE_SOLO2).isPaused);
			}, 2000);
			
			// check stopAtZero 
			// if stopAtZero is true when do fadeIn/Out, not dispatch onComplete signal.
			// use fade.ended signal. (fade is SoundTween)
			
			setTimeout(function():void{
				var vi:VorbisInstance = VorbisAS.play(FILE_LOOP);
				vi = vi.fadeTo(0);
				vi.fade.stopAtZero = true;
				trace("fade. stopAtZero ",vi.fade.stopAtZero );
				
				vi.soundCompleted.addOnce(function(vi:VorbisInstance):void{
					trace(" sound complete. isPlayed=", vi.isPlaying); // not dispatch
				});
				
				vi.fade.ended.addOnce(function(vi:VorbisInstance):void{
					trace(" soundTween ended. isPlayed=", vi.isPlaying); // dispatch
				});
				
			}, 5000);
		}
		
		
		public function testLoopRemainng():void
		{
			trace("LoopRemaining check");
			
			// no loop -------------------
			
			var vi:VorbisInstance = VorbisAS.play(FILE_LOOP, 1, 0, 0); // no loop
			trace( "play, loop = 0"," LoopRemaining ",vi.loopsRemaining , " / loop ", vi.loops);
			vi.soundCompleted.add( function( vi:VorbisInstance ):void{
				trace("onComplete");
				trace( "play, loop = " + vi.loops , " LoopRemaining " , vi.loopsRemaining , " / loop ", vi.loops);
			});
			
			// 1 loop ( no loop ) -------------------
			// 
			setTimeout(function():void{
				vi = VorbisAS.play(FILE_LOOP, 1, 0, 1); // 1 loop
				trace( "play, loop = 1"," LoopRemaining ",vi.loopsRemaining , " / loop ", vi.loops);
			}, 10000);
			
			// 2 loop -------------------
			
			setTimeout(function():void{
				vi = VorbisAS.play(FILE_LOOP, 1, 0, 2); // 2 loop
				trace( "play, loop = 2"," LoopRemaining ",vi.loopsRemaining , " / loop ", vi.loops);
				setTimeout(function():void{
					trace( "play, loop = 2"," LoopRemaining ",vi.loopsRemaining , " / loop ", vi.loops);
				}, 10000);
			}, 20000);
			
			// infinity loop -------------------
			
			setTimeout(function():void{
				vi = VorbisAS.play(FILE_LOOP, 1, 0, -1); // infinity loop
				trace( "play, loop = -1(Infinity)", " LoopRemaining ", vi.loopsRemaining , " / loop ", vi.loops);
				
				setTimeout(function():void{
					trace( "play, loop = -1(Infinity)", " LoopRemaining ", vi.loopsRemaining , " / loop ", vi.loops);
				}, 10000);
				
				setTimeout(function():void{
					trace( "play, loop = -1(Infinity)", " LoopRemaining ", vi.loopsRemaining , " / loop ", vi.loops);
				}, 20000);
				
				setTimeout(function():void{
					trace( "play, loop = -1(Infinity)", " LoopRemaining ", vi.loopsRemaining , " / loop ", vi.loops);
					vi.stop();
					trace("stop loop");
				}, 25000);
			}, 40000);
			
		}
	
		//////-------------------------------------------------------
		
		private function testAccessorOnAS3():void 
		{
			trace( "AccessorTest" );
			
			// initialize haxe
			//haxe.initSwc(new MovieClip() );
			
			// init
			//trace("before initialize",VorbisAS.manager);
			//VorbisAS.initialize();
			//trace("after initialize", VorbisAS.manager);
			
			// play
			var vi:VorbisInstance = VorbisAS.playLoop(FILE_LOOP);
			vi.fadeTo(0.2,2000);
			
			setTimeout(function():void{
				( vi.isPaused )? vi.resume() : vi.pause() ;
				trace(" VorbisInstance isPaused", vi.isPaused　, " isPlaying",vi.isPlaying , "pos", vi.position );
			}, 2000);
			
			setTimeout(function():void{
				( vi.isPaused )? vi.resume() : vi.pause() ;
				trace(" VorbisInstance isPaused", vi.isPaused　, " isPlaying",vi.isPlaying , "pos", vi.position );
			}, 4000);
			
			setTimeout(function():void{
				vi.stop();
				trace( " stop. Accessor test is over.");
				trace(" VorbisInstance isPaused", vi.isPaused　, " isPlaying",vi.isPlaying , "pos", vi.position );
			}, 6000);
			
			// check accessor
			// VorbisAS
			trace("--- accessor check ---");
			trace("VorbisAS.manager", VorbisAS.manager);
			VorbisAS.group("music");
			VorbisAS.group("se");
			trace("VorbisAS.groups",VorbisAS.groups);
			trace("VorbisAS.loadCompleted",VorbisAS.loadCompleted);
			trace("VorbisAS.loadFailed",VorbisAS.loadFailed);
			trace("VorbisAS.volume",VorbisAS.volume);
			trace("VorbisAS.volume",VorbisAS.volume = 0.7);
			trace("VorbisAS.masterVolume",VorbisAS.masterVolume);
			trace("VorbisAS.masterVolume",VorbisAS.masterVolume = 0.5);
			trace("VorbisAS.mute",VorbisAS.mute);
			trace("VorbisAS.pan",VorbisAS.pan);
			trace("VorbisAS.tickEnabled", VorbisAS.tickEnabled);
			trace("VorbisAS.parent",VorbisAS.parent);
			
			trace("---");
			// VorbisInstance
			trace("VorbisInstance.fade",vi.fade );
			trace("VorbisInstance.isPaused",vi.isPaused);
			trace("VorbisInstance.isPlaying",vi.isPlaying);
			trace("VorbisInstance.loops",vi.loops);
			trace("VorbisInstance.loopsRemaining",vi.loopsRemaining);
			trace("VorbisInstance.manager",vi.manager);
			trace("VorbisInstance.volume",vi.volume);
			trace("VorbisInstance.masterVolume",vi.masterVolume);
			trace("VorbisInstance.mixedVolume",vi.mixedVolume);
			trace("VorbisInstance.mute",vi.mute);
			trace("VorbisInstance.pan",vi.pan);
			trace("VorbisInstance.position",vi.position);
			trace("VorbisInstance.soundTransform", vi.soundTransform);
			
			trace("---");
			// VorbisTween
			if ( vi.fade ){
				trace("VorbisTween.isComplete",vi.fade.isComplete);
			}
			
			trace("---");
			// VorbisManager
			trace("VorbisManager.parent",VorbisAS.manager.parent);
			trace("VorbisManager.groups",VorbisAS.manager.groups);
			trace("VorbisManager.loadCompleted",VorbisAS.manager.loadCompleted);
			trace("VorbisManager.loadFailed",VorbisAS.manager.loadFailed);
			trace("VorbisManager.volume",VorbisAS.manager.volume);
			trace("VorbisManager.masterVolume",VorbisAS.manager.masterVolume);
			trace("VorbisManager.mute",VorbisAS.manager.mute);
			trace("VorbisManager.pan",VorbisAS.manager.pan);
			trace("VorbisManager.tickEnabled", VorbisAS.manager.tickEnabled);
		}
	}

}