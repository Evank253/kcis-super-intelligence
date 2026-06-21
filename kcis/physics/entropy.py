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
