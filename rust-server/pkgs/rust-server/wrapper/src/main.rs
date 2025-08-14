use anyhow::{Context, Result};
use clap::{Parser, ValueHint};
use rustix::mount::mount_bind;
use rustix::process::{getgid, getuid};
use rustix::thread::{UnshareFlags, unshare_unsafe};
use std::fs::create_dir_all;
use std::os::unix::{fs::PermissionsExt, process::CommandExt};
use std::path::{Path, PathBuf};
use std::process::Command;

static RUST_SERVER_FILE: &str = "RustDedicated";
static RUST_HARMONY_MODS_DIRECTORY: &str = "HarmonyMods";
static RUST_SERVER_IDENTITY_DIRECTORY: &str = "server";
static RUST_BUNDLES_DIRECTORY: &str = "Bundles";
static RUST_CFG_DIRECTORY: &str = "cfg";
static RUST_OXIDE_COMPILER_FILE: &str = "Oxide.Compiler";

#[derive(Parser, Debug)]
struct Args {
    /// Directory with Rust dedicated server installation.
    #[clap(short, long, value_hint = ValueHint::DirPath)]
    server_dir: PathBuf,

    /// Directory for Rust dedicated server configuration and data. If not set,
    /// current working directory is used.
    #[clap(short, long, value_hint = ValueHint::DirPath)]
    data_dir: Option<PathBuf>,

    #[clap(short, long, hide = true)]
    argv0: Option<String>,

    /// Command-line arguments to pass to the Rust dedicated server.
    #[clap(trailing_var_arg = true)]
    server_args: Vec<String>,
}

fn main() -> Result<()> {
    let args = Args::parse();

    let argv0 = args.argv0.unwrap_or_else(|| {
        std::env::args()
            .next()
            .unwrap_or(RUST_SERVER_FILE.to_string())
    });

    let data_dir = match args.data_dir {
        Some(dir) => {
            create_dir_all(&dir).with_context(|| {
                format!(
                    "Create intermediate directories for {}",
                    dir.to_string_lossy(),
                )
            })?;
            dir
        }
        None => PathBuf::from("."),
    };

    unshare_namespaces()?;
    prepare_server_identity(&args.server_dir, &data_dir)
        .context("Prepare server identity directory")?;
    prepare_harmony_mods(&args.server_dir, &data_dir).context("Prepare harmony mods directory")?;
    prepare_bundles(&args.server_dir, &data_dir).context("Prepare bundles directory")?;
    prepare_cfg(&args.server_dir, &data_dir).context("Prepare cfg directory")?;
    prepare_oxide_compiler(&args.server_dir, &data_dir).context("Prepare oxide compiler file")?;

    let program = args.server_dir.join(RUST_SERVER_FILE);

    let err = Command::new(program.clone())
        .arg0(argv0)
        .args(args.server_args)
        .current_dir(data_dir)
        .exec();

    Err(err).context(format!("Failed to execute {}", program.to_string_lossy()))
}

fn unshare_namespaces() -> Result<()> {
    let uid = getuid();
    let gid = getgid();

    let mut namespaces = UnshareFlags::NEWNS;
    if !uid.is_root() {
        namespaces |= UnshareFlags::NEWUSER;
    }

    unsafe { unshare_unsafe(namespaces) }.context("Failed to unshare namespaces")?;

    if uid.is_root() {
        return Ok(());
    }

    std::fs::write("/proc/self/setgroups", "deny").context("Failed to deny setgroups")?;
    std::fs::write("/proc/self/uid_map", format!("{0} {0} 1", uid.as_raw()))
        .context("Failed to write user ID map")?;
    std::fs::write("/proc/self/gid_map", format!("{0} {0} 1", gid.as_raw()))
        .context("Failed to write group ID map")?;

    Ok(())
}

fn prepare_server_identity(server_dir: &Path, data_dir: &Path) -> Result<()> {
    let source = data_dir.join(RUST_SERVER_IDENTITY_DIRECTORY);
    let target = server_dir.join(RUST_SERVER_IDENTITY_DIRECTORY);
    create_dir_all(&source)?;
    mount_bind(&source, &target)?;
    Ok(())
}

fn prepare_harmony_mods(server_dir: &Path, data_dir: &Path) -> Result<()> {
    let source = data_dir.join(RUST_HARMONY_MODS_DIRECTORY);
    let target = server_dir.join(RUST_HARMONY_MODS_DIRECTORY);
    create_dir_all(&source)?;
    mount_bind(&source, &target)?;
    Ok(())
}

fn prepare_bundles(server_dir: &Path, data_dir: &Path) -> Result<()> {
    let source = server_dir.join(RUST_BUNDLES_DIRECTORY);
    let target = data_dir.join(RUST_BUNDLES_DIRECTORY);
    create_dir_all(&target)?;
    mount_bind(&source, &target)?;
    Ok(())
}

fn prepare_cfg(server_dir: &Path, data_dir: &Path) -> Result<()> {
    // NB: for some reason Rust server attempts to open files under cfg
    // directory for write (but only reads them). This fails because write
    // permission bit is not set. As a workaround, we copy directory contents
    // with write bit set.
    //
    // WARNING: this a potentially destructive operation since we remove
    // existing cfg directory contents in data dir. Ideally, this should be
    // fixed on Rust’s side.

    let source = server_dir.join(RUST_CFG_DIRECTORY);
    let target = data_dir.join(RUST_CFG_DIRECTORY);

    if target.try_exists()? {
        std::fs::remove_dir_all(&target)?;
    }

    let _ = copy_dir::copy_dir(source, &target)?;

    for entry in walkdir::WalkDir::new(target) {
        let entry = entry?;
        let metadata = entry.metadata()?;
        let mut permissions = metadata.permissions();
        let mode = permissions.mode();
        permissions.set_mode(mode | 0o200); // u+w
        std::fs::set_permissions(entry.path(), permissions)?;
    }

    Ok(())
}

fn prepare_oxide_compiler(server_dir: &Path, data_dir: &Path) -> Result<()> {
    let source = server_dir.join(RUST_OXIDE_COMPILER_FILE);
    if !std::fs::exists(&source)? {
        return Ok(());
    }
    let target = data_dir.join(RUST_OXIDE_COMPILER_FILE);
    create_file(&target)?;
    mount_bind(&source, &target)?;
    Ok(())
}

fn create_file(path: &Path) -> Result<()> {
    let _ = std::fs::OpenOptions::new()
        .append(true)
        .create(true)
        .open(path)?;
    Ok(())
}
