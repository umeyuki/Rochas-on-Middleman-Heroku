---
title: Middleman + Slim + Herokuでブログをつくりました
date: 2013-10-01
tags: Middleman, Rails
layout: post
description: Middleman + Slim + Herokuでブログをつくりました
---
「Rails の View 版」というのが Middleman の第一印象。  
ブログ記事は Markdown で書けて、ライブリロードもできる。  
ウォッチ、ビルド、デプロイまでをターミナルから一気に行えるところに魅かれ、Middleman と Slim でブログをつくり、Heroku にアップしました。

![Rochas](images/rochas.jpg "Rochas")

### 1. Middlemanとは何か
Middleman とは Ruby製、Sinatraベースの静的サイトジェネレータで、ファイル構造やレイアウト・テンプレートという概念 は Ruby on Rails によく似ていています。  
大きな違いは Rails にはデータベースがあり、MVC で構成されているのに対し、Middleman にはデータベースや Model, Controller がなく、View だけで構成され、あくまで成果物は静的なHTMLである点です。そういった点から Jekyll に似ているとも言われています。  

Middlemanはデフォルト言語をERBとし、その他 Haml, Slim, Sass,  Less, Stylus, CoffeeScript, Markdown など様々なメタ言語が使え、コンパイルも自動化できます。  
また```link_to```や```stylesheet_link_tag```など Template Helpers が使えたり、Asset Pipeline という Javascript や CSS を連結、圧縮する機能もあります。  
つまり、静的サイトであるにもかかわらず動的言語であるRubyが埋め込めたり、Railsのロジックが使えることで、何回も同じようなコードを書かなくて済み、かといってデータベースの複雑さがない。しかもビルドツールとしての役割も果たすのです。  
これら Rails ではお馴染みの機能は Middleman にデフォルトで入っているものもあれば、RubyGem をインストールし```config.rb```にちょっと設定を書いていくだけで追加することができます。  

ただ Jekyll のようにデプロイ先がデフォルトでは用意されていないので、今回はHerokuにアップし
ということで早速 Middleman をインストール。Ruby2.0.0以上が必要です。



### 2. Middleman をインストール

```sh
$ gem install middleman
```
まずはMiddlemanをインストール。Middleman自体も Gem でできています。これで Middleman のライブラリやコマンドが揃い```middleman init```でプロジェクトをつくることができるようになります。  
また Extention を使いたい時は```init```コマンドの後ろにフラグをつけます。

* Middleman Blog Extention 

```sh
$ middleman init project_name --template=blog
```

``` --template=blog ```フラグを付けるとブログに必要な機能を含めることができます。  

* Middleman Blog Extention + config.ru  

```sh
$ middleman init project_name --rack --template=blog
```

```--rack ```フラグを付けるとconfig.ruファイルを追加することができます。config.ru は Heroku など Rackベースのサーバにホスティングしたい場合に必要になります。



```sh
project_name
├── Gemfile
├── Gemfile.lock
├── config.rb
├── config.ru
└── source
    ├── 2012-01-01-example-article.html.markdown
    ├── calendar.html.erb
    ├── feed.xml.builder
    ├── images
    ├── index.html.erb
    ├── javascripts
    ├── layout.erb
    ├── stylesheets
    └── tag.html.erb
```

ターミナルから必要な Gem をインストールしたら```config.rb```に設定を書く。これを繰り返していくことがカスタマイズの基本的な方法になります。
管理画面は存在せず、ターミナルとお好みのエディタだけでつくっていくのです。


### 3. ERBからSlimに変更
```sh
$ gem install slim
```
config.rbに以下の設定を追記します。参考にさせていただきました。

```ruby
Slim::Engine.set_default_options :pretty => true

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

### 4. 記事をGithubフレーバーのMarkdownで書いてみよう
MiddlemanはデフォルトでMarkdownが使えるのですが、Markdownエンジンにも色々あるみたい。Github風味で記述できるようにしたかったので、デフォルトのKramdownから[Redcarpet](https://github.com/vmg/redcarpet) に変更してみます。  
Gemfileに以下を記述 → ターミナルからインストール → config.rbに設定を追記。

```ruby
gem "redcarpet", "~> 3.0.0"
```
```sh
$ bundle install
```
```ruby
set :markdown, :tables => true, :autolink => true, :gh_blockcode => true, :fenced_code_blocks => true, :with_toc_data => true, :smartypants => true

set :markdown_engine, :redcarpet
```
[vmg/redcarpet](https://github.com/vmg/redcarpet) 

### 5. Middleman-Syntax Extentionでソースコードをきれいにしてみよう
ブログにはソースコードがつきもの。Middlemanのデフォルトにはないのですが、Middleman-Syntax Extentionが用意されていますのでそれをインストールしてみます。
Gemfileに以下を記述 → ターミナルからインストール → config.rbに設定を追記。

```ruby
gem "middleman-syntax", "~> 1.2.1"
```
```sh
$ bundle install
```
```ruby
activate :syntax
```



