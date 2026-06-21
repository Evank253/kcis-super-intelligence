.PHONY: install test run bench clean

install:
	python -m pip install --upgrade pip setuptools wheel
	python -m pip install -e ".[dev]"

test:
	python -m compileall -q .
	python -m pytest -q

run:
	python main.py --task "Explain how entropy routing improves AI compute efficiency." --explain

bench:
	python -m kcis.benchmarks.runner --tasks bench/tasks.jsonl --out results/kcis_benchmark.json

clean:
	rm -rf **pycache** .pytest_cache .kcis_memory build dist *.egg-info*
	find . -name "__pycache__" -type d -prune -exec rm -rf {} +
