CHANGELOG
=========
## ver 0.4
-------------------------------
## August 19, 2016
* fixed accessor problem on AS3. all accessor  use @:getter , @:setter　tag and #if-#end macro for swc code.
* update ATTENSIONonAS3

## ver 0.3.1
-------------------------------
## August 13, 2016
* change create Tween process. to Tween Instance recycle.
* rename VorbisInstance._currentTween -> fade. and change public, with remove getter get_fade().
* VorbisInstance.destroy reinstate try-catch.

## August 12, 2016
* update ATTENSIONonAS3.
* add ATTENSIONonAS3_jp.md
* update VorbisInstance,VorbisManager,VorbisSound,VorbisSoundChannel. rename private field to begin with Underscore.
* update VorbisManager.play. remove Unnecessary instance check processing.

## August 10, 2016
* update compileSWC.hxml add --no-traces.
* add haxelib.json

## ver 0.3
-------------------------------

## August 9, 2016
* change VorbisManager.loadSound. remove argument buffer.
* update comments and Doc.
* update README.
* add ATTENSIONonAS3.md. README_jp.md


## August 8, 2016
* bugfix VorbisSoundChannel. position return Illegal value( about Actual time + 500ms).  change Reader.currentMillisecond -> SoundChannel.position.
* update VorbisInstance,VorbisManager. some accessor have local field.
* bugfix @:protected metatag. this tag is change to static field.
* test on AS3 over... perhaps working...
* add testAS3.

## August 6, 2016
* bugfix VorbisTween.isComplete property. access private -> public.
* bugfix accessor problem.
* bug   static manager initialzie error................. thinking now.

## ver 0.2.1
-------------------------------

## August 5, 2016
* update comments. VorbisAS, VorbisInstance, VorbisManager, VorbisTween.
* change assets. and add assets.md.
* update compileTest.hxml.
* add main method to VorbisSoundTest and VorbisASTest.
* change test assets.
* update README.md. add Quick Start chapter.
* update generateDoc.bat. exclude haxe and flash default package.
* update license. MIT LICENSE.
* add LICENSE file. update README.md
* remove license.txt

## ver 0.2
-------------------------------

## August 4, 2016
* bugfix VorbisInstance loop and loopsRemaining property.    

	* loop value is...  
	0 or 1 = no loop(play Once)  
	2...X = X loop ( play X count )  
	-1 = infinitely loop.  
	* loopRemaining value is...  
	0 = loop complete or no loop.  
	1...X = playing loop. 1 is last loop.  
	-1 = infinitely loop.  

* add generateDoc.bat
* update comments. VorbisSound,VorbisSoundChannel.

## ver 0.11
-------------------------------

## August 3, 2016
* change VorbisManager set_soundtransform always return null;
* add VorbisAS.loadSoundBytes function.
* bugfix VorbisAS.play remove enableSeamlessLoop argument.
* bugfix VorbisInstance loopsremaining. return valid value.
* update VorbisInstance.loop , VorbisSoundChannel.loop. add setter. it can change loop count when already playing.
* update README.md

## ver 0.1
-------------------------------

## August 2, 2016
* rename classes.  VorbisAS, VorbisInstance, VorbisManager, VorbisTween, VorbisASTest.
* bugfix VorbisInstance onSoundComplete. null point exception when this.channel is null.
* add VorbisAS static accesor and fuctions.
* update VorbisManager property read only. groups, loadCompleted, loadFailed.
* update VorbisSoundASTest.
* add README.md

## August 1, 2016
* change VorbisSound. like a flash.media.Sound.
* 一応動いている。 SoundTweenは手を付けてないが問題ない。
* flash.media.Soundと異なり、ストリーミング再生はできないので、そこだけ気をつける必要がある。ロード完了前にplayされるとエラーが出る。
* update VorbisSoundManager. add new method addSoundBytes.
* bugfix VorbisSound constructor. loopstart is startMillisecond. this is segmentLoop. change to loopstart is 0 everytime.
* update VorbisSoundInstance,VorbisSoundManager. deleete enableSeamlessLoop.
* update test classes...

