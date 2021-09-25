# HeadAndBodyApp
## 環境構築
### podのバージョン確認
```
$ pod --version
1.10.2
```
podコマンドが使えない方はこちら
https://qiita.com/ShinokiRyosei/items/3090290cb72434852460
### ライブラリインストール
```
$ pod install
```
### xcworkspaceファイルを確認して開く
```
$ ls -dla HeadAndBodyDataGenerator.xcworkspace
drwxr-xr-x@ 5 reoharada  staff  160  9 25 04:43 HeadAndBodyDataGenerator.xcworkspace
$ open HeadAndBodyDataGenerator.xcworkspace
```
### xcodeでビルドを行う
