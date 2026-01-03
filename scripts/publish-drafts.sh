#!/bin/bash
# publish-drafts.sh - Convert draft posts to published
# Usage: ./scripts/publish-drafts.sh [post-path]

set -e

if [ -n "$1" ]; then
    # Publish specific post
    POST_FILE="$1"

    if [ ! -f "$POST_FILE" ]; then
        echo "Error: Post file not found: $POST_FILE"
        exit 1
    fi

    echo "Publishing: $POST_FILE"
    sed -i 's/draft = true/draft = false/' "$POST_FILE"
    echo "✓ Post published"
else
    # List all draft posts
    echo "Finding draft posts..."
    echo ""

    find content/ -name "index.md" -exec grep -l "draft = true" {} \; | while read -r post; do
        echo "📝 $post"
    done

    echo ""
    read -p "Publish all drafts? (y/N) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find content/ -name "index.md" -exec sed -i 's/draft = true/draft = false/' {} \;
        echo "✓ All drafts published"
    else
        echo "Cancelled"
    fi
fi
