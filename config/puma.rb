#!/usr/bin/env puma
threads 0, 32
daemonize true
projects_path = "/tmp"
appname = "ads"
application_path = "/home/slon/projects/#{appname}"
environment railsenv = File.open("#{application_path}/env", "rb").read
pidfile "#{projects_path}/shared/pids/#{appname}.pid"
state_path "#{projects_path}/shared/sockets/#{appname}.state"
stdout_redirect "#{application_path}/log/#{appname}.stdout.log", "#{application_path}/log/#{appname}.stderr.log"
bind "unix://#{projects_path}/shared/sockets/#{appname}.sock"
activate_control_app "unix://#{projects_path}/shared/sockets/#{appname}ctl.sock", { auth_token: 'cd43fd4cf2d4c3f2d4c2f3d4cf23d4cf23d4f234cf234cf4c4d23f4efe2' }
