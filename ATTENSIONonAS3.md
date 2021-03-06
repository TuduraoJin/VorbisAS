# !!Attension on AS3!!

日本語版はこちら [ATTENSIONonAS3_jp.md](https://github.com/TuduraoJin/VorbisAS/blob/master/ATTENSIONonAS3_jp.md)

## initialize
if use SWC on AS3. you need initialize haxe system first.

example

	haxe.initSwc( new MovieClip() );
	VorbisAS.initialize();

## Don't use setter return value.
Don't use setter like haxe. like this.     

	var value:Float = instance.field = 0.5;

setter return value is same to argument, even If argument value is changed in setter function.   
However. basically setter return value is Void in AS3.    
it is not necessary to worry too much.

## for developer 
if you will coding for AS3 by Haxe 3.
please check following memo...

* shouldn't use metatag [@:isVar] to accessor field(get,set). It is create duplicately field on AS3 and this field *doesn't* through getter/setter functions.
* shouldn't use haxe compile option [-D swf-protected]. It is cause some runtime error on AS3. TypeError 1006.
* shouldn't use metatag [@:protected] to private field. If set this tag, field is changed static field.

these problems found on haxe 3.2.1. and FlashDevelop 5.1.1.1.     
Just maybe, it might be fixed in later versions.     
I hope!

------------------------------------
# Fixed Problems
Occurred these issues in coding for AS3.
just maybe, help for you.


## Native accessor does not working...

**you need directly access getter/setter functions on AS3.**

example

    VorbisAS.volume; // does not work!

    VorbisAS.get_volume();
	var vi:VorbisInstance = VorbisAS.play(FILE_MUSIC);
	vi.get_isPlaying();     // getter
	vi.set_volume(0.5);     // setter
	

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

p.s private getter/setter function change to public on AS3. at this case.


### how to Fixed ?
accessor be coded as follows.

example
*AccessorTest.hx*

	#if (swc || as3)
	@:extern public var fieldA:Int;
	
	private var _fieldA:Int;
	
	@:getter(fieldA)
	private function get_fieldA():Int{
		return _fieldA;
	}
	
	@:setter(fieldA)
	private function set_fieldA( value:Int ):Int {
		_fieldA = value + 1;
		return _fieldA;
	}
	
	#else
	
	// for Haxe swf
	public var fieldA(default, set):Int;
	private function set_fieldA( value:Int ):Int {
		return fieldA = value + 1;
	}
	#end

generated ActionScript code. use -as3 compile option.

	protected var _fieldA : int;
	protected function get fieldA() : int {
		return this._fieldA;
	}
	
	protected function set fieldA(value : int) : int {
		this._fieldA = value + 1;
		return this._fieldA;
	}
	
that it! I've been wishing this code.     

you should be noted there are three points.

**(1) MetaTag @:getter / @:setter**    
this tag is working for flash.   
it is add to getter/setter function. function is changed to native accessor.
these tag's argument is accessor field name.
but It is not created physical field.

**(2) MetaTag @:extern and extern field for SWC**   
@:extern tag is for abstruct field/function.    
if you use @:getter/setter tag only and access to field in other Class.
it cause compile error [has no field].
extern field is avoid to no field error. and field is not build after compile.

**(3) #if-else macro for branch to some platforms**    
above (1) , (2) is for SWC only. not working for haxe.     
For haxe user, branches to compile code.
 #if (swc || as3) section is for SWC and build AS3 code. 
 #else section is for haxe.
