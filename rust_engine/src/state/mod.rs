use crate::{
    database::service::DatabaseService,
    service::engine::EngineService,
};

#[derive(Clone)]
pub struct AppState {
    pub engine: EngineService,
    pub database: DatabaseService,
}

impl AppState {
    pub fn new(
        engine: EngineService,
        database: DatabaseService,
    ) -> Self {
        Self {
            engine,
            database,
        }
    }
}