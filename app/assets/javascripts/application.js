// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//Turbo links disabled as temp fix of more/less options on signin/signup pages
// require turbolinks
//= require bootstrap-sprockets
//= require myusa
//= require bootstrap-tokenfield

$(function() {
  
  var menuToggle = $('#myusa-button-nav_mobile').unbind();

  menuToggle.on('click', function(e) {
    e.preventDefault();
    $('#myusa-menu_mobile').slideToggle(function(){
      if($('#myusa-menu_mobile').is(':hidden')) {
        $('#myusa-menu_mobile').removeAttr('style');
      }
    });
  });
});
