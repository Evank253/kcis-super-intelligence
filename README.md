# KCIS — Ketchum's Compute Intelligence Systems + Super Intelligence

KCIS stands for **Ketchum's Compute Intelligence Systems**.

This repository combines KCIS with **Ketchum's Physics Optimized Super Intelligence System**, a physics-inspired AI orchestration layer designed to improve how LLM systems route, compress, reason, remember, and account for compute.

## What KCIS is

KCIS is **not a replacement for GPT, Claude, Gemini, or Llama**.

KCIS is an intelligence orchestration/control layer that can run on top of foundation models.

Correct comparison:

```text
Claude alone vs Claude + KCIS
GPT alone vs GPT + KCIS
Llama alone vs Llama + KCIS
LangChain/AutoGen vs KCIS orchestration
```

## Included modules

- Entropy routing
- Quantum-inspired complex weighting
- Tensor/SVD compression
- Reservoir memory
- Spintronic-style persistent memory
- Reversible graph optimization proxy
- Thermodynamic energy accounting
- Adversarial solve/critic/repair reasoning
- Benchmark runner
- CLI
- Tests

## Install

```bash
python3 -m venv .venv
source .venv/bin/activate
make install
```

## Test

```bash
make test
```

## Run

```bash
kcis --task "Explain KCIS in simple terms." --explain
```

or:

```bash
python main.py --task "Explain entropy routing." --json
```

## Benchmark

```bash
make bench
```

Results will be written to:

```text
results/kcis_benchmark.json
results/kcis_benchmark.md
```

## Optional LLM providers

By default KCIS uses a local deterministic rule-based adapter so tests work without API keys.

Later, use:

```bash
export KCIS_LLM_PROVIDER=openai
export OPENAI_API_KEY=...
```

or:

```bash
export KCIS_LLM_PROVIDER=anthropic
export ANTHROPIC_API_KEY=...
```

Then run:

```bash
kcis --provider openai --task "Solve this..."
```

## Architecture

```text
Input
 ↓
KCIS Kernel
 ↓
Entropy Router
 ↓
Quantum-Inspired Field Weighting
 ↓
Tensor Compression
 ↓
Reservoir Memory
 ↓
Spintronic Persistent Memory
 ↓
Reversible Graph Optimization
 ↓
Adversarial Reasoning
 ↓
Response Synthesizer
 ↓
Thermodynamic Accounting
 ↓
Metrics + Answer
```

## Goal

Prove whether KCIS improves:

- token efficiency
- latency
- cost
- memory coherence
- reasoning quality
- estimated energy per task
