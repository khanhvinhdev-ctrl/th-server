use axum::{
    routing::get,
    Router,
};

use std::net::SocketAddr;

use crate::config;
use super::routes;

pub async fn run() {
    let config = crate::engine::config::EngineConfig::new();

    let state = crate::engine::state::EngineState::new(
        config,
    );

    let app = Router::new()
    .route("/health", get(routes::health))
    .route("/api/engine/info", get(routes::info))
    .with_state(state);

    let addr = SocketAddr::from(([0, 0, 0, 0], config::ENGINE_PORT));

    println!(
        "ThServer Engine Worker listening on {}",
        addr
    );

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("failed to bind engine port");

    axum::serve(listener, app)
        .await
        .expect("engine worker server error");
}