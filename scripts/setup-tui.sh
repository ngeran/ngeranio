#!/bin/bash
# ============================================
# TUI SETUP & LAUNCH SCRIPT
# ============================================
# Creates Python virtual environment
# Installs dependencies
# Launches the TUI
# ============================================

set -o pipefail

# ============================================
# CONFIGURATION
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENV_DIR="${PROJECT_ROOT}/.venv"
TUI_SCRIPT="${SCRIPT_DIR}/automation-tui.py"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================
# FUNCTIONS
# ============================================

print_header() {
  echo ""
  echo -e "${BLUE}============================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}============================================${NC}"
  echo ""
}

print_info() {
  echo -e "${CYAN}ℹ${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# ============================================
# CHECK PYTHON
# ============================================
print_header "NGERAN[IO] TUI SETUP & LAUNCH"

if ! command -v python3 &> /dev/null; then
  print_error "Python 3 is not installed"
  echo ""
  echo "Please install Python 3 first:"
  echo "  Ubuntu/Debian: sudo apt install python3 python3-venv"
  echo "  macOS: brew install python3"
  echo "  Arch: sudo pacman -S python python-pip"
  exit 1
fi

PYTHON_VERSION=$(python3 --version)
print_success "$PYTHON_VERSION found"

# ============================================
# CHECK PYTHON VENV MODULE
# ============================================
print_info "Checking Python venv module..."

if ! python3 -c "import venv" 2>/dev/null; then
  print_error "Python venv module is not installed"
  echo ""
  echo "Please install python3-venv:"
  echo "  Ubuntu/Debian: sudo apt install python3-venv"
  echo "  macOS: Should be included with python3"
  echo "  Arch: sudo pacman -S python-pip"
  exit 1
fi

print_success "Python venv module available"

# ============================================
# CREATE OR UPDATE VIRTUAL ENVIRONMENT
# ============================================
print_info "Setting up virtual environment..."

if [[ -d "$VENV_DIR" ]]; then
  print_info "Virtual environment already exists at .venv/"

  # Check if it's properly set up
  if [[ -f "${VENV_DIR}/bin/activate" ]] && [[ -f "${VENV_DIR}/bin/python3" ]]; then
    print_success "Virtual environment is valid"
  else
    print_warning "Virtual environment appears broken, recreating..."
    rm -rf "$VENV_DIR"
    python3 -m venv "$VENV_DIR"

    if [[ $? -ne 0 ]]; then
      print_error "Failed to create virtual environment"
      exit 1
    fi

    print_success "Virtual environment recreated"
  fi
else
  print_info "Creating new virtual environment at .venv/..."

  # Create virtual environment
  python3 -m venv "$VENV_DIR"

  if [[ $? -ne 0 ]]; then
    print_error "Failed to create virtual environment"
    exit 1
  fi

  print_success "Virtual environment created"
fi

# ============================================
# ACTIVATE VIRTUAL ENVIRONMENT
# ============================================
print_info "Activating virtual environment..."

# Activate virtual environment
source "${VENV_DIR}/bin/activate"

if [[ $? -ne 0 ]]; then
  print_error "Failed to activate virtual environment"
  exit 1
fi

print_success "Virtual environment activated"

# ============================================
# UPGRADE PIP
# ============================================
print_info "Upgrading pip..."

pip install --upgrade pip --quiet

if [[ $? -eq 0 ]]; then
  print_success "pip upgraded"
else
  print_warning "Failed to upgrade pip (continuing anyway)"
fi

# ============================================
# INSTALL DEPENDENCIES
# ============================================
print_info "Installing dependencies..."

# Install from requirements.txt
REQUIREMENTS_FILE="${SCRIPT_DIR}/requirements.txt"

if [[ -f "$REQUIREMENTS_FILE" ]]; then
  pip install -r "$REQUIREMENTS_FILE" --quiet

  if [[ $? -eq 0 ]]; then
    print_success "Dependencies installed"
  else
    print_error "Failed to install dependencies"
    exit 1
  fi
else
  # Fallback: install textual directly
  print_info "No requirements.txt found, installing textual directly..."

  pip install textual --quiet

  if [[ $? -eq 0 ]]; then
    print_success "Textual installed"
  else
    print_error "Failed to install Textual"
    exit 1
  fi
fi

# ============================================
# VERIFY TEXTUAL INSTALLATION
# ============================================
print_info "Verifying Textual installation..."

if python3 -c "import textual; print(f'Textual {textual.__version__}')" 2>/dev/null; then
  TEXTUAL_VERSION=$(python3 -c "import textual; print(textual.__version__)")
  print_success "Textual $TEXTUAL_VERSION installed"
else
  print_error "Textual installation verification failed"
  exit 1
fi

# ============================================
# CHECK PROJECT STRUCTURE
# =============================================
print_info "Validating project structure..."

if [[ ! -d "$PROJECT_ROOT/content" ]]; then
  print_warning "Not in valid project directory (content/ not found)"
  print_info "Continuing anyway..."
fi

# ============================================
# LAUNCH TUI
# =============================================
print_header "LAUNCHING TUI"

print_success "All setup complete!"
echo ""
echo -e "${CYAN}To stop the TUI:${NC} Press 'q' or Ctrl+C"
echo -e "${CYAN}To restart:${NC} Run './scripts/tui' again"
echo ""
echo "Starting TUI..."
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Launch the TUI
exec python3 "$TUI_SCRIPT"
