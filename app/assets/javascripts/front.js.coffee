#--------------------------------------------------------------------------------------------------
$(document).click (e)->
  document_onclick e

#--------------------------------------------------------------------------------------------------
ad_content = (ad) ->
	HandlebarsTemplates['ad_item']({ad: ad})
	
#--------------------------------------------------------------------------------------------------
document_onclick = (e) ->
	if /new_ad/.test e.target.id
		$.fancybox
			content: HandlebarsTemplates['new_ad']()
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

#--------------------------------------------------------------------------------------------------
set_file_listener = ->
	$(".file").change (event) ->
		input = $(event.currentTarget)
		readers = []
		for file in input[0].files
			readers.push new FileReader()
			readers.slice(-1)[0].onload = (e) ->
				image_base64 = e.target.result
				preview = HandlebarsTemplates['img_thumb']({src: image_base64})
				$(".upload-preview").html($(".upload-preview").html()+preview)
			readers.slice(-1)[0].readAsDataURL file
			$(".upload-preview").hide().show(0)
