use axum::{
    extract::State,
    http::StatusCode,
    response::Json,
};

use serde_json::{json, Value};
use std::net::UdpSocket;

use crate::state::AppState;

fn get_local_ip() -> String {
    match UdpSocket::bind("0.0.0.0:0")
        .and_then(|socket| {
            socket.connect("8.8.8.8:80")?;
            socket.local_addr()
        }) {
        Ok(addr) => addr.ip().to_string(),
        Err(_) => "127.0.0.1".to_string(),
    }
}

pub async fn status(
    State(state): State<AppState>,
) -> Json<Value> {
    let engine_state = state.engine.status().await;
    let host = get_local_ip();

    let uptime = engine_state
        .started_at
        .map(|started| started.elapsed().as_secs())
        .unwrap_or(0);

    Json(json!({
        "running": engine_state.running,
        "pid": engine_state.pid,
        "uptime": uptime,
        "host": host,
        "port": 8081
    }))
}

pub async fn start(
    State(state): State<AppState>,
) -> StatusCode {
    state.engine.start().await;

    StatusCode::NO_CONTENT
}

pub async fn stop(
    State(state): State<AppState>,
) -> StatusCode {
    state.engine.stop().await;

    StatusCode::NO_CONTENT
}

pub async fn restart(
    State(state): State<AppState>,
) -> StatusCode {
    state.engine.restart().await;

    StatusCode::NO_CONTENT
}

pub async fn logs(
    State(state): State<AppState>,
) -> Json<Value> {
    let logs = state.engine.logs().await;

    Json(json!({
        "logs": logs
    }))
}

pub async fn clear_logs(
    State(state): State<AppState>,
) -> StatusCode {
    state.engine.clear_logs().await;

    StatusCode::NO_CONTENT
}