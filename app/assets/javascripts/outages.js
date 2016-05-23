function get_cookie(name) {
  cookies = document.cookie.split(';');
  for(i = 0; i < cookies.length; i++) {
    cookie = cookies[i].trim();
    if (cookie.indexOf(name + "=") == 0) {
      return cookie.substring(name.length + 1);
    }
  }
  return null;
}

$(document).ready(function(){
  var tz = get_cookie('time_zone');
  if(! tz) tz = $().get_timezone();
  console.log(tz);
  var option = $("#time_zone_setter option[value='" + tz +"']");
  console.log(option[0]);
  option[0].selected = true;
  // document.cookie = "time_zone=" + tz;
  console.log("Whole cookie: " + document.cookie);
  console.log("tz: " + tz);
});
