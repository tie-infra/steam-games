use anyhow::{Context, Result};
use clap::{Parser, ValueHint};
use nix::mount::{mount, MsFlags};
use nix::sched::{unshare, CloneFlags};
use nix::unistd::{getgid, getuid};
use std::fs::create_dir_all;
use std::os::unix::process::CommandExt;
use std::path::{Path, PathBuf};
use std::process::Command;

#[derive(Parser, Debug)]
struct Args {
    /// Directory with Unreal Engine dedicated server project root.
    #[clap(short, long, value_hint = ValueHint::DirPath)]
    project_root: PathBuf,

    /// Path to the Unreal Engine dedicated server executable.
    #[clap(short, long)]
    executable: PathBuf,

    /// Paths to the directories under the project root where the Unreal Engine
    /// dedicated server saves game state and configuration.
    #[clap(short, long, value_hint = ValueHint::DirPath)]
    saved_dirs: Vec<String>,

    /// Whether to change current working directory to the project root.
    #[clap(short, long)]
    change_dir: bool,

    #[clap(short, long, hide = true)]
    argv0: Option<String>,

    /// Command-line arguments to pass to the Unreal Engine dedicated server.
    #[clap(trailing_var_arg = true)]
    server_args: Vec<String>,
}

fn main() -> Result<()> {
    let args = Args::parse();

    let argv0 = args
        .argv0
        .unwrap_or_else(|| std::env::args().next().unwrap_or("unreal-wrapper".to_string()));

    unshare_namespaces()?;

    prepare_project_root(
        &args.project_root,
        &args.saved_dirs,
    )
    .context("Failed to bind state directories")?;

    let program = args.executable;

    let mut cmd = Command::new(program.clone());
    cmd.arg0(argv0).args(args.server_args);
    if args.change_dir {
        cmd.current_dir(&args.project_root);
    }
    let err = cmd.exec();

    Err(err).context(format!("Failed to execute {}", program.to_string_lossy()))
}

fn unshare_namespaces() -> Result<()> {
    let uid = getuid();
    let gid = getgid();

    let mut namespaces = CloneFlags::CLONE_NEWNS;
    if !uid.is_root() {
        namespaces |= CloneFlags::CLONE_NEWUSER;
    }

    unshare(namespaces).context("Failed to unshare namespaces")?;

    if uid.is_root() {
        return Ok(());
    }

    std::fs::write("/proc/self/setgroups", "deny").context("Failed to deny setgroups")?;
    std::fs::write("/proc/self/uid_map", format!("{0} {0} 1", uid))
        .context("Failed to write user ID map")?;
    std::fs::write("/proc/self/gid_map", format!("{0} {0} 1", gid))
        .context("Failed to write group ID map")?;

    Ok(())
}

fn prepare_project_root(project_root: &Path, dirs: &Vec<String>) -> Result<()> {
    for dir in dirs {
        create_dir_all(dir)?;
    }
    for dir in dirs {
        mount_bind(Path::new(dir), &project_root.join(dir))?;
    }
    Ok(())
}

fn mount_bind(source: &Path, target: &Path) -> Result<()> {
    let none = None::<&str>;
    mount(Some(source), target, none, MsFlags::MS_BIND, none)?;
    Ok(())
}
