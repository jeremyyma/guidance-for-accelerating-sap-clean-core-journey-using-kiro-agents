#!/bin/bash
# Claude Opus Model Comparison Tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$SCRIPT_DIR/claude/TEST_${TIMESTAMP}.log"
MODEL="claude-opus-4.5"
PACKAGE="TESTCDS2ENTITY"

echo "==================================================================" | tee $LOG_FILE
echo "Claude Opus Model Comparison Test Suite" | tee -a $LOG_FILE
echo "Timestamp: $TIMESTAMP" | tee -a $LOG_FILE
echo "Model: $MODEL" | tee -a $LOG_FILE
echo "Package: $PACKAGE" | tee -a $LOG_FILE
echo "==================================================================" | tee -a $LOG_FILE

cd /Users/i817989/git/guidance-for-accelerating-sap-clean-core-journey-using-kiro-agents

# Test 1: ATC Checker
echo "" | tee -a $LOG_FILE
echo "TEST 1: ATC Compliance Checker" | tee -a $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting ATC check..." | tee -a $LOG_FILE

START_TIME=$(date +%s)
kiro-cli chat \
  --agent sap-atc-checker \
  --model $MODEL \
  --no-interactive \
  "Check package $PACKAGE for Clean Core compliance. Provide detailed findings with categories and severity levels." \
  2>&1 | tee -a $LOG_FILE

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Store results
mkdir -p "$SCRIPT_DIR/claude/atc"
cp -r kiro_result/* "$SCRIPT_DIR/claude/atc/" 2>/dev/null || true

echo "ATC check completed in $DURATION seconds" | tee -a $LOG_FILE
echo "Results stored in: $SCRIPT_DIR/claude/atc/" | tee -a $LOG_FILE

# Test 2: Code Documenter
echo "" | tee -a $LOG_FILE
echo "TEST 2: Code Documenter" | tee -a $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting code documentation..." | tee -a $LOG_FILE

START_TIME=$(date +%s)
kiro-cli chat \
  --agent sap-custom-code-documenter \
  --model $MODEL \
  --no-interactive \
  "Document all classes and functions in $PACKAGE package. Include technical specifications, business context, and integration points." \
  2>&1 | tee -a $LOG_FILE

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Store results
mkdir -p "$SCRIPT_DIR/claude/docs"
cp -r kiro_result/* "$SCRIPT_DIR/claude/docs/" 2>/dev/null || true

echo "Documentation completed in $DURATION seconds" | tee -a $LOG_FILE
echo "Results stored in: $SCRIPT_DIR/claude/docs/" | tee -a $LOG_FILE

# Test 3: Unused Code Discovery
echo "" | tee -a $LOG_FILE
echo "TEST 3: Unused Code Discovery" | tee -a $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting unused code discovery..." | tee -a $LOG_FILE

START_TIME=$(date +%s)
kiro-cli chat \
  --agent sap-unused-code-discovery \
  --model $MODEL \
  --no-interactive \
  "Find unused code, dead functions, orphaned variables, and deprecated patterns in $PACKAGE. Provide removal safety assessment." \
  2>&1 | tee -a $LOG_FILE

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Store results
mkdir -p "$SCRIPT_DIR/claude/unused"
cp -r kiro_result/* "$SCRIPT_DIR/claude/unused/" 2>/dev/null || true

echo "Unused code discovery completed in $DURATION seconds" | tee -a $LOG_FILE
echo "Results stored in: $SCRIPT_DIR/claude/unused/" | tee -a $LOG_FILE

# Summary
echo "" | tee -a $LOG_FILE
echo "==================================================================" | tee -a $LOG_FILE
echo "Claude Opus Tests Completed Successfully" | tee -a $LOG_FILE
echo "Log file: $LOG_FILE" | tee -a $LOG_FILE
echo "Results stored in: $SCRIPT_DIR/claude/" | tee -a $LOG_FILE
echo "==================================================================" | tee -a $LOG_FILE
