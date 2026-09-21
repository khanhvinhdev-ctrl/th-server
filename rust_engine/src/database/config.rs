#[derive(Clone)]
pub struct DatabaseConfig {
    pub path: String,
}

impl DatabaseConfig {
    pub fn new() -> Self {
        let path = std::env::var("THSERVER_DB_PATH")
            .unwrap_or_else(|_| "data/thserver.db".to_string());

        Self { path }
    }
}