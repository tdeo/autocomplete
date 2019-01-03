// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery
//= require jquery-ui
//= require jquery-ui/widgets/autocomplete
//= require turbolinks
//= require_tree .

function display(city) {
  $.ajax({
    method: 'GET',
    url: '/city/' + city.idx,
    dataType: 'html',
  }).done(function(response) {
    $('#city_info').html(response);
  })

}

$(document).on('ready turbolinks:load', function() {
  $('#search').autocomplete({
    autoFocus: true,
    source: '/search',
    minLength: 3,
    delay: 250,
    focus: function(event, ui) {
      return false;
    },
    select: function(event, ui) {
      $('#search').val(ui.item.label);
      display(ui.item);
      return false;
    }
  });
});
