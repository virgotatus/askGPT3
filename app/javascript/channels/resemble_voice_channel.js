import consumer from "channels/consumer"

document.addEventListener('voice-channel', (e) => {
  consumer.subscriptions.create({channel: "ResembleVoiceChannel", uuid: `${e.detail}`}, {
    connected() {
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      // Called when there's incoming data on the websocket for this channel
      console.log("incoming stream websocket of resemble!");
      console.log("websocket data:", data)
      var audio = document.getElementById('audio');
      audio.src = data.audio_src_url;
      audio.volume = 0.3;
      audio.play();
    }
  });
})
