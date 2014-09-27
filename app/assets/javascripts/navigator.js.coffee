setPage = undefined
ASYNC = true
NavigationCache = {} unless NavigationCache

#--------------------------------------------------------------------------------------------------
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
	new Date().getTime()

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
	console.log "57#push state"
	history.pushState
		page: params["page"]
		type: "page"
	, document.title, params["page"]
#	console.log
#		"window.location.pathname": window.location.pathname
#		html: $(params["target"]).html()
	navCache window.location.pathname, 
		html: $(params["target"]).html()
		timestamp: $(params["target"]).attr("data-timestamp")

#--------------------------------------------------------------------------------------------------
setPage = (page, params, target, success_callback = null, callback_params = null) ->
	if navCache(page) && ( navCache(page)["html"] != "" && navCache(page)["html"] != null )
		$(target).html(navCache(page).html)
		if success_callback
			success_callback(callback_params)
		console.log "75#push state"
		history.pushState
			page: page
			type: "page"
		, document.title, page
	else
		window.get_ajax "#{page}", {layout: false, timestamp: true}, ASYNC, "GET", draw_ajax_page, {layout: false, page: page, target: target}, "json"

#--------------------------------------------------------------------------------------------------
doc_ready = ->
	console.log "85#push state"
	console.log $("#content").html()
	history.pushState
		page: window.location.pathname
		type: "page"
	, document.title, window.location.pathname
	navCache window.location.pathname,
		html: $("#content").html()
		timestamp: $($("#wrapper")).attr("timestamp") || current_timestamp()

#--------------------------------------------------------------------------------------------------
$(document).ready ->
	doc_ready()

#-------------------------------------------------------------------------------------------------
window.onpopstate = (e) ->
	console.log "window.onpopstate"
	console.log e
	console.log history
	return if !e.state || !e.state.page || !navCache(e.state.page) || !history.pushState
	console.log !e.state, !e.state.page, !navCache(e.state.page), !history.pushState
	console.log {navCache: navCache}
	$("#content").html navCache(e.state.page)["html"] if navCache(e.state.page)["html"].length > 2 if e.state.type.length > 0

#--------------------------------------------------------------------------------------------------
$(document).click (e)->
	document_onclick e

#--------------------------------------------------------------------------------------------------
document_onclick = (e) ->
	if /^[aA]$/.test(e.target.tagName)# && /^\//.test(e.target.attr("href"))
		e.preventDefault()
		setPage $(e.target).attr("href"), {}, "#content"

