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
#	console.log "Новейшая статья на сервере: ", new Date(data).getTime()
	server_timestamp = new Date(data).getTime()
	client_timestamp = latest_ads()
#	console.log "Новейшая статья у клиента:", latest_ads_timestamp()
	if server_timestamp > client_timestamp["timestamp"]
		console.log "Надо обновить индекс, есть новые статьи."
		window.get_ajax "/", {layout: false, timezone: window.timezone_name(), timestamp: true, later_than: client_timestamp["date"], count: window.limit_2}, true, "GET", window.update_index_mini, {layout: false, position: "prepend"}, "json"

#--------------------------------------------------------------------------------------------------
init_event_src = ->
	if eventSrc is undefined
#		console.log "Создаём eventSrc"
		eventSrc = new EventSource("/index_channel?later_than='#{latest_ads()['timestamp']}'")
	eventSrc.onmessage = (e) ->
		stream_responder(e.data)

#--------------------------------------------------------------------------------------------------
initStreams = ->
	console.log "В этом браузере нет поддержки EventSource." unless window.EventSource
	init_event_src()

	eventSrc.onerror = (e) ->
#		console.log e
		if @readyState is EventSource.CONNECTING
#			console.log "Соединение разорвано, пересоединяемся..."
#			console.log e
#      console.log @readyState
		else if @readyState is EventSource.OPEN
#			console.log "Соединение Открыто."
#      console.log e
#       console.log @readyState
		else if @readyState is EventSource.CLOSED
#			console.log "Соединение закрыто. Переоткрываем..."
			init_event_src()
#      console.log "попытка переоткрытия соединения."
#      console.log e
##      console.log @readyState
#		else
#      console.log "Другая ошибка, состояние: " + @readyState
#      console.log e
#    e.preventDefault()

#  eventSrc.onopen = (e) ->
#    console.log "Соединение открыто"
#    console.log e
