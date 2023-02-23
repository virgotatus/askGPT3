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

function textarea_change(e) {
  let buttons = document.getElementsByClassName(".buttons").show();
  document.getElementById('answer-container').classList.remove("showing");
  document.getElementById('audio').pause();
  
}

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