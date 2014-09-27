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
		$(e.target).replaceWith("<textarea style='width: #{p_width}' id='#{id}' type='text' class='form-control'>#{comment_text}</textarea>")
		$("textarea##{id}").focus()
		$("textarea##{id}").blur ->
			new_text = $("textarea##{id}").val()
			$("textarea##{id}").replaceWith "<p style='width: #{p_width}' data-type='comment_img' class='img_comment'>#{new_text}</p>"

#--------------------------------------------------------------------------------------------------
set_file_listener = () ->
	$(".file").change (event) ->
		input = $(event.currentTarget)
		readers = []
		for file in input[0].files
			readers.push new FileReader()
			readers.slice(-1)[0].onload = (e) ->
				image_base64 = e.target.result
				id = makeid(7)
				preview = HandlebarsTemplates['img_thumb']({src: image_base64, img_comment: file.name, id: id})
				$(".upload-preview").append(preview)
				preview_id = $(preview).attr('id')
				preview_image_width = $("##{preview_id} img").css("width")
				$("##{preview_id}").css
					width: preview_image_width
				#$(".upload-preview").hide().show(0)
				upload(file, onSuccess, onError, onProgress, "#{id}")
			readers.slice(-1)[0].readAsDataURL file

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
