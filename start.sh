#!/bin/sh
# RECONX supervisor script (Linux / macOS / Docker ENTRYPOINT)
#
# Usage:
#   ./start.sh                       Run in the foreground (Ctrl-C to stop)
#   nohup ./start.sh >reconx.log 2>&1 &  Run in the background
#   ./start.sh -addr :9000           Pass extra arguments through to reconx unchanged
#
# Run reconx and decide whether to restart it based on its exit code.
#
#   0      Normal user stop       → Exit the loop
#   75     Restart requested      → Restart immediately (after "One-click Update" or "Rollback" in the UI)
#   Other  Crash                  → Restart with backoff (1→2→4… up to 60 seconds)
#
# Downloads, SHA256 verification, and binary replacement stay in Go to avoid duplicating critical
# logic in sh and bat. Replacing the executable with a broken binary would leave this script
# restarting it endlessly, requiring manual recovery. reconx handles verification and replacement
# at startup in the selfupdate package, keeping the script simple.
set -u

cd "$(dirname "$0")" || exit 1

BIN=./reconx
[ -x "$BIN" ] || { echo "[reconx] Executable not found: $BIN" >&2; exit 1; }

RESTART_CODE=75
MAX_DELAY=60

child=0
stopping=0

# Forward stop signals to reconx.
#
# Docker requires this: docker stop only sends SIGTERM to PID 1 (this script), not its child.
# Without forwarding, reconx cannot shut down gracefully and is forcibly killed with SIGKILL
# after 10 seconds, interrupting running tasks.
forward() {
	stopping=1
	if [ "$child" -ne 0 ]; then
		kill -TERM "$child" 2>/dev/null || true
	fi
}
trap forward INT TERM

delay=1
while :; do
	"$BIN" "$@" &
	child=$!

	# A signal interrupts wait with a status >128 while the child is still shutting down gracefully.
	# Wait again to get the child's actual exit code.
	wait "$child"
	code=$?
	if [ "$code" -gt 128 ]; then
		wait "$child"
		code=$?
	fi
	child=0

	if [ "$stopping" -eq 1 ]; then
		echo "[reconx] Stopped"
		exit 0
	fi

	case "$code" in
		0)
			echo "[reconx] Exited normally"
			exit 0
			;;
		"$RESTART_CODE")
			# Update/rollback is ready: reconx replaces the binary at the next startup (see selfupdate.Bootstrap).
			echo "[reconx] Restart requested (applying the new version)…"
			delay=1
			;;
		*)
			echo "[reconx] Unexpected exit (code=$code); restarting in ${delay}s" >&2
			sleep "$delay"
			delay=$((delay * 2))
			[ "$delay" -gt "$MAX_DELAY" ] && delay=$MAX_DELAY
			;;
	esac
done
