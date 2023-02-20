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