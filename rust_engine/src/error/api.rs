use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};

use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct ApiError {
    pub error: ErrorBody,
}

#[derive(Debug, Serialize)]
pub struct ErrorBody {
    pub code: String,
    pub message: String,
}

impl ApiError {
    pub fn new(
        status: StatusCode,
        code: impl Into<String>,
        message: impl Into<String>,
    ) -> ApiErrorResponse {
        ApiErrorResponse {
            status,
            body: Self {
                error: ErrorBody {
                    code: code.into(),
                    message: message.into(),
                },
            },
        }
    }
}

pub struct ApiErrorResponse {
    pub status: StatusCode,
    pub body: ApiError,
}

impl IntoResponse for ApiErrorResponse {
    fn into_response(self) -> Response {
        (
            self.status,
            Json(self.body),
        )
            .into_response()
    }
}