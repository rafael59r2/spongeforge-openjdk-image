#! /usr/bin/env sh

# Search server on tmux panes and stop it.
server_stop () {
	printf '%s' "Send 'stop' to pane"
	for i in $(tmux lsp -a -F '#D:#{pane_start_command}' | grep FORGE_JAR | cut -d: -f1 | xargs); do
		printf '%s' " ${i}..."
		tmux send -t ${i} 'stop' Enter
	done
	printf '%s\n' 'DONE'
	printf '%s' 'Waiting for server stop...'
	while pgrep java > /dev/null; do sleep 1; done
	printf '%s\n' 'DONE'
}

# Since OOM dump hardcodet for now, move last if present.
# Otherwise JVM fail to create new.
[ -e ./logs/OOM_Dump_last.hprof ] && mv -f ./logs/OOM_Dump_last.hprof ./logs/OOM_Dump_previous.hprof && printf '%s\n' 'Old OOM dump moved!'

export JVM_OPT="${@}"
tmux new -d -s "${SPONGEFORGE_TMUX_SNAME}" '/usr/bin/java ${JVM_OPT_STRICT} ${JVM_OPT} -jar "${SPONGEFORGE_HOME}/${FORGE_SERVER_JAR}"'
printf '%s\n' "Created new tmux session '${SPONGEFORGE_TMUX_SNAME}'"
printf '%s\n' 'To get server console run:' "docker exec -ti $(awk -F "docker-|\.scope" '/^1:/ {print substr($2, 0, 10)}' /proc/self/cgroup) tmux attach -t ${SPONGEFORGE_TMUX_SNAME}"

# Setup handler for graceful server shutdown on 'docker stop'.
trap "printf '%s\n' 'Got SIGINT/SIGTERM!'; server_stop" SIGINT SIGTERM

# Loop to keep container up
sleep 5
while pgrep -o java > /dev/null; do sleep 5; done
printf '%s\n' 'FULL STOP!!!'
exit 0
