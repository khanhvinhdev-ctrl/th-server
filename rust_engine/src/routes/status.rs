use axum::Json;
use serde_json::{json, Value};

pub async fn status() -> Json<Value> {
    Json(json!({
        "service": "ThServer",
        "engine": "rust",
        "status": "running",
        "version": "0.1.0"
    }))
}