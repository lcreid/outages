$(document).ready(function(){
  var tz = $().get_timezone();
  console.log(tz);
  var option = $("#user_time_zone option[value='" + tz +"']");
  console.log(option);
  option[0].selected = true
});
