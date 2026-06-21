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
