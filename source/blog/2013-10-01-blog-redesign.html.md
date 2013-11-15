---
title: Middleman + Slim + Herokuでブログをつくりました
date: 2013-10-01
tags: Middleman, Rails
description: Middleman + Slim + Herokuでブログをつくりました
image: "http://rochas.cc/images/rochas.jpg"
---

記事はMarkdownで書けて、ビルド、デプロイまでを一気に行えるところに魅かれ、Middlemanでブログをリデザイン、Herokuにアップしました。  

### 1. 静的サイト、ビルドツールとしてのMiddleman
[Middleman](http://middlemanjp.github.io/)はRuby製、Sinatraベースの静的サイトジェネレータです。Ruby on RailsのViewをつくっていくような感じで、データベースやModel、Controllerがなく、成果物はあくまでも静的なHTMLです。  
データの扱いはシンプルでありながらも、Rubyを埋め込めたり、Railsのロジックが使えることでHTMLをより効率的に書くことができます。
またMiddlemanはビルドツールとしての機能も持ち合わせています。

* layout、template、partialでページが構成され、共通部分をまとめることができる。  
* 変数やループ、条件分岐などRubyの文法が使える。  
* テンプレートにはデフォルトのERBの他、Haml、Slim、Sass、Less、Stylus、CoffeeScript、Markdownなどの言語が使える。  
* LiveReloadで自動コンパイルできる。  
* ```link_to```や```stylesheet_link_tag```などRailsのTemplate Helpersが使える。
* Asset PipelineでJavascriptやCSSの依存ファイルをrequireできる。
* JavascriptやCSSをminify、gzipなどパフォーマンスの最適化ができる。


これらの機能はデフォルトで入っているものもあれば、RubyGemをインストールし```config.rb```にほんの少し設定を書いていくだけで追加することができるのです。  

デプロイ環境は用意されていないので、私はGitからデプロイできる、Herokuにアップすることにしました。
Herokuに独自ドメインを割り当て、```rochas.herokuapp.com```にアクセスがあったら```rochas.cc```にリダイレクトさせるようRack::Rewriteで指定しています。  


では実際にどのようにカスタマイズしたかをご紹介したいと思います。  
Ruby2.0.0以上、bundlerが必要です。


### 2. Middlemanをインストール

```sh
$ gem install middleman
```
これで以下のコマンドから、プロジェクトの作成、ローカルサーバの起動、ビルドができるようになります。

```sh
$ middleman init 
$ middleman server
$ middleman build

$ middleman --help
```

### 3. Middleman Blog Extentionでプロジェクトを作成する
```sh
$ middleman init myproject
```
ターミナルから```init```コマンドを実行するとプロジェクトを作成することができます。
Middleman Blog Extentionを追加したい時は後ろに``` --template=blog ```フラグを付けます。

```sh
$ middleman init myproject --template=blog
```

さらに```--rack ```フラグを付けると```config.ru```を追加することができます。```config.ru```は Herokuから独自ドメインにリダイレクトをかける時に必要になります。

```sh
$ middleman init myproject --rack --template=blog
```

### 3. ローカルサーバを起動する
```sh
$ bundle exec middleman server
```
ターミナルから```server```コマンドを実行後、```http://localhost:4567/```にアクセスするとローカルサーバが起動します。ブログのベースとなるものが表示されると思います。Ctrl-C でシャットダウンします。

### 4. Middleman Blogのプロジェクトフォルダを確認する

```sh
myproject
├── Gemfile
├── Gemfile.lock
├── config.rb
├── config.ru
├── .gitignore
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

* ```Gemfile``` ─ これからインストールするGemとバージョンを書くレシピ。
* ```Gemfile.lock``` ─ すでにインストール済のGemと依存関係にあるGemが書かれている。どんなGemがどのバージョンで入っているか、バージョンエラーが起きた時などの確認用で、編集することはありません。ここを見るとLiveReload、Sass、Compass、Hamlは既に入っているのでインストールする必要ないということがわかります。
* ```config.rb``` ─ 設定ファイル。ディレクトリ名、パーマリンク、ページネーションなどブログ用の設定や、ビルド時の設定などがブロックごとに、コメントアウトされています。
* ```source``` ─ 実際に開発していくファイルが格納されていて、ここがビルド対象となります。    

新たなGemをインストールしたら```config.rb```に設定を書く。  これを繰り返していくことがカスタマイズの基本的な方法になります。  
管理画面は存在しないのでターミナルとお好みのエディタだけでつくっていきます。  
ちゃんと```.gitignore```も含まれていますね、ここで```$ git init``` 
いよいよカスタマイズしていきます。

### 5. LiveReloadを使う
LiveReloadはブラウザの自動反映や、Sassなどの自動コンパイルを行ってくれます。  
Middlemanのデフォルトに入っているので```config.rb```の真ん中あたりのコメントを解除して保存するだけでLiveReloadが使えるようになります。

```ruby
activate :livereload
```
ローカルサーバを立ち上げている場合には一旦再起動すると```config.rb```の変更が適用されます。


### 6. Slimでテンプレートを書く
[Slim](http://slim-lang.com/)とは高速で軽量なテンプレートエンジンで、
閉じタグどころか```< > < />```を全部省略し、HTMLのアウトラインをインデントで表現していく感じです。  
デフォルト言語のERBからにSlim変更するにはGemをインストールする必要があります。  
```Gemfile```に以下を記述。  

```ruby
gem "slim", "~> 2.0.2"
```
ターミナルから実行。

```sh
$ bundle install
```

```config.rb``` に設定を記述。


```ruby
Slim::Engine.set_default_options :pretty => true

Slim::Engine.set_default_options :shortcut => {
  '#' => {:tag => 'div', :attr => 'id'},
  '.' => {:tag => 'div', :attr => 'class'},
  '&' => {:tag => 'input', :attr => 'type'}
}
```

[RubyGem](http://rubygems.org/gems/slim) / [Github](https://github.com/slim-template/slim)

これでSlimが書けるようになります。でもデフォルトで生成された  
```index.html.erb```、```calendar.html.erb```、```tag.html.erb```、```layout.erb```の4つのファイルは既にERBで書かれているので直さなければなりません。  
そこで [HTML2Slim](http://html2slim.herokuapp.com/)（変換ツール）か、[slim-template/html2slim](https://github.com/slim-template/html2slim)（Gem）使って変換してみます。  
ターミナルからGemをインストール。  

```sh
$ gem install html2slim
```
変更前 変更後のファイル名を付けて実行。  

```sh
$ erb2slim index.html.erb index.html.slim
```

何箇所かエラーがでるのでそこは自力で修正。便利だけど頼りすぎはよくない。


### 7. RedcarpetでMarkdownを書く
MiddlemanはデフォルトでもMarkdownは書けるのですが、Githubフレーバーで書けるようにしたかったので、デフォルトエンジンのkramdownから[Redcarpet](https://github.com/vmg/redcarpet)に変更します。手順は同じです。  
```Gemfile```に以下を記述 → ターミナルからインストール → ```config.rb```に設定を記述

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
[RubyGem](http://rubygems.org/gems/redcarpet) / [Github](https://github.com/vmg/redcarpet) 

### 8. Middleman-Syntaxでソースコードをフォーマットする
Middlemanのデフォルトにはないので、Middleman-Syntaxをインストールします。  colorを付けたい場合は別途RougeというGemも必要です。  
```Gemfile```に以下を記述 → ターミナルからインストール → ```config.rb```に設定を記述

```ruby
gem "middleman-syntax", "~> 1.2.1"
```
```sh
$ bundle install
```
```ruby
activate :syntax
```
[RubyGem](http://rubygems.org/gems/middleman-syntax) / [Github](https://github.com/middleman/middleman-syntax)
 
### 9. Middleman::Autoprefixerでベンダープレフィックス
[Can I use...](http://caniuse.com/)

```sh
$ gem "middleman-autoprefixer", "~> 0.2.3"
```
```ruby
activate :autoprefixer, browsers: ['last 2 versions', 'ie 8', 'ie 9']
```

[RubyGem](http://rubygems.org/gems/middleman-autoprefixer) / [Github](https://github.com/porada/middleman-autoprefixer)

### 10. minify、gzipでパフォーマンスの最適化
```ruby
activate :minify_javascript
activate :minify_css
activate :gzip
```


### 11. Middlemanそして#p4d 
必要な機能だけをシンプルな方法で追加していく。このスタイルはデザインしていても、コードをかいていても、とても心地がいいと感じました。
とはいえひとりでは解決できなかったこともたくさんあり、ブログを公開できたのは[#p4d](http://prog4designer.github.io/)の存在が大きかった。  
オーガナイザーの[@satococoa](https://twitter.com/satococoa)さん、[@tatsuoSakurai](https://twitter.com/tatsuoSakurai)さん、[@tkawa](https://twitter.com/tkawa)さん、Fuchiwakiさんが先生になってくださり、ソースコードをRails風にリファクタリングしたり、Gitを使ったHerokuへのデプロイ、rackベースのリダイレクトなど色々なことを学びました。  
これらはMiddlemanに限ったことではなくて、RailsやRubyにつながるし、ワークフローの見直しにもなると思います。なので次回以降もう少しこのチュートリアルの続きを書いていきたいと思っています。本当にありがとうございました。  
<p class="note ">* [#p4d](http://prog4designer.github.io/) ─ デザイナーとプログラマーで集まってWebやアプリをつくったりデザインやプログラミングについて相談したりする会</p>



















