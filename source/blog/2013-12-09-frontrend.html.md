---
title: Chrome Developer Teamから学ぶサイトパフォーマンス
date: 2013-12-09
tags: Performance, Chrome Dev Tools
description: 
image: "http://rochas.cc/images/frontrend1.gif"
---

[Frontrend x Chrome Tech Talk Night Extended](http://frontrend.github.io/events/chrome/)で、Addy氏、Jake氏、Paul氏のセッションに感動し、[Frontrend Advent Calender 2013](http://www.adventar.org/calendars/62)に参加させていただきました。9日目のRochasです。  

昨今のモバイリズムの中、ユーザーの85％がデスクトップと同等かそれ以上にモバイルでの高速化を求め、57%以上がロードに3秒以上かかるサイトからは離脱してしまうとの[統計結果](http://www.strangeloopnetworks.com/web-performance-infographics/)が示すように、私達は様々なデバイスやアクセス環境でのテストが必要になりました。  
これらの問題をより早い段階で効率良く解決していくにはどうしたらいいのでしょうか。  

<section class="note">

 * The Mobile Web Development Workflow ─ Addy Osmani  
[Vimeo](http://vimeo.com/78326642) / [Speaker Deck](https://speakerdeck.com/addyosmani/mobile-web-development-workflow)  

 * Rendering without lumpy bits ─ Jake Archibald  
[Vimeo](http://vimeo.com/78330147) / [Speaker Deck](https://speakerdeck.com/jaffathecake/rendering-without-lumps)  

 * Mobile Web Developer Tools & Performance ─ Paul Irish  
[Vimeo](http://vimeo.com/78331559) / [Google Drive](https://docs.google.com/presentation/d/1LEk6KoNk8-yL-Ge-y3mw4pV-Z9J8wjMXX_E77Rwq1rw/pub?start=false&loop=false&delayms=3000#slide=id.p)  
</section>

Addy氏はモバイルサイト開発のためのツールやワークフローについて。Jake氏はレンダリングパフォーマンスについて。  Paul氏はChrome Dev ToolsのRemote Debuggingをライブで披露してくださいました。  
Chrome Developer Teamから学んだ中から特に心に残ったところをまとめてみたいと思います。

<section class="note">
### Agenda
1. [レンダリングプロセス](#lesson1)
 * [Layout](#lesson2)
 * [Paint](#lesson3)
2. [Chrome Dev Toolsを使ったループ処理のデバッグ](#lesson4)<br/><br/>
3. [モバイルのタップの300msの遅延とuser-scalable=no](#lesson5)<br/><br/>
4. [グラフィクスパフォーマンス](#lesson6)
 * [setTimeout vs requestAnimationFrame](#lesson7)
 * [CPU vs GPU](#lesson8)
 * [requestFramaAnimation vs CSS transform](#lesson9)
 * [@keyframes top/left vs @keyframes transform](#lesson10)
5. [TranslateZ Hackとは何か](#lesson11)
 * [TranslateZ Hackでスクロールパフォーマンスを改善する](#lesson12)
6. [まとめ](#lesson13)
</section>

<h3 id="lesson1">1. レンダリングプロセス</h3>
ページがロードされてから、ドキュメント内のタグを解析し、Webページに表示するまでをレンダリングといいます。  
ブラウザで何が起きているのか、このレンダリングプロセスがパフォーマンスに大きく影響します。  

1. Parsing  
レンダリングエンジンがHTMLドキュメントのタグを解析し、DOMツリーが構築される。  

2. Recalculae Style  
DOMツリーとスタイル情報からセレクタマッチングが行われ、レンダーツリーが構築される。  

3. Layout  
レンダーツリーの位置的な情報やボックスサイズを元にスクリーンにLayoutされる。  
```width, margin, border, left, top```  

4. Paint  
レンダーツリーの視覚的な情報を元にスクリーンにPaintされる。  
```box-shadow, border-radius, background, outline``` 

![Rendering Process](images/frontrend1.jpg)  

Chrome Dev ToolsのTimelineで検証してみると、ローディングが進む度に、Scriptが呼び出され、LayoutやPaintが繰り返し発生していることがよくわかります。ではこのTimelineを見て、何をどうチューニングすべきなのでしょうか。  

<h4 id="lesson2">Layout</h4>
* Layoutは、DOMノードの追加・削除、スクロール、ウィンドウのリサイズ、オリエンテーションの変更など、位置的な情報が計算されることによって発生します。  

* Layout発生のトリガーとなるJavaScript  
```offsetTop, offsetLeft, offsetWidth, offsetHeight```  
```clientTop, clientLeft, clientWidth, clientHeight```  
```scrollTop, scrollLeft, scrollWidth, scrollHeight```  
```scrollBy(), scrollTo(), scrollX, scrollY```  
```getComputedStyle(), getClientRect()```  
```height, width```  

* Layoutは親要素に遡って再計算されるため、パフォーマンスに大きなダメージを与えます。  
```position: relative```だとdocumentルートから再計算されます。どこでLayoutが発生しているのかを意識し、極力発生範囲を限定しましょう。

* ```visiblity: hidden```を指定するとpaintが発生しますが、```display: none```だと位置的な情報が失われるため、Layoutが発生してしまいます。  

<h4 id="lesson3">Paint</h4>
* PaintはLayoutほどダメージは大きくないとはいえ、むしろ発生源が多く侮れない。```box-shadow```と```border-radius```の併用はやめたり、値を10pxから5pxに下げるなどスタイルを調整してみましょう。  

* Paint負荷が高いプロパティ  
```gradient```  
```box-shadow```  
```border-radius```  
```filter: blur```  
```background```  
```position:fixed```  
```background-attachment: fixed```  

* CSSプロパティの中でも```transform```と```opacity```はCompositeされ、GUIレンダリングで処理できるためPaintタイムを抑えることができます。  

* Chrome Dev Tools > Setting > General > にはPaintを可視化する便利な機能があります。最近Canaryは挙動がかわり、chrome://flagsで設定するようになった模様。
 * Show paint rectangles ─ Paintの発生箇所を赤い線で表示。  
 * Enable continues page repaintin ─ ペイントタイム(ms)をヒストグラムで計測。  
 * Show composite layer borders ─ Compositeされているレイヤーをオレンジの線で表示。 


<h3 id="lesson4">2. Chrome Dev Toolsを使ったループ処理のデバッグ</h3>
では実際にChrome Dev ToolsのCanaryで、[Demo](http://jsbin.com/oNiVUYe/3/quiet)を使ってJake氏のデバッグを再現してみます。  
緑色のボックスをリサイズすると、それに追随してテキストの```width```も変わる仕組になっています。  
これをTimelineパネルから検証するとScriptingとLayoutが多発していることがわかります。

![Timeline Panel](images/frontrend2.jpg)  

① スタートボタンから検証開始。  
② グラフの突出している部分をドラッグで絞り込む。  
③ 警告！の部分を選択すると詳細が表示されます。この例だと124行目がボトルネックとなっており、ドキュメント全体でLayoutが発生しているので事態は深刻です。  
ここをClickするとSourceパネルの124行目に飛び、JavaScriptを修正することができます。  
原因は、```width=offsetWidth```なループ処理。要素の位置を取得して、設定させるため、位置的な再計算が繰り返されているのです。

![Source Panel](images/frontrend3.gif)  

これを以下のように修正してみます。取得した値は何回も呼び出すのではなくローカル変数にキャッシュし呼び出しを1回にするとパフォーマンスは向上します。

Bad  

```
while (i--) {
  var greenBlockWidth = sizer.offsetWidth;
  ps[i].style.width =  greenBlockWidth + 'px';
}
```

Better  

```
var greenBlockWidth = sizer.offsetWidth;
  while (i--) {
    ps[i].style.width = greenBlockWidth + 'px';
  }
```  

<h3 id="lesson5">3. モバイルのタップの300msの遅延とuser-scalable=no</h3>
快適なユーザー体験を与えるためにはロードスピードだけではありません。ユーザーは何らかのアクションをしてからレスポンスがあるまで、100ms以上かかると遅いと感じるとされています。  
しかしモバイルでは、タップしてからイベント発生までに300msの遅延が生じます。その理由はシングルタップなのかダブルタップなのかを判定するため300msの```delay```が指定されているからです。  

Click Eventではなくて Touch Events (```touchstart```/```touchend```) を使えばイベントの発生と実行が同期され、300msの遅延を防ぐことができます。しかしModern IEはTouch Eventsに対応していないため、Pointer Eventsを使わなければなりません。  

Chrome for Android、Firefox for Android32からはviewportに```user-scalable=no```または```minimum-scale=1, maximum-scale=1```で拡大禁止にすることで300msの遅延を防げるようになりました。   

<a href="http://patrickhlauke.github.io/touch/tests/event-listener_user-scalable-no.html">![remove 300ms delayl](images/frontrend4.jpg)</a>
  

こちらは[Webkit Bugzilla](https://bugs.webkit.org/show_bug.cgi?id=122212) が行なった[テスト](http://patrickhlauke.github.io/touch/tests/event-listener_user-scalable-no.html)ですが、依然iOS Safari、Androidは対応していませんし、Modern IEの場合は```-ms-touch-action: none```といったように処理を分けなければなりません。  
マルチデバイス対応に関しては[FastClick](https://github.com/ftlabs/fastclick)などpolyfillを使うという選択肢もありますが、ダブルタップやピンチによる拡大ができなくなる点は解決しません。  
300msの遅延回避することで逆にアクセサビリティが損なわれてしまわないか、よく検討する必要があります。  

<h3 id="lesson6">4. グラフィクスパフォーマンス</h3>

<h4 id="lesson7">setTimeout vs requestAnimationFrame</h4>
フレームレートとは動画やアニメーションで1秒間に何回フレームが描画されるかを単位FPS(Frame Per second)で表したものです。ブラウザの一般的なリフレッシュレートは60Hzであり、スムーズなアニメーションを実現するには16.67ms以内に処理を完結させる必要があります。  

![16ms=.0167秒 1/.0167秒=60FPS](images/frontrend5.gif)  

従来の```setTimeout```や```setInterval```の場合、フレームレートを一定に保つことが難しく、アニメーションがガタガタしやすい。
一方```requestAnimationFrame```は、60FPSを振り切らないよう考慮されており、またタブがアクティブでない場合は、実行回数が自動的に低下しCPUの負荷を抑えることができます。    
JavaScriptベースのアニメーション、canvas、WebGL、SVGで有効です。  
ただしIE9以下、Androidは非対応なのでsetTimeoutによるフォールバックと、ベンダープリフィクスが必要です。  

```
window.requestAnimFrame = (function(){
  return  window.requestAnimationFrame       ||
          window.webkitRequestAnimationFrame ||
          window.mozRequestAnimationFrame    ||
          function( callback ){
            window.setTimeout(callback, 1000 / 60);
          };
})();
```


<h4 id="lesson8">CPU vs GPU</h4>
CPUレンダリングは1枚のスクリーン上で連続して処理を行うのに対し、
GPUレンダリングは描画処理を分割して並行処理を行うため負荷を分散させることができます。  
このあたりの内部構造についてはginpei_jpさんが語ってくださっています。  
<p class="note">[スムーズなアニメーションを実装するコツと仕組みを説明するよ。CPUとGPUを理解しハードウェアアクセラレーションを駆使するのだ！- Ginpen.com](http://ginpen.com/2013/12/06/hardware-acceleration/)</p>

現在Chromeでは以下の条件下ではほとんどのOSでハードウェアレンダリングモードになり、より高速なグラフィクスアニメーションが可能となります。  
[chrome://gpu/](chrome://gpu/)  から自分のOSでのハードウェアレンダリング対応が確認できます。

3D transform  
Animation (transform, opacity, fillter)  
Flash, Silverlight  
Canvas  
Video  

また```Transform```と```opacity```に関しては、Chrome、Firefox、Safari、Opera、(IE11は条件が違うかも)でハードウェアレンダリングが可能です。  

<h4 id="lesson9">requestFramaAnimation vs CSS transform</h4>
JSベースのアニメーションsetTimeoutや```setInterval```、```requestAnimationFrame```でさえ、CPUレンダリングで処理されるため、負荷がかかってしまうケースがあります。  
一方TransformやOpacityを伴うCSSアニメーションは、レイヤーが分割され(Composite)、GPUレンダリングで処理されるため、Paintの発生を押さえることができます。  

```scale → transform: scale(n)```  
```move → transform translateX(npx)```  
```rotate → transform: rotate(ndeg)```  
```fade → opacity: 0..1```  

<h4 id="lesson10">@keyframes top/left vs @keyframes transform</h4>
ただしCSSアニメーションが全て速いというのは早とちりで、top/leftを使ったキーフレームアニメーションではLayoutが発生し、ガタガタになってしまいます。 同じ```@keyframes```でも```transforｍ```を使うとスムーズになります。  Demoは-webkit-のみベンダープリフィクス付き。

<a class="jsbin-embed" href="http://jsbin.com/ESAKuwuk/1/embed?css,output">@keyframes top/left</a><script src="http://static.jsbin.com/js/embed.js"></script>  

<a class="jsbin-embed" href="http://jsbin.com/uxAjeNAt/1/embed?css,output">@keyframes transform</a><script src="http://static.jsbin.com/js/embed.js"></script>  

違いがわかりにくいかもしれないが計測してみると一目瞭然。```@keyframes transform```はPaintタイムが0ms。オレンジの線のところでレイヤーがCompositeされ、GPUレンダリングになっています！  

![Keyframes Amnimation](images/frontrend6.gif)  

GPU対応は今のところCSSアニメーションのほうが進んでいるけれども、JSにしかできない表現もあるし、canvas、WebGLやSVGなど、アニメーションを実装する方法は色々ありますので、特徴を抑えておきたいですね。

<h3 id="lesson11">5. TranslateZ Hackとは何か</h3>
TranslateZ HackとはGPUレンダリングを利用したハックです。  
```-webkit-transform: translateZ(0);```または```-webkit-transform: translate3d(0,0,0);```を指定すると、レイヤーがCompositeされ、Chrrome上でハードウェアレンダリングモードに切り替わり、パフォーマンスが改善されるのです。
JSベースや、CompositeされないCSSアニメーション(```transform```でない)に対して、半ば無理やりGPUレンダリングを実行しようという試みです。

<h4 id="lesson12">TranslateZ Hackでスクロールパフォーマンスを改善する</h4>
ここでまた[Demo](http://jsbin.com/oNiVUYe/3/quiet)を使ってPaul氏のデバッグを再現してみます。  
body全体に背景画像を固定した```position: fixed```なレイアウトは、Documentルートから画像が再配置されるため、LayoutとPaintの両方が発生します。 実際スクロールをするとバグる時があり、とくにモバイルだと事態は深刻です。これをTranslateZ Hackで改善してみます。  

![TranslateZ Hack](images/frontrend7.jpg)  

Bad  

```
<style>
  body {
    background: url("images/bg.jpg") fixed;
    background-size: cover;
  }
  </style>
</head>
<body>
```

Better  

```
<style>
  .bg {
      background: url("images/bg.jpg");
      position: fixed;
      -webkit-transform: translateZ(0);
      background-size: cover;
      top: 0;
      left: 0;
      z-index: -1;
      width: 100%;
      height: 100%;
  }
  </style>
</head>
<body>
     <div class="bg"></div>
```
ポイントは```-webkit-transform: translateZ(0);```をbodyではなく、あえて1つ下の階層のDivに指定している点です。
TranslateZ Hackは安物のビールのようなもの、やり過ぎはよくないのです！  

Worst

```
body {
  webkit-transform: translateZ(0);
}
```

例えば、bodyや*アスタリスクだと全ての要素がレイヤーに分割されます。するとGPUの使い過ぎで逆にパフォーマンスは落ちてしまいます。  
TranslateZ Hackはアニメーション要素だけに限定し、Chrome Dev Toolsで確認をしましょう。


<h3 id="lesson13">6. まとめ</h3>
* LayoutやPaintの多発はレンダリングパフォーマンスにダメージを与える。
* LayoutのトリガーとなるJavaScriptを探そう。
* Paintコストの高いCSSプロパティによる過剰な装飾はやめよう。
* FPSは常に16.67msを維持しよう。
* GPUレンダリングを使ってCPUメモリを解放しよう。
* JSベースのアニメーションは```setTimeout```や```setInterval```ではなく```requestAnimationFrame```を使おう。
* CSSアニメーションは```@keyframes top/left```より```@keyframes transform```がスムーズ。
* TranslateZ Hackは用法用量を守りましょう。
* 以上Tipsは大事だけれども、継続的にTestを繰り返すことが最も大切。 


> ルールよりツール。─ Addy Osmani  

> Webはセマンティクス、リーダブル、アクセシブルであるべき。 ─ Jake Archibald  

> 目指すところは、フレームレート60FPS以内、サーバーレスポンス200ms以内、ページインデックス1000ms以内。 ─ Paul Irish  


最後に。。このイベントを支えてくださったみなさま、本当にありがとうございました。Google Teamとサイバーエージェントのスピーカーの方々がお互いリスペクトし合っているのがとても印象に残っています。    
それでは明日は[tomofさん](http://www.adventar.org/calendars/62)。 よろしくお願いいたします。

<section class="note">
### 参考
 * [Layout、Paintingとは何か？レンダリングから学ぶWebサイトのパフォーマンス - Dress Cording](http://dresscording.com/blog/performance/layout_painting.html)
 * [VelocityConf: Rendering Performance Case Studies // Speaker Deck] (https://speakerdeck.com/addyosmani/velocityconf-rendering-performance-case-studies)
 * [Touch And Mouse Together Again For The First Time - HTML5 Rocks](http://www.html5rocks.com/en/mobile/touchandmouse/)
 * [Why Moving Elements With Translate() Is Better Than Pos:abs Top/left - Paul Ilish](http://www.paulirish.com/2012/why-moving-elements-with-translate-is-better-than-posabs-topleft/)
 * [Accelerated Rendering in Chrome: The Layer Model - HTML5 Rocks](http://www.html5rocks.com/ja/tutorials/speed/layers/)
 * [On translate3d and layer creation hacks - Aerotwist](http://aerotwist.com/blog/on-translate3d-and-layer-creation-hacks/)
</section>
