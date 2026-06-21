from __future__ import annotations

import argparse
import json
import statistics
import time
from pathlib import Path
from typing import Dict, List, Any

from kcis.adapters.llm_adapter import adapter_from_provider
from kcis.core.config import KCISConfig
from kcis.core.tokens import count_tokens, estimate_cost_usd
from kcis.intelligence.build import build_kcis


def load_tasks(path: str) -> List[Dict[str, Any]]:
    tasks = []
    for line in Path(path).read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        tasks.append(json.loads(line))
    return tasks


def score_answer(task: Dict[str, Any], answer: str) -> float:
    expected = str(task.get("expected", "")).strip().lower()
    if expected:
        return 1.0 if expected in answer.lower() else 0.0

    # Simple non-keyed heuristic.
    if not answer.strip():
        return 0.0
    if len(answer.strip()) < 10:
        return 0.4
    return 0.75


def pct_delta(new: float, old: float) -> float:
    if abs(old) < 1e-12:
        return 0.0
    return ((new - old) / old) * 100.0


def run_baseline(task_text: str, provider: str, config: KCISConfig) -> Dict[str, Any]:
    llm = adapter_from_provider(provider, config.model)

    start = time.perf_counter()
    answer = llm.generate(f"Answer this task directly:\n\n{task_text}")
    latency = time.perf_counter() - start

    input_tokens = count_tokens(task_text)
    output_tokens = count_tokens(answer)
    total_tokens = input_tokens + output_tokens

    return {
        "answer": answer,
        "latency_s": latency,
        "input_tokens": input_tokens,
        "output_tokens": output_tokens,
        "total_tokens": total_tokens,
        "estimated_cost_usd": estimate_cost_usd(
            input_tokens,
            output_tokens,
            config.input_cost_per_million,
            config.output_cost_per_million,
        ),
        "estimated_joules": config.watts_estimate * latency,
    }


def run_benchmark(
    tasks_path: str = "bench/tasks.jsonl",
    out_path: str = "results/kcis_benchmark.json",
    provider: str = "rule",
    limit: int | None = None,
) -> Dict[str, Any]:
    config = KCISConfig.from_env()
    tasks = load_tasks(tasks_path)
    if limit:
        tasks = tasks[:limit]

    kernel = build_kcis(provider=provider, config=config)

    rows = []

    for task in tasks:
        task_id = task.get("id", "task")
        task_text = task["task"]

        baseline = run_baseline(task_text, provider, config)
        baseline["quality_score"] = score_answer(task, baseline["answer"])

        state = kernel.run(task_text)
        kcis = {
            "answer": state.answer,
            "latency_s": state.metrics.latency_s,
            "input_tokens": state.metrics.input_tokens,
            "output_tokens": state.metrics.output_tokens,
            "total_tokens": state.metrics.total_tokens,
            "estimated_cost_usd": state.metrics.estimated_cost_usd,
            "estimated_joules": state.metrics.estimated_joules,
            "entropy": state.metrics.entropy,
            "route": state.route,
            "compression_ratio": state.metrics.compression_ratio,
            "compression_error": state.metrics.compression_error,
            "quality_score": score_answer(task, state.answer),
        }

        delta = {
            "latency_pct": pct_delta(kcis["latency_s"], baseline["latency_s"]),
            "tokens_pct": pct_delta(kcis["total_tokens"], baseline["total_tokens"]),
            "cost_pct": pct_delta(kcis["estimated_cost_usd"], baseline["estimated_cost_usd"]),
            "joules_pct": pct_delta(kcis["estimated_joules"], baseline["estimated_joules"]),
            "quality_delta": kcis["quality_score"] - baseline["quality_score"],
        }

        rows.append(
            {
                "id": task_id,
                "task": task_text,
                "baseline": baseline,
                "kcis": kcis,
                "delta": delta,
            }
        )

    summary = summarize(rows)
    result = {
        "system": "KCIS - Ketchum's Compute Intelligence Systems",
        "provider": provider,
        "tasks_path": tasks_path,
        "summary": summary,
        "rows": rows,
    }

    out = Path(out_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2))

    md_path = out.with_suffix(".md")
    md_path.write_text(render_markdown(result))

    return result


def summarize(rows: List[Dict[str, Any]]) -> Dict[str, Any]:
    if not rows:
        return {}

    def mean_delta(key: str) -> float:
        return statistics.mean(r["delta"][key] for r in rows)

    return {
        "tasks": len(rows),
        "avg_latency_pct": mean_delta("latency_pct"),
        "avg_tokens_pct": mean_delta("tokens_pct"),
        "avg_cost_pct": mean_delta("cost_pct"),
        "avg_joules_pct": mean_delta("joules_pct"),
        "avg_quality_delta": mean_delta("quality_delta"),
        "routes": {
            route: sum(1 for r in rows if r["kcis"]["route"] == route)
            for route in ["fast", "standard", "deep"]
        },
    }


def render_markdown(result: Dict[str, Any]) -> str:
    s = result["summary"]
    lines = [
        "# KCIS Benchmark Report",
        "",
        f"Provider: `{result['provider']}`",
        f"Tasks: `{s.get('tasks', 0)}`",
        "",
        "## Summary",
        "",
        f"- Average latency delta: `{s.get('avg_latency_pct', 0):.2f}%`",
        f"- Average token delta: `{s.get('avg_tokens_pct', 0):.2f}%`",
        f"- Average cost delta: `{s.get('avg_cost_pct', 0):.2f}%`",
        f"- Average joules delta: `{s.get('avg_joules_pct', 0):.2f}%`",
        f"- Average quality delta: `{s.get('avg_quality_delta', 0):.3f}`",
        f"- Routes: `{s.get('routes', {})}`",
        "",
        "## Per-task results",
        "",
    ]

    for row in result["rows"]:
        lines.extend(
            [
                f"### {row['id']}",
                "",
                f"- Route: `{row['kcis']['route']}`",
                f"- Latency delta: `{row['delta']['latency_pct']:.2f}%`",
                f"- Token delta: `{row['delta']['tokens_pct']:.2f}%`",
                f"- Cost delta: `{row['delta']['cost_pct']:.2f}%`",
                f"- Joules delta: `{row['delta']['joules_pct']:.2f}%`",
                f"- Quality delta: `{row['delta']['quality_delta']:.3f}`",
                "",
            ]
        )

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Run KCIS benchmark")
    parser.add_argument("--tasks", default="bench/tasks.jsonl")
    parser.add_argument("--out", default="results/kcis_benchmark.json")
    parser.add_argument("--provider", default="rule")
    parser.add_argument("--limit", type=int, default=None)

    args = parser.parse_args()

    result = run_benchmark(
        tasks_path=args.tasks,
        out_path=args.out,
        provider=args.provider,
        limit=args.limit,
    )

    print(json.dumps(result["summary"], indent=2))


if __name__ == "__main__":
    main()
