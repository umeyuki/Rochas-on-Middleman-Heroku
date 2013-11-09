---
title: Middleman + Slim + Herokuでブログをつくりました
date: 2013-10-01
tags: Middleman, Rails
layout: post
description: Middleman + Slim + Herokuでブログをつくりました
image: "http://rochas.cc/images/rochas.jpg"
---
「Rails の View 版」というのが Middleman の第一印象。  
ブログ記事は Markdown で書けて、ライブリロードもできる。  
ウォッチ、ビルド、デプロイまでをターミナルから一気に行えるところに魅かれ、Middleman と Slim でブログをつくり、Heroku にアップしました。

![Middleman](images/middleman.png "Middleman")

### 1. Middlemanとは何か
[Middleman](http://middlemanjp.github.io/)はRuby製、Sinatraベースの静的サイトジェネレータで、ファイル構造はRuby on Railsによく似ていています。大きな違いはRailsはMVCで構成されているのに対し、MiddlemanにはデータベースやModel、Controllerがなく、Viewだけで構成され、あくまで成果物は静的なHTMLである点です。  
