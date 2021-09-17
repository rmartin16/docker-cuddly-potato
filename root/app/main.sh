#!/usr/bin/env sh
set -euf

# Make sure we are in the venv
[ -n "${VIRTUAL_ENV:-}" ]

# Forward SIGTERM to child
# Thank you https://unix.stackexchange.com/a/444676
prep_term() {
    unset term_child_pid
    unset term_kill_needed
    trap 'handle_term' TERM INT
}
handle_term() {
    if [ -n "${term_child_pid:-}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    else
        term_kill_needed="yes"
    fi
}
wait_term() {
    term_child_pid=$!
    if [ -n "${term_kill_needed:-}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    fi
    wait "${term_child_pid}"
    trap - TERM INT
    wait "${term_child_pid}"
}

echo "Starting cuddly potato!"
set +e
# If we are running in an interactive shell, we can't 
#  (and don't need to) do any of the fancy interrupt catching
if [ -t 0 ]; then
    uwsgi --ini uwsgi.ini
 else
    prep_term
    env
    whoami
    uwsgi --ini uwsgi.ini &
    wait_term
fi
set -e
