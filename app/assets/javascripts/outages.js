$(document).ready(function(){
  var tz = $().get_timezone();
  console.log(tz);
  var option = $("#time_zone_setter option[value='" + tz +"']");
  console.log(option[0]);
  option[0].selected = true;
  // document.cookie = "time_zone=" + tz;
  console.log("Whole cookie: " + document.cookie);
  console.log("tz: " + tz);
});
