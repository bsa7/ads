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
		set_file_listener(new_id)
	else if /input_file/.test e.target.id
		$("input.file").click()
	else if /delete_img/.test e.target.getAttribute("data-type")
		$(e.target.parentNode).remove()
	else if /comment_img/.test e.target.getAttribute("data-type")
		comment_text = $(e.target).html()
		id = e.target.parentNode.id
		p_width = $(e.target).css("width")
		$(e.target).replaceWith("<textarea style='width: #{p_width}' id='#{id}' type='text' class='form-control'>#{comment_text}</textarea>")
		$("textarea##{id}").focus()
		$("textarea##{id}").blur ->
			new_text = $("textarea##{id}").val()
			$("textarea##{id}").replaceWith "<p style='width: #{p_width}' data-type='comment_img' class='img_comment'>#{new_text}</p>"

#--------------------------------------------------------------------------------------------------
set_file_listener = (id) ->
	$(".file").change (event) ->
		input = $(event.currentTarget)
		readers = []
		for file in input[0].files
			readers.push new FileReader()
			#readers.slice(-1)[0].readAsDataURL file
			readers.slice(-1)[0].onload = (e) ->
				image_base64 = e.target.result
				preview = HandlebarsTemplates['img_thumb']({src: image_base64, img_comment: file.name, id: makeid(7)})
				console.log "begin"
				#console.log preview
				$(".upload-preview").append(preview)
				console.log "end"
				#$(".upload-preview").hide().show(0)
				upload(file, onSuccess, onError, onProgress, "#{id}")
			readers.slice(-1)[0].readAsDataURL file

#--------------------------------------------------------------------------------------------------
onSuccess = (e) ->
	console.log "success"
	console.log e

#--------------------------------------------------------------------------------------------------
onLoad = ->
	console.log "loaded"

#--------------------------------------------------------------------------------------------------
onError = (e) ->
	console.log "error"
	console.log e

#--------------------------------------------------------------------------------------------------
onProgress = (loaded, total, bar) ->
	console.log loaded, total, bar

#--------------------------------------------------------------------------------------------------
upload = (file, onSuccess, onError, onProgress, bar) ->
	xhr = new XMLHttpRequest()
	xhr.onload = xhr.onerror = ->
		if @status isnt 200
			onError this
			return
		onSuccess(this)
		return

	xhr.upload.onprogress = (event) ->
		onProgress event.loaded, event.total, bar
		return

	xhr.open "POST", "/upload_image?file_name=#{file.name}&ads_id=#{$('.new_ads').attr('id')}", true
	xhr.setRequestHeader('X-CSRF-Token', window.get_token())
	xhr.send file

###
	$.ajax
		async: true
		type: "post"
		datatype: "json"
		data: file
		url: "/upload_image?file_name=#{file.name}&ads_id=#{$('.new_ads').attr('id')}"
		multipart: true
		xhrFields:
			onprogress: (e) ->
				onProgress e.loaded, e.total, bar
				console.log e
			onerror: (e) ->
				onError(e)
				console.log e
			onsuccess: (e) ->
				onSuccess(e)
				console.log e
		success: (data) ->
			console.log "success!"
			console.log data
		error: (e) ->
			console.log "error!"
			console.log e
		#processData: false
		#contentType: false
###

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
