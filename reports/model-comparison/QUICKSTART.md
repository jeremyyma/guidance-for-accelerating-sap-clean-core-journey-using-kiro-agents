# Model Comparison - Quick Start Guide

> ⚠️ **DISCLAIMER**
>
> This testing framework represents **personal experimentation and research only**. It is provided "as-is" without any warranty. Results are NOT officially supported by SAP, AWS, Anthropic, OpenAI, or Google. Do NOT rely on these results for production decisions without independent validation.
>
> **Test Disclaimer:** These tests were conducted on a specific package (TESTCDS2ENTITY) under specific conditions. Results may not apply to your environment, configurations, or packages.
>
> **No Liability:** The author disclaims any liability for losses or damages resulting from use of this framework or its recommendations.
>
> **Your Responsibility:** You are responsible for conducting your own testing and validation before deploying any recommendations in production.
>
> **Always Verify:** Compare these results against official documentation, SAP support, and your own comprehensive testing.

Comprehensive framework for testing and comparing Kiro agents across Claude, GPT-4, and Gemini models.

## 📋 Overview

This testing framework allows you to:
- Run Kiro agents (ATC, Documenter, Unused Code Discovery) with 3 different LLM models
- Compare output quality, accuracy, and performance across models
- Store results organized by model name and test type
- Generate analysis reports with quality metrics
- Choose the best model for each agent use case

## 🚀 Quick Start

### Option 1: Run All Tests (Recommended)

```bash
cd /Users/i817989/git/guidance-for-accelerating-sap-clean-core-journey-using-kiro-agents/reports/model-comparison

# Run complete test suite (Claude + GPT-4 + Gemini)
bash run_all_tests.sh
```

**Duration:** ~30-60 minutes (depending on SAP system and network speed)  
**Output:** Master log + individual model results + comparison summary

### Option 2: Run Individual Model Tests

```bash
cd /Users/i817989/git/guidance-for-accelerating-sap-clean-core-journey-using-kiro-agents/reports/model-comparison

# Run Claude Opus tests only
bash claude_tests.sh

# Run GPT-4 tests only
bash gpt4_tests.sh

# Run Gemini tests only
bash gemini_tests.sh
```

## 📁 Results Organization

After tests complete, results are stored as:

```
reports/model-comparison/
├── claude/
│   ├── atc/              # ATC compliance findings
│   ├── docs/             # Documentation output
│   ├── unused/           # Unused code findings
│   └── TEST_*.log        # Test execution log
├── gpt4/
│   ├── atc/
│   ├── docs/
│   ├── unused/
│   └── TEST_*.log
├── gemini/
│   ├── atc/
│   ├── docs/
│   ├── unused/
│   └── TEST_*.log
├── COMPARISON_SUMMARY.md # Analysis results
└── MASTER_*.log          # Master execution log
```

## ⚙️ Prerequisites

### 1. SAP System Connection

```bash
# Verify SAP environment is configured
cat mcp/sap.env

# Start MCP server if not running
./mcp/mcp-launcher.sh &

# Verify connection
./check-setup.sh --test-connection
```

### 2. API Keys

Set environment variables for each model:

```bash
# Claude
export ANTHROPIC_API_KEY="sk-ant-..."

# GPT-4 / OpenAI
export OPENAI_API_KEY="sk-..."

# Gemini / Google
export GEMINI_API_KEY="..."
```

### 3. Kiro CLI

```bash
# Verify installation
kiro-cli --version

# Should show: kiro-cli 2.14.x or higher
```

## 📊 Evaluating Results

### 1. Review Individual Model Results

```bash
# View Claude results
ls -la reports/model-comparison/claude/atc/
cat reports/model-comparison/claude/atc/SUMMARY.md

# View GPT-4 results
ls -la reports/model-comparison/gpt4/docs/
cat reports/model-comparison/gpt4/docs/SUMMARY.md

# View Gemini results
ls -la reports/model-comparison/gemini/unused/
```

### 2. Quality Comparison Criteria

**For ATC Checker:**
- Accuracy of Clean Core violations identified
- Completeness of findings across all package objects
- Clarity and actionability of recommendations
- Performance (execution time)

**For Code Documenter:**
- Coverage of all classes and methods
- Technical accuracy of documentation
- Business context inclusion
- Code examples provided
- Readability and organization

**For Unused Code Discovery:**
- Detection accuracy (finding actual dead code)
- False positive rate (avoiding incorrect flags)
- Impact analysis on removal
- Safety guidance provided

### 3. Update Comparison Summary

After reviewing outputs, edit the comparison summary:

```bash
vim reports/model-comparison/COMPARISON_SUMMARY.md
```

Fill in:
- Quality scores for each model/agent combo
- Cost estimates (tokens/pricing)
- Strengths and weaknesses
- Final recommendations

## 💰 Cost Analysis

Compare costs across models:

```bash
# Review token usage from logs
grep -i "tokens\|usage" reports/model-comparison/claude/atc/TEST_*.log
grep -i "tokens\|usage" reports/model-comparison/gpt4/atc/TEST_*.log
grep -i "tokens\|usage" reports/model-comparison/gemini/atc/TEST_*.log
```

Approximate costs per test (as of 2026-07):
- **Claude Opus:** $0.15-0.30 per test
- **GPT-4:** $0.10-0.25 per test  
- **Gemini:** $0.05-0.15 per test

## 🏆 Selecting the Best Model

### Decision Matrix

| Use Case | Recommended | Reason |
|----------|------------|--------|
| **Production Audits** | Claude Opus | Highest accuracy, comprehensive findings |
| **Quick Scans** | Gemini or GPT-4 | Fast, cost-effective |
| **Documentation** | Model varies | Evaluate based on output clarity |
| **Cost-Conscious** | Gemini | Lowest cost, good performance |
| **Compliance Critical** | Claude Opus | Most reliable for compliance checks |

## 📝 Documentation & Examples

For detailed information:
- [KIRO_MODEL_AGNOSTIC.md](../../KIRO_MODEL_AGNOSTIC.md) — Full model selection guide
- [README.md](../../README.md) — General project documentation
- [Baseline Results](../../docs/baselines/) — Reference output examples

## 🔧 Customization

### Change Test Package

Edit individual test scripts and change:
```bash
PACKAGE="TESTCDS2ENTITY"  # Change to your package
```

### Change Prompts

Edit the `kiro-cli chat` commands to customize:
```bash
kiro-cli chat \
  --agent sap-atc-checker \
  --model $MODEL \
  --no-interactive \
  "Your custom prompt here..."
```

### Add More Test Cases

Create new test scripts following the same pattern:
```bash
cp claude_tests.sh custom_tests.sh
# Edit custom_tests.sh to change MODEL and PACKAGE
```

## 🐛 Troubleshooting

### "Model not found" error

```bash
# Verify API key is set
echo $ANTHROPIC_API_KEY   # For Claude
echo $OPENAI_API_KEY      # For GPT-4
echo $GEMINI_API_KEY      # For Gemini

# If empty, set the API key first
export ANTHROPIC_API_KEY="your-key-here"
```

### "SAP connection failed" error

```bash
# Check SAP environment
cat mcp/sap.env

# Test connection
curl -v https://<SAP_HOST>/sap/bc/adt/discovery

# Start MCP server
./mcp/mcp-launcher.sh &
```

### Results not saving

```bash
# Ensure write permissions on reports directory
ls -la reports/model-comparison/
chmod 755 reports/model-comparison/

# Check kiro_result directory
ls -la kiro_result/
```

## 📤 Sharing Results

To share comparison results with team:

```bash
# Create archive
tar czf model-comparison-results-$(date +%Y%m%d).tar.gz \
  reports/model-comparison/

# Or commit to git
git add reports/model-comparison/
git commit -m "feat: add model comparison test results [Claude/GPT/Gemini]"
git push
```

## ✅ Workflow Checklist

- [ ] Configure SAP connection (sap.env)
- [ ] Set API keys for all three models
- [ ] Verify Kiro CLI is installed
- [ ] Review baseline examples in docs/baselines/
- [ ] Run all tests: `bash run_all_tests.sh`
- [ ] Review individual results in claude/, gpt4/, gemini/
- [ ] Evaluate output quality using provided criteria
- [ ] Fill in COMPARISON_SUMMARY.md with findings
- [ ] Select recommended model(s) for each agent
- [ ] Commit results for team reference

## 📞 Support

For issues or questions:
1. Check [KIRO_MODEL_AGNOSTIC.md](../../KIRO_MODEL_AGNOSTIC.md) for model documentation
2. Review [logs](.) for detailed error messages
3. Consult [README.md](../../README.md) for general setup help

---

**Created:** 2026-07-27  
**Framework Version:** 1.0  
**Status:** Ready for testing
