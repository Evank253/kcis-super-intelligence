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
