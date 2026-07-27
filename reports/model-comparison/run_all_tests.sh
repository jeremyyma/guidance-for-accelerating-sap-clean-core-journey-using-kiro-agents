#!/bin/bash
# Master Model Comparison Test Runner

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MASTER_LOG="$SCRIPT_DIR/MASTER_${TIMESTAMP}.log"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $MASTER_LOG
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a $MASTER_LOG
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a $MASTER_LOG
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a $MASTER_LOG
}

# Header
echo "" | tee $MASTER_LOG
echo "╔════════════════════════════════════════════════════════════════════╗" | tee -a $MASTER_LOG
echo "║     KIRO MODEL COMPARISON TEST SUITE - MASTER RUNNER              ║" | tee -a $MASTER_LOG
echo "║     Testing: Claude Opus, GPT-4, and Gemini                        ║" | tee -a $MASTER_LOG
echo "╚════════════════════════════════════════════════════════════════════╝" | tee -a $MASTER_LOG
echo "" | tee -a $MASTER_LOG

log "Master test suite started"
log "Timestamp: $TIMESTAMP"
log "Master log: $MASTER_LOG"
log ""

# Prerequisite checks
log "Checking prerequisites..."

# Check Kiro CLI
if ! which kiro-cli &> /dev/null; then
    log_error "kiro-cli not found. Install Kiro CLI first."
    exit 1
fi
log_success "kiro-cli is installed: $(kiro-cli --version)"

# Check SAP environment
if [ ! -f "$SCRIPT_DIR/../../mcp/sap.env" ]; then
    log_warning "SAP environment file not configured at mcp/sap.env"
    log_warning "Tests may fail if SAP system is not accessible"
fi

# Check API keys
if [ -z "$ANTHROPIC_API_KEY" ]; then
    log_warning "ANTHROPIC_API_KEY not set - Claude tests may fail"
fi
if [ -z "$OPENAI_API_KEY" ]; then
    log_warning "OPENAI_API_KEY not set - GPT-4 tests may fail"
fi
if [ -z "$GEMINI_API_KEY" ]; then
    log_warning "GEMINI_API_KEY not set - Gemini tests may fail"
fi

log ""
log "Prerequisites check complete"
log ""

# Function to run model tests
run_model_tests() {
    local model=$1
    local script="$SCRIPT_DIR/${model}_tests.sh"
    
    if [ ! -f "$script" ]; then
        log_error "Test script not found: $script"
        return 1
    fi
    
    log "Running $model model tests..."
    if bash "$script" >> $MASTER_LOG 2>&1; then
        log_success "$model tests completed successfully"
        return 0
    else
        log_error "$model tests failed"
        return 1
    fi
}

# Run tests sequentially
FAILED_TESTS=()

log "=========================================="
log "PHASE 1: CLAUDE OPUS TESTS"
log "=========================================="
if ! run_model_tests "claude"; then
    FAILED_TESTS+=("Claude Opus")
fi
log ""

log "=========================================="
log "PHASE 2: GPT-4 TESTS"
log "=========================================="
if ! run_model_tests "gpt4"; then
    FAILED_TESTS+=("GPT-4")
fi
log ""

log "=========================================="
log "PHASE 3: GEMINI TESTS"
log "=========================================="
if ! run_model_tests "gemini"; then
    FAILED_TESTS+=("Gemini")
fi
log ""

# Generate analysis
log "=========================================="
log "PHASE 4: ANALYSIS & COMPARISON"
log "=========================================="

if command -v python3 &> /dev/null; then
    log "Running comparison analysis..."
    if python3 "$SCRIPT_DIR/analyze_results.py" >> $MASTER_LOG 2>&1; then
        log_success "Analysis completed successfully"
    else
        log_warning "Analysis encountered issues (see log for details)"
    fi
else
    log_warning "Python3 not found, skipping automated analysis"
fi

log ""

# Summary
echo "" | tee -a $MASTER_LOG
echo "╔════════════════════════════════════════════════════════════════════╗" | tee -a $MASTER_LOG
echo "║     TEST SUITE SUMMARY                                             ║" | tee -a $MASTER_LOG
echo "╚════════════════════════════════════════════════════════════════════╝" | tee -a $MASTER_LOG
echo "" | tee -a $MASTER_LOG

if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo -e "${GREEN}[✓] All model tests completed successfully${NC}" | tee -a $MASTER_LOG
else
    echo -e "${RED}[✗] ${#FAILED_TESTS[@]} test suite(s) failed:${NC}" | tee -a $MASTER_LOG
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "${RED}    - $test${NC}" | tee -a $MASTER_LOG
    done
fi

echo "" | tee -a $MASTER_LOG
echo "Results Directory Structure:" | tee -a $MASTER_LOG
echo "  reports/model-comparison/" | tee -a $MASTER_LOG
echo "  ├── claude/" | tee -a $MASTER_LOG
echo "  │   ├── atc/" | tee -a $MASTER_LOG
echo "  │   ├── docs/" | tee -a $MASTER_LOG
echo "  │   └── unused/" | tee -a $MASTER_LOG
echo "  ├── gpt4/" | tee -a $MASTER_LOG
echo "  │   ├── atc/" | tee -a $MASTER_LOG
echo "  │   ├── docs/" | tee -a $MASTER_LOG
echo "  │   └── unused/" | tee -a $MASTER_LOG
echo "  ├── gemini/" | tee -a $MASTER_LOG
echo "  │   ├── atc/" | tee -a $MASTER_LOG
echo "  │   ├── docs/" | tee -a $MASTER_LOG
echo "  │   └── unused/" | tee -a $MASTER_LOG
echo "  ├── COMPARISON_SUMMARY.md" | tee -a $MASTER_LOG
echo "  ├── MASTER_${TIMESTAMP}.log" | tee -a $MASTER_LOG
echo "  └── [model]_tests.sh" | tee -a $MASTER_LOG
echo "" | tee -a $MASTER_LOG

echo "Next Steps:" | tee -a $MASTER_LOG
echo "  1. Review detailed results in reports/model-comparison/[model]/" | tee -a $MASTER_LOG
echo "  2. Fill in manual quality assessments in COMPARISON_SUMMARY.md" | tee -a $MASTER_LOG
echo "  3. Compare output quality, accuracy, and performance" | tee -a $MASTER_LOG
echo "  4. Commit results for team reference" | tee -a $MASTER_LOG
echo "" | tee -a $MASTER_LOG

echo "Master Log File:" | tee -a $MASTER_LOG
echo "  $MASTER_LOG" | tee -a $MASTER_LOG
echo "" | tee -a $MASTER_LOG

log "Master test suite completed at $(date)"
echo "" | tee -a $MASTER_LOG

# Exit with appropriate code
if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    log_success "All tests passed"
    exit 0
else
    log_error "Some tests failed - see log for details"
    exit 1
fi
