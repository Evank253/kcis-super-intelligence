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
