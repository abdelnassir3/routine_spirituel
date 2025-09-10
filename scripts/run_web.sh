#!/bin/bash

# Script to run Flutter web app and keep it active
echo "🚀 Starting Flutter Web Application..."
echo "📍 Access the app at: http://localhost:5000"
echo "Press Ctrl+C to stop the application"
echo ""

# Run Flutter in web mode
flutter run -d chrome --web-port=5000

# Keep the script running
while true; do
    sleep 1
done