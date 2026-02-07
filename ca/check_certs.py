import subprocess
import os
import json
import datetime
import sys
# credit to gpt-oss:20b

UNMERGED_CA_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "./private/valid-ca")

# Yellow text ANSI escape code
YELLOW = "\033[93m"
RESET = "\033[0m"

def main() -> None:
    has_valid_long = False
    for filename in os.listdir(UNMERGED_CA_FOLDER):
        if not filename.lower().endswith(".crt"):
            continue
        cert_path = os.path.join(UNMERGED_CA_FOLDER, filename)

        # This will raise CalledProcessError if nebula-cert fails
        result = subprocess.run(
            ["nebula-cert", "print", "-path", cert_path, "-json"],
            capture_output=True,
            text=True,
            check=True,
        )
        # This will raise JSONDecodeError if output is invalid
        cert_json = json.loads(result.stdout)

        # Access the notAfter field directly
        not_after_str = cert_json[0]["details"]["notAfter"]
        not_after = datetime.datetime.fromisoformat(not_after_str)

        now = datetime.datetime.now(tz=not_after.tzinfo)
        threshold = now + datetime.timedelta(days=90)

        if not_after <= now:
            print(f"{YELLOW}WARNING: Certificate {cert_path} expired on {not_after_str}{RESET}")
        else:
            print(f"Certificate {cert_path} is valid until {not_after_str}")
            if not_after > threshold:
                has_valid_long = True

    # Exit code logic: 0 if any certificate stays valid for >3 months
    # Non‑zero positive exit code otherwise
    if has_valid_long:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
