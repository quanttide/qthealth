/// 量潮健康 CLI 入口。
use std::process::ExitCode;

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().collect();
    match args.get(1).map(String::as_str) {
        Some("health") => run_health(),
        Some("--version" | "-V") => {
            println!("qthealth-cli 0.1.0");
            ExitCode::SUCCESS
        }
        Some("--help" | "-h") | None => {
            print_help();
            ExitCode::SUCCESS
        }
        Some(other) => {
            eprintln!("未知命令：{other}（见 --help）");
            ExitCode::FAILURE
        }
    }
}

/// 健康状态检查（占位——真实检查接入 provider/健康数据源）。
fn run_health() -> ExitCode {
    println!("量潮健康：系统状态占位（cli 骨架）");
    ExitCode::SUCCESS
}

fn print_help() {
    println!(
        "量潮健康 CLI\n\n用法：qthealth-cli <命令>\n\n命令：\n  health    健康状态检查（占位）\n  --version 版本信息\n  --help    帮助"
    );
}
