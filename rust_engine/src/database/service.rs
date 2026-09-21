use sqlx::SqlitePool;

use super::{
    config::DatabaseConfig,
    connection::DatabaseConnection,
    migration,
};

#[derive(Clone)]
pub struct DatabaseService {
    connection: DatabaseConnection,
    config: DatabaseConfig,
}

impl DatabaseService {
    pub async fn new(
        config: DatabaseConfig,
    ) -> Result<Self, sqlx::Error> {
        let connection =
        DatabaseConnection::new(&config).await?;
            
        migration::run(&connection.pool).await?;
        
        Ok(Self {
            connection,
            config,
        })
    }

    pub fn pool(&self) -> &SqlitePool {
        &self.connection.pool
    }

    pub fn config(&self) -> &DatabaseConfig {
        &self.config
    }
}