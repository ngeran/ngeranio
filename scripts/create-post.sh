#!/bin/bash
# ============================================
# CREATE POST - Enhanced with Phase 1 Libraries
# ============================================
# Automated post creation script for AI agents
# Usage: ./scripts/create-post.sh <category> <post-title>
# ============================================

set -o pipefail

# ============================================
# LIBRARY SETUP
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source Phase 1 libraries
source "${PROJECT_ROOT}/scripts/lib/common.sh"
source "${PROJECT_ROOT}/scripts/lib/logger.sh"
source "${PROJECT_ROOT}/scripts/lib/error-handler.sh"
source "${PROJECT_ROOT}/scripts/lib/config.sh"

# ============================================
# CONFIGURATION
# ============================================
CONTENT_DIR=$(get_config "CONTENT_DIR" "content/routing")
VALID_CATEGORIES=("ospf" "bgp" "mpls" "junos")
AUTO_BACKUP=$(get_config "CONTENT_AUTO_BACKUP" "true")
IMAGE_DEFAULT_WIDTH=$(get_config "IMAGE_DEFAULT_WIDTH" "1200")
IMAGE_DEFAULT_HEIGHT=$(get_config "IMAGE_DEFAULT_HEIGHT" "630")
IMAGE_PLACEHOLDER_COLOR=$(get_config "IMAGE_PLACEHOLDER_COLOR" "#5e81ac")

# ============================================
# FUNCTIONS
# ============================================

show_usage() {
  cat << EOF
Usage: ${0##*/} <category> <post-title> [options]

Arguments:
  category      Post category (ospf, bgp, mpls, junos)
  post-title    Title of the post (use quotes for multi-word titles)

Options:
  --force       Overwrite if post already exists
  --no-backup   Skip backup before creation
  --help        Show this help message

Examples:
  ${0##*/} ospf "OSPF Virtual Links"
  ${0##*/} bgp "BGP Communities" --force
  ${0##*/} mpls "MPLS Labels"

EOF
  exit 0
}

create_post() {
  local category="$1"
  local title="$2"
  local force="$3"
  local no_backup="$4"

  log_content "INFO" "Creating new post..."
  log_content "INFO" "Category: $category"
  log_content "INFO" "Title: $title"

  # Validate category
  if ! validate_category "$category"; then
    log_content "ERROR" "Invalid category: $category"
    log_content "ERROR" "Valid categories: ${VALID_CATEGORIES[*]}"
    return 1
  fi

  # Generate slug
  local slug
  slug=$(generate_slug "$title")

  log_content "INFO" "Generated slug: $slug"

  # Create directory path
  local post_dir="${CONTENT_DIR}/${category}/${slug}"

  # Check if directory already exists
  if [[ -d "$post_dir" ]]; then
    if [[ "$force" != "true" ]]; then
      log_content "ERROR" "Post already exists: $post_dir"
      log_content "ERROR" "Use --force to overwrite"
      return 1
    else
      log_content "WARNING" "Overwriting existing post: $post_dir"
    fi
  fi

  # Create directory
  mkdir -p "$post_dir"

  # Generate current date
  local current_date
  current_date=$(date -Iseconds)

  # Create index.md with enhanced template
  cat > "${post_dir}/index.md" << EOF
+++
title = '${title}'
date = ${current_date}
draft = true
tags = ["${category}", "Routing", "Networking"]
featured_image = 'featured.png'
summary = 'Add a 2-3 sentence summary of this post'
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

  # Create featured image placeholder
  log_content "INFO" "Creating featured image..."

  if command -v convert &>/dev/null; then
    convert -size ${IMAGE_DEFAULT_WIDTH}x${IMAGE_DEFAULT_HEIGHT} xc:"${IMAGE_PLACEHOLDER_COLOR}" \
      -pointsize 48 -fill white -gravity center \
      -annotate 0 "$title" \
      "${post_dir}/featured.png" 2>/dev/null || {
      log_content "WARNING" "ImageMagick failed. Creating placeholder file..."
      touch "${post_dir}/featured.png"
    }
  else
    log_content "WARNING" "ImageMagick not found. Creating placeholder file..."
    touch "${post_dir}/featured.png"
  fi

  log_content "SUCCESS" "✓ Post created successfully!"
  log_content "INFO" "  Location: ${post_dir}/index.md"
  echo ""
  log_content "INFO" "Next steps:"
  log_content "INFO" "  1. Edit content in: ${post_dir}/index.md"
  log_content "INFO" "  2. Replace featured.png with actual image"
  log_content "INFO" "  3. Add diagrams/images to post directory"
  log_content "INFO" "  4. Validate: ./scripts/quality-gate.sh validate ${post_dir}/index.md"
  log_content "INFO" "  5. Preview: ./scripts/preview.sh"
  log_content "INFO" "  6. When ready, set draft = false"

  return 0
}

# ============================================
# MAIN
# ============================================

main() {
  # Parse arguments
  if [[ $# -lt 2 ]]; then
    show_usage
  fi

  local category="$1"
  local title="$2"
  local force="false"
  local no_backup="false"

  shift 2

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force)
        force="true"
        shift
        ;;
      --no-backup)
        no_backup="true"
        shift
        ;;
      --help|-h)
        show_usage
        ;;
      *)
        log_content "ERROR" "Unknown option: $1"
        echo ""
        show_usage
        ;;
    esac
  done

  # Create post
  create_post "$category" "$title" "$force" "$no_backup"
}

# Run main
main "$@"

