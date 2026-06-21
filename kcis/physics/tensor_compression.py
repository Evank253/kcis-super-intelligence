from __future__ import annotations

import hashlib
import numpy as np

from kcis.core.state import KCISState


class TensorCompressor:
    """
    Low-rank SVD compressor for text-derived state matrices.

    This is a practical stand-in for deeper tensor network compression.
    Later extensions can add TT/MPS contraction.
    """

    name = "tensor_compression"

    def __init__(self, dim: int = 64, rank_ratio: float = 0.30):
        self.dim = dim
        self.rank_ratio = rank_ratio

    def _text_to_matrix(self, text: str) -> np.ndarray:
        tokens = text.split()
        if not tokens:
            tokens = [text or "empty"]

        width = max(4, min(256, len(tokens)))
        mat = np.zeros((self.dim, width), dtype=float)

        for j, tok in enumerate(tokens[:width]):
            digest = hashlib.sha256(tok.encode("utf-8")).digest()
            for k, b in enumerate(digest[: min(self.dim, len(digest))]):
                mat[k, j] += (b / 255.0) - 0.5

        return mat

    def process(self, state: KCISState) -> KCISState:
        matrix = self._text_to_matrix(state.input_text)

        u, s, vh = np.linalg.svd(matrix, full_matrices=False)

        if state.route == "deep":
            ratio = min(0.60, self.rank_ratio * 1.5)
        elif state.route == "fast":
            ratio = max(0.10, self.rank_ratio * 0.6)
        else:
            ratio = self.rank_ratio

        rank = max(1, int(len(s) * ratio))

        u_r = u[:, :rank]
        s_r = s[:rank]
        vh_r = vh[:rank, :]

        reconstructed = (u_r * s_r) @ vh_r

        original_size = matrix.size
        compressed_size = u_r.size + s_r.size + vh_r.size
        compression_ratio = compressed_size / max(original_size, 1)

        error = float(np.mean((matrix - reconstructed) ** 2))

        state.metrics.compression_ratio = float(compression_ratio)
        state.metrics.compression_error = error

        state.physics_state["tensor_compression"] = {
            "method": "svd_low_rank",
            "original_shape": list(matrix.shape),
            "rank": rank,
            "original_size": int(original_size),
            "compressed_size": int(compressed_size),
            "compressed_to_original_ratio": float(compression_ratio),
            "reconstruction_mse": error,
        }

        return state
