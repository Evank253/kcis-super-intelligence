from __future__ import annotations

from typing import Optional

from kcis.core.config import KCISConfig
from kcis.core.kernel import KCISKernel
from kcis.adapters.llm_adapter import adapter_from_provider

from kcis.physics.entropy import EntropyRouter
from kcis.physics.quantum_field import QuantumFieldWeighting
from kcis.physics.tensor_compression import TensorCompressor
from kcis.physics.reservoir import ReservoirMemory
from kcis.physics.reversible_graph import ReversibleGraphOptimizer
from kcis.physics.thermodynamics import ThermodynamicAccounting

from kcis.memory.spintronic_memory import SpintronicMemory

from kcis.intelligence.adaptive_mutation import AdaptiveMutation
from kcis.intelligence.adversarial_reasoning import AdversarialReasoning
from kcis.intelligence.synthesizer import ResponseSynthesizer


def build_kcis(
    provider: Optional[str] = None,
    model: Optional[str] = None,
    config: Optional[KCISConfig] = None,
    memory_path: Optional[str] = None,
) -> KCISKernel:
    config = config or KCISConfig.from_env()
    llm = adapter_from_provider(provider or config.llm_provider, model or config.model)

    memory_file = memory_path or config.memory_path

    kernel = KCISKernel(config=config)

    # Physics optimization layer
    kernel.register(EntropyRouter(config.low_entropy_threshold, config.high_entropy_threshold))
    kernel.register(QuantumFieldWeighting())
    kernel.register(TensorCompressor(rank_ratio=config.tensor_rank_ratio))
    kernel.register(ReservoirMemory())
    kernel.register(SpintronicMemory(path=memory_file))
    kernel.register(ReversibleGraphOptimizer())

    # Intelligence layer
    kernel.register(AdaptiveMutation())
    kernel.register(AdversarialReasoning(llm=llm, max_rounds=config.max_debate_rounds))
    kernel.register(ResponseSynthesizer(llm=llm))

    # Final accounting
    kernel.register(
        ThermodynamicAccounting(
            watts_estimate=config.watts_estimate,
            input_cost_per_million=config.input_cost_per_million,
            output_cost_per_million=config.output_cost_per_million,
        )
    )

    return kernel
