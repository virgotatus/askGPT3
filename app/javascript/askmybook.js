function split_question(alter_context) {
  var text_arr = alter_context.split("+");
  var random_chose = parseInt(Math.random()*(text_arr.length));
  return text_arr[random_chose];
}

function click_lucky(alter_context) {
  var context = split_question(alter_context);
  // Get the text field element
  var bodyField = document.getElementById("prompt_body");
  // Set the value of the text field
  bodyField.value = context;
}

$(document).ready(function() {
  const luckyButton = document.getElementById("lucky-button");
  // Bind a "click" event listener to the button element
  luckyButton.addEventListener('click', function(event) {
    // This function will be called when the button is clicked
    document.getElementById('ask-button').click();
    console.log('Button clicked!');
  });

  $("textarea").bind('input propertychange', function(e) {
    $(".buttons").show();
    document.getElementById('answer-container').classList.remove("showing");
    document.getElementById('audio').pause();
    $("#ask-another-button").css("display", "none");
  });

  $("#ask-another-button").click(function(e) {
    $(".buttons").show();
    document.getElementById('answer-container').classList.remove("showing");
    document.getElementById('audio').pause();
    $("#ask-another-button").css("display", "none");
    $("textarea").select();
  });

  var showText = function(target, message, index) {
    if (index < message.length) {
      var interval = parseInt(Math.random()*40 + 30);
      $(target).append(message[index++]);
      setTimeout(function () { showText(target, message, index); }, interval);
    } else {
      //history.pushState({}, null, "/question/" + window.newQuestionId);
      $("#ask-another-button").css("display", "block");
    }
  }
  
  
  $("form").submit(function(e) {
    if (document.getElementById("prompt_body").value == "") {
      alert("Please ask a question!");
      e.preventDefault();
      return false;
    }

    let askButton = document.getElementById("ask-button");
    askButton.textContent = "Asking...";
    askButton.disabled = true;
    
    // Make the AJAX request
    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: $(this).serialize(),
      datatype: "json",
      encode: true,
      beforeSend: function(xhr) {
        // Do something before the request is sent
        var token = $('meta[name="csrf-token"]').attr('content');
        console.log(token);
        xhr.setRequestHeader('X-CSRF-Token', token);
      },
      success: function(data) {
        // Do something with the response data
        $(".buttons").hide();
        console.log(data);

        var answer = document.getElementById('answer');
        answer.innerHTML = "";
        document.getElementById('answer-container').classList.add("showing");
        window.answerShower = setTimeout(function() {
          showText("#answer", data.answer, 0);
        }, 1200);

        if (data.audio_src_url) {
          var audio = document.getElementById('audio');
          audio.src = data.audio_src_url;
          audio.volume = 0.3;
          audio.play();
        }
        else {
          console.log(data.audio_uuid);
          const eventAudioChannel = new CustomEvent("voice-channel", {
            detail: data.audio_uuid,
          });
          document.dispatchEvent(eventAudioChannel);
        }

        askButton.textContent = "Ask question";
        askButton.disabled = false;
        console.log("submit success");
        //window.newQuestionId = data.id;
      },
      error: function(xhr, textStatus, errorThrown) {
        // Handle errors here
      },
      complete: function() {
        // Do something after the request is complete
      }
    });

    e.preventDefault();
    return false;
  });

  $("#test-resemble").click(function(e) {
    post_message = {"id": "cecad6xf9",
    "project_id": "3700a2f1",
    "url": "https://app.resemble.ai/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBCTlpMVkF3PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--6212af427bea869ec1970ba9417ee3681d84fc78/cecad6f9-22694eeb.wav"};
    $.ajax({
      type: "POST",
      url: "/prompts/resemble_callback",
      data: post_message,
      datatype: "json",
      encode: true,
      beforeSend: function(xhr) {
        // Do something before the request is sent
        var token = $('meta[name="csrf-token"]').attr('content');
        console.log(token);
        xhr.setRequestHeader('X-CSRF-Token', token);
      },
      success: function(data) {
        console.log("post test resemble");
      },
    });

  });

})

/*
<script>
$(document).ready(function() {
  var showText = function(target, message, index) {
    if (index < message.length) {
      var interval = randomInteger(30, 70);
      $(target).append(message[index++]);
      setTimeout(function () { showText(target, message, index); }, interval);
    } else {
      history.pushState({}, null, "/question/" + window.newQuestionId);
      $("#ask-another-button").css("display", "block");
    }
  }

  $("textarea").bind('input propertychange', function(e) {
    $(".buttons").show();
    document.getElementById('answer-container').classList.remove("showing");
    clearTimeout(window.answerShower);
    document.getElementById('audio').pause();
    $("#ask-another-button").css("display", "none");
  });

  $("#ask-another-button").click(function(e) {
    $(".buttons").show();
    document.getElementById('answer-container').classList.remove("showing");
    clearTimeout(window.answerShower);
    document.getElementById('audio').pause();
    $("#ask-another-button").css("display", "none");
    $("textarea").select();
  });

  $("form").submit(function(e) {
    if (document.getElementById("question").value == "") {
      alert("Please ask a question!");
      e.preventDefault();
      return false;
    }

    let askButton = document.getElementById("ask-button");
    askButton.textContent = "Asking...";
    askButton.disabled = true;

    $.ajax({
      type: 'POST',
      url: '/ask',
      data: $("form").serialize(),
      datatype: "json",
      encode: true
    }).done(function(data) {
      $(".buttons").hide();

      var audio = document.getElementById('audio');
      audio.src = data.audio_src_url;

      var answer = document.getElementById('answer');
      answer.innerHTML = "";
      document.getElementById('answer-container').classList.add("showing");

      window.answerShower = setTimeout(function() {
        showText("#answer", data.answer, 0);
      }, 1200);

      audio.volume = 0.3;
      audio.play();

      askButton.textContent = "Ask question";
      askButton.disabled = false;

      window.newQuestionId = data.id;
    });

    e.preventDefault();
    return false;
  });
});
</script>
*/