from __future__ import annotations

from kcis.core.state import KCISState
from kcis.core.tokens import count_tokens


class ReversibleGraphOptimizer:
    """
    Reversible-compute inspired optimization proxy.

    Tracks how many intermediate tokens/state units could be reclaimed
    by using reversible execution and avoiding duplicate context.
    """

    name = "reversible_graph_optimizer"

    def process(self, state: KCISState) -> KCISState:
        tokens = count_tokens(state.input_text)

        if state.route == "fast":
            reclaim = int(tokens * 0.08)
            graph = ["input", "fast_reason", "synthesize"]
        elif state.route == "deep":
            reclaim = int(tokens * 0.28)
            graph = [
                "input",
                "compress_state",
                "solve",
                "critic",
                "repair",
                "reverse_release_intermediates",
                "synthesize",
            ]
        else:
            reclaim = int(tokens * 0.16)
            graph = ["input", "compress_state", "reason", "reverse_release_intermediates", "synthesize"]

        state.metrics.reversible_reclaim_tokens = reclaim
        state.physics_state["reversible_graph"] = {
            "graph": graph,
            "estimated_reclaim_tokens": reclaim,
            "note": "Reversible-compute inspired memory accounting.",
        }

        return state
