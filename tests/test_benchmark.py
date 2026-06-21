import json

from kcis.benchmarks.runner import run_benchmark


def test_benchmark_smoke(tmp_path):
    tasks = tmp_path / "tasks.jsonl"
    out = tmp_path / "result.json"

    tasks.write_text(
        json.dumps(
            {
                "id": "math",
                "task": "If John has 12 apples and gives away 5, then buys 9 more, how many apples does he have?",
                "expected": "16",
            }
        )
        + "\n"
    )

    result = run_benchmark(
        tasks_path=str(tasks),
        out_path=str(out),
        provider="rule",
    )

    assert out.exists()
    assert result["summary"]["tasks"] == 1
    assert result["rows"][0]["kcis"]["answer"]
