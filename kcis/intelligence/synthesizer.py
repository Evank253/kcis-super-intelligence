from __future__ import annotations

from kcis.core.state import KCISState
from kcis.adapters.llm_adapter import LLMAdapter


class ResponseSynthesizer:
    name = "response_synthesizer"

    def __init__(self, llm: LLMAdapter):
        self.llm = llm

    def process(self, state: KCISState) -> KCISState:
        if not state.answer:
            state.answer = self.llm.generate(f"Answer this task:\n\n{state.input_text}")

        if state.metadata.get("explain", False):
            trace = (
                "\n\n---\n"
                "KCIS Trace\n"
                f"- route: {state.route}\n"
                f"- entropy: {state.metrics.entropy:.4f}\n"
                f"- compression_ratio: {state.metrics.compression_ratio:.4f}\n"
                f"- compression_error: {state.metrics.compression_error:.6f}\n"
                f"- reservoir_resonance: {state.metrics.memory_resonance:.4f}\n"
                f"- reversible_reclaim_tokens: {state.metrics.reversible_reclaim_tokens}\n"
            )
            state.answer = f"{state.answer}{trace}"

        state.intelligence_state["synthesizer"] = {
            "explain": bool(state.metadata.get("explain", False)),
            "answer_length": len(state.answer),
        }

        return state
