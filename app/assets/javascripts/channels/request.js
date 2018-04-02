$(document).ready(function() {
  (function() {
    App.request = App.cable.subscriptions.create({
      channel: 'RequestChannel'
    },
    {
      connected: function() {},
      disconnected: function() {},
      received: function(data) {
        if (data.content.blank == null) {
          $('#list-comment').append('<li>' + '<div class="review-section well">' + '<div class= "row">' + '<div class="col-md-4 user-review">' + '<div class = "bold">' + '<h4>' + data.username + '</h4>' + '</div>' + '<i>' + '</i>' + '</div>' + '<div class="col-md-8">' + '<div class = comment-content>' + data.content + '</div>' + '</div>' + '</div>' + '</div>' + '</li>'
          );
        }
      }
    });
  }).call(this);
})
