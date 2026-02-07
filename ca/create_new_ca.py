import subprocess
import os
import json
import datetime
import shutil

# Paths
UNMERGED_CA_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "./private/valid-ca")
MERGED_CA_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "./private/merged_ca.crt")
LATEST_CA_KEY_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "./private/latest_ca.key")
LATEST_CA_CRT_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "./private/latest_ca.crt")

# Ensure the CA folder exists
os.makedirs(UNMERGED_CA_FOLDER, exist_ok=True)

# Remove any pre‑existing CA files from the current directory
for old in ("ca.key", "ca.crt"):
    if os.path.exists(old):
        os.remove(old)

# 1. Create a new CA
subprocess.run(
    # 1 year.
    ["nebula-cert", "ca", "-name", "Marius net", "-duration", "8760h"],
    check=True,
)

# 2. Read the expiration date of the new certificate
result = subprocess.run(
    ["nebula-cert", "print", "-path", "ca.crt", "-json"],
    capture_output=True,
    text=True,
    check=True,
)
cert_json = json.loads(result.stdout)
# The output is a list; the first element contains the details
not_after_str = cert_json[0]["details"]["notAfter"]
not_after_dt = datetime.datetime.fromisoformat(not_after_str)
# Format: ca-YYYYMMDD_HHMMSS.crt
file_suffix = not_after_dt.strftime("%Y%m%d_%H%M%S")
crt_new_path = os.path.join(UNMERGED_CA_FOLDER, f"ca-{file_suffix}.crt")
key_new_path = os.path.join(UNMERGED_CA_FOLDER, f"ca-{file_suffix}.key")

# 3. Move the newly created cert and key into the folder with timestamped names
os.rename("ca.crt", crt_new_path)
os.rename("ca.key", key_new_path)

# 4. Concatenate all .crt files in the folder into the merged CA file
with open(MERGED_CA_FILE, "w") as merged_out:
    for crt_file in sorted(
        f for f in os.listdir(UNMERGED_CA_FOLDER) if f.lower().endswith(".crt")
    ):
        crt_path = os.path.join(UNMERGED_CA_FOLDER, crt_file)
        with open(crt_path, "r") as src:
            merged_out.write(src.read() + "\n")

# 5. Copy the newly created key to the latest key file location
shutil.copy(key_new_path, LATEST_CA_KEY_FILE)
shutil.copy(crt_new_path, LATEST_CA_CRT_FILE)

print(f"Created new CA files:\n  {crt_new_path}\n  {key_new_path}")
print(f"Merged certificates written to {MERGED_CA_FILE}")
print(f"Latest key copied to {LATEST_CA_KEY_FILE}")
print(f"Latest certificate copied to {LATEST_CA_CRT_FILE}")
