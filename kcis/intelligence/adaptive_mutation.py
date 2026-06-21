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
