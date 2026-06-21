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
