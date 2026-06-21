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
