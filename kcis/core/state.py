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
