#!/bin/bash
# preview.sh - Start Hugo development server with drafts

echo "Starting Hugo development server..."
echo "Server will be available at: http://localhost:1313"
echo ""
echo "Press Ctrl+C to stop"
echo ""

hugo server -D --bind 0.0.0.0 --buildDrafts
