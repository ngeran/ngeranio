#!/bin/bash
# ============================================
# SAFE TESTING WORKFLOW
# ============================================
# This script demonstrates safe testing of
# the Phase 2 automation system
# ============================================

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=========================================="
echo "Phase 2 Automation Testing Workflow"
echo "=========================================="
echo ""

# ============================================
# TEST 1: Create a Test Post
# ============================================
echo "TEST 1: Creating a test post..."
echo "Command: ./scripts/create-post.sh ospf \"Test Post\""
echo ""

./scripts/create-post.sh ospf "Test Post"

if [[ $? -eq 0 ]]; then
  echo "✓ Test post created successfully"
  TEST_POST="content/routing/ospf/test-post/index.md"
else
  echo "✗ Failed to create test post"
  exit 1
fi

echo ""
echo "=========================================="
echo ""

# ============================================
# TEST 2: Validate the Test Post
# ============================================
echo "TEST 2: Validating the test post..."
echo "Command: ./scripts/quality-gate.sh validate $TEST_POST"
echo ""

./scripts/quality-gate.sh validate "$TEST_POST"

echo ""
echo "=========================================="
echo ""

# ============================================
# TEST 3: Get Post Information
# ============================================
echo "TEST 3: Getting post information..."
echo "Command: ./scripts/ai-content-manager.sh info $TEST_POST"
echo ""

./scripts/ai-content-manager.sh info "$TEST_POST"

echo ""
echo "=========================================="
echo ""

# ============================================
# TEST 4: List All Drafts
# ============================================
echo "TEST 4: Listing all draft posts..."
echo "Command: ./scripts/ai-content-manager.sh list drafts"
echo ""

./scripts/ai-content-manager.sh list drafts

echo ""
echo "=========================================="
echo ""

# ============================================
# TEST 5: Check Logs
# ============================================
echo "TEST 5: Checking automation logs..."
echo ""

if [[ -f "logs/automation.log" ]]; then
  echo "✓ automation.log exists"
  echo "Last 5 entries:"
  tail -n 5 "logs/automation.log"
else
  echo "⚠ automation.log not found"
fi

echo ""
echo "=========================================="
echo ""

# ============================================
# CLEANUP OPTION
# ============================================
echo "CLEANUP:"
echo "The test post was created at: $TEST_POST"
echo ""
echo "To remove the test post, run:"
echo "  rm -rf content/routing/ospf/test-post"
echo ""
echo "Or use the AI content manager:"
echo "  ./scripts/ai-content-manager.sh delete $TEST_POST"
echo ""
echo "=========================================="
echo ""
echo "Testing workflow complete!"
echo ""
echo "Summary:"
echo "  - Test post created"
echo "  - Validation run"
echo "  - Post info displayed"
echo "  - Draft list shown"
echo "  - Logs checked"
echo ""
echo "Next steps:"
echo "  1. Review the test post at: $TEST_POST"
echo "  2. Edit the content to add real information"
echo "  3. Validate again when ready"
echo "  4. Preview locally: ./scripts/preview.sh"
echo "  5. Publish when ready: ./scripts/publish-drafts.sh $TEST_POST --validate"
echo ""
