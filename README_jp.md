# VorbisAS

このライブラリはFlash、AIR上でOggVorbisファイルの再生をサポートします。
このライブラリのAPIはSoundASを参考にしています。
使用したHaxeのバージョン 3.2.1

## 機能概要
* Clean modern API　
* API Chaining: VorbisAS.play("music").fadeTo(0);
* サウンドのグルーピングをサポートします。例えばBGMグループとSEグループを分けて管理したりなど。
* シームレスなループをサポートします。
* 内部に自前のTweenシステムを持っており、外部のTweenライブラリは必要ありません。Tweenはフェード処理に使用しています。
* Modular API: Use VorbisInstance directly and ignore the rest.
* 制限が緩く、自由に使用できるライセンスです。

## クイックスタート
このライブラリを使うにあたって、まず、2つのSWCファイルをあなたのプロジェクトにインポートする必要があります。

* lib/as3-signals-v0.8.swc
* bin/VorbisAS.swc

これで準備はOKです。
あとは、VorbisASの機能を使う前に、最初にVorbisAS.initializeメソッドを呼び出す必要があります。

	VorbisAS.initialize();

これでVorbisASは使えるようになりました。エンジョイしてください。

**もしあなたが ActionScript3 ユーザの場合**、ATTENSIONonAS3.mdを必ず読んでください。


## API Overview

ドキュメント全文は次のファイルを参照してください。 [doc/pages/index.html]

### VorbisAS

このクラスはライブラリのメインインターフェイスを担います。
VorbisASクラスはファイルのロードやサウンドのコントロールをグローバルに行います。


Initialize:

*    **VorbisAS.initialize** VorbisASの初期化処理を行います。一番最初に呼び出してください。

Access:

*    **VorbisAS.manager** VorbisASの実体であるstaticインスタンスに直接アクセスできます。

Loading / Unloading: 

*    **VorbisAS.addSound**(type:String, sound:VorbisSound):Void
*    **VorbisAS.addSoundBytes**(type:String, bytes:Bytes):Void
*    **VorbisAS.loadSound**(url:String, type:String, buffer:Int = 100):Void
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
単体の音楽をコントロールします。stop,start,resume と volume変更、再生位置変更を簡単に行えます。

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

    // 外部のサウンドファイルをロードします。
    VorbisAS.loadSound("assets/Click.ogg", "click");

	// すでに生成済みのインスタンスを登録します。
    VorbisAS.addSound("click", clickSound);
	
	// すでにロード済みのOggVorbisバイナリを登録します。
	VorbisAS.addSoundBytes("click", bytes); //bytes is Bytes class(ByteArray on AS3). loaded by URLStream...etc
	
### Basic Playback

    //Play sound.
        //allowMultiple:　同時に複数のインスタンスの再生を許可します。（効果音のように同じ音を重ねて鳴らす場合に使用）
        //allowInterrupt: すでに再生されているときに、前の音を一旦停止して最初から再生します。
    VorbisAS.play("click", volume, startTime, loops, allowMultiple, allowInterrupt);

	// ゲーム効果音として鳴らす場合のショートカット関数　（ループなし、多重再生あり）
    VorbisAS.playFx("click");

	// BGMとして鳴らす場合のショートカット関数（無限ループ、単一再生）
    VorbisAS.playLoop("music");

	// 全サウンドのミュートを切り替える。
    VorbisAS.mute = !VorbisAS.mute;

    //PauseAll / ResumeAll
    VorbisAS.pauseAll();
    VorbisAS.resumeAll();
    
	// 単独サウンドインスタンスのポーズ/レジューム切り替え
    var sound:VorbisInstance = VorbisAS.getSound("music");
    (sound.isPaused)? sound.resume() : sound.pause();

    //Fade Out
    VorbisAS.getSound("click").fadeTo(0);

    //Fade masterVolume out
    VorbisAS.fadeMasterTo(0);

### Groups

    //Create a group
    var musicGroup:VorbisManager = VorbisAS.group("music");

	// グループに音楽を登録
    musicGroup.loadSound("assets/TitleMusic.mp3", "titleMusic");
    musicGroup.loadSound("assets/GameMusic.mp3", "gameMusic");

    // グループでもVorbisASと同じAPIを使用できます
    musicGroup.play("titleMusic")
    musicGroup.volume = .5;
    musicGroup.mute = muteMusic;
    musicGroup.fadeTo(0);
    //etc...

    //Stop All Groups
    for(var i:int = VorbisAS.groups.length; i--;){
        VorbisAS.groups[i].stopAll();
    }

### Advanced 

    //Mute one sound
    SoundsAS.getSound("click").mute = true;

    //Fade from .3 to .7 over 3 seconds
    VorbisAS.getSound("click").fadeFrom(.3, .7, 3000);

	// VorbisASを介さずに、VorbisInstanceを直接操作する。
    var sound:VorbisInstance = new VorbisInstance(mySound, "click");
    sound.play(volume);
    sound.position = 500; //Set position of sound in milliseconds
    sound.volume = .5; 
	sound.fadeTo(0);

	// 2つの音楽をつなげて連続で再生する。
    VorbisAS.play(MUSIC1).soundCompleted.addOnce(function(si:VorbisInstance){
        VorbisAS.playLoop(MUSIC2);
    });

	// 2回ループ再生し、ループ完了後に何らかの処理をする。
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



## ライセンス
MIT ライセンスです。
詳しくは　[LICENSE]　ファイルを見てください。    
簡単に言えば、コピーライトだけ書いてくれれば自由に使っていただいて構いません。

## フォークしたソース
もし、ソースを編集する気があるなら、以下の素晴らしいリポジトリをチェックしておくとよいでしょう。

* [treefortress/SoundAS](https://github.com/treefortress/SoundAS/)
* [shohei909/haxe\_stb\_ogg\_sound](https://github.com/shohei909/haxe_stb_ogg_sound)
* [nothings/stb single-file public domain libraries for C/C++](https://github.com/nothings/stb)

## 使用する外部ライブラリ
このライブラリを使用するにあたって、as3-signalsライブラリをインポートする必要があります。
VorbisASにはas3-signalsは含まれていません。SWCコンパイルコマンドでも含まないようにしています。
インポートするas3-signalsのSWCファイルは lib　フォルダに入っています。

* [as3-signals](https://github.com/robertpenner/as3-signals)