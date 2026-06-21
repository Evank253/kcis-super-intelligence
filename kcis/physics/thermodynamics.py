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
