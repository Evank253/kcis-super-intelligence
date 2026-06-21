from kcis.intelligence.build import build_kcis


def test_kcis_kernel_runs(tmp_path):
    memory_path = tmp_path / "memory.json"
    kernel = build_kcis(provider="rule", memory_path=str(memory_path))

    state = kernel.run("Explain how entropy routing improves compute efficiency.")

    assert state.answer
    assert state.route in {"fast", "standard", "deep"}
    assert state.metrics.entropy >= 0
    assert state.metrics.input_tokens > 0
    assert state.metrics.output_tokens > 0
    assert state.metrics.estimated_joules >= 0
    assert "tensor_compression" in state.physics_state
    assert "spintronic" in state.memory_state
