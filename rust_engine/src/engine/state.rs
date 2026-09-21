use std::time::Instant;

use super::config::EngineConfig;

#[derive(Clone)]
pub struct EngineState {
    pub config: EngineConfig,
    pub started_at: Instant,
}

impl EngineState {
    pub fn new(config: EngineConfig) -> Self {
        Self {
            config,
            started_at: Instant::now(),
        }
    }

    pub fn uptime(&self) -> u64 {
        self.started_at.elapsed().as_secs()
    }
}