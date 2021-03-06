# VorbisAS

This is OggVorbis playback library for Flash and AIR.

API like SoundAS.

coded Haxe 3.2.1

日本語のREADMEはこちら [README_jp.md](https://github.com/TuduraoJin/VorbisAS/blob/master/README_jp.md)

## Features
* Clean modern API
* API Chaining: VorbisAS.play("music").fadeTo(0);
* Supports groups of sounds
* Supports seamless looping
* Built-in Tweening system, no dependancies
* Modular API: Use VorbisInstance directly and ignore the rest.
* Non-restrictive and unambigous license

## Quick Start
you need import these file in your project.

**Haxe user**    

* [lib/as3-signals-v0.8.swc](https://github.com/TuduraoJin/VorbisAS/tree/master/lib)
* [src](https://github.com/TuduraoJin/VorbisAS/tree/master/src) directory .hx files.

**ActionScript user**

* [lib/as3-signals-v0.8.swc](https://github.com/TuduraoJin/VorbisAS/tree/master/lib)
* [bin/VorbisAS.swc](https://github.com/TuduraoJin/VorbisAS/tree/master/bin)

it's done.

you must call first VorbisAS.initialize.

	VorbisAS.initialize();

ok. VorbisAS is available now.   
you can use VorbisAS. enjoy!

###**If you are ActionScript3 user**.
you need check [ATTENSIONonAS3.md](https://github.com/TuduraoJin/VorbisAS/blob/master/ATTENSIONonAS3.md).
There are Note about the API.

## API Overview

Full documentation can be found here: [doc/pages/index.html](https://github.com/TuduraoJin/VorbisAS/blob/master/doc/pages/index.html)

### VorbisAS
This Class is the main interface for the library. It's responsible for loading and controlling all sounds globally. 

Initialize:

*    **VorbisAS.initialize** initialize VorbisAS. you need call first.

Access:

*    **VorbisAS.manager** use to direct access static instance.

Loading / Unloading: 

*    **VorbisAS.addSound**(type:String, sound:VorbisSound):Void
*    **VorbisAS.addSoundBytes**(type:String, bytes:Bytes):Void
*    **VorbisAS.loadSound**(url:String, type:String):Void
*    **VorbisAS.removeSound**(type:String):void
*    **VorbisAS.removeAll**():void

Playback:

*    **VorbisAS.getSound**(type:String, forceNew:Bool = false):VorbisInstance
*    **VorbisAS.play**(type:String, volume:Float = 1, startTime:Float = 0, loops:Int = 0, allowMultiple:Bool = false, allowInterrupt:Bool = true ):VorbisInstance
*    **VorbisAS.playFx**playFx(type:String, volume:Float = 1, startTime:Float = 0, loops:Int = 0):VorbisInstance 
*    **VorbisAS.playLoop**(type:String, volume:Float = 1, startTime:Float = 0):VorbisInstance
*    **VorbisAS.resume**(type:String):VorbisInstance 
*    **VorbisAS.resumeAll**():Void
*    **VorbisAS.pause**(type:String):VorbisInstance
*    **VorbisAS.pauseAll**():Void
*    **VorbisAS.stopAll**():Void
*    **VorbisAS.set masterVolume**(value:Float):Float
*    **VorbisAS.fadeFrom**(type:String, startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance
*    **VorbisAS.fadeAllFrom**(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void
*    **VorbisAS.fadeMasterFrom**(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void
*    **VorbisAS.fadeTo**(type:String, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance
*    **VorbisAS.fadeAllTo**(endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void
*    **VorbisAS.fadeMasterTo**(endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void

####VorbisInstance
Controls playback of individual sounds, allowing you to easily stop, start, resume and set volume or position.

*     **play**(volume:Float = 1, startTime:Float = 0, loops:Int = 0, allowMultiple:Bool = true):VorbisInstance
*     **pause**():VorbisInstance
*     **resume**(forceStart:Bool = false):VorbisInstance 
*     **stop**():VorbisInstance
*     **volume**(value:Float):Float
*     **mute**(value:Bool):Bool
*     **get isPlayed**:Bool
*     **get isPaused**:Bool
*     **fadeFrom**(startVolume:Float, endVolume:Float, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance 
*     **fadeTo**(endVolume:Float, duration:Float = 1000, stopAtZero:Bool = true):VorbisInstance 
*     **fade.end**(applyEndVolume:Boolean = false):Void
*     **destroy**():Void

## Code Examples

### Loading

    //Load sound from an external file
    VorbisAS.loadSound("assets/Click.ogg", "click");

    //Inject an already loaded Sound instance
    VorbisAS.addSound("click", clickSound);
	
	//Inject an already loaded OggVorbis binary.
	VorbisAS.addSoundBytes("click", bytes); //bytes is Bytes class(ByteArray on AS3). loaded by URLStream...etc
	
### Basic Playback

    //Play sound.
        //allowMultiple: Allow multiple overlapping sound instances.
        //allowInterrupt: If this sound is currently playing, start it over.
    VorbisAS.play("click", volume, startTime, loops, allowMultiple, allowInterrupt);

    //Shortcut for typical game fx (no looping, allows for multiple instances)
    VorbisAS.playFx("click");

    //Shortcut for typical game music (loops forever, no multiple instances)
    VorbisAS.playLoop("music");

    //Toggle Mute for all sounds
    VorbisAS.mute = !VorbisAS.mute;

    //PauseAll / ResumeAll
    VorbisAS.pauseAll();
    VorbisAS.resumeAll();
    
    //Toggle Pause on individual song
    var sound:VorbisInstance = VorbisAS.getSound("music");
    (sound.isPaused)? sound.resume() : sound.pause();

    //Fade Out
    VorbisAS.getSound("click").fadeTo(0);

    //Fade masterVolume out
    VorbisAS.fadeMasterTo(0);

### Groups

    //Create a group
    var musicGroup:VorbisManager = VorbisAS.group("music");

    //Add sound(s) to group
    musicGroup.loadSound("assets/TitleMusic.mp3", "titleMusic");
    musicGroup.loadSound("assets/GameMusic.mp3", "gameMusic");

    //Use entire VorbisAS API on Group:
    musicGroup.play("titleMusic")
    musicGroup.volume = .5;
    musicGroup.mute = muteMusic;
    musicGroup.fadeTo(0);
    //etc...

    //Stop All Groups
	for( g in VorbisAS.groups ){
		g.stopAll();
	}
	

### Advanced 

    //Mute one sound
    SoundsAS.getSound("click").mute = true;

    //Fade from .3 to .7 over 3 seconds
    VorbisAS.getSound("click").fadeFrom(.3, .7, 3000);

	//Manage a VorbisInstance directly and ignore VorbisAS
    var sound:VorbisInstance = new VorbisInstance(mySound, "click");
    sound.play(volume);
    sound.position = 500; //Set position of sound in milliseconds
    sound.volume = .5; 
	sound.fadeTo(0);

    //String 2 songs together
    VorbisAS.play(MUSIC1).soundCompleted.addOnce(function(si:VorbisInstance){
        VorbisAS.playLoop(MUSIC2);
    });

    //Loop twice, and trigger something when all loops are finished.
    VorbisAS.play(MUSIC1, 1, 0, 2).soundCompleted.add(function(vi:VorbisInstance){
        if(vi.loopsRemaining == 0){
            trace("Loops completed!");
            vi.soundCompleted.removeAll();
        }
    }
	
	// check fade completed
	var vi:VorbisInstance = VorbisAS.play(MUSIC1, 1, 0, 2).fadeTo(0, 2000);
	vi.fade.ended.addOnce( function (vi:VorbisInstance):Void {
			trace("fade complete");
		});



## License
MIT LICENSE. see [LICENSE](https://github.com/TuduraoJin/VorbisAS/blob/master/LICENSE)

## fork sources
If you want to customize sources, check these amazing repositories.

* [treefortress/SoundAS](https://github.com/treefortress/SoundAS/)
* [shohei909/haxe\_stb\_ogg\_sound](https://github.com/shohei909/haxe_stb_ogg_sound)
* [nothings/stb single-file public domain libraries for C/C++](https://github.com/nothings/stb)

## using external libraries
**you need import as3-signals library.**
VorbisAS library don't contained Signal.
import Signal SWC file from **[lib](https://github.com/TuduraoJin/VorbisAS/tree/master/lib)** directory.

* [as3-signals](https://github.com/robertpenner/as3-signals)