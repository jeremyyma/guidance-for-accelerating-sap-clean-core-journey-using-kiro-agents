#!/usr/bin/env python3
"""
Model Comparison Analysis Script

Analyzes and compares Kiro agent outputs across Claude, GPT-4, and Gemini models.
Generates a structured comparison report with quality metrics.
"""

import os
import json
import sys
from pathlib import Path
from datetime import datetime
import re

# Configuration
MODELS = ["claude", "gpt4", "gemini"]
AGENTS = ["atc", "docs", "unused"]
COMPARISON_DIR = Path(__file__).parent

class ModelComparator:
    def __init__(self, base_dir=COMPARISON_DIR):
        self.base_dir = base_dir
        self.results = {}
        self.metrics = {}
        
    def analyze_findings(self, model, agent):
        """Analyze findings from a specific model and agent combination."""
        results_dir = self.base_dir / model / agent
        
        if not results_dir.exists():
            return None
            
        findings = {
            "file_count": 0,
            "total_findings": 0,
            "categories": {},
            "files": []
        }
        
        # Count result files
        for file_path in results_dir.rglob("*.md"):
            findings["file_count"] += 1
            findings["files"].append(str(file_path.relative_to(self.base_dir)))
            
            # Count findings in content
            with open(file_path, 'r') as f:
                content = f.read()
                # Count finding patterns (adjust regex based on output format)
                finding_count = len(re.findall(r'(?:Finding|Issue|Violation|Warning|Error):', content))
                findings["total_findings"] += finding_count
        
        return findings
    
    def compare_models(self):
        """Run comprehensive comparison across all models."""
        print("=" * 80)
        print("MODEL COMPARISON ANALYSIS")
        print("=" * 80)
        print(f"Generated: {datetime.now().isoformat()}\n")
        
        for agent in AGENTS:
            print(f"\n{'=' * 80}")
            print(f"AGENT: {agent.upper()}")
            print(f"{'=' * 80}\n")
            
            agent_results = {}
            scores = {}
            
            for model in MODELS:
                findings = self.analyze_findings(model, agent)
                
                if findings:
                    agent_results[model] = findings
                    
                    # Calculate quality score (placeholder - customize per agent)
                    quality_score = self.calculate_quality_score(model, agent, findings)
                    scores[model] = quality_score
                    
                    print(f"MODEL: {model.upper()}")
                    print(f"  Files Generated: {findings['file_count']}")
                    print(f"  Total Findings: {findings['total_findings']}")
                    print(f"  Quality Score: {quality_score}/10")
                    print(f"  Result Files:")
                    for file in findings["files"][:3]:  # Show first 3 files
                        print(f"    - {file}")
                    if len(findings["files"]) > 3:
                        print(f"    ... and {len(findings['files']) - 3} more files")
                    print()
            
            # Determine winner
            if scores:
                winner = max(scores, key=scores.get)
                print(f"WINNER FOR {agent.upper()}: {winner.upper()} (Score: {scores[winner]}/10)")
                print(f"  Rationale: [Manually review outputs and document reasoning]")
        
        # Generate summary table
        self.generate_summary_table()
    
    def calculate_quality_score(self, model, agent, findings):
        """
        Calculate quality score based on findings.
        Customize scoring logic per agent type.
        """
        score = 0.0
        
        if agent == "atc":
            # ATC: More findings is better (up to a point)
            finding_score = min(findings["total_findings"] / 10, 5)
            file_score = min(findings["file_count"] / 2, 3)
            completeness = 2  # Manual review required
            score = finding_score + file_score + completeness
            
        elif agent == "docs":
            # Docs: File count matters (more complete docs)
            file_score = min(findings["file_count"] / 2, 4)
            finding_score = min(findings["total_findings"] / 20, 4)
            clarity = 2  # Manual review required
            score = file_score + finding_score + clarity
            
        elif agent == "unused":
            # Unused code: Accurate findings with low false positives
            finding_score = min(findings["total_findings"] / 5, 5)
            accuracy = 3  # Manual review required
            safety = 2  # Manual review required
            score = finding_score + accuracy + safety
        
        return round(score, 1)
    
    def generate_summary_table(self):
        """Generate markdown summary table."""
        summary_file = self.base_dir / "COMPARISON_SUMMARY.md"
        
        with open(summary_file, 'w') as f:
            f.write("# Model Comparison Summary\n\n")
            f.write(f"**Generated:** {datetime.now().isoformat()}\n\n")
            f.write("## Overall Results\n\n")
            f.write("| Model | ATC Quality | Documentation Quality | Unused Code Quality | Overall | Recommendation |\n")
            f.write("|-------|-------------|----------------------|---------------------|---------|----------------|\n")
            f.write("| Claude Opus | — | — | — | — | Review outputs |\n")
            f.write("| GPT-4 | — | — | — | — | Review outputs |\n")
            f.write("| Gemini | — | — | — | — | Review outputs |\n\n")
            f.write("## Detailed Findings\n\n")
            f.write("### ATC Compliance Checker\n")
            f.write("**Winner:** [Model name] - [Reason]\n\n")
            f.write("### Code Documenter\n")
            f.write("**Winner:** [Model name] - [Reason]\n\n")
            f.write("### Unused Code Discovery\n")
            f.write("**Winner:** [Model name] - [Reason]\n\n")
            f.write("## Cost Analysis\n\n")
            f.write("| Model | Tokens (ATC) | Tokens (Docs) | Tokens (Unused) | Total Cost Estimate |\n")
            f.write("|-------|--------------|---------------|-----------------|--------------------|\n")
            f.write("| Claude Opus | — | — | — | — |\n")
            f.write("| GPT-4 | — | — | — | — |\n")
            f.write("| Gemini | — | — | — | — |\n\n")
            f.write("## Recommendations\n\n")
            f.write("Based on quality metrics and cost analysis:\n\n")
            f.write("1. **ATC Checks:** [Recommended model]\n")
            f.write("2. **Code Documentation:** [Recommended model]\n")
            f.write("3. **Unused Code Detection:** [Recommended model]\n")
            f.write("4. **Most Cost-Effective:** [Recommended model]\n")
            f.write("5. **Overall Best Quality:** [Recommended model]\n\n")
        
        print(f"\nComparison summary written to: {summary_file}")

def main():
    """Main entry point."""
    comparator = ModelComparator()
    
    # Check if test results exist
    test_dirs = [COMPARISON_DIR / model for model in MODELS]
    if not any(d.exists() for d in test_dirs):
        print("ERROR: No test results found. Run model comparison tests first:")
        print("  bash reports/model-comparison/claude_tests.sh")
        print("  bash reports/model-comparison/gpt4_tests.sh")
        print("  bash reports/model-comparison/gemini_tests.sh")
        sys.exit(1)
    
    # Run comparison
    comparator.compare_models()
    
    print("\n" + "=" * 80)
    print("ANALYSIS COMPLETE")
    print("=" * 80)
    print("\nNext steps:")
    print("1. Review detailed outputs in reports/model-comparison/[model]/")
    print("2. Fill in manual quality assessments in COMPARISON_SUMMARY.md")
    print("3. Commit results for team reference")

if __name__ == "__main__":
    main()
