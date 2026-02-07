import subprocess
import argparse
import sys
import os
import concurrent.futures
from typing import Iterable

# Mapping of machine identifiers to their SSH host and flake name.
# Add or edit entries as your deployment targets change.
MACHINES = {
    "zana": {"host": "ygg.zana.net.mariusdavid.fr", "name": "zana"},
    "marella": {"host": "192.168.1.79", "name": "marella"},
    "scrogne": {"host": "mariusdavid.fr", "name": "scrogne"},
}

def deploy_nebula(host: str, name: str):
    # copy nebula mesh VPN cert stuff
    # (can’t move after rebuild. It might not execute if nebula fail to start)
    # But the nebula-mariusnet might not exist yet...
    path_to_secrets = "ca/private/"
    crt_src = os.path.join(path_to_secrets, name + ".crt")
    key_src = os.path.join(path_to_secrets, name + ".key")
    ca_crt_src = os.path.join(path_to_secrets, "merged_ca.crt")
    with open(crt_src, "rb") as f:
        subprocess.run(
            ["ssh", f"root@{host}", "umask 077; cat > /secret/nebula-" + name + ".crt"],
            input=f.read(),
            check=True,
        )
    with open(key_src, "rb") as f:
        subprocess.run(
            ["ssh", f"root@{host}", "umask 077; cat > /secret/nebula-" + name + ".key"],
            input=f.read(),
            check=True,
        )
    with open(ca_crt_src, "rb") as f:
        subprocess.run(
            ["ssh", f"root@{host}", "umask 077; cat > /secret/nebula-ca.crt"],
            input=f.read(),
            check=True,
        )

    subprocess.run(
        ["ssh", f"root@{host}", "chown nebula-mariusnet /secret/nebula-ca.crt /secret/nebula-" + name + ".crt /secret/nebula-" + name + ".key"],
        check=True,
    )

def run_rebuild(host: str, name: str) -> None:
    nebula_error = None
    try:
        deploy_nebula(host, name)
    except Exception as e:
        nebula_error = e

    # deploy itself
    subprocess.run(
        [
            "nixos-rebuild",
            "switch",
            "--target-host",
            f"root@{host}",
            "--flake",
            f".#{name}",
        ],
        check=True,
    )

    if nebula_error is not None:
        raise nebula_error


def deploy_parallel(machines: Iterable[str], workers: int = 4) -> None:
    """Deploy multiple machines concurrently."""
    jobs = [(MACHINES[m]["host"], MACHINES[m]["name"]) for m in machines]
    with concurrent.futures.ProcessPoolExecutor(max_workers=workers) as pool:
        futures = {
            pool.submit(run_rebuild, host, name): m for (host, name), m in zip(jobs, machines)
        }
        for future in concurrent.futures.as_completed(futures):
            machine = futures[future]
            try:
                future.result()
                print(f"\033[32m[✓] Deployed {machine}\033[0m")
            except Exception as exc:
                print(f"\033[31m[✗] {machine} failed: {exc}\033[0m", file=sys.stderr)


def main() -> None:
    parser = argparse.ArgumentParser(description="Deploy one or more machines")
    parser.add_argument(
        "--machines",
        required=True,
        help="Comma‑separated list of machine names to deploy, or 'all'",
    )
    parser.add_argument(
        "--parallel",
        action="store_true",
        help="Enable parallel deployment (default off)",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=4,
        help="Number of parallel workers, used only when --parallel is set",
    )
    args = parser.parse_args()

    if args.machines == "all":
        target_machines = MACHINES.keys()
    else:
        target_machines = [m.strip() for m in args.machines.split(",") if m.strip()]

    unknown = [m for m in target_machines if m not in MACHINES]
    if unknown:
        print(f"Error: Unknown machine(s): {', '.join(unknown)}", file=sys.stderr)
        sys.exit(1)

    if args.parallel:
        deploy_parallel(target_machines, workers=args.workers)
    else:
        for machine in target_machines:
            info = MACHINES[machine]
            try:
                run_rebuild(info["host"], info["name"])
                print(f"\033[32m[✓] Deployed {machine}\033[0m")
            except Exception as exc:
                print(f"\033[31m[✗] {machine} failed: {exc}\033[0m", file=sys.stderr)


if __name__ == "__main__":
    main()
