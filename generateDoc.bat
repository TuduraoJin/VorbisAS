rem use haxelib dox1.0.0
rem you need install dox. https://github.com/HaxeFoundation/dox
haxe -cp ./src -D doc-gen -swf-lib lib\as3-signals-v0.8.swc --macro include('jp.gr.java_conf.ennea.sound') --macro include('stb.format') --no-output -xml ./doc/VorbisAS.xml -swf ./doc/DocDummy.swf
haxelib run dox -i ./doc -o ./doc/pages --title VorbisAS --exclude "^haxe.*|^flash.*|^[A-Z]"
pause
