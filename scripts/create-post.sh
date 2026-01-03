#!/bin/bash
# create-post.sh - Automated post creation script for AI agents
# Usage: ./scripts/create-post.sh <category> <post-title>

set -e

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <category> <post-title>"
    echo "Example: $0 ospf 'OSPF Virtual Links'"
    exit 1
fi

CATEGORY=$1
TITLE=$2
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

# Validate category
VALID_CATEGORIES=("ospf" "bgp" "mpls" "junos")
if [[ ! " ${VALID_CATEGORIES[@]} " =~ " ${CATEGORY} " ]]; then
    echo "Error: Invalid category '$CATEGORY'"
    echo "Valid categories: ${VALID_CATEGORIES[*]}"
    exit 1
fi

# Create the post
POST_DIR="content/routing/$CATEGORY/$SLUG"

echo "Creating new post..."
echo "Category: $CATEGORY"
echo "Title: $TITLE"
echo "Slug: $SLUG"
echo "Directory: $POST_DIR"

# Create directory
mkdir -p "$POST_DIR"

# Create index.md with template
cat > "$POST_DIR/index.md" << EOF
+++
title = '$TITLE'
date = $(date -u +"%Y-%m-%dT%H:%M:%S-05:00")
draft = true
tags = ["$CATEGORY", "Networking", "Study Notes"]
featured_image = 'featured.png'
summary = 'Add a 2-3 sentence summary of this post'
categories = ['routing']
+++

## Overview
[Provide a brief introduction to the topic]

## Background
[Explain the context and why this topic matters]

## Key Concepts

### Concept 1
[Detailed explanation]

### Concept 2
[Detailed explanation]

## Configuration Examples

\`\`\`junos
# Add configuration examples here

\`\`\`

## Verification

\`\`\`bash
# Add verification commands here

\`\`\`

## Troubleshooting

[Common issues and solutions]

## Exam Tips

[JNCIE-SP specific tips]

## Summary

[Key takeaways]

## References

- [Juniper Documentation](https://www.juniper.net/documentation/)
EOF

# Create placeholder for featured image
convert -size 1200x630 xc:'#5e81ac' \
    -pointsize 48 -fill white -gravity center \
    -annotate 0 "$TITLE" \
    "$POST_DIR/featured.png" 2>/dev/null || {
    echo "Note: ImageMagick not found. Creating placeholder file..."
    touch "$POST_DIR/featured.png"
}

echo ""
echo "✓ Post created successfully!"
echo "  Location: $POST_DIR/index.md"
echo ""
echo "Next steps:"
echo "  1. Edit content in: $POST_DIR/index.md"
echo "  2. Replace featured.png with actual image"
echo "  3. Add diagrams/images to post directory"
echo "  4. Preview: hugo server -D"
echo "  5. When ready, set draft = false"
echo ""
