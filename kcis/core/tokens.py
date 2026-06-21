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
