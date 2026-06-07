#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GG-Agentic-Harness-Foundry Information & Version utility
Outputs version details, Gemini engine compatibility status, and system overviews.
"""

import sys
import json
import argparse

# Try to reconfigure stdout to UTF-8 to handle unicode safely if supported
if hasattr(sys.stdout, 'reconfigure'):
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

FOUNDRY_INFO = {
    "name": "GG-Agentic-Harness-Foundry",
    "version": "1.5.0",
    "description": "Personal Agentic OS Foundry with FGM overnight loops, harness-100 templates, multi-platform runtime (Gemini, Claude, OpenAI), dynamic scaffolding routing, and interactive plan approval.",
    "platform": "Antigravity IDE (Gemini)",
    "last_updated": "2026-06-07",
    "gemini_compatibility": {
        "Gemini 1.5 Pro / Flash": {
            "status": "Compatible",
            "notes": "Native Tool Calling, 1M/2M Context, Multimodal input support"
        },
        "Gemini 2.0 Pro / Flash": {
            "status": "Compatible",
            "notes": "Advanced Reasoning, Real-time Audio, Live Search integration"
        },
        "Gemini 3.5 Pro / Flash": {
            "status": "Compatible & Optimized",
            "notes": "Agentic Planning Mode, High-speed JSON Structured Output, Multi-agent Autonomy"
        }
    },
    "core_systems": [
        {
            "id": "ICIP",
            "name": "Ishikawa Context Isolation Protocol",
            "version": "1.0.0",
            "description": "Prevents context contamination of sub-agents and drift by anchoring goals using a purpose anchor and summarizing branch maps."
        },
        {
            "id": "CRP",
            "name": "Checkpoint & Resume Protocol",
            "version": "1.0.0",
            "description": "Saves session progress and Decision Logs to checkpoint.json to support seamless auto-resume in case of failures."
        },
        {
            "id": "TCM",
            "name": "Tiered Context Management",
            "version": "1.0.0",
            "description": "Monitors context window usage and triggers Soft (30%) or Hard (50%) Compaction, preserving the purpose anchor and TL;DR."
        },
        {
            "id": "EPR",
            "name": "Error Pattern Registry",
            "version": "1.0.0",
            "description": "Records and searches error patterns across 3 tiers (Global/User/Project) to provide Pre-flight warnings before starting tasks."
        },
        {
            "id": "REE",
            "name": "Rule Enforcement Engine",
            "version": "1.0.0",
            "description": "Enforces MUST/SHOULD rules by parsing markdown rule definitions, injecting them at Pre-flight, and performing Post-flight audits."
        },
        {
            "id": "Intent Engine",
            "name": "Intent Classification Engine",
            "version": "1.0.0",
            "description": "Decodes natural language requests, structures them into an Intent Object, and recommends agent archetypes and harness settings."
        },
        {
            "id": "FGM",
            "name": "Foundry Goal Mode",
            "version": "1.0.0",
            "description": "Enables Claude Code-like unattended autonomous execution loops with self-correction, progress auditing, safety limit guards, and real-time status reporting."
        },
        {
            "id": "Harness Scaffolder",
            "name": "Harness Scaffolder (v1.5.0)",
            "version": "1.2.0",
            "description": "Scaffolds customized harnesses with multi-platform namespace targets (.gemini/.claude/.openai), dynamic path routing, plan approvals, and setup scripts."
        }
    ]
}

BANNER = r"""
================================================================================
  ____  ____          _                               _   _ 
 / ___|/ ___|        / \   __ _  ___ _ __  _ __   ___| \ | |
| |  _| |  _  _____ / _ \ / _` |/ _ \ '_ \| '_ \ / _ \  \| |
| |_| | |_| ||_____/ ___ \ (_| |  __/ | | | | | |  __/|\  |
 \____|\____|     /_/   \_\__, |\___|_| |_|_| |_|\___|_| \_|
                          |___/                             
 _   _                                     _____                      _ 
| | | | __ _ _ __ _ __   ___  ___ ___     |  ___|__  _   _ _ __   __| |_ __ _   _ 
| |_| |/ _` | '__| '_ \ / _ \/ __/ __|    | |_ / _ \| | | | '_ \ / _` | '__| | | |
|  _  | (_| | |  | | | |  __/\__ \__ \    |  _| (_) | |_| | | | | (_| | |  | |_| |
|_| |_|\__,_|_|  |_| |_|\___||___/___/    |_|  \___/ \__,_|_| |_|\__,_|_|   \__, |
                                                                            |___/ 
                     [ FOUNDRY VERSION CONTROL SYSTEM ]
================================================================================
"""

def print_text_ui():
    print(BANNER)
    print("=" * 80)
    print(f" Name        : {FOUNDRY_INFO['name']}")
    print(f" Version     : v{FOUNDRY_INFO['version']}")
    print(f" Updated     : {FOUNDRY_INFO['last_updated']}")
    print(f" Platform    : {FOUNDRY_INFO['platform']}")
    print(f" Description : {FOUNDRY_INFO['description']}")
    print("=" * 80)
    print("\n* Gemini Engine Compatibility Status:")
    for engine, spec in FOUNDRY_INFO["gemini_compatibility"].items():
        status_str = f"[{spec['status']}]"
        print(f" - {engine:<28} : {status_str:<22} | {spec['notes']}")
    
    print("\n* Core Deployed Systems:")
    for system in FOUNDRY_INFO["core_systems"]:
        print(f" - {system['id']:<15} (v{system['version']}) : {system['name']}")
        print(f"   └─ {system['description']}")
    print("=" * 80)

def main():
    parser = argparse.ArgumentParser(description="GG-Agentic-Harness-Foundry CLI Info Utility")
    parser.add_argument("-j", "--json", action="store_true", help="Output details in JSON format")
    parser.add_argument("-v", "--version", action="store_true", help="Output only the version string")
    args = parser.parse_args()

    if args.version:
        print(FOUNDRY_INFO["version"])
    elif args.json:
        # Use ascii=False to maintain native JSON string integrity if redirected
        print(json.dumps(FOUNDRY_INFO, indent=2, ensure_ascii=False))
    else:
        print_text_ui()

if __name__ == "__main__":
    main()
