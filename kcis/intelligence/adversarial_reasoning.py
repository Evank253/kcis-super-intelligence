from __future__ import annotations

from kcis.core.state import KCISState
from kcis.adapters.llm_adapter import LLMAdapter


class AdversarialReasoning:
    """
    Solver -> critic -> repair loop.

    Deep route gets more adversarial pressure.
    Fast route gets a cheap direct answer.
    """

    name = "adversarial_reasoning"

    def __init__(self, llm: LLMAdapter, max_rounds: int = 2):
        self.llm = llm
        self.max_rounds = max_rounds

    def process(self, state: KCISState) -> KCISState:
        if state.route == "fast":
            prompt = f"Answer concisely:\n\n{state.input_text}"
            answer = self.llm.generate(prompt, max_tokens=256)
            rounds = 0

        elif state.route == "deep":
            prompt = (
                "Solve the task carefully. Use concise reasoning and return the best answer.\n\n"
                f"Task:\n{state.input_text}"
            )
            answer = self.llm.generate(prompt, max_tokens=512)
            rounds = self.max_rounds

            for i in range(rounds):
                critique = self.llm.generate(
                    "Find the worst flaw, missing edge case, or unsupported claim in this answer.\n\n"
                    f"Task:\n{state.input_text}\n\nAnswer:\n{answer}\n\nFlaw:",
                    max_tokens=256,
                )
                repaired = self.llm.generate(
                    "Fix the flaw and return an improved final answer only.\n\n"
                    f"Task:\n{state.input_text}\n\nFlaw:\n{critique}\n\nCurrent answer:\n{answer}",
                    max_tokens=512,
                )

                state.raw_outputs.append(
                    {
                        "round": i + 1,
                        "critique": critique,
                        "repair": repaired,
                    }
                )
                answer = repaired

        else:
            prompt = f"Solve the task clearly and accurately:\n\n{state.input_text}"
            answer = self.llm.generate(prompt, max_tokens=384)
            rounds = 0

        state.answer = answer
        state.intelligence_state["adversarial_reasoning"] = {
            "route": state.route,
            "rounds": rounds,
            "raw_output_count": len(state.raw_outputs),
        }

        return state
