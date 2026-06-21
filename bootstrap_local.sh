#!/usr/bin/env bash
set -euo pipefail

echo "Bootstrapping KCIS codebase locally..."

mkdir -p .github/workflows
mkdir -p kcis/core
mkdir -p kcis/physics
mkdir -p kcis/memory
mkdir -p kcis/intelligence
mkdir -p kcis/adapters
mkdir -p kcis/benchmarks
mkdir -p tests
mkdir -p bench
mkdir -p results

cat > .gitignore <<'GITIGNORE'
.venv/
__pycache__/
*.pyc
.pytest_cache/
.env
results/*.json
results/*.md
.kcis_memory/
dist/
build/
*.egg-info/
GITIGNORE

cat > requirements.txt <<'REQ'
numpy>=1.24
python-dotenv>=1.0
pydantic>=2.0
pytest>=8.0
pytest-asyncio>=0.23
REQ

cat > pyproject.toml <<'PYPROJECT'
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "kcis"
version = "0.1.0"
description = "Ketchum's Compute Intelligence Systems: physics-inspired AI orchestration and optimization kernel"
readme = "README.md"
requires-python = ">=3.10"
dependencies = [
  "numpy>=1.24",
  "python-dotenv>=1.0",
  "pydantic>=2.0"
]

[project.optional-dependencies]
dev = [
  "pytest>=8.0",
  "pytest-asyncio>=0.23"
]
openai = ["openai>=1.0.0"]
anthropic = ["anthropic>=0.25.0"]

[project.scripts]
kcis = "kcis.cli:main"
kcis-bench = "kcis.benchmarks.runner:main"

[tool.setuptools.packages.find]
include = ["kcis*"]
PYPROJECT

cat > Makefile <<'MAKE'
.PHONY: install test run bench clean

install:
	python -m pip install --upgrade pip setuptools wheel
	python -m pip install -e ".[dev]"

test:
	python -m compileall -q .
	python -m pytest -q

run:
	python main.py --task "Explain how entropy routing improves AI compute efficiency." --explain

bench:
	python -m kcis.benchmarks.runner --tasks bench/tasks.jsonl --out results/kcis_benchmark.json

clean:
	rm -rf **pycache** .pytest_cache .kcis_memory build dist *.egg-info*
	find . -name "__pycache__" -type d -prune -exec rm -rf {} +
MAKE

cat > README.md <<'README'
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
README

cat > main.py <<'MAIN'
from kcis.cli import main

if __name__ == "__main__":
    main()
MAIN

cat > kcis/__init__.py <<'INIT'
"""
KCIS: Ketchum's Compute Intelligence Systems.
Physics-inspired AI orchestration and optimization kernel.
"""

__version__ = "0.1.0"
INIT

cat > kcis/core/__init__.py <<'INIT'
from .state import KCISState, KCISMetrics
from .kernel import KCISKernel

__all__ = ["KCISState", "KCISMetrics", "KCISKernel"]
INIT

cat > kcis/core/state.py <<'STATE'
from __future__ import annotations

from dataclasses import dataclass, field, asdict
from typing import Any, Dict, List, Optional
import time


@dataclass
class KCISMetrics:
    latency_s: float = 0.0
    input_tokens: int = 0
    output_tokens: int = 0
    total_tokens: int = 0

    estimated_cost_usd: float = 0.0
    estimated_joules: float = 0.0

    entropy: float = 0.0
    route_confidence: float = 0.0

    compression_ratio: float = 0.0
    compression_error: float = 0.0

    memory_resonance: float = 0.0
    reversible_reclaim_tokens: int = 0

    quality_score: Optional[float] = None

    stage_timings: Dict[str, float] = field(default_factory=dict)
    module_joules: Dict[str, float] = field(default_factory=dict)


@dataclass
class KCISState:
    task: str
    context: str = ""
    answer: str = ""
    route: str = "standard"

    memory_state: Dict[str, Any] = field(default_factory=dict)
    physics_state: Dict[str, Any] = field(default_factory=dict)
    intelligence_state: Dict[str, Any] = field(default_factory=dict)

    agent_trace: List[Dict[str, Any]] = field(default_factory=list)
    raw_outputs: List[Dict[str, Any]] = field(default_factory=list)

    metrics: KCISMetrics = field(default_factory=KCISMetrics)
    metadata: Dict[str, Any] = field(default_factory=dict)

    created_at: float = field(default_factory=time.perf_counter)

    @property
    def input_text(self) -> str:
        if self.context:
            return f"{self.task}\n\nContext:\n{self.context}"
        return self.task

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)
STATE

cat > kcis/core/config.py <<'CONFIG'
from __future__ import annotations

from dataclasses import dataclass
import os


@dataclass
class KCISConfig:
    low_entropy_threshold: float = 0.35
    high_entropy_threshold: float = 0.68

    watts_estimate: float = 75.0

    input_cost_per_million: float = 0.50
    output_cost_per_million: float = 1.50

    llm_provider: str = "rule"
    model: str = "local-rule"

    max_debate_rounds: int = 2
    tensor_rank_ratio: float = 0.30

    memory_path: str = ".kcis_memory/state.json"

    @classmethod
    def from_env(cls) -> "KCISConfig":
        return cls(
            low_entropy_threshold=float(os.getenv("KCIS_LOW_ENTROPY", "0.35")),
            high_entropy_threshold=float(os.getenv("KCIS_HIGH_ENTROPY", "0.68")),
            watts_estimate=float(os.getenv("KCIS_WATTS", "75")),
            input_cost_per_million=float(os.getenv("KCIS_INPUT_COST_PER_M", "0.50")),
            output_cost_per_million=float(os.getenv("KCIS_OUTPUT_COST_PER_M", "1.50")),
            llm_provider=os.getenv("KCIS_LLM_PROVIDER", "rule"),
            model=os.getenv("KCIS_MODEL", "local-rule"),
            max_debate_rounds=int(os.getenv("KCIS_MAX_DEBATE_ROUNDS", "2")),
            tensor_rank_ratio=float(os.getenv("KCIS_TENSOR_RANK_RATIO", "0.30")),
            memory_path=os.getenv("KCIS_MEMORY_PATH", ".kcis_memory/state.json"),
        )
CONFIG

cat > kcis/core/tokens.py <<'TOKENS'
from __future__ import annotations


def count_tokens(text: str) -> int:
    """
    Lightweight token estimator.
    Roughly compatible with common BPE averages: ~4 chars/token.
    """
    if not text:
        return 0
    return max(1, len(text) // 4)


def estimate_cost_usd(
    input_tokens: int,
    output_tokens: int,
    input_cost_per_million: float = 0.50,
    output_cost_per_million: float = 1.50,
) -> float:
    return (
        (input_tokens / 1_000_000.0) * input_cost_per_million
        + (output_tokens / 1_000_000.0) * output_cost_per_million
    )
TOKENS

cat > kcis/core/kernel.py <<'KERNEL'
from __future__ import annotations

from typing import Protocol, List, Optional
import time

from .state import KCISState
from .config import KCISConfig
from .tokens import count_tokens, estimate_cost_usd


class KCISModule(Protocol):
    name: str

    def process(self, state: KCISState) -> KCISState:
        ...


class KCISKernel:
    """
    Central KCIS execution kernel.

    Every physics/intelligence/memory module accepts KCISState and returns KCISState.
    This makes all systems composable.
    """

    def __init__(
        self,
        modules: Optional[List[KCISModule]] = None,
        config: Optional[KCISConfig] = None,
    ):
        self.modules: List[KCISModule] = modules or []
        self.config = config or KCISConfig.from_env()

    def register(self, module: KCISModule) -> None:
        self.modules.append(module)

    def run(self, task: str, context: str = "", **metadata) -> KCISState:
        state = KCISState(task=task, context=context, metadata=metadata)
        state.metrics.input_tokens = count_tokens(state.input_text)

        for module in self.modules:
            name = getattr(module, "name", module.__class__.__name__)
            start = time.perf_counter()

            state = module.process(state)

            elapsed = time.perf_counter() - start
            joules = self.config.watts_estimate * elapsed

            state.metrics.stage_timings[name] = elapsed
            state.metrics.module_joules[name] = joules
            state.metrics.estimated_joules += joules

            state.agent_trace.append(
                {
                    "module": name,
                    "route": state.route,
                    "entropy": state.metrics.entropy,
                    "latency_s": elapsed,
                    "estimated_joules": joules,
                }
            )

        state.metrics.latency_s = time.perf_counter() - state.created_at
        state.metrics.output_tokens = count_tokens(state.answer)
        state.metrics.total_tokens = state.metrics.input_tokens + state.metrics.output_tokens
        state.metrics.estimated_cost_usd = estimate_cost_usd(
            state.metrics.input_tokens,
            state.metrics.output_tokens,
            self.config.input_cost_per_million,
            self.config.output_cost_per_million,
        )

        return state
KERNEL

cat > kcis/adapters/__init__.py <<'INIT'
from .llm_adapter import (
    LLMAdapter,
    RuleBasedAdapter,
    OpenAIAdapter,
    AnthropicAdapter,
    adapter_from_provider,
)

__all__ = [
    "LLMAdapter",
    "RuleBasedAdapter",
    "OpenAIAdapter",
    "AnthropicAdapter",
    "adapter_from_provider",
]
INIT

cat > kcis/adapters/llm_adapter.py <<'LLM'
from __future__ import annotations

from typing import Protocol, Optional
import os
import re


class LLMAdapter(Protocol):
    def generate(self, prompt: str, system: Optional[str] = None, max_tokens: int = 512) -> str:
        ...


class RuleBasedAdapter:
    """
    Local deterministic adapter.

    Purpose:
    - lets tests pass without API keys
    - gives predictable benchmark behavior
    - can be replaced by OpenAI, Anthropic, or local Llama
    """

    def generate(self, prompt: str, system: Optional[str] = None, max_tokens: int = 512) -> str:
        low = prompt.lower()

        if "12 apples" in low and "gives away 5" in low and "buys 9" in low:
            return "John has 16 apples."

        if "bat and a ball" in low and "$1.10" in low:
            return "The ball costs $0.05 and the bat costs $1.05."

        if "items=[]" in low or "mutable default" in low:
            return (
                "The bug is the mutable default argument items=[]. "
                "Use None as the default and create a new list inside the function."
            )

        if "summarize" in low:
            text = prompt.split(":", 1)[-1].strip()
            text = re.sub(r"\s+", " ", text)
            return f"Summary: {text[:220]}"

        if "find the worst flaw" in low:
            return "The main risk is insufficient verification, missing edge cases, or overclaiming without benchmark evidence."

        if "fix the flaw" in low or "improved answer" in low:
            return "Improved answer: verify the result, state assumptions clearly, and avoid claims not supported by benchmark data."

        if "entropy routing" in low:
            return (
                "Entropy routing improves AI orchestration by sending simple low-uncertainty tasks through a fast path "
                "and complex high-uncertainty tasks through deeper reasoning, reducing unnecessary token and compute use."
            )

        if "kcis" in low:
            return (
                "KCIS is Ketchum's Compute Intelligence Systems: a physics-inspired orchestration layer that routes, "
                "compresses, remembers, verifies, and accounts for compute around LLMs."
            )

        return (
            "KCIS response: analyze the task, route by uncertainty, use memory and compression when useful, "
            "verify the answer, and report compute metrics."
        )


class OpenAIAdapter:
    def __init__(self, model: Optional[str] = None):
        self.model = model or os.getenv("KCIS_MODEL", "gpt-4o-mini")

    def generate(self, prompt: str, system: Optional[str] = None, max_tokens: int = 512) -> str:
        try:
            from openai import OpenAI
        except ImportError as exc:
            raise RuntimeError("Install OpenAI support with: pip install -e '.[openai]'") from exc

        client = OpenAI()
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": prompt})

        response = client.chat.completions.create(
            model=self.model,
            messages=messages,
            max_tokens=max_tokens,
        )
        return response.choices[0].message.content or ""


class AnthropicAdapter:
    def __init__(self, model: Optional[str] = None):
        self.model = model or os.getenv("KCIS_MODEL", "claude-3-5-haiku-latest")

    def generate(self, prompt: str, system: Optional[str] = None, max_tokens: int = 512) -> str:
        try:
            import anthropic
        except ImportError as exc:
            raise RuntimeError("Install Anthropic support with: pip install -e '.[anthropic]'") from exc

        client = anthropic.Anthropic()
        response = client.messages.create(
            model=self.model,
            system=system or "",
            max_tokens=max_tokens,
            messages=[{"role": "user", "content": prompt}],
        )
        return response.content[0].text


def adapter_from_provider(provider: Optional[str] = None, model: Optional[str] = None) -> LLMAdapter:
    provider = (provider or os.getenv("KCIS_LLM_PROVIDER", "rule")).lower()

    if provider in {"rule", "local", "dummy", "offline"}:
        return RuleBasedAdapter()

    if provider == "openai":
        return OpenAIAdapter(model=model)

    if provider in {"anthropic", "claude"}:
        return AnthropicAdapter(model=model)

    raise ValueError(f"Unknown KCIS LLM provider: {provider}")
LLM

cat > kcis/physics/__init__.py <<'INIT'
from .entropy import EntropyRouter
from .quantum_field import QuantumFieldWeighting
from .tensor_compression import TensorCompressor
from .reservoir import ReservoirMemory
from .reversible_graph import ReversibleGraphOptimizer
from .thermodynamics import ThermodynamicAccounting

__all__ = [
    "EntropyRouter",
    "QuantumFieldWeighting",
    "TensorCompressor",
    "ReservoirMemory",
    "ReversibleGraphOptimizer",
    "ThermodynamicAccounting",
]
INIT

cat > kcis/physics/entropy.py <<'ENTROPY'
from __future__ import annotations

import math
import re
from collections import Counter

from kcis.core.state import KCISState


class EntropyRouter:
    name = "entropy_router"

    def __init__(self, low_threshold: float = 0.35, high_threshold: float = 0.68):
        self.low_threshold = low_threshold
        self.high_threshold = high_threshold

    def estimate_entropy(self, text: str) -> float:
        """
        Normalized Shannon entropy over words/chars.

        Returns roughly 0..1.
        Higher means more uncertainty/diversity/complexity.
        """
        if not text:
            return 0.0

        tokens = re.findall(r"[A-Za-z0-9_.$+-]+", text.lower())
        if len(tokens) < 3:
            tokens = list(text.lower())

        counts = Counter(tokens)
        total = sum(counts.values())
        if total <= 1:
            return 0.0

        h = 0.0
        for c in counts.values():
            p = c / total
            h -= p * math.log2(p + 1e-12)

        max_h = math.log2(max(len(counts), 2))
        h_norm = h / max_h if max_h > 0 else 0.0

        length_pressure = min(len(text) / 4000.0, 1.0)
        complexity = 0.70 * h_norm + 0.30 * length_pressure
        return max(0.0, min(1.0, complexity))

    def process(self, state: KCISState) -> KCISState:
        entropy = self.estimate_entropy(state.input_text)
        state.metrics.entropy = entropy

        if entropy < self.low_threshold:
            route = "fast"
            confidence = 1.0 - entropy
        elif entropy > self.high_threshold:
            route = "deep"
            confidence = entropy
        else:
            route = "standard"
            confidence = 1.0 - abs(entropy - 0.5)

        state.route = route
        state.metrics.route_confidence = confidence
        state.physics_state["entropy"] = entropy
        state.physics_state["entropy_route"] = route
        state.physics_state["entropy_thresholds"] = {
            "low": self.low_threshold,
            "high": self.high_threshold,
        }

        return state
ENTROPY

cat > kcis/physics/quantum_field.py <<'QUANTUM'
from __future__ import annotations

import cmath
import math
import re
from collections import Counter

from kcis.core.state import KCISState


class QuantumFieldWeighting:
    """
    Physics-inspired, not physics-native.

    Creates complex-valued amplitudes over task terms.
    Used as an importance signal for routing/synthesis.
    """

    name = "quantum_field_weighting"

    def __init__(self, phase_step: float = 0.173):
        self.phase_step = phase_step

    def process(self, state: KCISState) -> KCISState:
        words = re.findall(r"[A-Za-z0-9_.$+-]+", state.input_text.lower())
        counts = Counter(words)

        amplitudes = {}
        norm = 0.0

        for i, (word, count) in enumerate(counts.items()):
            magnitude = math.sqrt(count)
            phase = i * self.phase_step
            amp = magnitude * cmath.exp(1j * phase)
            amplitudes[word] = amp
            norm += abs(amp) ** 2

        norm = math.sqrt(norm) if norm > 0 else 1.0

        weighted = []
        for word, amp in amplitudes.items():
            probability = (abs(amp) / norm) ** 2
            weighted.append((word, probability, amp.real, amp.imag))

        weighted.sort(key=lambda x: x[1], reverse=True)
        top_terms = weighted[:10]

        state.physics_state["quantum_field"] = {
            "type": "complex_amplitude_importance",
            "top_terms": [
                {
                    "term": t[0],
                    "probability": t[1],
                    "real": t[2],
                    "imag": t[3],
                }
                for t in top_terms
            ],
            "normalization": norm,
            "note": "Physics-inspired complex weighting, not literal quantum hardware.",
        }

        return state
QUANTUM

cat > kcis/physics/tensor_compression.py <<'TENSOR'
from __future__ import annotations

import hashlib
import numpy as np

from kcis.core.state import KCISState


class TensorCompressor:
    """
    Low-rank SVD compressor for text-derived state matrices.

    This is a practical stand-in for deeper tensor network compression.
    Later extensions can add TT/MPS contraction.
    """

    name = "tensor_compression"

    def __init__(self, dim: int = 64, rank_ratio: float = 0.30):
        self.dim = dim
        self.rank_ratio = rank_ratio

    def _text_to_matrix(self, text: str) -> np.ndarray:
        tokens = text.split()
        if not tokens:
            tokens = [text or "empty"]

        width = max(4, min(256, len(tokens)))
        mat = np.zeros((self.dim, width), dtype=float)

        for j, tok in enumerate(tokens[:width]):
            digest = hashlib.sha256(tok.encode("utf-8")).digest()
            for k, b in enumerate(digest[: min(self.dim, len(digest))]):
                mat[k, j] += (b / 255.0) - 0.5

        return mat

    def process(self, state: KCISState) -> KCISState:
        matrix = self._text_to_matrix(state.input_text)

        u, s, vh = np.linalg.svd(matrix, full_matrices=False)

        if state.route == "deep":
            ratio = min(0.60, self.rank_ratio * 1.5)
        elif state.route == "fast":
            ratio = max(0.10, self.rank_ratio * 0.6)
        else:
            ratio = self.rank_ratio

        rank = max(1, int(len(s) * ratio))

        u_r = u[:, :rank]
        s_r = s[:rank]
        vh_r = vh[:rank, :]

        reconstructed = (u_r * s_r) @ vh_r

        original_size = matrix.size
        compressed_size = u_r.size + s_r.size + vh_r.size
        compression_ratio = compressed_size / max(original_size, 1)

        error = float(np.mean((matrix - reconstructed) ** 2))

        state.metrics.compression_ratio = float(compression_ratio)
        state.metrics.compression_error = error

        state.physics_state["tensor_compression"] = {
            "method": "svd_low_rank",
            "original_shape": list(matrix.shape),
            "rank": rank,
            "original_size": int(original_size),
            "compressed_size": int(compressed_size),
            "compressed_to_original_ratio": float(compression_ratio),
            "reconstruction_mse": error,
        }

        return state
TENSOR

cat > kcis/physics/reservoir.py <<'RESERVOIR'
from __future__ import annotations

import hashlib
import numpy as np

from kcis.core.state import KCISState


class ReservoirMemory:
    """
    Echo-state/reservoir memory.

    Keeps nonlinear state across a single run.
    SpintronicMemory handles persistence across runs.
    """

    name = "reservoir_memory"

    def __init__(
        self,
        n: int = 64,
        spectral_radius: float = 0.95,
        leak: float = 0.25,
        seed: int = 253,
    ):
        self.n = n
        self.leak = leak
        rng = np.random.default_rng(seed)

        w = rng.normal(0, 1, size=(n, n))
        mask = rng.random((n, n)) < 0.12
        w = w * mask

        eigs = np.linalg.eigvals(w)
        radius = max(float(np.max(np.abs(eigs))), 1e-6)
        self.w = w * (spectral_radius / radius)

        self.win = rng.normal(0, 0.2, size=(n,))
        self.x = np.zeros(n)

    def _encode_scalar(self, text: str) -> float:
        if not text:
            return 0.0
        digest = hashlib.sha256(text.encode("utf-8")).digest()
        return (sum(digest) / (255.0 * len(digest))) * 2.0 - 1.0

    def step(self, u: float) -> None:
        candidate = np.tanh(self.w @ self.x + self.win * u)
        self.x = (1.0 - self.leak) * self.x + self.leak * candidate

    def process(self, state: KCISState) -> KCISState:
        chunks = state.input_text.split()
        if not chunks:
            chunks = [state.input_text]

        for chunk in chunks[:128]:
            self.step(self._encode_scalar(chunk))

        resonance = float(np.mean(self.x))
        norm = float(np.linalg.norm(self.x))

        state.metrics.memory_resonance = resonance
        state.memory_state["reservoir"] = {
            "size": self.n,
            "resonance": resonance,
            "state_norm": norm,
            "note": "Echo-state nonlinear short-term memory.",
        }

        return state
RESERVOIR

cat > kcis/physics/reversible_graph.py <<'REVERSIBLE'
from __future__ import annotations

from kcis.core.state import KCISState
from kcis.core.tokens import count_tokens


class ReversibleGraphOptimizer:
    """
    Reversible-compute inspired optimization proxy.

    Tracks how many intermediate tokens/state units could be reclaimed
    by using reversible execution and avoiding duplicate context.
    """

    name = "reversible_graph_optimizer"

    def process(self, state: KCISState) -> KCISState:
        tokens = count_tokens(state.input_text)

        if state.route == "fast":
            reclaim = int(tokens * 0.08)
            graph = ["input", "fast_reason", "synthesize"]
        elif state.route == "deep":
            reclaim = int(tokens * 0.28)
            graph = [
                "input",
                "compress_state",
                "solve",
                "critic",
                "repair",
                "reverse_release_intermediates",
                "synthesize",
            ]
        else:
            reclaim = int(tokens * 0.16)
            graph = ["input", "compress_state", "reason", "reverse_release_intermediates", "synthesize"]

        state.metrics.reversible_reclaim_tokens = reclaim
        state.physics_state["reversible_graph"] = {
            "graph": graph,
            "estimated_reclaim_tokens": reclaim,
            "note": "Reversible-compute inspired memory accounting.",
        }

        return state
REVERSIBLE

cat > kcis/physics/thermodynamics.py <<'THERMO'
from __future__ import annotations

import time

from kcis.core.state import KCISState
from kcis.core.tokens import count_tokens, estimate_cost_usd


class ThermodynamicAccounting:
    name = "thermodynamic_accounting"

    def __init__(
        self,
        watts_estimate: float = 75.0,
        input_cost_per_million: float = 0.50,
        output_cost_per_million: float = 1.50,
    ):
        self.watts_estimate = watts_estimate
        self.input_cost_per_million = input_cost_per_million
        self.output_cost_per_million = output_cost_per_million

    def process(self, state: KCISState) -> KCISState:
        elapsed = time.perf_counter() - state.created_at

        state.metrics.latency_s = elapsed
        state.metrics.output_tokens = count_tokens(state.answer)
        state.metrics.total_tokens = state.metrics.input_tokens + state.metrics.output_tokens

        # Prefer kernel accumulated joules. Fall back to watts*time.
        if state.metrics.estimated_joules <= 0:
            state.metrics.estimated_joules = self.watts_estimate * elapsed

        state.metrics.estimated_cost_usd = estimate_cost_usd(
            state.metrics.input_tokens,
            state.metrics.output_tokens,
            self.input_cost_per_million,
            self.output_cost_per_million,
        )

        state.physics_state["thermodynamics"] = {
            "watts_estimate": self.watts_estimate,
            "latency_s": elapsed,
            "estimated_joules": state.metrics.estimated_joules,
            "joules_per_token": state.metrics.estimated_joules / max(state.metrics.total_tokens, 1),
            "entropy_energy_product": state.metrics.entropy * state.metrics.estimated_joules,
        }

        return state
THERMO

cat > kcis/memory/__init__.py <<'INIT'
from .spintronic_memory import SpintronicMemory

__all__ = ["SpintronicMemory"]
INIT

cat > kcis/memory/spintronic_memory.py <<'SPIN'
from __future__ import annotations

import json
import math
import os
from pathlib import Path

from kcis.core.state import KCISState


class SpintronicMemory:
    """
    Spintronic-style persistent memory.

    Not literal spintronic hardware. It models:
    - persistence
    - decay
    - hysteresis
    - resonance recall
    """

    name = "spintronic_memory"

    def __init__(
        self,
        path: str = ".kcis_memory/state.json",
        alpha: float = 0.86,
        beta: float = 0.14,
        hysteresis: float = 0.05,
    ):
        self.path = Path(path)
        self.alpha = alpha
        self.beta = beta
        self.hysteresis = hysteresis
        self.memory_value = 0.0
        self.runs = 0
        self._load()

    def _load(self) -> None:
        try:
            if self.path.exists():
                data = json.loads(self.path.read_text())
                self.memory_value = float(data.get("memory_value", 0.0))
                self.runs = int(data.get("runs", 0))
        except Exception:
            self.memory_value = 0.0
            self.runs = 0

    def _save(self) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        data = {
            "memory_value": self.memory_value,
            "runs": self.runs,
            "alpha": self.alpha,
            "beta": self.beta,
            "hysteresis": self.hysteresis,
        }
        self.path.write_text(json.dumps(data, indent=2))

    def encode(self, text: str) -> float:
        if not text:
            return 0.0
        raw = sum(ord(c) for c in text) / max(len(text), 1)
        return math.tanh((raw - 90.0) / 35.0)

    def process(self, state: KCISState) -> KCISState:
        u = self.encode(state.input_text)

        previous = self.memory_value
        hysteresis_term = self.hysteresis * math.tanh(u - previous)

        self.memory_value = self.alpha * previous + self.beta * u + hysteresis_term
        self.runs += 1
        self._save()

        state.memory_state["spintronic"] = {
            "memory_value": self.memory_value,
            "previous": previous,
            "input_value": u,
            "runs": self.runs,
            "alpha": self.alpha,
            "beta": self.beta,
            "hysteresis": self.hysteresis,
            "note": "Persistent decay/hysteresis memory model.",
        }

        return state
SPIN

cat > kcis/intelligence/__init__.py <<'INIT'
from .build import build_kcis
from .adversarial_reasoning import AdversarialReasoning
from .synthesizer import ResponseSynthesizer
from .adaptive_mutation import AdaptiveMutation

__all__ = [
    "build_kcis",
    "AdversarialReasoning",
    "ResponseSynthesizer",
    "AdaptiveMutation",
]
INIT

cat > kcis/intelligence/adversarial_reasoning.py <<'ADVERSARY'
from __future__ import annotations

from kcis.core.state import KCISState
from kcis.adapters.llm_adapter import LLMAdapter


class AdversarialReasoning:
    """
    Solver -> critic -> repair loop.

    Deep route gets more adversarial pressure.
    Fast route gets a cheap direct answer.
    """

    name = "adversarial_reasoning"

    def __init__(self, llm: LLMAdapter, max_rounds: int = 2):
        self.llm = llm
        self.max_rounds = max_rounds

    def process(self, state: KCISState) -> KCISState:
        if state.route == "fast":
            prompt = f"Answer concisely:\n\n{state.input_text}"
            answer = self.llm.generate(prompt, max_tokens=256)
            rounds = 0

        elif state.route == "deep":
            prompt = (
                "Solve the task carefully. Use concise reasoning and return the best answer.\n\n"
                f"Task:\n{state.input_text}"
            )
            answer = self.llm.generate(prompt, max_tokens=512)
            rounds = self.max_rounds

            for i in range(rounds):
                critique = self.llm.generate(
                    "Find the worst flaw, missing edge case, or unsupported claim in this answer.\n\n"
                    f"Task:\n{state.input_text}\n\nAnswer:\n{answer}\n\nFlaw:",
                    max_tokens=256,
                )
                repaired = self.llm.generate(
                    "Fix the flaw and return an improved final answer only.\n\n"
                    f"Task:\n{state.input_text}\n\nFlaw:\n{critique}\n\nCurrent answer:\n{answer}",
                    max_tokens=512,
                )

                state.raw_outputs.append(
                    {
                        "round": i + 1,
                        "critique": critique,
                        "repair": repaired,
                    }
                )
                answer = repaired

        else:
            prompt = f"Solve the task clearly and accurately:\n\n{state.input_text}"
            answer = self.llm.generate(prompt, max_tokens=384)
            rounds = 0

        state.answer = answer
        state.intelligence_state["adversarial_reasoning"] = {
            "route": state.route,
            "rounds": rounds,
            "raw_output_count": len(state.raw_outputs),
        }

        return state
ADVERSARY

cat > kcis/intelligence/synthesizer.py <<'SYNTH'
from __future__ import annotations

from kcis.core.state import KCISState
from kcis.adapters.llm_adapter import LLMAdapter


class ResponseSynthesizer:
    name = "response_synthesizer"

    def __init__(self, llm: LLMAdapter):
        self.llm = llm

    def process(self, state: KCISState) -> KCISState:
        if not state.answer:
            state.answer = self.llm.generate(f"Answer this task:\n\n{state.input_text}")

        if state.metadata.get("explain", False):
            trace = (
                "\n\n---\n"
                "KCIS Trace\n"
                f"- route: {state.route}\n"
                f"- entropy: {state.metrics.entropy:.4f}\n"
                f"- compression_ratio: {state.metrics.compression_ratio:.4f}\n"
                f"- compression_error: {state.metrics.compression_error:.6f}\n"
                f"- reservoir_resonance: {state.metrics.memory_resonance:.4f}\n"
                f"- reversible_reclaim_tokens: {state.metrics.reversible_reclaim_tokens}\n"
            )
            state.answer = f"{state.answer}{trace}"

        state.intelligence_state["synthesizer"] = {
            "explain": bool(state.metadata.get("explain", False)),
            "answer_length": len(state.answer),
        }

        return state
SYNTH

cat > kcis/intelligence/adaptive_mutation.py <<'MUTATE'
from __future__ import annotations

import json
from pathlib import Path

from kcis.core.state import KCISState


class AdaptiveMutation:
    """
    Self-tuning parameter store.

    This module records feedback hooks and can be extended to tune entropy thresholds,
    compression ratios, and debate rounds based on benchmark results.
    """

    name = "adaptive_mutation"

    def __init__(self, path: str = ".kcis_memory/params.json"):
        self.path = Path(path)
        self.params = {
            "cheap_bias": 1.0,
            "compression_bias": 1.0,
            "debate_bias": 1.0,
        }
        self._load()

    def _load(self):
        try:
            if self.path.exists():
                self.params.update(json.loads(self.path.read_text()))
        except Exception:
            pass

    def _save(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(json.dumps(self.params, indent=2))

    def process(self, state: KCISState) -> KCISState:
        feedback = state.metadata.get("feedback")

        if isinstance(feedback, dict):
            if feedback.get("latency_bad"):
                self.params["cheap_bias"] *= 1.05
            if feedback.get("quality_bad"):
                self.params["debate_bias"] *= 1.05
            if feedback.get("cost_bad"):
                self.params["compression_bias"] *= 1.05

        self._save()
        state.intelligence_state["adaptive_mutation"] = dict(self.params)
        return state
MUTATE

cat > kcis/intelligence/build.py <<'BUILD'
from __future__ import annotations

from typing import Optional

from kcis.core.config import KCISConfig
from kcis.core.kernel import KCISKernel
from kcis.adapters.llm_adapter import adapter_from_provider

from kcis.physics.entropy import EntropyRouter
from kcis.physics.quantum_field import QuantumFieldWeighting
from kcis.physics.tensor_compression import TensorCompressor
from kcis.physics.reservoir import ReservoirMemory
from kcis.physics.reversible_graph import ReversibleGraphOptimizer
from kcis.physics.thermodynamics import ThermodynamicAccounting

from kcis.memory.spintronic_memory import SpintronicMemory

from kcis.intelligence.adaptive_mutation import AdaptiveMutation
from kcis.intelligence.adversarial_reasoning import AdversarialReasoning
from kcis.intelligence.synthesizer import ResponseSynthesizer


def build_kcis(
    provider: Optional[str] = None,
    model: Optional[str] = None,
    config: Optional[KCISConfig] = None,
    memory_path: Optional[str] = None,
) -> KCISKernel:
    config = config or KCISConfig.from_env()
    llm = adapter_from_provider(provider or config.llm_provider, model or config.model)

    memory_file = memory_path or config.memory_path

    kernel = KCISKernel(config=config)

    # Physics optimization layer
    kernel.register(EntropyRouter(config.low_entropy_threshold, config.high_entropy_threshold))
    kernel.register(QuantumFieldWeighting())
    kernel.register(TensorCompressor(rank_ratio=config.tensor_rank_ratio))
    kernel.register(ReservoirMemory())
    kernel.register(SpintronicMemory(path=memory_file))
    kernel.register(ReversibleGraphOptimizer())

    # Intelligence layer
    kernel.register(AdaptiveMutation())
    kernel.register(AdversarialReasoning(llm=llm, max_rounds=config.max_debate_rounds))
    kernel.register(ResponseSynthesizer(llm=llm))

    # Final accounting
    kernel.register(
        ThermodynamicAccounting(
            watts_estimate=config.watts_estimate,
            input_cost_per_million=config.input_cost_per_million,
            output_cost_per_million=config.output_cost_per_million,
        )
    )

    return kernel
BUILD

cat > kcis/cli.py <<'CLI'
from __future__ import annotations

import argparse
import json

from kcis.intelligence.build import build_kcis


def main() -> None:
    parser = argparse.ArgumentParser(description="KCIS - Ketchum's Compute Intelligence Systems")
    parser.add_argument("--task", type=str, default="Explain KCIS.")
    parser.add_argument("--context", type=str, default="")
    parser.add_argument("--provider", type=str, default=None, help="rule, openai, anthropic")
    parser.add_argument("--model", type=str, default=None)
    parser.add_argument("--memory-path", type=str, default=None)
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--explain", action="store_true")

    args = parser.parse_args()

    kernel = build_kcis(
        provider=args.provider,
        model=args.model,
        memory_path=args.memory_path,
    )

    state = kernel.run(
        task=args.task,
        context=args.context,
        explain=args.explain,
    )

    if args.json:
        print(json.dumps(state.to_dict(), indent=2))
    else:
        print(state.answer)
        print()
        print("Metrics:")
        print(json.dumps(state.metrics.__dict__, indent=2, default=str))


if __name__ == "__main__":
    main()
CLI

cat > kcis/benchmarks/__init__.py <<'INIT'
from .runner import run_benchmark

__all__ = ["run_benchmark"]
INIT

cat > kcis/benchmarks/runner.py <<'BENCH'
from __future__ import annotations

import argparse
import json
import statistics
import time
from pathlib import Path
from typing import Dict, List, Any

from kcis.adapters.llm_adapter import adapter_from_provider
from kcis.core.config import KCISConfig
from kcis.core.tokens import count_tokens, estimate_cost_usd
from kcis.intelligence.build import build_kcis


def load_tasks(path: str) -> List[Dict[str, Any]]:
    tasks = []
    for line in Path(path).read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        tasks.append(json.loads(line))
    return tasks


def score_answer(task: Dict[str, Any], answer: str) -> float:
    expected = str(task.get("expected", "")).strip().lower()
    if expected:
        return 1.0 if expected in answer.lower() else 0.0

    # Simple non-keyed heuristic.
    if not answer.strip():
        return 0.0
    if len(answer.strip()) < 10:
        return 0.4
    return 0.75


def pct_delta(new: float, old: float) -> float:
    if abs(old) < 1e-12:
        return 0.0
    return ((new - old) / old) * 100.0


def run_baseline(task_text: str, provider: str, config: KCISConfig) -> Dict[str, Any]:
    llm = adapter_from_provider(provider, config.model)

    start = time.perf_counter()
    answer = llm.generate(f"Answer this task directly:\n\n{task_text}")
    latency = time.perf_counter() - start

    input_tokens = count_tokens(task_text)
    output_tokens = count_tokens(answer)
    total_tokens = input_tokens + output_tokens

    return {
        "answer": answer,
        "latency_s": latency,
        "input_tokens": input_tokens,
        "output_tokens": output_tokens,
        "total_tokens": total_tokens,
        "estimated_cost_usd": estimate_cost_usd(
            input_tokens,
            output_tokens,
            config.input_cost_per_million,
            config.output_cost_per_million,
        ),
        "estimated_joules": config.watts_estimate * latency,
    }


def run_benchmark(
    tasks_path: str = "bench/tasks.jsonl",
    out_path: str = "results/kcis_benchmark.json",
    provider: str = "rule",
    limit: int | None = None,
) -> Dict[str, Any]:
    config = KCISConfig.from_env()
    tasks = load_tasks(tasks_path)
    if limit:
        tasks = tasks[:limit]

    kernel = build_kcis(provider=provider, config=config)

    rows = []

    for task in tasks:
        task_id = task.get("id", "task")
        task_text = task["task"]

        baseline = run_baseline(task_text, provider, config)
        baseline["quality_score"] = score_answer(task, baseline["answer"])

        state = kernel.run(task_text)
        kcis = {
            "answer": state.answer,
            "latency_s": state.metrics.latency_s,
            "input_tokens": state.metrics.input_tokens,
            "output_tokens": state.metrics.output_tokens,
            "total_tokens": state.metrics.total_tokens,
            "estimated_cost_usd": state.metrics.estimated_cost_usd,
            "estimated_joules": state.metrics.estimated_joules,
            "entropy": state.metrics.entropy,
            "route": state.route,
            "compression_ratio": state.metrics.compression_ratio,
            "compression_error": state.metrics.compression_error,
            "quality_score": score_answer(task, state.answer),
        }

        delta = {
            "latency_pct": pct_delta(kcis["latency_s"], baseline["latency_s"]),
            "tokens_pct": pct_delta(kcis["total_tokens"], baseline["total_tokens"]),
            "cost_pct": pct_delta(kcis["estimated_cost_usd"], baseline["estimated_cost_usd"]),
            "joules_pct": pct_delta(kcis["estimated_joules"], baseline["estimated_joules"]),
            "quality_delta": kcis["quality_score"] - baseline["quality_score"],
        }

        rows.append(
            {
                "id": task_id,
                "task": task_text,
                "baseline": baseline,
                "kcis": kcis,
                "delta": delta,
            }
        )

    summary = summarize(rows)
    result = {
        "system": "KCIS - Ketchum's Compute Intelligence Systems",
        "provider": provider,
        "tasks_path": tasks_path,
        "summary": summary,
        "rows": rows,
    }

    out = Path(out_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2))

    md_path = out.with_suffix(".md")
    md_path.write_text(render_markdown(result))

    return result


def summarize(rows: List[Dict[str, Any]]) -> Dict[str, Any]:
    if not rows:
        return {}

    def mean_delta(key: str) -> float:
        return statistics.mean(r["delta"][key] for r in rows)

    return {
        "tasks": len(rows),
        "avg_latency_pct": mean_delta("latency_pct"),
        "avg_tokens_pct": mean_delta("tokens_pct"),
        "avg_cost_pct": mean_delta("cost_pct"),
        "avg_joules_pct": mean_delta("joules_pct"),
        "avg_quality_delta": mean_delta("quality_delta"),
        "routes": {
            route: sum(1 for r in rows if r["kcis"]["route"] == route)
            for route in ["fast", "standard", "deep"]
        },
    }


def render_markdown(result: Dict[str, Any]) -> str:
    s = result["summary"]
    lines = [
        "# KCIS Benchmark Report",
        "",
        f"Provider: `{result['provider']}`",
        f"Tasks: `{s.get('tasks', 0)}`",
        "",
        "## Summary",
        "",
        f"- Average latency delta: `{s.get('avg_latency_pct', 0):.2f}%`",
        f"- Average token delta: `{s.get('avg_tokens_pct', 0):.2f}%`",
        f"- Average cost delta: `{s.get('avg_cost_pct', 0):.2f}%`",
        f"- Average joules delta: `{s.get('avg_joules_pct', 0):.2f}%`",
        f"- Average quality delta: `{s.get('avg_quality_delta', 0):.3f}`",
        f"- Routes: `{s.get('routes', {})}`",
        "",
        "## Per-task results",
        "",
    ]

    for row in result["rows"]:
        lines.extend(
            [
                f"### {row['id']}",
                "",
                f"- Route: `{row['kcis']['route']}`",
                f"- Latency delta: `{row['delta']['latency_pct']:.2f}%`",
                f"- Token delta: `{row['delta']['tokens_pct']:.2f}%`",
                f"- Cost delta: `{row['delta']['cost_pct']:.2f}%`",
                f"- Joules delta: `{row['delta']['joules_pct']:.2f}%`",
                f"- Quality delta: `{row['delta']['quality_delta']:.3f}`",
                "",
            ]
        )

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Run KCIS benchmark")
    parser.add_argument("--tasks", default="bench/tasks.jsonl")
    parser.add_argument("--out", default="results/kcis_benchmark.json")
    parser.add_argument("--provider", default="rule")
    parser.add_argument("--limit", type=int, default=None)

    args = parser.parse_args()

    result = run_benchmark(
        tasks_path=args.tasks,
        out_path=args.out,
        provider=args.provider,
        limit=args.limit,
    )

    print(json.dumps(result["summary"], indent=2))


if __name__ == "__main__":
    main()
BENCH

cat > bench/tasks.jsonl <<'TASKS'
{"id":"math_1","task":"If John has 12 apples and gives away 5, then buys 9 more, how many apples does he have?","expected":"16"}
{"id":"logic_1","task":"A bat and a ball cost $1.10 total. The bat costs $1.00 more than the ball. How much does the ball cost?","expected":"$0.05"}
{"id":"summary_1","task":"Summarize this in one sentence: KCIS is a physics-inspired AI orchestration system using entropy routing, tensor compression, reservoir memory, adversarial agents, and thermodynamic accounting."}
{"id":"code_1","task":"Find the bug in this Python function: def add_items(items=[]): items.append(1); return items","expected":"mutable default"}
{"id":"reasoning_1","task":"Explain why measuring token usage, latency, and quality is necessary before claiming an AI architecture is more efficient."}
TASKS

cat > tests/test_kernel.py <<'TEST'
from kcis.intelligence.build import build_kcis


def test_kcis_kernel_runs(tmp_path):
    memory_path = tmp_path / "memory.json"
    kernel = build_kcis(provider="rule", memory_path=str(memory_path))

    state = kernel.run("Explain how entropy routing improves compute efficiency.")

    assert state.answer
    assert state.route in {"fast", "standard", "deep"}
    assert state.metrics.entropy >= 0
    assert state.metrics.input_tokens > 0
    assert state.metrics.output_tokens > 0
    assert state.metrics.estimated_joules >= 0
    assert "tensor_compression" in state.physics_state
    assert "spintronic" in state.memory_state
TEST

cat > tests/test_modules.py <<'TEST'
from kcis.physics.entropy import EntropyRouter
from kcis.memory.spintronic_memory import SpintronicMemory
from kcis.core.state import KCISState


def test_entropy_router_outputs_valid_route():
    router = EntropyRouter()
    state = KCISState(task="simple test")
    state = router.process(state)

    assert 0 <= state.metrics.entropy <= 1
    assert state.route in {"fast", "standard", "deep"}


def test_spintronic_memory_persists(tmp_path):
    path = tmp_path / "spin.json"

    mem1 = SpintronicMemory(path=str(path))
    state1 = mem1.process(KCISState(task="remember quantum compute routing"))

    assert path.exists()
    assert "spintronic" in state1.memory_state

    mem2 = SpintronicMemory(path=str(path))
    state2 = mem2.process(KCISState(task="second run"))

    assert state2.memory_state["spintronic"]["runs"] >= 2
TEST

cat > tests/test_benchmark.py <<'TEST'
import json

from kcis.benchmarks.runner import run_benchmark


def test_benchmark_smoke(tmp_path):
    tasks = tmp_path / "tasks.jsonl"
    out = tmp_path / "result.json"

    tasks.write_text(
        json.dumps(
            {
                "id": "math",
                "task": "If John has 12 apples and gives away 5, then buys 9 more, how many apples does he have?",
                "expected": "16",
            }
        )
        + "\n"
    )

    result = run_benchmark(
        tasks_path=str(tasks),
        out_path=str(out),
        provider="rule",
    )

    assert out.exists()
    assert result["summary"]["tasks"] == 1
    assert result["rows"][0]["kcis"]["answer"]
TEST

cat > .github/workflows/tests.yml <<'YAML'
name: KCIS Tests

on:
  push:
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install
        run: |
          python -m pip install --upgrade pip setuptools wheel
          python -m pip install -e ".[dev]"

      - name: Compile
        run: python -m compileall -q .

      - name: Test
        run: python -m pytest -q
YAML

echo "Bootstrap logic complete."
