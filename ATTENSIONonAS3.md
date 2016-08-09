# !!Attension on AS3!!

## initialize
if use SWC on AS3. you need initialize haxe system first.

example

	haxe.initSwc( new MovieClip() );
	VorbisAS.initialize();

## Native accessor does not working...

**you need directly access getter/setter functions on AS3.**

example

    VorbisAS.volume; // does not work!

    VorbisAS.get_volume();
	var vi:VorbisInstance = VorbisAS.play(FILE_MUSIC);
	vi.get_isPlaying();     // getter
	vi.set_volume(0.5);     // setter
	

## need directly access funcitons list.

following properties need directly access getter/setter function.

	// VorbisAS
	trace("VorbisAS.groups",VorbisAS.get_groups());
	trace("VorbisAS.loadCompleted",VorbisAS.get_loadCompleted());
	trace("VorbisAS.loadFailed",VorbisAS.get_loadFailed());
	trace("VorbisAS.volume",VorbisAS.get_volume());
	trace("VorbisAS.masterVolume",VorbisAS.get_masterVolume());
	trace("VorbisAS.mute",VorbisAS.get_mute());
	trace("VorbisAS.pan",VorbisAS.get_pan());
	trace("VorbisAS.tickEnabled", VorbisAS.get_tickEnabled());
	trace("VorbisAS.parent",VorbisAS.get_parent());
	
	// VorbisInstance
	trace("VorbisInstance.fade",vi.get_fade());
	trace("VorbisInstance.isPaused",vi.get_isPaused());
	trace("VorbisInstance.isPlaying",vi.get_isPlaying());
	trace("VorbisInstance.loops",vi.get_loops());
	trace("VorbisInstance.loopsRemaining",vi.get_loopsRemaining());
	trace("VorbisInstance.manager",vi.manager);
	trace("VorbisInstance.volume",vi.get_volume());
	trace("VorbisInstance.masterVolume",vi.get_masterVolume());
	trace("VorbisInstance.mixedVolume",vi.get_mixedVolume());
	trace("VorbisInstance.mute",vi.get_mute());
	trace("VorbisInstance.pan",vi.get_pan());
	trace("VorbisInstance.position",vi.get_position());
	trace("VorbisInstance.soundTransform", vi.get_soundTransform());
	
	// VorbisTween
	if ( vi.get_fade() ){
		trace("VorbisTween.isComplete",vi.get_fade().isComplete);
	}
	
	// VorbisManager
	trace("VorbisManager.parent",VorbisAS.manager.parent);
	trace("VorbisManager.groups",VorbisAS.manager.groups);
	trace("VorbisManager.loadCompleted",VorbisAS.manager.loadCompleted);
	trace("VorbisManager.loadFailed",VorbisAS.manager.loadFailed);
	trace("VorbisManager.volume",VorbisAS.manager.get_volume());
	trace("VorbisManager.masterVolume",VorbisAS.manager.get_masterVolume());
	trace("VorbisManager.mute",VorbisAS.manager.get_mute());
	trace("VorbisManager.pan",VorbisAS.manager.get_pan());
	trace("VorbisManager.tickEnabled", VorbisAS.manager.get_tickEnabled());


### why...?

this is an error by haxe compiler...( I think. )  
When haxe code compile to SWC.
field(get,set) is not defined native accessor.
because ,field(get,set) is not physical.
sure, that's right.  
see web documents [https://haxe.org/manual/class-field-property-rules.html](https://haxe.org/manual/class-field-property-rules.html)

use @:isVar metatag , looks like fine on Haxe.
but AS3...  
It is create duplicately field and this field **doesn't** through getter/setter functions.

example
*AccessorTest.hx*

	Class AccessorTest {
		
		// physical field
		public var fieldA(default, set):Int;
		
		private function set_fieldA( value:Int ):Int{
			return this.fieldA = value + 1;
		}
		
		// get,set with @:isVar 		
		@:isVar
		public var fieldB(get, set):Int;
		
		private function get_fieldB():Int{
			if ( this.fieldB > 10 ){
				return 10;
			}
			return this.fieldB;
		}
		
		function set_fieldB( value:Int ):Int{
			this.fieldB = value;
			if ( this.fieldB > 10 ){
				return 10;
			}
			return this.fieldB;
		}
	}

AccessorTest compile to SWC. and import AS3 project.	
test following code.

	trace("get FieldA", at.fieldA  );
	trace("set FieldA", at.fieldA = 3 );
	trace("get FieldA", at.fieldA  );
	trace("set set_FieldA", at.set_fieldA(3)  );
	
	trace("get FieldB", at.fieldB );
	trace("set FieldB", at.fieldB = 13 );
	trace("get FieldB", at.fieldB );
	trace("get get_FieldB", at.get_fieldB() );
	trace("get set_FieldB", at.set_fieldB(19) );

output

	get FieldA 0		// 0
	set FieldA 3		// 3 !?, It returns 4 on the assumption.
	get FieldA 3		// 3 !?
	set set_FieldA 4 	// 4 , That's right!
	get FieldB 0 		// 0
	set FieldB 13		// 13 !?, It returns 10 on the assumption.
	get FieldB 13		// 13 !?
	get get_FieldB 10	// 10 , That's right!
	get set_FieldB 10	// 10 , That's right!

you know what happened.
fieldA and fieldB is **does not** through the getter/setter functions.
but getter/setter function is working by call directly.

I don't know why cause this plobrem...
However, we have a way that call directly getter/setter function.
it's work fine.

p.s private getter/setter function change to public on AS3.

## for developer 
if you will coding for AS3 by Haxe 3.
please check following memo...

* shouldn't use metatag [@:isVar] to accessor field(get,set). It is create duplicately field on AS3 and this field *doesn't* through getter/setter functions.
* shouldn't use haxe compile option [-D swf-protected]. It is cause some runtime error on AS3. TypeError 1006.
* shouldn't use metatag [@:protected] to private field. If set this tag, field is changed static field.

these problems found on haxe 3.2.1. and FlashDevelop 5.1.1.1.     
Just maybe, it might be fixed in later versions.     
I hope!