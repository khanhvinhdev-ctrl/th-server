use std::process::Stdio;
use std::sync::Arc;
use std::time::Instant;

use tokio::process::{Child, Command};
use tokio::sync::Mutex;

#[derive(Clone)]
pub struct EngineService {
    runtime: Arc<Mutex<EngineRuntime>>,
}

struct EngineRuntime {
    child: Option<Child>,
    started_at: Option<Instant>,
    logs: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct EngineState {
    pub running: bool,
    pub pid: Option<u32>,
    pub started_at: Option<Instant>,
    pub logs: Vec<String>,
}

impl EngineService {
    pub fn new() -> Self {
        Self {
            runtime: Arc::new(Mutex::new(EngineRuntime {
                child: None,
                started_at: None,
                logs: Vec::new(),
            })),
        }
    }

    pub async fn status(&self) -> EngineState {
        let mut runtime = self.runtime.lock().await;

        if let Some(child) = runtime.child.as_mut() {
            match child.try_wait() {
                Ok(Some(_)) => {
                    runtime.child = None;
                    runtime.started_at = None;

                    runtime
                        .logs
                        .push("Engine exited".to_string());
                }
                Ok(None) => {}
                Err(_) => {
                    runtime.child = None;
                    runtime.started_at = None;

                    runtime
                        .logs
                        .push("Failed to check engine process".to_string());
                }
            }
        }

        EngineState {
            running: runtime.child.is_some(),
            pid: runtime
                .child
                .as_ref()
                .and_then(|child| child.id()),
            started_at: runtime.started_at,
            logs: runtime.logs.clone(),
        }
    }

    pub async fn start(&self) {
        let mut runtime = self.runtime.lock().await;

        if let Some(child) = runtime.child.as_mut() {
            match child.try_wait() {
                Ok(None) => {
                    return;
                }
                Ok(Some(_)) => {
                    runtime.child = None;
                    runtime.started_at = None;
                }
                Err(_) => {
                    runtime.child = None;
                    runtime.started_at = None;
                }
            }
        }

        let executable = match std::env::current_exe() {
            Ok(path) => path,
            Err(error) => {
                runtime.logs.push(format!(
                    "Failed to locate engine executable: {}",
                    error
                ));
                return;
            }
        };

        let child = Command::new(executable)
            .arg("--engine-worker")
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn();

        match child {
            Ok(child) => {
                let pid = child.id();

                runtime.child = Some(child);
                runtime.started_at = Some(Instant::now());

                runtime.logs.push(format!(
                    "Engine started (PID {})",
                    pid.unwrap_or(0)
                ));
            }

            Err(error) => {
                runtime.logs.push(format!(
                    "Failed to start engine: {}",
                    error
                ));
            }
        }
    }

    pub async fn stop(&self) {
        let mut runtime = self.runtime.lock().await;

        let Some(mut child) = runtime.child.take() else {
            return;
        };

        let pid = child.id();

        match child.kill().await {
            Ok(_) => {
                let _ = child.wait().await;

                runtime.started_at = None;

                runtime.logs.push(format!(
                    "Engine stopped (PID {})",
                    pid.unwrap_or(0)
                ));
            }

            Err(error) => {
                runtime.logs.push(format!(
                    "Failed to stop engine: {}",
                    error
                ));

                runtime.child = Some(child);
            }
        }
    }

    pub async fn restart(&self) {
        {
            let mut runtime = self.runtime.lock().await;

            if let Some(mut child) = runtime.child.take() {
                let old_pid = child.id();

                let _ = child.kill().await;
                let _ = child.wait().await;

                runtime.started_at = None;

                runtime.logs.push(format!(
                    "Engine stopped (PID {})",
                    old_pid.unwrap_or(0)
                ));
            }
        }

        self.start().await;

        let mut runtime = self.runtime.lock().await;

        if runtime.child.is_some() {
            runtime
                .logs
                .push("Engine restarted".to_string());
        }
    }

    pub async fn logs(&self) -> Vec<String> {
        self.runtime.lock().await.logs.clone()
    }

    pub async fn clear_logs(&self) {
        self.runtime.lock().await.logs.clear();
    }
}