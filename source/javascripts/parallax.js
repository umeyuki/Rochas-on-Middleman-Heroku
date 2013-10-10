 $(document).ready(function(){
    
    if($(window).width()>760){
      $(document).scroll(function(){
          val1 = 1.05 - ( ($(document).scrollTop()) / ($('.header').height()) );
          $('.flip').css('opacity', val1);
          val2= -1 + ( ($(document).scrollTop()) /  $(window).height()+0.8 );
          $('.footer p').css('opacity', val2);
      });
}
});
