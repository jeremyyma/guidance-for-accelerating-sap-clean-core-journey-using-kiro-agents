# Model-Agnostic Kiro ATC & Documentation Agents

This document describes the model-agnostic Kiro agent setup for SAP Clean Core compliance checking and ABAP code documentation.

## What Changed

All native Kiro agents have been updated to use **`"model": "auto"`** instead of hardcoded model names. This allows you to run the same agents with **any LLM supported by Kiro-CLI**, without modifying agent configuration files.

### Modified Agents

The following agents are now model-agnostic:

| Agent | Purpose | File |
|-------|---------|------|
| `sap-atc-checker` | ABAP Test Cockpit (Clean Core compliance) | `.kiro/agents/sap-atc-checker.json` |
| `sap-custom-code-documenter` | Document ABAP source code | `.kiro/agents/sap-custom-code-documenter.json` |
| `sap-unused-code-discovery` | Identify unused ABAP objects | `.kiro/agents/sap-unused-code-discovery.json` |
| `business-function-mapper` | Map SAP business functions | `.kiro/agents/business-function-mapper.json` |
| `abap-accelerator` | General ABAP acceleration tasks | `.kiro/agents/abap-accelerator.json` |

## Why Model-Agnostic?

**Benefits:**

- 🤖 **Flexibility:** Use Claude, GPT-4, Gemini, or any Kiro-supported model
- 💰 **Cost Control:** Switch between models based on budget and performance needs
- 🔄 **Easy Switching:** No config file edits required—just change the `--model` CLI flag
- 📊 **A/B Testing:** Compare model outputs on the same task
- 🌍 **Vendor Independence:** Not locked into one LLM provider

**Trade-offs:**

- Slower agents may perform better than faster models for complex code analysis
- Token usage varies by model (affects cost)
- Performance characteristics differ across models

## Running Agents with Different Models

### Syntax

```bash
kiro-cli chat --agent <AGENT_NAME> --model <MODEL_ID> --no-interactive "<PROMPT>"
```

### Examples

#### Using Claude Opus (High Performance)

```bash
kiro-cli chat --agent sap-atc-checker --model claude-opus-4.5 --no-interactive 'Check package TESTCDS2ENTITY'
```

#### Using Claude Sonnet (Balanced)

```bash
kiro-cli chat --agent sap-atc-checker --model claude-sonnet-4 --no-interactive 'Check package TESTCDS2ENTITY'
```

#### Using Claude Haiku (Fast & Budget-Friendly)

```bash
kiro-cli chat --agent sap-atc-checker --model claude-haiku-3.5 --no-interactive 'Check package TESTCDS2ENTITY'
```

#### Using Auto (Kiro Decides)

```bash
kiro-cli chat --agent sap-atc-checker --model auto --no-interactive 'Check package TESTCDS2ENTITY'
```

The `auto` setting lets Kiro-CLI select the best model based on your system configuration and available models.

#### Using GPT-4 (OpenAI)

```bash
kiro-cli chat --agent sap-atc-checker --model gpt-4 --no-interactive 'Check package TESTCDS2ENTITY'
```

#### Using Gemini (Google)

```bash
kiro-cli chat --agent sap-atc-checker --model gemini-2.0-pro-exp --no-interactive 'Check package TESTCDS2ENTITY'
```

## Complete Baseline Examples

### ATC Checker Baseline (Model-Agnostic)

```bash
# Using Claude Opus
kiro-cli chat --trust-all-tools --agent sap-atc-checker --model claude-opus-4.5 --no-interactive 'Check package TESTCDS2ENTITY'

# Using Sonnet (medium cost/performance)
kiro-cli chat --trust-all-tools --agent sap-atc-checker --model claude-sonnet-4 --no-interactive 'Check package TESTCDS2ENTITY'

# Using Haiku (low cost)
kiro-cli chat --trust-all-tools --agent sap-atc-checker --model claude-haiku-3.5 --no-interactive 'Check package TESTCDS2ENTITY'

# Auto-select
kiro-cli chat --trust-all-tools --agent sap-atc-checker --model auto --no-interactive 'Check package TESTCDS2ENTITY'
```

### Code Documenter Baseline (Model-Agnostic)

```bash
kiro-cli chat --trust-all-tools --agent sap-custom-code-documenter --model claude-opus-4.5 --no-interactive 'Document package TESTCDS2ENTITY'
```

### Unused Code Discovery (Model-Agnostic)

```bash
kiro-cli chat --trust-all-tools --agent sap-unused-code-discovery --model claude-opus-4.5 --no-interactive 'Discover unused code in package TESTCDS2ENTITY'
```

## Configuration Details

### Agent Config Structure

Each agent JSON file now contains:

```json
{
  "name": "sap-atc-checker",
  "description": "ABAP Test Cockpit checker using SAP AWS ABAP Accelerator MCP",
  "prompt": "file://../../agents/native/atc-checker-instructions.md",
  "mcpServers": {
    "aws-abap-accelerator": {
      "url": "http://localhost:8001/mcp"
    }
  },
  "tools": ["read", "write", "shell", "todo", "@aws-abap-accelerator/aws_abap_cb_*"],
  "resources": ["file://AGENTS.md"],
  "model": "auto"
}
```

**Key field:** `"model": "auto"` allows Kiro-CLI's `--model` flag to override without editing the file.

## Environment Setup

### 1. Configure SAP Connection

```bash
# Edit or create mcp/sap.env
cp mcp/sap.env.example mcp/sap.env

# Required settings:
# SAP_SID=ER1
# SAP_HOST=ldai4er1.wdf.sap.corp:8000
# SAP_CLIENT=001
# SAP_USERNAME=MAJE
# SAP_ATC_VARIANT=ABAP_CLEAN_CORE_READINESS
```

### 2. Set SAP Password

```bash
echo -n "your_password" > secrets/sap_password
chmod 644 secrets/sap_password
```

### 3. Start AWS ABAP Accelerator MCP

```bash
bash mcp/mcp-launcher.sh
```

This starts the MCP server on `http://localhost:8001/mcp` that agents connect to.

### 4. Verify Setup

```bash
bash check-setup.sh
```

Should show: ✅ All 31 checks passed

## Model Selection Guide

### Task Complexity vs. Model Performance

| Task | Complexity | Recommended Model | Reason |
|------|-----------|-------------------|--------|
| Check small package for violations | Low | Haiku, Sonnet | Simple pattern matching |
| Document 50+ ABAP objects | High | Opus | Complex code analysis |
| Discover unused code across system | Very High | Opus | Requires deep semantic understanding |
| Quick ATC scan | Low | Haiku | Speed + cost priority |
| Production compliance audit | High | Opus | Accuracy critical |

### Cost Comparison (Approximate, per run on TESTCDS2ENTITY)

| Model | Speed | Cost | Best For |
|-------|-------|------|----------|
| Haiku | ⚡⚡⚡ | $ | Dev/testing, quick checks |
| Sonnet | ⚡⚡ | $$ | Balanced production use |
| Opus | ⚡ | $$$ | Complex analysis, accuracy critical |
| GPT-4 | ⚡⚡ | $$$$ | Compare alternatives |
| Gemini | ⚡⚡ | $$ | Cost-effective alternative |

## Advanced Usage

### Running Sequential Baselines (Model Comparison)

```bash
#!/bin/bash
# Compare all models on the same package

PACKAGE="TESTCDS2ENTITY"
MODELS=("claude-opus-4.5" "claude-sonnet-4" "claude-haiku-3.5")

for MODEL in "${MODELS[@]}"; do
  echo "=== Running with $MODEL ==="
  kiro-cli chat --trust-all-tools --agent sap-atc-checker --model $MODEL \
    --no-interactive "Check package $PACKAGE"
  echo "Results saved to kiro_result/sessions/"
done
```

### Running with Custom Model Configuration

If you have a custom model endpoint configured in Kiro:

```bash
kiro-cli chat --agent sap-atc-checker --model my-custom-model --no-interactive 'Check package TESTCDS2ENTITY'
```

## Output & Results

All agent executions produce timestamped session directories:

```
kiro_result/sessions/
  ├── YYYYMMDD_HHMMSS_TESTCDS2ENTITY_atc/
  │   ├── kiro-chat-messages.jsonl
  │   ├── sap-atc-checker.log
  │   └── tool execution logs
  └── [additional sessions...]

reports/
  ├── atc/TESTCDS2ENTITY/
  │   ├── atc_raw_result.json
  │   ├── summary.md
  │   └── [object findings]
  └── docs/TESTCDS2ENTITY/
      ├── index.md
      └── [documented objects]
```

## Troubleshooting

### "Model not found" Error

```
Error: Model 'gpt-4' not found
```

**Solution:** Ensure the model is configured in Kiro-CLI. Run:

```bash
kiro-cli models list
```

### Agent Runs Slowly with Certain Model

**Cause:** Slower models take longer to analyze complex ABAP code.

**Solution:** Use `--model auto` to let Kiro select optimally, or switch to Opus for better performance.

### Different Results Between Models

**Expected:** Different LLMs may classify findings differently, especially borderline violations.

**Best Practice:** Use Opus for production compliance audits; use Haiku/Sonnet for initial scans.

## Reverting to Hardcoded Model

If you need a specific model hardcoded in the config (not recommended):

```bash
# Edit the agent JSON manually
jq '.model = "claude-opus-4.5"' .kiro/agents/sap-atc-checker.json > temp && mv temp .kiro/agents/sap-atc-checker.json
```

## Related Documentation

- [Kiro-CLI Documentation](https://kiro.dev/docs/)
- [AWS ABAP Accelerator MCP](https://github.com/aws-solutions-library-samples/aws-abap-accelerator-http)
- [SAP Clean Core Principles](https://www.sap.com/topics/clean-core.html)

## Contributing

When adding new agents, follow the model-agnostic pattern:

```json
{
  "model": "auto"
}
```

This ensures all agents remain flexible across LLM providers.

---

**Last Updated:** 2026-07-23  
**Status:** Production Ready  
**Model Agnostic:** ✅ Yes
