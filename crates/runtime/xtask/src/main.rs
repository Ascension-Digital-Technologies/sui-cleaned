//! Repository maintenance commands for the cleaned Sui Rust workspace.
//!
//! Keep this crate dependency-free. It should compile fast and work on a fresh clone.

use std::env;
use std::ffi::OsStr;
use std::fs;
use std::io;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const DOMAIN_DIRS: &[&str] = &[
    "api",
    "crypto",
    "config",
    "runtime",
    "consensus",
    "execution",
    "network",
    "protocol",
    "storage",
];

const ROOT_WORK_AREAS: &[&str] = &["bench", "tests", "tools"];

const CORE_PACKAGES: &[&str] = &[
    "consensus-config",
    "consensus-types",
    "consensus-core",
    "shared-crypto",
    "sui-keys",
    "sui-tls",
    "sui-protocol-config",
    "sui-protocol-config-macros",
    "sui-types",
    "typed-store-error",
    "typed-store-derive",
    "typed-store",
    "mysten-network",
];

const SUI_COMPAT_PACKAGES: &[&str] = &[
    "sui-protocol-config",
    "sui-types",
    "sui-json-rpc-types",
    "sui-framework",
    "sui-execution",
    "sui-core",
    "sui-move-build",
    "sui-package-resolver",
];

const ALLOWED_ROOT_ENTRIES: &[&str] = &[
    ".cargo",
    ".editorconfig",
    ".gitattributes",
    ".git",
    ".github",
    ".gitignore",
    "Cargo.lock",
    "Cargo.toml",
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "LICENSE",
    "Makefile",
    "NOTICE",
    "README.md",
    "RELEASE.md",
    "SECURITY.md",
    "SUPPORT.md",
    "bench",
    "clippy.toml",
    "crates",
    "docs",
    "rust-toolchain.toml",
    "rustfmt.toml",
    "scripts",
    "tests",
    "tools",
];

const REQUIRED_DOCS: &[&str] = &[
    "docs/architecture.md",
    "docs/build.md",
    "docs/build_modes.md",
    "docs/domain_commands.md",
    "docs/repo_hygiene.md",
    "docs/root_layout.md",
    "docs/script_inventory.md",
    "docs/source_map.md",
    "docs/troubleshooting.md",
    "docs/linux_toolchain.md",
    "docs/official_sui.md",
    "docs/release_checklist.md",
    "docs/embedded_sources.md",
    "docs/windows_build.md",
    "docs/workspace_tiers.md",
    "docs/xtask.md",
];

fn main() -> ExitCode {
    match run() {
        Ok(code) => ExitCode::from(code),
        Err(err) => {
            eprintln!("xtask error: {err}");
            ExitCode::from(1)
        }
    }
}

fn run() -> io::Result<u8> {
    let mut args = env::args().skip(1);
    let cmd = args.next().unwrap_or_else(|| "help".to_string());
    let rest: Vec<String> = args.collect();

    match cmd.as_str() {
        "help" | "-h" | "--help" => {
            print_help();
            Ok(0)
        }
        "status" => status(false),
        "audit" | "doctor" => status(true),
        "tree" => tree_cmd(&rest),
        "domains" | "list-domains" => {
            print_domains();
            Ok(0)
        }
        "tiers" | "list-tiers" => {
            print_tiers();
            Ok(0)
        }
        "scripts" | "list-scripts" => scripts(),
        "check-root" | "root" => check_root_cmd(),
        "check-layout" | "layout" => check_layout_cmd(),
        "check-domain" | "domain" => check_domain(&rest),
        "repair" | "repair-windows" => repair_windows(),
        "metadata" | "meta" => cargo(&["metadata", "--format-version", "1", "--no-deps"]),
        "check-fast" | "fast" => cargo(&["check"]),
        "check-core" | "core" => cargo_packages(CORE_PACKAGES, false),
        "check-workspace" | "workspace" => cargo(&["check", "--workspace"]),
        "check-sui-compat" | "sui-compat" | "compat" => cargo_packages(SUI_COMPAT_PACKAGES, false),
        "check-full" | "full" => cargo(&["check", "--workspace", "--all-targets"]),
        "fmt" => cargo(&["fmt", "--all"]),
        "clippy-fast" => cargo(&["clippy"]),
        "clippy-workspace" => cargo(&["clippy", "--workspace"]),
        "clippy-full" => cargo(&["clippy", "--workspace", "--all-targets", "--all-features"]),
        other => {
            eprintln!("unknown xtask command: {other}\n");
            print_help();
            Ok(2)
        }
    }
}

fn print_help() {
    println!(r#"sui-clean repository tasks

Usage:
  cargo xtask <command> [args]

Repo hygiene:
  status                         static repo health report
  audit                          stricter static report, including docs/root policy
  tree [domain|bench|tests|tools] print package tree
  domains                        list allowed crates/ domains
  tiers                          print build tier summary
  scripts                        print script inventory
  check-root                     verify root files match built-in root policy
  check-layout                   verify crates/ domains and promoted bench/tests/tools layout

Setup / repair:
  repair-windows                 apply Windows GNU repair passes

Build tiers:
  check-fast                     cargo check; default members only
  check-core                     first-party core packages only
  check-workspace                all active workspace packages, normal targets only
  check-sui-compat               selected Sui execution/protocol compatibility packages
  check-full                     full upstream parity gate; workspace + all targets
  check-domain <domain>          check every package under crates/<domain>
  check-domain <domain> --all-targets

Other:
  metadata                       cargo metadata --format-version 1 --no-deps
  fmt                            cargo fmt --all
  clippy-fast                    cargo clippy
  clippy-workspace               cargo clippy --workspace
  clippy-full                    cargo clippy --workspace --all-targets --all-features
"#);
}

fn repo_root() -> io::Result<PathBuf> {
    let cwd = env::current_dir()?;
    let mut cur = cwd.as_path();
    loop {
        if cur.join("Cargo.toml").exists() && cur.join("crates").exists() {
            return Ok(cur.to_path_buf());
        }
        cur = cur.parent().ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "could not find repo root"))?;
    }
}

fn cargo(args: &[&str]) -> io::Result<u8> {
    let cargo = env::var("CARGO").unwrap_or_else(|_| "cargo".to_string());
    run_cmd(cargo, args)
}

fn cargo_owned(args: &[String]) -> io::Result<u8> {
    let cargo = env::var("CARGO").unwrap_or_else(|_| "cargo".to_string());
    let status = Command::new(cargo).args(args).status()?;
    Ok(status.code().unwrap_or(1) as u8)
}

fn cargo_packages(pkgs: &[&str], all_targets: bool) -> io::Result<u8> {
    let mut args: Vec<&str> = vec!["check"];
    for pkg in pkgs {
        args.push("--package");
        args.push(pkg);
    }
    if all_targets {
        args.push("--all-targets");
    }
    cargo(&args)
}

fn run_cmd<I, S>(program: impl AsRef<OsStr>, args: I) -> io::Result<u8>
where
    I: IntoIterator<Item = S>,
    S: AsRef<OsStr>,
{
    let status = Command::new(program).args(args).status()?;
    Ok(status.code().unwrap_or(1) as u8)
}

fn repair_windows() -> io::Result<u8> {
    let root = repo_root()?;
    run_script(&root, "repair-windows")
}

fn run_script(root: &Path, stem: &str) -> io::Result<u8> {
    let scripts = root.join("scripts");
    if cfg!(windows) {
        let script = scripts.join(format!("{stem}.bat"));
        println!("running {}", script.display());
        run_cmd("cmd", ["/C", &script.display().to_string()])
    } else {
        let script = scripts.join(format!("{stem}.sh"));
        println!("running {}", script.display());
        run_cmd(script, std::iter::empty::<&str>())
    }
}

fn print_domains() {
    println!("allowed crates/ domains\n");
    for domain in DOMAIN_DIRS {
        println!("  {domain}");
    }
    println!("\nroot work areas\n");
    for area in ROOT_WORK_AREAS {
        println!("  {area}");
    }
}

fn print_tiers() {
    println!("build tiers\n");
    println!("  check-fast       cargo check");
    println!("                   default-members only; normal daily loop\n");
    println!("  check-core       {} explicit core packages", CORE_PACKAGES.len());
    println!("                   config, consensus, crypto, network, protocol, storage\n");
    println!("  check-domain     cargo check --package for packages under one crates/<domain>");
    println!("                   e.g. cargo xtask check-domain execution\n");
    println!("  check-workspace  cargo check --workspace");
    println!("                   all active packages, normal lib/bin targets\n");
    println!("  check-sui-compat {} explicit Sui compatibility packages", SUI_COMPAT_PACKAGES.len());
    println!("                   protocol/execution compatibility surface\n");
    println!("  check-full       cargo check --workspace --all-targets");
    println!("                   full upstream parity gate; intentionally huge");
}

fn scripts() -> io::Result<u8> {
    println!("script inventory\n");
    println!("  public entrypoints");
    println!("    setup-linux.sh            install Linux native build dependencies");
    println!("    setup-windows.bat/.ps1    install/prepare Windows native build dependencies");
    println!("    build.bat/.sh             build wrapper: debug, release, workspace, full, check");
    println!("    check.bat/.sh             build tier wrapper: fast, core, workspace, compat, full");
    println!("    test.bat/.sh              test wrapper: fast, workspace, full, run");
    println!("    clean.bat/.sh             clean wrapper: target, native, xtask");
    println!("    fmt.bat/.sh               cargo xtask fmt");
    println!("    status.bat/.sh            cargo xtask status");
    println!("    repair-windows.bat/.sh    apply Windows GNU native-build fixes\n");
    println!("  private helpers");
    println!("    scripts/lib/              Python and PowerShell implementation helpers\n");
    Ok(0)
}

fn check_root_cmd() -> io::Result<u8> {
    let root = repo_root()?;
    let mut failed = false;
    println!("root policy check");
    println!("repo: {}\n", root.display());
    root_clutter_ok(&root, &mut failed)?;
    check(&mut failed, "root bench directory", root.join("bench").exists());
    check(&mut failed, "root tests directory", root.join("tests").exists());
    check(&mut failed, "root tools directory", root.join("tools").exists());
    check(&mut failed, "bench/tests/tools outside crates", !root.join("crates/bench").exists() && !root.join("crates/tests").exists() && !root.join("crates/tools").exists());
    check(&mut failed, "no vendor/upstream/manifests/reports root", !root.join("vendor").exists() && !root.join("upstream").exists() && !root.join("manifests").exists() && !root.join("reports").exists());
    check(&mut failed, "legacy manifests not in root", !root.join("_manifest").exists());
    if failed { Ok(1) } else { Ok(0) }
}

fn check_layout_cmd() -> io::Result<u8> {
    let root = repo_root()?;
    let mut failed = false;
    println!("layout check");
    println!("repo: {}\n", root.display());
    layout_ok(&root, &mut failed)?;
    if failed { Ok(1) } else { Ok(0) }
}

fn layout_ok(root: &Path, failed: &mut bool) -> io::Result<bool> {
    let mut ok = true;
    let crates = root.join("crates");
    for domain in DOMAIN_DIRS {
        let exists = crates.join(domain).is_dir();
        check(failed, &format!("crates/{domain}"), exists);
        ok &= exists;
    }

    if crates.exists() {
        let mut entries = Vec::new();
        for entry in fs::read_dir(&crates)? {
            let entry = entry?;
            if entry.file_type()?.is_dir() {
                entries.push(entry.file_name().to_string_lossy().to_string());
            }
        }
        entries.sort();
        for name in entries {
            if !DOMAIN_DIRS.iter().any(|allowed| *allowed == name) {
                println!("    unexpected crates/ domain: {name}");
                ok = false;
                *failed = true;
            }
        }
    }

    for area in ROOT_WORK_AREAS {
        let exists = root.join(area).is_dir();
        check(failed, &format!("root {area}/"), exists);
        ok &= exists;
        let absent_from_crates = !root.join("crates").join(area).exists();
        check(failed, &format!("crates/{area} absent"), absent_from_crates);
        ok &= absent_from_crates;
    }

    for path in ["vendor", "upstream", "manifests", "reports", "xtask", "crates/runtime/sui", "crates/execution/external-crates"] {
        let absent = !root.join(path).exists();
        check(failed, &format!("{path} absent"), absent);
        ok &= absent;
    }

    let move_vm = root.join("crates/execution/move-vm").is_dir();
    check(failed, "crates/execution/move-vm", move_vm);
    ok &= move_vm;

    Ok(ok)
}

fn tree_cmd(args: &[String]) -> io::Result<u8> {
    let root = repo_root()?;
    if args.is_empty() {
        println!("sui-clean tree\n");
        print_package_tree(&root, "crates", 3)?;
        print_package_tree(&root, "bench", 2)?;
        print_package_tree(&root, "tests", 2)?;
        print_package_tree(&root, "tools", 2)?;
        return Ok(0);
    }

    let name = &args[0];
    let rel = if DOMAIN_DIRS.iter().any(|d| *d == name) {
        format!("crates/{name}")
    } else if ROOT_WORK_AREAS.iter().any(|d| *d == name) {
        name.to_string()
    } else {
        eprintln!("unknown tree target: {name}");
        eprintln!("use one of: {} or {}", DOMAIN_DIRS.join(", "), ROOT_WORK_AREAS.join(", "));
        return Ok(2);
    };
    print_package_tree(&root, &rel, 5)?;
    Ok(0)
}

fn print_package_tree(root: &Path, rel: &str, max_depth: usize) -> io::Result<()> {
    let base = root.join(rel);
    if !base.exists() {
        println!("{rel}/ missing");
        return Ok(());
    }
    println!("{rel}/");
    let mut packages = Vec::new();
    collect_packages(&base, &mut packages)?;
    packages.sort_by(|a, b| a.0.cmp(&b.0));
    for (path, name) in packages {
        let depth = path.components().count();
        if depth > max_depth {
            continue;
        }
        let indent = "  ".repeat(depth.saturating_sub(1));
        println!("{indent}{}  ({name})", path.display());
    }
    println!();
    Ok(())
}

fn check_domain(args: &[String]) -> io::Result<u8> {
    if args.is_empty() {
        eprintln!("usage: cargo xtask check-domain <{}> [--all-targets]", DOMAIN_DIRS.join("|"));
        return Ok(2);
    }
    let domain = &args[0];
    if !DOMAIN_DIRS.iter().any(|allowed| *allowed == domain) {
        eprintln!("unknown domain: {domain}");
        eprintln!("allowed domains: {}", DOMAIN_DIRS.join(", "));
        return Ok(2);
    }
    let all_targets = args.iter().any(|arg| arg == "--all-targets");
    let root = repo_root()?;
    let dir = root.join("crates").join(domain);
    let mut packages = Vec::new();
    collect_packages(&dir, &mut packages)?;
    packages.sort_by(|a, b| a.1.cmp(&b.1));
    packages.dedup_by(|a, b| a.1 == b.1);
    if packages.is_empty() {
        eprintln!("no Cargo packages found under crates/{domain}");
        return Ok(1);
    }
    println!("checking domain `{domain}` ({} package(s))", packages.len());
    let mut cargo_args: Vec<String> = vec!["check".to_string()];
    for (_, pkg) in &packages {
        cargo_args.push("--package".to_string());
        cargo_args.push(pkg.clone());
    }
    if all_targets {
        cargo_args.push("--all-targets".to_string());
    }
    cargo_owned(&cargo_args)
}

fn collect_packages(dir: &Path, packages: &mut Vec<(PathBuf, String)>) -> io::Result<()> {
    if !dir.exists() {
        return Ok(());
    }
    for entry in fs::read_dir(dir)? {
        let entry = entry?;
        let path = entry.path();
        let name = entry.file_name().to_string_lossy().to_string();
        if name == "target" || name == ".git" || name == ".vendor-tmp" {
            continue;
        }
        if entry.file_type()?.is_dir() {
            let manifest = path.join("Cargo.toml");
            if manifest.exists() {
                if let Some(pkg_name) = package_name(&manifest)? {
                    let root = repo_root()?;
                    let rel = path.strip_prefix(root).unwrap_or(&path).to_path_buf();
                    packages.push((rel, pkg_name));
                }
            }
            collect_packages(&path, packages)?;
        }
    }
    Ok(())
}

fn package_name(manifest: &Path) -> io::Result<Option<String>> {
    let text = fs::read_to_string(manifest)?;
    let mut in_package = false;
    for raw in text.lines() {
        let line = raw.trim();
        if line.starts_with('[') {
            in_package = line == "[package]";
            continue;
        }
        if in_package && line.starts_with("name") {
            if let Some((_, value)) = line.split_once('=') {
                let value = value.trim().trim_matches('"');
                if !value.is_empty() {
                    return Ok(Some(value.to_string()));
                }
            }
        }
    }
    Ok(None)
}

fn status(strict: bool) -> io::Result<u8> {
    let root = repo_root()?;
    let mut failed = false;

    println!("sui-clean status");
    println!("repo: {}\n", root.display());

    check(&mut failed, "root Cargo.toml", root.join("Cargo.toml").exists());
    check(&mut failed, "GitHub CODEOWNERS", root.join(".github/CODEOWNERS").exists());
    check(&mut failed, "support docs", root.join("SUPPORT.md").exists() && root.join("CHANGELOG.md").exists() && root.join("RELEASE.md").exists());
    check(&mut failed, "gitattributes", root.join(".gitattributes").exists());
    check(&mut failed, "xtask member", file_contains(root.join("Cargo.toml"), "crates/runtime/xtask")?);
    check(&mut failed, "cargo xtask alias", file_contains(root.join(".cargo/config.toml"), "xtask =")?);
    check(&mut failed, "xtask under crates/runtime", root.join("crates/runtime/xtask/Cargo.toml").exists());
    check(&mut failed, "default members configured", file_contains(root.join("Cargo.toml"), "default-members")?);
    check(&mut failed, "root bench directory", root.join("bench").exists());
    check(&mut failed, "root tests directory", root.join("tests").exists());
    check(&mut failed, "root tools directory", root.join("tools").exists());
    check(&mut failed, "bench/tests/tools outside crates", !root.join("crates/bench").exists() && !root.join("crates/tests").exists() && !root.join("crates/tools").exists());
    let domain_layout_ok = layout_ok(&root, &mut failed)?;
    check(&mut failed, "domain layout", domain_layout_ok);
    check(&mut failed, "Windows RocksDB cstdint flag", file_contains(root.join(".cargo/config.toml"), "CXXFLAGS_x86_64_pc_windows_gnu")?);
    check(&mut failed, "Windows bindgen libclang path", file_contains(root.join(".cargo/config.toml"), "LIBCLANG_PATH")?);
    check(&mut failed, "Windows libclang helper", root.join("scripts/lib/repair-windows-bindgen-libclang.ps1").exists());
    check(&mut failed, "single repair-windows wrapper", root.join("scripts/repair-windows.bat").exists() && root.join("scripts/repair-windows.sh").exists());
    check(&mut failed, "build/test/clean scripts", root.join("scripts/build.bat").exists() && root.join("scripts/test.bat").exists() && root.join("scripts/clean.bat").exists());
    check(&mut failed, "typed-store Windows-safe RocksDB", typed_store_windows_safe(&root)?);
    check(&mut failed, "workspace inheritance audit", root.join("scripts/lib/audit-workspace-inheritance.py").exists());
    check(&mut failed, "direct path audit", root.join("scripts/lib/audit-direct-paths.py").exists());
    let root_clutter = root_clutter_ok(&root, &mut failed)?;
    check(&mut failed, "root clutter", root_clutter);
    check(&mut failed, "no generated reports root", !root.join("reports").exists());
    check(&mut failed, "legacy manifests absent from root", !root.join("_manifest").exists());

    let move_core = root.join("crates/execution/move-vm/move/crates/move-core-types/Cargo.toml");
    if move_core.exists() {
        check(&mut failed, "Move uint pin", file_contains(move_core, "uint = \"0.9.5\"")?);
    } else {
        println!("  skip  Move uint pin: move-vm source missing");
    }

    if strict {
        println!("\nstrict audit");
        for doc in REQUIRED_DOCS {
            check(&mut failed, doc, root.join(doc).exists());
        }
        check(&mut failed, "scripts/README.md", root.join("scripts/README.md").exists());
        for domain in DOMAIN_DIRS {
            check(&mut failed, &format!("crates/{domain}/README.md"), root.join("crates").join(domain).join("README.md").exists());
        }
    }

    println!();
    if failed {
        println!("status: FAIL");
        Ok(1)
    } else {
        println!("status: PASS");
        Ok(0)
    }
}

fn check(failed: &mut bool, name: &str, ok: bool) {
    println!("  {:<42} {}", name, if ok { "pass" } else { "FAIL" });
    if !ok {
        *failed = true;
    }
}

fn file_contains(path: impl AsRef<Path>, needle: &str) -> io::Result<bool> {
    match fs::read_to_string(path) {
        Ok(text) => Ok(text.contains(needle)),
        Err(err) if err.kind() == io::ErrorKind::NotFound => Ok(false),
        Err(err) => Err(err),
    }
}

fn typed_store_windows_safe(root: &Path) -> io::Result<bool> {
    let p = root.join("crates/storage/typed-store/Cargo.toml");
    let text = fs::read_to_string(p)?;
    Ok(text.contains("target_os = \"linux\"")
        && text.contains("features = [\"jemalloc\"]")
        && !text.contains("cfg(not(target_env = \"msvc\"))"))
}

fn root_clutter_ok(root: &Path, failed: &mut bool) -> io::Result<bool> {
    let mut ok = true;
    let mut entries: Vec<String> = Vec::new();
    for entry in fs::read_dir(root)? {
        let entry = entry?;
        let name = entry.file_name().to_string_lossy().to_string();
        entries.push(name);
    }
    entries.sort();
    for name in entries {
        if !ALLOWED_ROOT_ENTRIES.iter().any(|allowed| *allowed == name) {
            println!("    unexpected root entry: {name}");
            ok = false;
            *failed = true;
        }
    }
    Ok(ok)
}
