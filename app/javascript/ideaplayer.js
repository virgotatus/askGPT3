$(document).ready(function() {
  var showText = function(target, message, index) {
    if (index < message.length) {
      var interval = parseInt(Math.random()*40 + 30);
      $(target).append(message[index++]);
      setTimeout(function () { showText(target, message, index); }, interval);
    } else {
      //history.pushState({}, null, "/question/" + window.newQuestionId);
    }
  }
  
  $("form").submit(function(e) {
    // if (document.getElementById("prompt_body").value == "") {
    //   alert("Please ask a question!");
    //   e.preventDefault();
    //   return false;
    // }

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
  
        askButton.textContent = "生成(Generate)";
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
})
