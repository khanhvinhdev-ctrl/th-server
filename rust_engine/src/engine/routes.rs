use axum::Json;
use serde_json::{json, Value};

use crate::{
    config,
    engine::state::EngineState,
};

pub async fn health() -> Json<Value> {
    Json(json!({
        "status": "ok",
        "service": "thserver-engine",
        "port": config::ENGINE_PORT
    }))
}

pub async fn info(
    axum::extract::State(state): axum::extract::State<EngineState>,
) -> Json<Value> {
    Json(json!({
        "name": state.config.name,
        "version": state.config.version,
        "port": state.config.port,
        "uptime": state.uptime()
    }))
}

