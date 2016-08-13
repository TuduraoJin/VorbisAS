# !!AS3での注意事項!!

## 初期化について
もしHaxeで生成されたSWCをAS3で使う場合、まずHaxeシステムを初期化する必要があります。

example

	haxe.initSwc( new MovieClip() );
	VorbisAS.initialize();

## Flashネイティブのアクセッサーが動作しない問題について

**AS3上では getter/setter メソッドに直接アクセスする必要があります。**
つまり、以下のようにしてください。

example

    VorbisAS.volume; // これは動きません。

    VorbisAS.get_volume();
	var vi:VorbisInstance = VorbisAS.play(FILE_MUSIC);
	vi.get_isPlaying();     // getter
	vi.set_volume(0.5);     // setter


## 直接アクセスが必要なアクセッサーの一覧

以下のプロパティはgetter/setterに直接アクセスする必要があります。

	// VorbisAS
	trace("VorbisAS.groups",        VorbisAS.get_groups());
	trace("VorbisAS.loadCompleted", VorbisAS.get_loadCompleted());
	trace("VorbisAS.loadFailed",    VorbisAS.get_loadFailed());
	trace("VorbisAS.volume",        VorbisAS.get_volume());
	trace("VorbisAS.masterVolume",  VorbisAS.get_masterVolume());
	trace("VorbisAS.mute",          VorbisAS.get_mute());
	trace("VorbisAS.pan",           VorbisAS.get_pan());
	trace("VorbisAS.tickEnabled",   VorbisAS.get_tickEnabled());
	trace("VorbisAS.parent",        VorbisAS.get_parent());
	
	// VorbisInstance
	trace("VorbisInstance.fade",            vi.fade);
	trace("VorbisInstance.isPaused",        vi.get_isPaused());
	trace("VorbisInstance.isPlaying",       vi.get_isPlaying());
	trace("VorbisInstance.loops",           vi.get_loops());
	trace("VorbisInstance.loopsRemaining",  vi.get_loopsRemaining());
	trace("VorbisInstance.manager",         vi.manager);
	trace("VorbisInstance.volume",          vi.get_volume());
	trace("VorbisInstance.masterVolume",    vi.get_masterVolume());
	trace("VorbisInstance.mixedVolume",     vi.get_mixedVolume());
	trace("VorbisInstance.mute",            vi.get_mute());
	trace("VorbisInstance.pan",             vi.get_pan());
	trace("VorbisInstance.position",        vi.get_position());
	trace("VorbisInstance.soundTransform",  vi.get_soundTransform());
	
	// VorbisTween
	trace("VorbisTween.isComplete",     vi.fade.isComplete);
	
	// VorbisManager
	trace("VorbisManager.parent",           VorbisAS.manager.parent);
	trace("VorbisManager.groups",           VorbisAS.manager.groups);
	trace("VorbisManager.loadCompleted",    VorbisAS.manager.loadCompleted);
	trace("VorbisManager.loadFailed",       VorbisAS.manager.loadFailed);
	trace("VorbisManager.volume",           VorbisAS.manager.get_volume());
	trace("VorbisManager.masterVolume",     VorbisAS.manager.get_masterVolume());
	trace("VorbisManager.mute",             VorbisAS.manager.get_mute());
	trace("VorbisManager.pan",              VorbisAS.manager.get_pan());
	trace("VorbisManager.tickEnabled",      VorbisAS.manager.get_tickEnabled());


### なぜこんなことに…？

これは、Haxeコンパイラの問題だと私は考えています。   
HaxeソースからSWCにコンパイルする際、フィールド変数(get,set)　はネイティブなアクセッサーになりません。
なぜなら、フィールド変数(get,set)は変数の実体を持たないからです。   
そう、その通り。Haxeのオフィシャルドキュメントにもそう記されています。   
[https://haxe.org/manual/class-field-property-rules.html](https://haxe.org/manual/class-field-property-rules.html)

そこでメタタグ　@:isVar　を使用してみましょう。みたところHaxe上では問題なく動作します。   
ところがAS3上となるとそうはいきません。    
@:isVarがつけられたフィールド変数は、自動的に変数の実体が定義されますが、**その変数にアクセスする際、getter/setterを介しません。**
以下にサンプルを示します。

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

上記のAccessorTest クラスをコンパイルし、SWCにします。   
そして、そのSWCをAS3プロジェクトにインポートします。     
AS3でのテストコードは以下の通りです。

	trace("get FieldA", at.fieldA  );
	trace("set FieldA", at.fieldA = 3 );
	trace("get FieldA", at.fieldA  );
	trace("set set_FieldA", at.set_fieldA(3)  );
	
	trace("get FieldB", at.fieldB );
	trace("set FieldB", at.fieldB = 13 );
	trace("get FieldB", at.fieldB );
	trace("get get_FieldB", at.get_fieldB() );
	trace("get set_FieldB", at.set_fieldB(19) );

出力結果

	get FieldA 0		// 0
	set FieldA 3		// 3 !?, 想定では 4 が返ってくるはず
	get FieldA 3		// 3 !?
	set set_FieldA 4 	// 4 , これが正しい動作です
	get FieldB 0 		// 0
	set FieldB 13		// 13 !?, 想定では 10 が返ってくるはず
	get FieldB 13		// 13 !?
	get get_FieldB 10	// 10 , これが正しい動作です
	get set_FieldB 10	// 10 , これが正しい動作です

なにが起きたのか、もうお分かりでしょう。       
fieldA と fieldB は、getter/setterが定義されているにも関わらず、getter/setterを呼び出していません。
ところが、getter/setterを直接呼び出した場合、正常に動作しています。

どうしてこのようになるのか、詳しい原因は分かりません。    
とはいえ、我々にはgetter/setterを直接呼び出すという対応策があります。
これは問題なく動作しますから、こうするしかないでしょう。

追記    
private で宣言されたgetter/setterを呼び出すことに疑問を持った方もいるかもしれません。
これも１つの問題なのですが、HaxeのSWCはAS3上だとgetter/setterが public になっています。

## 開発者の方へ

もし、HaxeでAS3向けにコードを書く場合、以下のメモをチェックしておくと良いかもしれません。

* メタタグ[ @:isVar ]はアクセッサー(get,set) に使用しないでください。使った場合、自動的に変数が定義され、その変数にアクセスしてもgetter/setterを通しません。
* Haxeのコンパイルオプションに[ -D swf-protected ]を使用しないでください。 このオプションを使った場合、AS3上でランタイムエラーを引き起こします。特に TypeError 1006。
* メタタグ[ @:protected ]を private なフィールド変数に使用しないでください。このタグをつけた変数は、AS3だとstaticに扱われます。

これらの問題は haxe 3.2.1　と FlashDevelop 5.1.1.1　で確認しています。
もしかしたら、後のバージョンでは解決しているかもしれません。    
いや、解決していてほしい。

