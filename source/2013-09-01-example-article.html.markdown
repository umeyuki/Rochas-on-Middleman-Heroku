---
title: Middlemanでブログをつくろう
date: 2013-09-01
tags: Middleman, rails
---
# Middlemanでブログをつくろう

## 1. Middlemantとは  

## 2. Middleman-Blogのインストール
```sh
$ gem install middleman
$ middleman init rochas --template=blog
```
ターミナルから必要な機能のGemをインストール → config.rbに設定を書く。これを繰り返していくことがカスタマイズの基本的な方法になります。
管理画面は存在せず、黒い画面からつくっていくのです。

## 3. MiddlemanをERBからSlimに変更
```sh
$ gem install slim
```
config.rbに以下の設定を追記します。参考にさせていただきました。

```ruby
# Slim settings
Slim::Engine.set_default_options :pretty => true
# shortcut
Slim::Engine.set_default_options :shortcut => {
  '#' => {:tag => 'div', :attr => 'id'},
  '.' => {:tag => 'div', :attr => 'class'},
  '&' => {:tag => 'input', :attr => 'type'}
}
```
[yterajima/my_middleman](https://github.com/yterajima/my_middleman)

これでMiddlemanでSlimが書けるようになりました。でもデフォルトで生成されたファイルは既にERBで書かれています。困ったなーという時は[HTML2Slim](http://html2slim.herokuapp.com/)変換ツールと[Gem](https://github.com/slim-template/html2slim)があります。便利。Gemのほうが楽そうなのでGemでのやり方をご紹介します。  
HTML2SlimはHTML → Slim、ERB → Slimの両方に変換できます。  
一箇所だけバグったけどそこは手直しで。。あとはばっちりです！

```sh
$ gem install html2slim
$ erb2slim INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [options]
$ erb2slim index.html.erb index.html.slim
```
[slim-template/html2slim](https://github.com/slim-template/html2slim)
