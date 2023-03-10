$(document).ready(function() {
  var showText = function(target, message, index) {
    if (index < message.length) {
      var interval = parseInt(Math.random()*40 + 30);
      $(target).append(message[index++]);
      setTimeout(function () { showText(target, message, index); }, interval);
    } else {
      $("#send-email").css("display", "block");
      //history.pushState({}, null, "/question/" + window.newQuestionId);
    }
  }
  
  $("#question").submit(function(e) {
    if (document.getElementById("idea_city").value == "") {
      alert("Please fill zone!");
      e.preventDefault();
      return false;
    }

    if (document.getElementById("idea_thing").value == "") {
      alert("Please fill thing!");
      e.preventDefault();
      return false;
    }

    let askButton = document.getElementById("ask-button");
    askButton.textContent = "Generating...";
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
        console.log(data);
        // var audio = document.getElementById('audio');
        // audio.src = data.audio_src_url;
        var oblique = document.getElementById('oblique');
        oblique.innerHTML = data.oblique;

        var answer = document.getElementById('answer');
        answer.innerHTML = "";
        document.getElementById('answer-container').classList.add("showing");
        window.answerShower = setTimeout(function() {
          showText("#answer", data.answer, 0);
        }, 1200);

        // audio.volume = 0.3;
        // audio.play();
        document.getElementById('send-email').classList.add("showing");
        $("#send-email-button").attr("disabled", false);
        $("#send-email-button").val("??????????????????????????????(Email it!)");
        askButton.textContent = "??????(Generate)";
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

  $("#send-email").submit(function(e) {
    if (document.getElementById("email").value == "") {
      alert("Please fill email!");
      e.preventDefault();
      return false;
    }

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
        xhr.setRequestHeader('X-CSRF-Token', token);
      },
      success: function(data) {
        // Do something with the response data
        $("#send-email-button").val("?????????");
        $("#send-email-button").attr("disabled", true);
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
})
