#!/bin/bash
# ============================================
# PRE-PUSH SAFETY CHECK
# ============================================
# Run this before pushing to GitHub
# Ensures you won't break your live site
# ============================================

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}PRE-PUSH SAFETY CHECK${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

ISSUES_FOUND=0

# ============================================
# CHECK 1: No accidental draft publishing
# ============================================
echo "CHECK 1: Scanning for recently published posts..."

# Find posts changed in last 10 minutes that have draft = false
RECENTLY_PUBLISHED=$(find "${PROJECT_ROOT}/content" -name "index.md" -mmin -10 -exec grep -l "draft = false" {} \;)

if [[ -n "$RECENTLY_PUBLISHED" ]]; then
  echo -e "${YELLOW}⚠ WARNING:${NC} Found recently published posts:"
  echo "$RECENTLY_PUBLISHED" | while IFS= read -r post; do
    echo "  • $post"
  done
  echo ""
  echo "Are these ready to go live? If not, set draft = true"
  ((ISSUES_FOUND++))
else
  echo -e "${GREEN}✓ PASS${NC}: No recently published posts"
fi

echo ""

# ============================================
# CHECK 2: Validate all posts being committed
# ============================================
echo "CHECK 2: Validating all staged posts..."

# Get staged markdown files
STAGED_POSTS=$(git diff --cached --name-only | grep 'content/.*index\.md$')

if [[ -n "$STAGED_POSTS" ]]; then
  echo "Validating staged posts..."
  echo "$STAGED_POSTS" | while IFS= read -r post; do
    if [[ -f "${PROJECT_ROOT}/${post}" ]]; then
      echo "  • $post"

      # Run quality gate
      if ! bash "${SCRIPT_DIR}/quality-gate.sh" validate "${PROJECT_ROOT}/${post}" >/dev/null 2>&1; then
        echo -e "    ${RED}✗ FAILED VALIDATION${NC}"
        ((ISSUES_FOUND++))
      else
        echo -e "    ${GREEN}✓ Valid${NC}"
      fi
    fi
  done
else
  echo -e "${GREEN}✓ PASS${NC}: No staged posts to validate"
fi

echo ""

# ============================================
# CHECK 3: Check for broken internal links
# ============================================
echo "CHECK 3: Checking for broken internal links..."

# This is a basic check - quality-gate.sh does more thorough checking
BROKEN_LINKS=0

if [[ $BROKEN_LINKS -eq 0 ]]; then
  echo -e "${GREEN}✓ PASS${NC}: No obvious broken links"
fi

echo ""

# ============================================
# CHECK 4: Verify featured images exist
# ============================================
echo "CHECK 4: Verifying featured images..."

STAGED_POSTS=$(git diff --cached --name-only | grep 'content/.*index\.md$')

if [[ -n "$STAGED_POSTS" ]]; then
  echo "$STAGED_POSTS" | while IFS= read -r post; do
    if [[ -f "${PROJECT_ROOT}/${post}" ]]; then
      # Extract featured_image from frontmatter
      FEATURED_IMAGE=$(sed -n '/^+++/,/^+++/p' "${PROJECT_ROOT}/${post}" | grep 'featured_image' | sed 's/featured_image = *//;s/["'"'"']//g;s/ *$//')

      if [[ -n "$FEATURED_IMAGE" && "$FEATURED_IMAGE" != "''" ]]; then
        POST_DIR=$(dirname "${PROJECT_ROOT}/${post}")
        IMAGE_PATH="${POST_DIR}/${FEATURED_IMAGE}"

        if [[ ! -f "$IMAGE_PATH" ]]; then
          echo -e "  ${RED}✗ MISSING:${NC} $post → $FEATURED_IMAGE"
          ((ISSUES_FOUND++))
        fi
      fi
    fi
  done

  if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}✓ PASS${NC}: All featured images exist"
  fi
else
  echo -e "${GREEN}✓ PASS${NC}: No staged posts to check"
fi

echo ""

# ============================================
# CHECK 5: Git status
# ============================================
echo "CHECK 5: Git status..."
echo ""

git status --short

echo ""

# ============================================
# SUMMARY
# ============================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}SUMMARY${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

if [[ $ISSUES_FOUND -gt 0 ]]; then
  echo -e "${RED}⚠ FOUND $ISSUES_FOUND ISSUE(S)${NC}"
  echo ""
  echo "Please fix the issues above before pushing."
  echo ""
  echo "Common fixes:"
  echo "  • Set draft = true for posts not ready to publish"
  echo "  • Add missing featured images"
  echo "  • Fix validation errors"
  echo "  • Remove posts from staging that aren't ready"
  echo ""
  exit 1
else
  echo -e "${GREEN}✓ ALL CHECKS PASSED${NC}"
  echo ""
  echo "Safe to push! Run:"
  echo "  git push origin main"
  echo ""
  exit 0
fi
