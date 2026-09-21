use axum::{
    routing::{get, post},
    Router,
};

use std::net::SocketAddr;

mod config;
mod engine;
mod error;
mod routes;
mod service;
mod database;
mod state;

use service::engine::EngineService;


#[tokio::main]
async fn main() {
    if std::env::args().any(|arg| arg == "--engine-worker") {
        engine::server::run().await;
        return;
    }

    run_control_server().await;
}

async fn run_control_server() {
    let engine_service = EngineService::new();

    let database_config =
        database::config::DatabaseConfig::new();

    let database_service =
        database::service::DatabaseService::new(
            database_config,
        )
        .await
        .expect("failed to initialize database");

    let app_state =
        state::AppState::new(
            engine_service,
            database_service,
        );
  
    let app = Router::new()
        .route("/health", get(routes::health::health))
        .route("/api/v1/status", get(routes::status::status))
        .route(
            "/api/engine/status",
            get(routes::engine::status),
        )
        .route(
            "/api/engine/start",
            post(routes::engine::start),
        )
        .route(
            "/api/engine/stop",
            post(routes::engine::stop),
        )
        .route(
            "/api/engine/restart",
            post(routes::engine::restart),
        )
        .route(
            "/api/engine/logs",
            get(routes::engine::logs),
        )
        .route(
            "/api/engine/logs/clear",
            post(routes::engine::clear_logs),
        )
        .with_state(app_state);

    let addr = SocketAddr::from(([0, 0, 0, 0], config::CONTROL_PORT));
  
    println!(
        "ThServer Engine Worker port: {}",
        config::ENGINE_PORT
    );

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("failed to bind control port");

    axum::serve(listener, app)
        .await
        .expect("control server error");
}