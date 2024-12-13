import subprocess
import time
import os
import shutil

BASE_BACKUP_DIR="~/testautobackup"

os.environ["LANG"] = "C"

while True:
        print("scanning...")
        try:
                out = subprocess.check_output(["dvdbackup", "--input=/dev/sr0", "--info"]).decode("utf-8")
        except Exception as e:
                print(e)
                print("error getting info")
                time.sleep(30)
                continue
        splitted = out.split("information of the DVD with title \"")
        if len(splitted) < 2:
                print("Couldn’t get DVD title")
                time.sleep(10)
                continue
        title = splitted[1].split("\n")[0][:-1]
        title = title.replace("/", "_").replace("\\", "_").replace("~", "_")
        print("detected " + title)
        out_dir = os.path.join(BASE_BACKUP_DIR, title)
        temp_dir = os.path.join(BASE_BACKUP_DIR, title + ".tmp")

        if os.path.exists(out_dir):
                print("disc already backed up in " + out_dir)
                time.sleep(30)
                continue
        if os.path.exists(temp_dir):
                assert title != "" # just extra safety
                shutil.rmtree(temp_dir)
        os.makedirs(temp_dir, exist_ok=True)
        try:
                subprocess.check_call(["dvdbackup", "--input=/dev/sr0", "--mirror", "-o", temp_dir, "--progress"])
        except Exception as e:
                print("failed to perform the backup")
                time.sleep(60)
                continue

        copied_folder_name = os.listdir(temp_dir)[0]
        copied_temp_dir_name = os.path.join(temp_dir, copied_folder_name)
        os.rename(copied_temp_dir_name, out_dir)
        os.rmdir(temp_dir)
        print("tutke backed up")