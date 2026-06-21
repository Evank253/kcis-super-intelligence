from __future__ import annotations

import argparse
import json

from kcis.intelligence.build import build_kcis


def main() -> None:
    parser = argparse.ArgumentParser(description="KCIS - Ketchum's Compute Intelligence Systems")
    parser.add_argument("--task", type=str, default="Explain KCIS.")
    parser.add_argument("--context", type=str, default="")
    parser.add_argument("--provider", type=str, default=None, help="rule, openai, anthropic")
    parser.add_argument("--model", type=str, default=None)
    parser.add_argument("--memory-path", type=str, default=None)
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--explain", action="store_true")

    args = parser.parse_args()

    kernel = build_kcis(
        provider=args.provider,
        model=args.model,
        memory_path=args.memory_path,
    )

    state = kernel.run(
        task=args.task,
        context=args.context,
        explain=args.explain,
    )

    if args.json:
        print(json.dumps(state.to_dict(), indent=2))
    else:
        print(state.answer)
        print()
        print("Metrics:")
        print(json.dumps(state.metrics.__dict__, indent=2, default=str))


if __name__ == "__main__":
    main()
