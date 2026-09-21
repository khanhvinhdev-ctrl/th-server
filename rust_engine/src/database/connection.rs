use sqlx::{
    sqlite::{SqliteConnectOptions, SqlitePool},
    ConnectOptions,
};

use super::config::DatabaseConfig;

#[derive(Clone)]
pub struct DatabaseConnection {
    pub pool: SqlitePool,
}

impl DatabaseConnection {
    pub async fn new(
        config: &DatabaseConfig,
    ) -> Result<Self, sqlx::Error> {
        if let Some(parent) =
            std::path::Path::new(&config.path).parent()
        {
            std::fs::create_dir_all(parent)
                .map_err(sqlx::Error::Io)?;
        }

        let options = SqliteConnectOptions::new()
            .filename(&config.path)
            .create_if_missing(true);

        let pool = SqlitePool::connect_with(options).await?;

        Ok(Self { pool })
    }
}