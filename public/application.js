$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_hits();
});


function player_hits() {
  $(document).on("click", "#hit", function() {
    $.ajax({
      url: "/hit"
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    })
    return false;
  });
};

function player_stays() {
  $(document).on("click", "#stay", function() {
    $.ajax({
      url: "/stay"
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    })
    return false;
  });
};


function dealer_hits() {
  $(document).on("click", "#dealer", function() {
    $.ajax({
      url: "/dealer_hit"
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    })
    return false;
  });
};
