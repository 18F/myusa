$(document).ready(function () {
  var background = false;

  $(".scope-list li").each(function(){

    if($(this).children().find('input[type=text]').length < 1){
      $(this).children().eq(1).delay(500).slideToggle();
      $(this).children().eq(0).children().eq(0).delay(500).toggleClass("rotate");
    }
  });

  $(".more-options").show();
  // hide or show the sign in buttons
  $(".more-options").click(function (e) {
    $(".hidden-buttons").show();
    $(".more-options").hide();
    $(".less-options").show();
    $(".omniauth-buttons").hide();
  });

  // toggle sign in and sign up forms
  $("#cta-signin").click(function (e) {
    console.log(e);
    $("#cta-signin").hide();
    $("#cta-signup").show();
    $(".content-signup").hide();
    $(".content-signin").show();
  });
  $("#cta-signup").click(function (e) {
    console.log(e);
    $("#cta-signup").hide();
    $("#cta-signin").show();
    $(".content-signin").hide();
    $(".content-signup").show();
  });

  $(".scope-list li").click(function(){
    $(this).children().eq(1).slideToggle();
    $(this).children().eq(0).children().eq(0).toggleClass("rotate");
  });

  $(".scope-list li p").click(function(){
    event.stopPropagation();
  });

  // DEBUG functions
  $("#debug-hide").click(function (e) {
    $(".debug").hide(400);
  });
  $("#debug-toggle").click(function (e) {
    // non-white buttons showing
    if ($($(".content-signin .btn")[0]).hasClass('btn-google')) {
      var buttons = ["btn-google", "btn-paypal", "btn-symantec"];
      for (var i = 0; i < buttons.length; i++) {
        var b = $($("." + buttons[i])[0]);
        b.removeClass(buttons[i]);
        b.addClass(buttons[i]+"-white");        
      }
    }
    // white buttons showing
    else {
      var buttons = ["btn-google", "btn-paypal", "btn-symantec"];
      for (var i = 0; i < buttons.length; i++) {
        var b = $($("." + buttons[i] + "-white")[0]);
        b.removeClass(buttons[i] + "-white");
        b.addClass(buttons[i]);        
      }
    }
  });
});
