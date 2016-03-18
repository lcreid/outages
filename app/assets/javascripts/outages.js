$(document).ready(function(){
  var tz = $().get_timezone();
  // console.log(tz);
  // var option = $("#outage_time_zone option[value='" + tz +"']");
  // console.log(option);
  $("#outage_time_zone option[value='" + tz +"']")[0].selected = true
});
