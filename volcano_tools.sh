#!/usr/bin/env bash

pid=0
pid_filename=".volcano.pid"
server_log_file="volcano.log"
server_name="VolcanoFTP"
server_script_file="volcano_ftp.rb"

start()
{
    if [ ! -f $pid_filename ]; then
        ./$server_script_file -s -l $server_log_file &
    else
        pid="`cat $pid_filename`"
        echo "$server_name: Server already started (PID: $pid)"
    fi
}
stop()
{
    if [ -f $pid_filename ]; then
        pkill -F $pid_filename
    else
        echo "$server_name: Server not started"
    fi
}
restart()
{
    stop
    start
}
usage()
{
    echo "Usage: $server_name Tools <command>";
    echo ""
    echo "Available commands are:"
    echo "  restart"
    echo "  start"
    echo "  stop"
    echo ""
    exit
}

if [ $# == 0 ]; then
    usage
fi

if [ $1 == "start" ]; then
    start
elif [ $1 == "stop" ]; then
    stop
elif [ $1 == "restart" ]; then
    restart
else
    usage
fi

