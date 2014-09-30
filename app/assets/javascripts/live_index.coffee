eventSrc = undefined
#--------------------------------------------------------------------------------------------------
$(document).ready ->
	doc_ready()

#--------------------------------------------------------------------------------------------------
latest_ads = ->
	datetime = new Date($("[data-datetime]")[0].getAttribute("data-datetime"))
	timestamp: datetime.getTime()
	date: datetime

#--------------------------------------------------------------------------------------------------
doc_ready = ->
	initStreams()

#--------------------------------------------------------------------------------------------------
stream_responder = (data) ->
	server_timestamp = new Date(data).getTime()
	client_timestamp = latest_ads()
	if server_timestamp > client_timestamp["timestamp"]
		window.get_ajax "/", {layout: false, timezone: window.timezone_name(), timestamp: true, later_than: client_timestamp["date"], count: window.limit_2}, true, "GET", window.update_index, {layout: false, position: "prepend"}, "json"

#--------------------------------------------------------------------------------------------------
init_event_src = ->
	if eventSrc is undefined
		eventSrc = new EventSource("/index_channel?later_than='#{latest_ads()['timestamp']}'")
	eventSrc.onmessage = (e) ->
		stream_responder(e.data)

#--------------------------------------------------------------------------------------------------
initStreams = ->
	console.log "В этом браузере нет поддержки EventSource." unless window.EventSource
	init_event_src()

	eventSrc.onerror = (e) ->
		if @readyState is EventSource.CONNECTING
		else if @readyState is EventSource.OPEN
		else if @readyState is EventSource.CLOSED
			init_event_src()
