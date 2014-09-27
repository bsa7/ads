#--------------------------------------------------------------------------------------------------
$(document).click (e)->
  document_onclick e

#--------------------------------------------------------------------------------------------------
ad_content = (ad) ->
	HandlebarsTemplates['ad_item']({ad: ad})
	
#--------------------------------------------------------------------------------------------------
document_onclick = (e) ->
	if /new_ad/.test e.target.id
		new_id = makeid(7)
		$.fancybox
			content: HandlebarsTemplates['new_ad']({id: new_id})
			padding: 0
			width: 848
			height: 686
			scrolling: 'no'
			tpl:
				closeBtn: "<span class=\"close_map\"></span>"
		helpers:
			overlay:
				locked: true
				speedOut: 30
				css:
					'background-color': 'rgba(111,11,11,0.6)'
		set_file_listener()
	else if /input_file/.test e.target.id
		$("input.file").click()
	else if /delete_img/.test e.target.getAttribute("data-type")
		$(e.target.parentNode).remove()
	else if /comment_img/.test e.target.getAttribute("data-type")
		comment_text = $(e.target).html()
		id = e.target.parentNode.id
		p_width = $(e.target).css("width")
		textarea = $(e.target).replaceWith("<textarea style='width: #{p_width}' id='#{id}' type='text' class='thumb-caption form-control'>#{comment_text}</textarea>")
		$("textarea##{id}").focus()
	else if /confirm/.test e.target.id
		ad_text = $("textarea.ad_text").val() 
		if ad_text == ""
			window.status_body "error", HandlebarsTemplates['text_needed_here']()
		else
			ads_images = []
			for img in $(".img_thumb")
				image = $(img)
#				console.log img.id
				progressbar = image.parent().children("progress.upload-progress")
				ads_images.push
					id: $(".new_ads")[0].id #img.id
					filename: image.children("img").attr("data-filename")
					comment: image.children("p[data-type='comment_img']").html()
					uploaded: parseInt(progressbar.attr("value")) / parseInt(progressbar.attr("max"))
				console.log $(progressbar)
				console.log progressbar.attr("value")
				console.log progressbar.attr("max")
			window.get_ajax "/add_ads", {ads_text: ad_text, ads_images: ads_images}, true, "POST", render_new_ads
			window.status_body "success", HandlebarsTemplates['ads_posted']()
			$.fancybox.close()
	else if /cancel/.test e.target.id
		$.fancybox.close()

#--------------------------------------------------------------------------------------------------
$(document).mousedown (e) ->
	for textarea in $(".thumb-caption")
		if /thumb-caption/.test("#{textarea.className}") && textarea.id != e.target.id
			p_width = $(textarea).parent().children("img").css("width")
			new_text = $(textarea).val()
			$(textarea).replaceWith "<p style='width: #{p_width}' data-type='comment_img' class='img_comment'>#{new_text}</p>"

#--------------------------------------------------------------------------------------------------
render_new_ads = (data) ->
	console.log "New ads created: "
	console.log data

#--------------------------------------------------------------------------------------------------
set_file_listener = ->
	$(".file").change (event) ->
		input = $(event.currentTarget)
		readers = []
		for file in input[0].files
			file_id = makeid(7)
			fast_preview = HandlebarsTemplates['img_thumb']({src: "/assets/images/thumb_dumb.gif", img_comment: file.name, id: file_id})
			$(".upload-preview").append(fast_preview)
			$(".upload-preview").hide().show(0)
			o = new FileReader()
			o.file_id = file_id
			o.file = file
			o.readAsDataURL file
			o.onload = (e) ->
				image_base64 = e.target.result
#				console.log @file_id, @file.name
				preview = HandlebarsTemplates['img_thumb']({src: image_base64, img_comment: @file.name, id: @file_id})
				pic_real_width = undefined
				pic_scaled_width = undefined
				pic_real_height = undefined
				pic_scaled_height = 100
				preloaded_image = $("<img id='#{@file_id}'/>")
				preloaded_image.file_id = @file_id
				preloaded_image.load( ->
					preloaded_image_id = $(this)[0].id
					$("##{preloaded_image_id}").replaceWith(preview)
					pic_real_width = @width
					pic_real_height = @height
					pic_scaled_width = pic_real_width * (100 / pic_real_height)
					$("##{preloaded_image_id}").css
						width: pic_scaled_width
					return
				).attr("src", image_base64)
				upload @file, onSuccess, onError, onProgress, @file_id

#--------------------------------------------------------------------------------------------------
onSuccess = (e, bar_id) ->
	$("##{bar_id} progress").remove()

#--------------------------------------------------------------------------------------------------
onLoad = ->
	console.log "loaded"

#--------------------------------------------------------------------------------------------------
onError = (e) ->
	console.log "error"
	console.log e

#--------------------------------------------------------------------------------------------------
onProgress = (loaded, total, bar_id) ->
	$("##{bar_id} progress").attr("value", "#{loaded / total * 100}")

#--------------------------------------------------------------------------------------------------
upload = (file, onSuccess, onError, onProgress, bar_id) ->
	xhr = new XMLHttpRequest()
	xhr.onload = xhr.onerror = ->
		if @status isnt 200
			onError this
			return
		onSuccess(this, bar_id)
		return

	xhr.upload.onprogress = (event) ->
		onProgress event.loaded, event.total, bar_id
		return

	xhr.open "POST", "/upload_image?file_name=#{file.name}&ads_id=#{$('.new_ads').attr('id')}", true
	xhr.setRequestHeader('X-CSRF-Token', window.get_token())
	xhr.send file

#--------------------------------------------------------------------------------------------------
document.addEventListener "dragstart", ((e) ->
	e.preventDefault()
	return false
), false

#--------------------------------------------------------------------------------------------------
window.get_token = ->
	$('meta[name="csrf-token"]').attr('content')

#--------------------------------------------------------------------------------------------------
makeid = (length_of) ->
	text = ""
	possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	i = 0
	while i < length_of
		text += possible.charAt(Math.floor(Math.random() * possible.length))
		i++
	text

#-- pause animation in status message block if mouse hover on them ---------------------------------
$("div[id$='_wrapper']").hover (e)->

  state = '-webkit-animation-play-state'
  @.css state, (i, v) ->
    (if v is "paused" then "running" else "paused")
  @.toggleClass "paused", @.css(state) is "paused"


#-- show a status message ---------------------------------------------------------------------------
window.status_body = (status, html, seconds = null) ->
	if seconds == 0
		$("##{status}_wrapper > div.data-message").html html
		$("##{status}_wrapper > div.data-transparent").css
			opacity: 0.9
		$("##{status}_wrapper").css
			top: "0px"
	else
		unless seconds
			seconds = 4
		seconds *= 1000
		if $("##{status}_wrapper > div.data-transparent").is(':animated')
			$("##{status}_wrapper > div.data-transparent").stop()
		if $("##{status}_wrapper > div.data-message").is(':animated')
			$("##{status}_wrapper > div.data-message").stop()
		if $("##{status}_wrapper").is(':animated')
			$("##{status}_wrapper").stop()
		$("##{status}_wrapper").css
			opacity: 0.9
			top: "0px"
		$("##{status}_wrapper > div.data-message").html html
		left = ($("##{status}_wrapper").width() - $("##{status}_wrapper > .data-message").width())/2
		top = ($("##{status}_wrapper").height() - $("##{status}_wrapper > .data-message").height())/2
		$("##{status}_wrapper > .data-message").css
			top: "#{top}px"
			left: "#{left}px"
		$("##{status}_wrapper > div.data-transparent").css
			opacity: 0.9
		$("##{status}_wrapper > div.data-message").css
			opacity: 1
		$("##{status}_wrapper > div.data-transparent").animate
			opacity: 0
			WebkitTransition: "opacity 2s ease-in-elastic"
			MozTransition: "opacity 2s ease-in-elastic"
			MsTransition: "opacity 2s ease-in-elastic"
			OTransition: "opacity 2s ease-in-elastic"
			transition: "opacity 2s ease-in-elastic"
		, seconds, ->
		$("##{status}_wrapper > div.data-message").animate
			opacity: 0
		, seconds, ->
			$("##{status}_wrapper").css #.animate
				opacity: 0
				top: "-200px"

#-- close a success, error message by click ---------------------------------------------------------------------------
$(document).click (e)->
	id = window.get_attr(e.target, "id", 3)
	if /_wrapper/.test(id)
		$("[id$='_wrapper'] > div.data-transparent").css
			opacity: 0
		$("[id$='_wrapper']").css
			top: "-200px"

#--------------------------------------------------------------------------------------------------
window.get_attr = (element, attr_name, depth = 1) ->
	res = []
	r = element
	for level in [1..depth]
		if r
			res.push $(r).attr(attr_name)
			r = r.parentNode
	res.first_not_empty()

#--------------------------------------------------------------------------------------------------
Array::first_not_empty = ->
	res = null
	for res in this
		if res
			break
	res

#--------------------------------------------------------------------------------------------------
window.get_ajax = (url, data_adds, async = false, query_type = "GET", callback = null, callback_params = null, datatype = "json") ->
	data =
		utf8: "\?"
		layout: false
		authenticity_token: window.get_token()
	for key, val of data_adds
		data[key] = val
	$.ajax
		async: async
		type: query_type
		datatype: datatype
		data: data
		url: url
		error: (data) ->
			if callback
				callback(data, callback_params)
			else
				data
		success: (data) ->
			if callback
				callback(data, callback_params)
			else
				data

