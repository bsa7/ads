eventSrc = undefined
#--------------------------------------------------------------------------------------------------
$(document).ready ->
	doc_ready()

#--------------------------------------------------------------------------------------------------
latest_ads = ->
	console.log $("[data-datetime]")
	date_str = $("[data-datetime]")[0].getAttribute("data-datetime")
	datetime = new Date(date_str)
	timestamp: datetime.getTime()
	date: date_str

#--------------------------------------------------------------------------------------------------
doc_ready = ->
	initStreams()

#--------------------------------------------------------------------------------------------------
stream_responder = (data) ->
	server_timestamp = new Date(data).getTime()
	client_timestamp = latest_ads()
	if server_timestamp > client_timestamp["timestamp"]
		window.get_ajax "/",
			layout: false
			timezone: window.timezone_name()
			timestamp: true
			later_than_date: client_timestamp["date"]
			later_than: client_timestamp["timestamp"]
			count: window.limit_2
		, true, "GET", window.update_index, {layout: false, position: "prepend"}, "json"

#--------------------------------------------------------------------------------------------------
init_event_src = ->
	if eventSrc is undefined
		eventSrc = new EventSource("/index_channel")
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
