$(document).ready(function() {
  (function() {
    App.conversation = App.cable.subscriptions.create({
      channel: 'ConversationChannel'
    },
    {
      connected: function() {},
      disconnected: function() {},
      received: function(data) {
        if (data.content.blank == null) {
          $('#list-message').append(data.message);
        }
        if (data.notify_to){
          $("#conversation-" + data.notify_to).addClass("notifying");
          $("#conversation-" + data.notify_to).on("click", function () {
              $("#conversation-"+ data.notify_to).removeClass("notifying")
          })
        }
      },
    });
  }).call(this);
})
