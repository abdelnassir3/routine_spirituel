#!/bin/bash

# Script to keep Flutter web running in the background
echo "🚀 Starting Flutter Web Server on port 5000..."
echo "📱 Access your app at: http://localhost:5000"
echo ""
echo "The server will keep running in the background."
echo "To stop it, run: pkill -f 'flutter.*chrome'"
echo ""

# Start Flutter and keep it alive by reading from a named pipe
mkfifo /tmp/flutter_pipe 2>/dev/null || true

# Run Flutter with input from the pipe
(
    # Keep the pipe open
    exec 3>/tmp/flutter_pipe
    
    # Start Flutter
    flutter run -d chrome --web-port=5000 </tmp/flutter_pipe &
    FLUTTER_PID=$!
    
    echo "Flutter process started with PID: $FLUTTER_PID"
    echo "Server is initializing..."
    
    # Keep the pipe writer open
    while kill -0 $FLUTTER_PID 2>/dev/null; do
        sleep 1
    done
    
    # Cleanup
    exec 3>&-
) &

# Give Flutter time to start
sleep 15

echo ""
echo "✅ Flutter Web Server should now be running at http://localhost:5000"
echo "Check the browser or run: curl http://localhost:5000"