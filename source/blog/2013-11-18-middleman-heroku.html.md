---
title: Middleman + Slim + Herokuでブログをつくりました
date: 2013-11-18
tags: Middleman
description: Middleman + Slim + Herokuでブログをつくりました
image: "http://rochas.cc/images/middleman.png"
---

記事はMarkdownで書いて、ビルド、デプロイまでを一気に行えるところに魅かれ、Middlemanでブログをリデザイン、Herokuにアップしました。(以前のブログ→ [Dresscording](http://dresscording.com/blog/))  

![Middleman](http://rochas.cc/images/middleman.png)

### 1. 静的サイト、ビルドツールとしてのMiddleman
[Middleman](http://middlemanjp.github.io/)はRuby製、Sinatraベースの静的サイトジェネレータです。Ruby on RailsのViewによく似ていますが、Model、Controllerはなく、ビルドした成果物はあくまでも静的なHTMLです。  
データベースがない分シンプルでありながらも、Rubyで動的な値が呼び出せたり、Railsのロジックが使えるため、HTMLをより効率的に書くことができたり、ブログにも拡張できます。
またMiddlemanはビルドツールとしての機能も持ち合わせています。
