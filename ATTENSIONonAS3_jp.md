# !!AS3での注意事項!!

## 初期化について
もしHaxeで生成されたSWCをAS3で使う場合、まずHaxeシステムを初期化する必要があります。

example

	haxe.initSwc( new MovieClip() );
	VorbisAS.initialize();

## セッターの返り値を使用しないでください
Haxeのようにセッターの返り値を使用しないでください。例えば以下のように。

	var value:Float = instance.field = 0.5;

セッターの返り値は引数と同じ値になります。たとえ、セッター内で値が変更されてreturnされたとしてもです。     
とはいえ、基本的にAS3ではセッターの返り値はVoidです。    
そこだけ頭に留めておけば、心配しなくてもいいでしょう。


## 開発者の方へ

もし、HaxeでAS3向けにコードを書く場合、以下のメモをチェックしておくと良いかもしれません。

* メタタグ[ @:isVar ]はアクセッサー(get,set) に使用しないでください。使った場合、自動的に変数が定義され、その変数にアクセスしてもgetter/setterを通しません。
* Haxeのコンパイルオプションに[ -D swf-protected ]を使用しないでください。 このオプションを使った場合、AS3上でランタイムエラーを引き起こします。特に TypeError 1006。
* メタタグ[ @:protected ]を private なフィールド変数に使用しないでください。このタグをつけた変数は、AS3だとstaticに扱われます。

これらの問題は haxe 3.2.1　と FlashDevelop 5.1.1.1　で確認しています。
もしかしたら、後のバージョンでは解決しているかもしれません。    
いや、解決していてほしい。
	
------------------------------------
# 解決済みの問題
私がAS3向けにコーディングしていて発生した問題です。
もしかしたら、これを読んでいるあなたの助けになるかもしれないです。


## Flashネイティブのアクセッサーが動作しない問題について

**AS3上では getter/setter メソッドに直接アクセスする必要があります。**
つまり、以下のようにしてください。

example

    VorbisAS.volume; // これは動きません。

    VorbisAS.get_volume();
	var vi:VorbisInstance = VorbisAS.play(FILE_MUSIC);
	vi.get_isPlaying();     // getter
	vi.set_volume(0.5);     // setter


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


### 解決方法は？
アクセッサを書くときは以下のようにしてください。

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


生成されるAS3コード。　-as3オプションを使って生成したものです。

	protected var _fieldA : int;
	protected function get fieldA() : int {
		return this._fieldA;
	}
	
	protected function set fieldA(value : int) : int {
		this._fieldA = value + 1;
		return this._fieldA;
	}
	

そう、これです！こういうコードを待っていたんです。

ここで注目すべき点は3点あります。

**(1) メタタグ @:getter / @:setter**    
このタグはflash向けのものです。
これはゲッターセッター関数に付与します。付与された関数はネイティブなアクセッサーに変換されます。
このタグの引数はアクセッサのフィールド名です。しかし、フィールド自体が生成されるわけではないので注意が必要です。


**(2) メタタグ @:extern and extern field for SWC**   
@:extern タグは　抽象フィールド/関数を定義するためのものです。    
もし、@:getter/setterタグだけを使用した状態で、ほかのクラスでそのアクセッサフィールドにアクセスした場合、フィールド変数が見つからない、というコンパイルエラーが発生します。
externフィールドは、このエラーを回避するためのものです。externフィールドはコンパイル後は実体を持ちません。


**(3) 各プラットフォームのための　#if-else マクロ**    
上記の(1) , (2) はSWCだけのためのコードです. このままではhaxeでは動きません。    
Haxeユーザのためにコンパイルコードを分岐する必要があります。
#if (swc || as3) セクションにはSWCとAS3生成向けのコードを書きます. 
#else セクションにはHaxe向けのコードを書きます。
