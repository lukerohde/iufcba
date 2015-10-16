app_helper_ready = ->
	$('input[type=file]').bind 'change', ->
	  size_in_megabytes = Math.round(@files[0].size / 1024 / 1024)
	  upload_time = Math.round(@files[0].size / 1024 / (1024/8))
	  if size_in_megabytes > 1
	    alert 'Warning: This file is large (' + size_in_megabytes + ' megabytes) and would take ' + upload_time + ' seconds to upload on a typical internet connection. So when you click submit, the system may appear to stall for a while.'
	  return

$(document).ready(app_helper_ready);
$(document).on('page:load', app_helper_ready);
