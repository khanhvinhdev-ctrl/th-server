use crate::config;

#[derive(Clone)]
pub struct EngineConfig {
    pub name: String,
    pub version: String,
    pub port: u16,
}

impl EngineConfig {
    pub fn new() -> Self {
        Self {
            name: "ThServer Engine".to_string(),
            version: "0.1.0".to_string(),
            port: config::ENGINE_PORT,
        }
    }
}