window.json_cache = {}
window.limit_1 = .5 # На какую часть нужно промотеть эл-т до низа, чтобы сработал ajax
window.limit_2 = 5  # Сколько скролл хочет загрузить свежих статей

#--------------------------------------------------------------------------------------------------
window.current_timestamp = ->
	new Date().getTime()

#--------------------------------------------------------------------------------------------------
window.getWindowSize = ->
	isDocumentElementHeightOff = ->
		d = document
		div = d.createElement("div")
		div.style.height = "2500px"
		d.body.insertBefore div, d.body.firstChild
		r = d.documentElement.clientHeight > 2400
		d.body.removeChild div
		r
	docEl = document.documentElement
	IS_BODY_ACTING_ROOT = docEl and docEl.clientHeight is 0
	if typeof document.clientWidth is "number"
		width: document.clientWidth
		height: document.clientHeight
	else if IS_BODY_ACTING_ROOT or isDocumentElementHeightOff()
		b = document.body

		width: b.clientWidth
		height: b.clientHeight
	else
		width: docEl.clientWidth
		height: docEl.clientHeight
		
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

#--------------------------------------------------------------------------------------------------
window.zeroPad = (num, places) ->
	zero = places - num.toString().length + 1
	Array(+(zero > 0 and zero)).join("0") + num

#--------------------------------------------------------------------------------------------------
window.timezone_name = ->
	Intl.DateTimeFormat().resolvedOptions().timeZone
