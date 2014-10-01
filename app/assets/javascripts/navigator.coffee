setPage = undefined
ASYNC = true
NavigationCache = {} unless NavigationCache

#-- this navigation cache used for fast page preload without any request to server ----------------
#-- also timestamp can be used for frequently updated pages
navCache = (key, value) ->
	res = null
	unless typeof window.localStorage is "undefined"
		if key && value
			try
				window.localStorage.setItem("html_by_link['#{key}']", value["html"])
				window.localStorage.setItem("timestamp_by_link['#{key}']", value["timestamp"])
			catch e
				window.status_body( "error", HandlebarsTemplates['common/local_storage_oversize'](), 12 ) if e is QUOTA_EXCEEDED_ERR
		if key && !value
			res =
				html: window.localStorage.getItem("html_by_link['#{key}']")
				timestamp: window.localStorage.getItem("timestamp_by_link['#{key}']")
	else
		if key && value
			NavigationCache[key] =
				html: value["html"]
				timestamp: value["timestamp"]
		if key && !value
			res = 
				html: NavigationCache[key]["html"]
				timestamp: NavigationCache[key]["timestamp"]
	return res

#--------------------------------------------------------------------------------------------------
current_timestamp = ->
	window.current_timestamp()

#--------------------------------------------------------------------------------------------------
draw_ajax_page = (response, params) ->
	data=
		timestamp: current_timestamp()
		html: response
	$(params["target"]).html(data["html"])
	$(params["target"]).attr("data-timestamp", data["timestamp"])
	#запись в кэш
	navCache params["page"],
		html: data["html"]
		timestamp: data["timestamp"]
	history.pushState
		page: params["page"]
		type: "page"
	, document.title, params["page"]
	navCache window.location.pathname, 
		html: $(params["target"]).html()
		timestamp: $(params["target"]).attr("data-timestamp")
	window.customize_layout()

#--------------------------------------------------------------------------------------------------
setPage = (page, params, target, success_callback = null, callback_params = null) ->
	window.store_index()
	if navCache(page) && ( navCache(page)["html"] != "" && navCache(page)["html"] != null )
		$(target).html(navCache(page).html)
		if success_callback
			success_callback(callback_params)
		history.pushState
			page: page
			type: "page"
		, document.title, page
		window.customize_layout()
	else
		window.get_ajax "#{page}",
			layout: false
			timestamp: true
		, ASYNC, "GET", draw_ajax_page,
			layout: false
			page: page
			target: target
		, "json"

#--------------------------------------------------------------------------------------------------
doc_ready = ->
	history.pushState
		page: window.location.pathname
		type: "page"
	, document.title, window.location.pathname
	navCache window.location.pathname,
		html: $("#content").html()
		timestamp: $($("#wrapper")).attr("timestamp") || current_timestamp()
	window.customize_layout()

#--------------------------------------------------------------------------------------------------
$(document).ready ->
	doc_ready()

#-------------------------------------------------------------------------------------------------
window.onpopstate = (e) ->
	return if !e.state || !e.state.page || !navCache(e.state.page) || !history.pushState
	$("#content").html navCache(e.state.page)["html"] if navCache(e.state.page)["html"].length > 2 if e.state.type.length > 0
	window.customize_layout()

#--------------------------------------------------------------------------------------------------
$(document).click (e)->
	document_onclick e

#--------------------------------------------------------------------------------------------------
document_onclick = (e) ->
	if /^[aA]$/.test(e.target.tagName) && /^\//.test(e.target.getAttribute("href"))
		e.preventDefault()
		setPage $(e.target).attr("href"), {}, "#content"
	
#--------------------------------------------------------------------------------------------------
window.customize_layout = ->
	window.restore_index()
	to_index_items = ["#ads_index_mini", "#to_home"]
	if $("#content .ads_list").length == 0 # if no index present on this page
		index_content = window.localStorage.getItem("ads_list")
		for item_to_show in to_index_items
			$(item_to_show).css
				display: "block"
		if index_content && index_content.length > 0
			window.draw_index index_content
		else
			window.get_ajax "/", {layout: false}, ASYNC, "GET", window.draw_index, {layout: false}, "json"
	else if $("#content .ads_list").length > 0
		for item_to_show in to_index_items
			$(item_to_show).css
				display: "none"
		$("#ads_index_mini").html("")

