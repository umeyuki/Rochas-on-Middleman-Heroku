---
title: Middleman + Slim + Herokuでブログをつくりました
date: 2013-11-19
tags: Middleman
description: Middleman + Slim + Herokuでブログをつくるチュートリアルをご紹介します。
image: "http://rochas.cc/images/middleman.png"
---

記事はMarkdownで書いて、ビルド、デプロイまでを一気に行えるところに魅かれ、Middlemanでブログをリデザイン、Herokuにアップしました。

### 1. 静的サイト、ビルドツールとしてのMiddleman
[Middleman](http://middlemanjp.github.io/)はRuby製、Sinatraベースの静的サイトジェネレータです。Ruby on RailsのViewによく似ていますが、Model、Controllerはなく、ビルドした成果物はあくまでも静的なHTMLです。  
データベースがない分シンプルでありながらも、Rubyで動的な値が呼び出せたり、Railsのロジックが使えるため、HTMLをより効率的に書くことができたり、ブログにも拡張できます。
またMiddlemanはビルドツールとしての機能も持ち合わせています。

![Middleman](http://rochas.cc/images/middleman.png)

* layout、template、partialでページが構成され、共通部分をまとめることができる。  
* デフォルト言語はERBとし、変数やループ、条件分岐などRubyの文法が使える。  
* ERBの他、Haml、Slim、Sass、Less、Stylus、CoffeeScript、Markdownなどの言語が使える。  
* LiveReloadで自動コンパイルできる。  
* ```link_to```や```stylesheet_link_tag```などRailsのTemplate Helpersが使える。
* Asset PipelineでJavascriptやCSSの依存ファイルをrequireできる。
* JavascriptやCSSをminify、gzipなどパフォーマンスの最適化ができる。


これらの機能はデフォルトで入っているものもあれば、RubyGemをインストールし```config.rb```にほんの少し設定を書くだけで追加することができます。  

デプロイ環境は用意されていないので、私はHerokuにアップすることにしました。
Herokuに独自ドメインを割り当て```rochas.herokuapp.com```にアクセスがあったら```rochas.cc```にリダイレクトさせるようRack::Rewriteで指定しています。  


では実際にどのようにつくったかを少しご紹介したいと思います。  
開発には Ruby 2.0.0〜、[bundler](http://bundler.io/)を使っています。


### 2. Middlemanをインストール

```sh
$ gem install middleman
```
ターミナルからMiddlemanをインストールすると、以下のコマンドから、プロジェクトの作成、ローカルサーバの起動、ビルドができるようになります。

```sh
$ middleman init 
$ middleman server
$ middleman build

$ middleman --help
```

### 3. Middleman Blog Extentionでプロジェクトを作成
```sh
$ middleman init myproject
$ middleman init myproject --template=blog
$ middleman init myproject --rack --template=blog
```
ターミナルから```init```コマンドを実行するとプロジェクトを作成することができます。また色々なExtentionを一緒にインストールすることもできます。  
Middleman Blog Extentionを追加したい時は後ろに``` --template=blog ```フラグを付けます。

さらに```--rack ```フラグを付けると```config.ru```を追加することができます。```config.ru```は Herokuから独自ドメインにリダイレクトをかける時に必要になります。

### 4. ローカルサーバを起動
```sh
$ bundle exec middleman server
```
ターミナルから```server```コマンドを実行後、```http://localhost:4567/```にアクセスするとローカルサーバが起動します。シンプルなブログが表示されると思います。Ctrl-C でシャットダウンします。


### 5. Middleman Blogのプロジェクトフォルダを確認

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
* ```config.rb``` ─ 設定ファイル。ブログ用の設定や、ビルド時の設定などがブロックごとに、コメントアウトされています。
* ```source``` ─ 実際に開発していくファイルが格納されていて、ここがビルド対象となります。    

新たなGemをインストールしたら```config.rb```に設定を書く。  これを繰り返していくことがカスタマイズの基本的な方法になります。  
管理画面は存在しないのでターミナルとエディタだけでつくっていきます。  
```.gitignore```も含まれているのでここで```$ git init``` 。  

いよいよカスタマイズしていきます。Gemから色々な機能を追加していくとテンション上がるので、まずは``Gemfile``と``config.rb``を触ってみます。このBlogの完成予想図はこちら。  
[Gemfile](https://github.com/DressCording/Rochas-on-Middleman-Heroku/blob/master/Gemfile) / [config.rb](https://github.com/DressCording/Rochas-on-Middleman-Heroku/blob/master/config.rb)

### 6. Blogの設定をする

Blogの設定は```config.rb```から行います。タイムゾーン、パーマリンク、ファイル名、ページネーションなど、必要に応じてコメントアウトを外し有効にします。  
必ず行わなければならないのはTime.zoneの指定です。```Time.zone = "Tokyo"```に変更しました。

```ruby
Time.zone = "Tokyo"

activate :blog do |blog|
  # blog.prefix = "blog"
  # blog.permalink = ":year/:month/:day/:title.html"
  # blog.sources = ":year-:month-:day-:title.html"
  # blog.taglink = "tags/:tag.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = ":year.html"
  # blog.month_link = ":year/:month.html"
  # blog.day_link = ":year/:month/:day.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/:num"
end
```
* ```blog.prefix = "blog"```を有効にすると、ルートパスの後ろに```/blog/```が付与されます。  
```http://rocha.cc/blog/2013/11/18/middleman-heroku.html```  

* ```blog.permalink = "blog/:tag/:title.html"```とするとパーマリンクが変更されます。  
```http://rocha.cc/blog/middleman/middleman-heroku.html```

* ```blog.default_extension = ".md"```とするとMarkdownの拡張子が変更されます。  

もし何も設定しなければビルド後のサイトマップは、実際のディレクトリ通りになり、```config.rb```から設定変更した場合は実際のディレクトリより優先して適用されます。また各ページのFrontmatterからページ毎に設定することもでき、その場合にはFrontmatterが最優先されます。  
デフォルト  →  ```config.rb``` → Frontmatter  
の順に優先度が高くなり、サイトマップを自在に上書きするこどができるのです。  

ビルド後のサイトマップを確認したい時は```http://0.0.0.0:4567/__middleman/sitemap/```から確かめることができます。  

### 7. LiveReloadを使う
LiveReloadはブラウザの自動反映や、Sassなどの自動コンパイルを行ってくれます。  
Middlemanのデフォルトに入っているので```config.rb```の真ん中あたりのコメントを解除して保存するだけでLiveReloadが使えるようになります。

```ruby
activate :livereload
```
ローカルサーバを立ち上げている場合には一旦再起動すると```config.rb```の変更が適用されます。


### 8. Slimでテンプレートを書く
[Slim](http://slim-lang.com/)とは高速で軽量なテンプレートエンジンで、
```< > < />```を全部省略し、HTMLのアウトラインをインデントで表現していくのが特徴です。  
デフォルト言語のERBからにSlim変更するにはGemをインストールする必要があります。  
```Gemfile```に以下を記述。  

```ruby
gem "slim", "~> 2.0.2"
```
ターミナルから実行。

```sh
$ bundle install
```

```config.rb``` にオプションを設定。```id class```を```# .```とショートカットで書けるようにします。


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
そこで [HTML2Slim](http://html2slim.herokuapp.com/)（変換ツール）か、[slim-template / html2slim](https://github.com/slim-template/html2slim)（Gem）使って変換してみます。  
ターミナルからGemをインストール。  

```sh
$ gem install html2slim
```
変更前 変更後のファイル名を付けて実行。  

```sh
$ erb2slim index.html.erb index.html.slim
```

何箇所かエラーがでるのでそこは自力で修正。便利だけど頼りすぎはよくない。。  
Slimは[公式ドキュメント](http://rdoc.info/gems/slim/frames)か翻訳版の[yterajima / slim](https://github.com/yterajima/slim/tree/README_ja) で学びました。  
ポイントはインデント、パイプそして「RailsっぽいSlim」を書くことです。例えばHelperをつかったり、Yamlに変数をつくったりするとよさそう。


### 9. RedcarpetでMarkdownを書く
MiddlemanはデフォルトでもMarkdownは書けるのですが、Githubと同じ記法で書けるようにしたかったので、デフォルトエンジンのkramdownから[Redcarpet](https://github.com/vmg/redcarpet)に変更します。手順は同じです。  
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

### 10. Middleman-Syntaxでソースコードをフォーマットする
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
 
### 11. Middleman::Autoprefixerで適切なベンダープリフィクスを付与
Autoprefixerは[Can I use...](http://caniuse.com/)のデータをもとに、必要なベンダープリフィクスを付与したり、不要なものを削除してくれる「ポストプロセッサ」です。  
CompassのMixinなどプリプロセッサとは違うアプローチで、[Grunt](https://github.com/nDmitry/grunt-autoprefixer)のタスクにもあります。  
```Gemfile```に以下を記述 → ターミナルからインストール → ```config.rb```にサポート対象ブラウザをオプションで指定することもできます。以下の例は最新の2バージョンとIE9がサポート対象。

```sh
$ gem "middleman-autoprefixer", "~> 0.2.3"
```
```ruby
activate :autoprefixer, browsers: ['last 2 versions', 'ie 9']
```

[RubyGem](http://rubygems.org/gems/middleman-autoprefixer) / [Github](https://github.com/porada/middleman-autoprefixer)  

### 12. minify、gzipでパフォーマンスの最適化
minify、gzipはビルド時に実行される機能で、```config.rb```の下のほうにある```build```メソッドのブロック内のコメントを解除するだけで有効になります。  

```ruby
activate :minify_javascript
activate :minify_css
activate :gzip
```

### 13. ビルドする
```sh
$ bundle exec middleman build
```
ターミナルから```build```コマンドを実行すると、ルートディレクトリにbuildフォルダが生成されます。中身は```index.html.gz```という拡張子のついた、gzip化された静的ファイルであることが確認できると思います。完成後はこのフォルダをデプロイします。


### 14. Middlemanそして#p4d   
[#p4d](http://prog4designer.github.io/)の[@satococoa](https://twitter.com/satococoa)さん、[@tatsuoSakurai](https://twitter.com/tatsuoSakurai)さん、[@tkawa](https://twitter.com/tkawa)さん、[Fuchiwaki](https://www.facebook.com/daisuke.fuchiwaki) には色々なことを学ばせていただきました。本当にありがとうございます！  
[Tokyo Middleman Meetup #1](http://connpass.com/event/3851/)にも参加します。Middlemanの公式サイトやSlimドキュメントを翻訳してくださった[@yterajima](https://twitter.com/yterajima)を始め、先駆者の方々が登壇されるとのことで今から楽しみ！  


このブログのデザインコンセプト、フォントや配色、使ったツールなどについては[Style Guide](http://rochas.cc/styleguide/)ページに書きました。
ソースはGithubで公開しています。  

* [Rochas-on-Middleman-Heroku](https://github.com/DressCording/Rochas-on-Middleman-Heroku)  
