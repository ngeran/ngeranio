#!/bin/bash
# Simple Hugo server control script

case "$1" in
  start)
    echo "Starting Hugo server..."
    hugo server -D --bind 0.0.0.0 --port 1313
    ;;
  stop)
    echo "Stopping Hugo server..."
    pkill -f "hugo server"
    echo "✅ Server stopped"
    ;;
  restart)
    echo "Restarting Hugo server..."
    pkill -f "hugo server"
    sleep 1
    hugo server -D --bind 0.0.0.0 --port 1313
    ;;
  status)
    if pgrep -f "hugo server" > /dev/null; then
      echo "✅ Hugo server is running"
      echo "Visit: http://localhost:1313"
    else
      echo "❌ Hugo server is not running"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    echo ""
    echo "Commands:"
    echo "  start   - Start Hugo development server"
    echo "  stop    - Stop Hugo server"
    echo "  restart - Restart Hugo server"
    echo "  status  - Check if server is running"
    exit 1
    ;;
esac
