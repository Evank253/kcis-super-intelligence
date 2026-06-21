from __future__ import annotations

import os
import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel

from kcis.intelligence.build import build_kcis
from kcis.core.config import KCISConfig

app = FastAPI(
    title="KCIS Web Interface",
    description="Interactive Web UI for Ketchum's Compute Intelligence Systems",
    version="0.1.0"
)

class TaskRequest(BaseModel):
    task: str
    context: str = ""
    provider: str = "rule"
    model: str = ""
    explain: bool = True

@app.post("/api/run")
async def run_kcis_task(req: TaskRequest):
    try:
        # Build configuration with override
        config = KCISConfig.from_env()
        if req.model:
            config.model = req.model
            
        kernel = build_kcis(
            provider=req.provider,
            model=req.model or None,
            config=config
        )
        
        # Run execution
        state = kernel.run(
            task=req.task,
            context=req.context,
            explain=req.explain
        )
        
        return JSONResponse(content={
            "success": True,
            "answer": state.answer,
            "route": state.route,
            "metrics": {
                "entropy": state.metrics.entropy,
                "route_confidence": state.metrics.route_confidence,
                "compression_ratio": state.metrics.compression_ratio,
                "compression_error": state.metrics.compression_error,
                "memory_resonance": state.metrics.memory_resonance,
                "reversible_reclaim_tokens": state.metrics.reversible_reclaim_tokens,
                "latency_s": state.metrics.latency_s,
                "input_tokens": state.metrics.input_tokens,
                "output_tokens": state.metrics.output_tokens,
                "total_tokens": state.metrics.total_tokens,
                "estimated_cost_usd": state.metrics.estimated_cost_usd,
                "estimated_joules": state.metrics.estimated_joules,
            },
            "physics_state": state.physics_state,
            "memory_state": state.memory_state,
            "intelligence_state": state.intelligence_state,
            "agent_trace": state.agent_trace,
            "raw_outputs": state.raw_outputs
        })
    except Exception as e:
        return JSONResponse(status_code=500, content={
            "success": False,
            "error": str(e)
        })

@app.get("/", response_class=HTMLResponse)
async def index():
    # Read HTML from the workspace path
    html_path = os.path.join(os.path.dirname(__file__), "templates", "index.html")
    if os.path.exists(html_path):
        with open(html_path, "r", encoding="utf-8") as f:
            return f.read()
    return "<h3>KCIS Web App HTML template not found.</h3>"

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8000"))
    uvicorn.run("app:app", host="0.0.0.0", port=port, reload=True)
