function get_cookie(name) {
  cookies = document.cookie.split(';');
  for(i = 0; i < cookies.length; i++) {
    cookie = cookies[i].trim();
    if (cookie.indexOf(name + "=") === 0) {
      return cookie.substring(name.length + 1);
    }
  }
  return null;
}

$(document).on('turbolinks:load', function() {
  // console.log("Raw cookie value: " + get_cookie('time_zone'));
  var tz = get_cookie('time_zone');
  // console.log("Time zone from JavaScript from cookie: " + tz);
  if(!tz) {
    tz = $().get_timezone();
    // console.log("Really got time zone from JavaScript: " + tz);
  }
  else {
    tz = decodeURIComponent(tz);
  }
  // console.log("Time zone from JavaScript or decode: " + tz);
  var option = $("#time_zone_setter option[value='" + tz +"']");
  if(option[0]) {
    // console.log(option[0]);
    option[0].selected = true;
  }
  else {
    // console.log("Couldn't find time_zone_setter for " + tz);
  }
  // document.cookie = "time_zone=" + tz;
  // console.log("Whole cookie: " + document.cookie);
  // console.log("tz: " + tz);
});
