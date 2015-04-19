$(document).ready(function() {
  $('#hit_button input').click(function() {
    alert("Player hits");

    $.ajax({
      type: "POST",
      url: "/game/player/hit"
    }).done(function(msg) {
      $("#game").html(msg)
    });
    return false;
  });
});

/*function player_hit() {
  $(document).on("click", "form#hit_button input", function() {
    alert("Player hits");
    $.ajax({
      type:'POST',
      url: '/game/player/hit'
    }).done(function(msg) {
      $('div#game').replaceWith(msg);
    });
    return false;
  });
}

function player_stay() {
  $('document').on("click", "#stay_button")
}*/
