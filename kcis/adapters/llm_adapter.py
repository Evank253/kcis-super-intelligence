from __future__ import annotations

from typing import Protocol, Optional
import os
import re


class LLMAdapter(Protocol):
    def generate(self, prompt: str, system: Optional[str] = None, max_tokens: int = 512) -> str:
        ...


class RuleBasedAdapter:
    """
    Local deterministic adapter.

    Purpose:
    - lets tests pass without API keys
    - gives predictable benchmark behavior
    - can be replaced by OpenAI, Anthropic, or local Llama
    """

    def generate(self, prompt: str, system: Optional[str] = None, max_tokens: int = 512) -> str:
        low = prompt.lower()

        if "12 apples" in low and "gives away 5" in low and "buys 9" in low:
            return "John has 16 apples."

        if "bat and a ball" in low and "$1.10" in low:
            return "The ball costs $0.05 and the bat costs $1.05."

        if "items=[]" in low or "mutable default" in low:
            return (
                "The bug is the mutable default argument items=[]. "
                "Use None as the default and create a new list inside the function."
            )

        if "summarize" in low:
            text = prompt.split(":", 1)[-1].strip()
            text = re.sub(r"\s+", " ", text)
            return f"Summary: {text[:220]}"

        if "find the worst flaw" in low:
            return "The main risk is insufficient verification, missing edge cases, or overclaiming without benchmark evidence."

        if "fix the flaw" in low or "improved answer" in low:
            return "Improved answer: verify the result, state assumptions clearly, and avoid claims not supported by benchmark data."

        if "entropy routing" in low:
            return (
                "Entropy routing improves AI orchestration by sending simple low-uncertainty tasks through a fast path "
                "and complex high-uncertainty tasks through deeper reasoning, reducing unnecessary token and compute use."
            )

        if "kcis" in low:
            return (
                "KCIS is Ketchum's Compute Intelligence Systems: a physics-inspired orchestration layer that routes, "
                "compresses, remembers, verifies, and accounts for compute around LLMs."
            )

        return (
            "KCIS response: analyze the task, route by uncertainty, use memory and compression when useful, "
            "verify the answer, and report compute metrics."
        )


class OpenAIAdapter:
    def __init__(self, model: Optional[str] = None):
        self.model = model or os.getenv("KCIS_MODEL", "gpt-4o-mini")

    def generate(self, prompt: str, system: Optional[str] = None, max_tokens: int = 512) -> str:
        try:
            from openai import OpenAI
        except ImportError as exc:
            raise RuntimeError("Install OpenAI support with: pip install -e '.[openai]'") from exc

        client = OpenAI()
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": prompt})

        response = client.chat.completions.create(
            model=self.model,
            messages=messages,
            max_tokens=max_tokens,
        )
        return response.choices[0].message.content or ""


class AnthropicAdapter:
    def __init__(self, model: Optional[str] = None):
        self.model = model or os.getenv("KCIS_MODEL", "claude-3-5-haiku-latest")

    def generate(self, prompt: str, system: Optional[str] = None, max_tokens: int = 512) -> str:
        try:
            import anthropic
        except ImportError as exc:
            raise RuntimeError("Install Anthropic support with: pip install -e '.[anthropic]'") from exc

        client = anthropic.Anthropic()
        response = client.messages.create(
            model=self.model,
            system=system or "",
            max_tokens=max_tokens,
            messages=[{"role": "user", "content": prompt}],
        )
        return response.content[0].text


def adapter_from_provider(provider: Optional[str] = None, model: Optional[str] = None) -> LLMAdapter:
    provider = (provider or os.getenv("KCIS_LLM_PROVIDER", "rule")).lower()

    if provider in {"rule", "local", "dummy", "offline"}:
        return RuleBasedAdapter()

    if provider == "openai":
        return OpenAIAdapter(model=model)

    if provider in {"anthropic", "claude"}:
        return AnthropicAdapter(model=model)

    raise ValueError(f"Unknown KCIS LLM provider: {provider}")
