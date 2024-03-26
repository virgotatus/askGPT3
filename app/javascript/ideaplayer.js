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

  $("#idea_city").click(function(e) {
    var bgm = document.getElementById('bgm');
    if (bgm.paused) {
      bgm.volume = 0.3;
      bgm.play();
    }
  });
  $("#idea_thing").click(function(e) {
    var bgm = document.getElementById('bgm');
    if (bgm.paused) {
      bgm.volume = 0.3;
      bgm.play();
    }
  });

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
    document.getElementById("answer-show").classList.replace("showing", "hidden");

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
        document.getElementById('answer-show').classList.add("showing");
        window.answerShower = setTimeout(function() {
          showText("#answer", data.answer, 0);
        }, 1200);

        // audio.volume = 0.3;
        // audio.play();
        $("#send-email-button").attr("disabled", false);
        $("#send-email-button").val("喜欢吗？发送邮箱吧(Email to Yourself)");
        askButton.textContent = "生成(Generate)";
        askButton.disabled = false;
        console.log("submit success");
        //window.newQuestionId = data.id;
      },
      error: function(xhr, textStatus, errorThrown) {
        // Handle errors here
        window.alert("生成失败(failed), 时机未到(waiting).");
        askButton.textContent = "生成(Generate)";
        askButton.disabled = false;
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
        $("#send-email-button").val("已发送（Finished)");
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

  $('#share-picture-button').click(function() {
    $.ajax({
      url: '/ideas/generate_shared_picture',
      method: 'GET',
      dataType: 'json',
      success: function(data) {
        console.log(data);
        // Do something with the response data
        $('#shared-picture').attr('src', data.img_path);
        $('#shared-picture-modal').attr('style', 'display:block');
      },
    });
  });
  // modal close button
  var share_close = document.getElementById("share-close");
  share_close.onclick = function() { 
    $('#shared-picture-modal').attr('style', 'display:none');
  }
  // $('#shared-picture-modal').click(function() {
  //   $(this).attr('style', 'display:none');
  // });

  $('#money-button').click(function() {
    $('#money-modal').attr('style', 'display:block');
  });
  $('#money-close').click(function() {
    $('#money-modal').attr('style', 'display:none');
  });

})
