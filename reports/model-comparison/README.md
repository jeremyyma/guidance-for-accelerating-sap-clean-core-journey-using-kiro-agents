# Model Comparison Testing Framework

> ⚠️ **DISCLAIMER**
>
> This testing framework and all results contained herein represent **personal experimentation and research only**. They are provided "as-is" without any warranty of any kind, expressed or implied. This work is NOT a production-ready solution, NOT officially supported by SAP or AWS, and is NOT suitable for use in mission-critical or regulated environments without independent validation and testing.
>
> **No Liability:** The author assumes no liability or responsibility for any losses, damages, or consequences arising from the use of this framework or its results. You use this framework entirely at your own risk.
>
> **Independent Validation Required:** Before making any production decisions based on these results, conduct your own comprehensive testing with your specific SAP environment, configurations, and business requirements.
>
> **Test Conditions:** Results are specific to the TESTCDS2ENTITY package and may not generalize to other packages or configurations. Model performance may vary based on API versions, region, pricing tier, and other factors.
>
> **Not a Warranty:** This is not a warranty, guarantee, or commitment regarding model behavior, quality, accuracy, or suitability for any specific purpose.

This directory contains methodology and results for comparing Kiro agent output across different LLM models.

## Test Strategy

**Objective:** Compare code quality, compliance findings, and documentation output from Claude, GPT-4, and Gemini models using the same Kiro agents on the same ABAP packages.

**Test Package:** TESTCDS2ENTITY (consistent baseline)  
**Date Range:** 2026-07-27 onward  
**Metrics:** Code quality, compliance findings accuracy, documentation clarity, performance

## Prerequisites

### 1. SAP System Configuration

```bash
cd /Users/i817989/git/guidance-for-accelerating-sap-clean-core-journey-using-kiro-agents

# Verify SAP environment
cat mcp/sap.env

# Start MCP server (if not running)
./mcp/mcp-launcher.sh &
```

### 2. Model API Keys

Ensure environment variables are set:
```bash
export ANTHROPIC_API_KEY="your-claude-key"
export OPENAI_API_KEY="your-gpt4-key"
export GEMINI_API_KEY="your-gemini-key"
```

### 3. Directory Structure

```
reports/model-comparison/
├── README.md                  # This file
├── run_model_comparison.sh    # Test execution script
├── COMPARISON_SUMMARY.md      # Results summary
├── claude/                    # Claude Opus results
│   ├── atc/                   # ATC checker output
│   ├── docs/                  # Documenter output
│   └── unused/                # Unused code output
├── gpt4/                      # GPT-4 results
│   ├── atc/
│   ├── docs/
│   └── unused/
└── gemini/                    # Gemini results
    ├── atc/
    ├── docs/
    └── unused/
```

## Test Commands

Run these commands sequentially to test each model on the same package.

### Test 1: Claude Opus (Baseline)

```bash
# Start time tracking
START_CLAUDE=$(date +%s)

# ATC Checker
kiro-cli chat \
  --agent sap-atc-checker \
  --model claude-opus-4.5 \
  --no-interactive \
  "Check package TESTCDS2ENTITY for Clean Core compliance. Provide detailed findings."

# Move results
mkdir -p reports/model-comparison/claude/atc
cp -r kiro_result/atc/* reports/model-comparison/claude/atc/

# Code Documenter
kiro-cli chat \
  --agent sap-custom-code-documenter \
  --model claude-opus-4.5 \
  --no-interactive \
  "Document all classes and functions in TESTCDS2ENTITY package. Include business context."

# Move results
mkdir -p reports/model-comparison/claude/docs
cp -r kiro_result/docs/* reports/model-comparison/claude/docs/

# Unused Code Discovery
kiro-cli chat \
  --agent sap-unused-code-discovery \
  --model claude-opus-4.5 \
  --no-interactive \
  "Find unused code, dead functions, and orphaned variables in TESTCDS2ENTITY."

# Move results
mkdir -p reports/model-comparison/claude/unused
cp -r kiro_result/unused/* reports/model-comparison/claude/unused/

END_CLAUDE=$(date +%s)
echo "Claude Opus execution time: $((END_CLAUDE - START_CLAUDE)) seconds" | tee reports/model-comparison/claude/TIMING.txt
```

### Test 2: GPT-4

```bash
# Start time tracking
START_GPT=$(date +%s)

# ATC Checker
kiro-cli chat \
  --agent sap-atc-checker \
  --model gpt-4 \
  --no-interactive \
  "Check package TESTCDS2ENTITY for Clean Core compliance. Provide detailed findings."

# Move results
mkdir -p reports/model-comparison/gpt4/atc
cp -r kiro_result/atc/* reports/model-comparison/gpt4/atc/

# Code Documenter
kiro-cli chat \
  --agent sap-custom-code-documenter \
  --model gpt-4 \
  --no-interactive \
  "Document all classes and functions in TESTCDS2ENTITY package. Include business context."

# Move results
mkdir -p reports/model-comparison/gpt4/docs
cp -r kiro_result/docs/* reports/model-comparison/gpt4/docs/

# Unused Code Discovery
kiro-cli chat \
  --agent sap-unused-code-discovery \
  --model gpt-4 \
  --no-interactive \
  "Find unused code, dead functions, and orphaned variables in TESTCDS2ENTITY."

# Move results
mkdir -p reports/model-comparison/gpt4/unused
cp -r kiro_result/unused/* reports/model-comparison/gpt4/unused/

END_GPT=$(date +%s)
echo "GPT-4 execution time: $((END_GPT - START_GPT)) seconds" | tee reports/model-comparison/gpt4/TIMING.txt
```

### Test 3: Gemini

```bash
# Start time tracking
START_GEMINI=$(date +%s)

# ATC Checker
kiro-cli chat \
  --agent sap-atc-checker \
  --model gemini-2.0 \
  --no-interactive \
  "Check package TESTCDS2ENTITY for Clean Core compliance. Provide detailed findings."

# Move results
mkdir -p reports/model-comparison/gemini/atc
cp -r kiro_result/atc/* reports/model-comparison/gemini/atc/

# Code Documenter
kiro-cli chat \
  --agent sap-custom-code-documenter \
  --model gemini-2.0 \
  --no-interactive \
  "Document all classes and functions in TESTCDS2ENTITY package. Include business context."

# Move results
mkdir -p reports/model-comparison/gemini/docs
cp -r kiro_result/docs/* reports/model-comparison/gemini/docs/

# Unused Code Discovery
kiro-cli chat \
  --agent sap-unused-code-discovery \
  --model gemini-2.0 \
  --no-interactive \
  "Find unused code, dead functions, and orphaned variables in TESTCDS2ENTITY."

# Move results
mkdir -p reports/model-comparison/gemini/unused
cp -r kiro_result/unused/* reports/model-comparison/gemini/unused/

END_GEMINI=$(date +%s)
echo "Gemini execution time: $((END_GEMINI - START_GEMINI)) seconds" | tee reports/model-comparison/gemini/TIMING.txt
```

## Evaluation Criteria

### ATC Compliance Findings

| Criteria | Weight | Evaluation |
|----------|--------|-----------|
| Finding Accuracy | 30% | Correctness of Clean Core violations identified |
| Recommendation Quality | 25% | Practical, actionable remediation steps |
| Performance | 20% | Execution speed (seconds) |
| Report Clarity | 15% | Organization and readability |
| False Positives | 10% | Absence of incorrect findings |

### Code Documentation

| Criteria | Weight | Evaluation |
|----------|--------|-----------|
| Completeness | 30% | All methods, parameters, returns documented |
| Accuracy | 25% | Technical correctness of descriptions |
| Business Context | 20% | Explanation of business purpose |
| Code Examples | 15% | Practical usage examples included |
| Clarity | 10% | Readability and language quality |

### Unused Code Discovery

| Criteria | Weight | Evaluation |
|----------|--------|-----------|
| Coverage | 30% | Detection rate of dead code |
| False Positives | 25% | Minimal false dead code reports |
| Impact Analysis | 20% | Understanding of removal consequences |
| Removal Safety | 15% | Guidance on safe removal process |
| Performance | 10% | Execution speed |

## Comparison Template

Use this template to evaluate each model's output:

```markdown
## Model Comparison: [AGENT_NAME]

### Claude Opus
- **Execution Time:** X seconds
- **Key Findings:** 
  - Finding 1
  - Finding 2
- **Strengths:**
  - Strength 1
  - Strength 2
- **Weaknesses:**
  - Weakness 1
  - Weakness 2
- **Overall Score:** X/10

### GPT-4
- **Execution Time:** X seconds
- **Key Findings:**
  - Finding 1
  - Finding 2
- **Strengths:**
  - Strength 1
  - Strength 2
- **Weaknesses:**
  - Weakness 1
  - Weakness 2
- **Overall Score:** X/10

### Gemini
- **Execution Time:** X seconds
- **Key Findings:**
  - Finding 1
  - Finding 2
- **Strengths:**
  - Strength 1
  - Strength 2
- **Weaknesses:**
  - Weakness 1
  - Weakness 2
- **Overall Score:** X/10

### Winner: [MODEL_NAME]
**Reason:** [Explanation of why this model's output was best]
```

## Cost Comparison

After test runs, calculate API costs:

```bash
# Get token counts from Kiro result logs
grep -i "tokens\|cost" reports/model-comparison/claude/atc/*.log
grep -i "tokens\|cost" reports/model-comparison/gpt4/atc/*.log
grep -i "tokens\|cost" reports/model-comparison/gemini/atc/*.log
```

| Model | Tokens Used | Est. Cost | Quality Score | Cost/Quality |
|-------|-------------|-----------|---------------|--------------|
| Claude Opus | — | — | — | — |
| GPT-4 | — | — | — | — |
| Gemini | — | — | — | — |

## Results Storage

Each model's results stored with:
- **Timestamp:** YYYY-MM-DD_HH:MM:SS
- **Model:** Model name and version
- **Agent:** Agent used
- **Package:** Target package (TESTCDS2ENTITY)
- **Findings:** Count of findings by category
- **Timing:** Execution time in seconds
- **Full Output:** Complete agent output files

## How to Run All Tests

Automated test script (create `run_model_comparison.sh`):

```bash
#!/bin/bash
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="reports/model-comparison/COMPARISON_${TIMESTAMP}.log"

echo "Starting model comparison testing at $(date)" | tee $LOG_FILE

# Run Claude tests
echo "=== Running Claude Opus tests ===" | tee -a $LOG_FILE
bash reports/model-comparison/claude_tests.sh 2>&1 | tee -a $LOG_FILE

# Run GPT-4 tests
echo "=== Running GPT-4 tests ===" | tee -a $LOG_FILE
bash reports/model-comparison/gpt4_tests.sh 2>&1 | tee -a $LOG_FILE

# Run Gemini tests
echo "=== Running Gemini tests ===" | tee -a $LOG_FILE
bash reports/model-comparison/gemini_tests.sh 2>&1 | tee -a $LOG_FILE

# Generate comparison report
echo "Generating comparison summary..." | tee -a $LOG_FILE
python3 reports/model-comparison/analyze_results.py | tee -a $LOG_FILE

echo "Model comparison testing complete at $(date)" | tee -a $LOG_FILE
```

## Next Steps

1. **Prepare Environment** — Ensure SAP connection and API keys configured
2. **Run Tests** — Execute test commands above in order
3. **Evaluate Results** — Use evaluation criteria to score each model
4. **Document Findings** — Fill in COMPARISON_SUMMARY.md
5. **Publish Results** — Commit results to repository for team reference

## References

- [KIRO_MODEL_AGNOSTIC.md](../../KIRO_MODEL_AGNOSTIC.md) — Model selection guide
- [Agent Guide](../../docs/agent-guide.md) — Agent capabilities and parameters
- [Baseline Results](../../../docs/baselines/) — Reference TESTCDS2ENTITY results

---

**Framework Created:** 2026-07-27  
**Status:** Ready for testing
