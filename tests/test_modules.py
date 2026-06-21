from kcis.physics.entropy import EntropyRouter
from kcis.memory.spintronic_memory import SpintronicMemory
from kcis.core.state import KCISState


def test_entropy_router_outputs_valid_route():
    router = EntropyRouter()
    state = KCISState(task="simple test")
    state = router.process(state)

    assert 0 <= state.metrics.entropy <= 1
    assert state.route in {"fast", "standard", "deep"}


def test_spintronic_memory_persists(tmp_path):
    path = tmp_path / "spin.json"

    mem1 = SpintronicMemory(path=str(path))
    state1 = mem1.process(KCISState(task="remember quantum compute routing"))

    assert path.exists()
    assert "spintronic" in state1.memory_state

    mem2 = SpintronicMemory(path=str(path))
    state2 = mem2.process(KCISState(task="second run"))

    assert state2.memory_state["spintronic"]["runs"] >= 2
