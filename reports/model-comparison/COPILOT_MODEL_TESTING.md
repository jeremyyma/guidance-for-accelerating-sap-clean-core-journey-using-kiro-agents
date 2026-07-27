# Copilot-Native Model Testing with `/model` Command

> ⚠️ **DISCLAIMER**
>
> This guide describes a personal testing approach using Copilot and is provided "as-is" without any warranty. Results from this approach are experimental and NOT suitable for production use without independent validation. You assume all responsibility for the results and any consequences of following this guide. This is personal experimentation only, not an officially supported or endorsed approach.

## Overview

Instead of running separate test scripts for each model, you can use **Copilot's built-in `/model` command** to test agents with different LLM models directly in the agent-compass environment.

## Available Models (via Copilot)

Your Copilot supports these models:
- `claude-3.5-sonnet` (Claude - highest quality)
- `gpt-4-turbo` (GPT-4)
- `claude-opus-4.5` (Claude Opus - premium)
- `gemini-2.0-flash` (Gemini - fastest)
- And others depending on your Copilot configuration

## How to Test with Different Models

### Option 1: Switch Model, Then Run Test

```
1. Type: /model
2. Select desired model from list
3. Run test command in selected model context
4. Switch to next model and repeat
```

### Option 2: Run Tests Sequentially in Each Model

For each model:

```bash
/model
# Select model (e.g., "Claude 3.5 Sonnet")

# Then in that model context:
cd /Users/i817989/git/guidance-for-accelerating-sap-clean-core-journey-using-kiro-agents

# Test 1: ATC Checker
kiro-cli chat \
  --agent sap-atc-checker \
  --model auto \
  --no-interactive \
  "Check package TESTCDS2ENTITY for Clean Core compliance"

# Test 2: Code Documenter
kiro-cli chat \
  --agent sap-custom-code-documenter \
  --model auto \
  --no-interactive \
  "Document all classes in package TESTCDS2ENTITY"

# Test 3: Unused Code Discovery
kiro-cli chat \
  --agent sap-unused-code-discovery \
  --model auto \
  --no-interactive \
  "Find unused code in package TESTCDS2ENTITY"
```

### Option 3: Create Model-Specific Agent Commands

**Test Claude:**
```
/model -> Select Claude 3.5 Sonnet
/test-claude
(custom command runs all 3 agents)
```

**Test GPT-4:**
```
/model -> Select GPT-4 Turbo
/test-gpt4
(custom command runs all 3 agents)
```

**Test Gemini:**
```
/model -> Select Gemini 2.0 Flash
/test-gemini
(custom command runs all 3 agents)
```

## Advantages of Copilot-Native Testing

✅ **Direct Model Control** - Switch models in real-time
✅ **Unified Interface** - No CLI context switching
✅ **Context Preservation** - Keep conversation history per model
✅ **Result Comparison** - Easy side-by-side model comparison
✅ **Custom Commands** - Create reusable test commands per model
✅ **Integrated Logging** - Copilot session logs track all tests

## Steps for Full Model Comparison via Copilot

### Step 1: Prepare Test Queries

Create test descriptions for each agent:

```markdown
### ATC Compliance Check
"Run ATC compliance check on package TESTCDS2ENTITY. 
Report Clean Core violations, recommendations, and severity levels."

### Code Documentation
"Generate technical documentation for all classes in TESTCDS2ENTITY.
Include method signatures, parameters, return values, and business context."

### Unused Code Detection
"Identify unused code in package TESTCDS2ENTITY.
Find dead methods, orphaned variables, and unused classes."
```

### Step 2: Test with First Model

```
/model -> Select Claude 3.5 Sonnet
Run: kiro-cli chat --agent sap-atc-checker --model auto --no-interactive "[test query]"
Document results in: reports/model-comparison/claude/atc/SUMMARY.md
```

### Step 3: Test with Second Model

```
/model -> Select GPT-4 Turbo
Run: kiro-cli chat --agent sap-atc-checker --model auto --no-interactive "[test query]"
Document results in: reports/model-comparison/gpt4/atc/SUMMARY.md
```

### Step 4: Test with Third Model

```
/model -> Select Gemini 2.0 Flash
Run: kiro-cli chat --agent sap-atc-checker --model auto --no-interactive "[test query]"
Document results in: reports/model-comparison/gemini/atc/SUMMARY.md
```

### Step 5: Compare and Score

Review outputs in each model directory and fill in COMPARISON_SUMMARY.md

## Practical Example

### In Claude Model Context:

```bash
export ANTHROPIC_API_KEY="YrrYE1Is3mdaZHycMaLHBu4C6WYZvQkaKBgOGjRlotc"
cd reports/model-comparison

# Run all 3 agents with Claude
kiro-cli chat --agent sap-atc-checker --model auto --no-interactive "Check TESTCDS2ENTITY"
# Save output to: claude/atc/SUMMARY.md

kiro-cli chat --agent sap-custom-code-documenter --model auto --no-interactive "Document TESTCDS2ENTITY"
# Save output to: claude/docs/SUMMARY.md

kiro-cli chat --agent sap-unused-code-discovery --model auto --no-interactive "Find unused code in TESTCDS2ENTITY"
# Save output to: claude/unused/SUMMARY.md
```

### Switch to GPT-4 Context:

```
/model -> Select GPT-4 Turbo

export OPENAI_API_KEY="sk-..."  (if needed)
# Run same 3 tests
# Save outputs to: gpt4/{atc,docs,unused}/SUMMARY.md
```

### Switch to Gemini Context:

```
/model -> Select Gemini 2.0 Flash

export GEMINI_API_KEY="..."  (if needed)
# Run same 3 tests
# Save outputs to: gemini/{atc,docs,unused}/SUMMARY.md
```

## Benefits Over CLI-Only Approach

| Feature | CLI-Only | Copilot `/model` |
|---------|----------|------------------|
| Model Switching | Separate scripts | Native command |
| Context Preservation | None | Full session history |
| Result Comparison | Manual file reading | Copilot memory |
| Quick Pivots | Slow (new script) | Fast (one command) |
| Integration | External | Native to workspace |
| Learning | Test runs only | Full conversation |
| Adjustments | Requires new run | Instant follow-up |

## Recommended Workflow

1. **Model Selection**
   - `/model` → Choose Claude 3.5 Sonnet (or Opus 4.5)
   
2. **Initialize Test Environment**
   - Set API key in terminal
   - Navigate to test directory
   
3. **Run Agents Sequentially**
   - ATC Checker → Save output
   - Code Documenter → Save output
   - Unused Code Discovery → Save output
   
4. **Switch Model**
   - `/model` → Choose next model
   - Repeat step 3
   
5. **Document Results**
   - Fill COMPARISON_SUMMARY.md with findings
   - Score each model per agent
   - Make recommendations

## Tips for Best Results

✅ Use same test package (TESTCDS2ENTITY) for all models
✅ Run all 3 agents per model for fair comparison
✅ Save outputs with consistent naming per model
✅ Note execution time and token usage
✅ Capture error messages if any occur
✅ Use Copilot's memory feature to track findings

## Next Steps

1. Choose your primary model: `/model`
2. Run first agent test with selected model
3. Save output to corresponding directory
4. Repeat for other agents
5. Switch model and test again
6. Compare all results in COMPARISON_SUMMARY.md

---

**Note:** This approach gives you the flexibility of Copilot's model selection while maintaining the structured comparison framework we built.

