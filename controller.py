import os
import subprocess
import time

#TODO: make sure it work correctly, send SMTP message on failure
TIMER_WAIT_TIME = 60 * 2
TIME_BETWEEN_FULL_UPDATE = 15 * 60 # update interval
TIME_BETWEEN_SITE_UPDATE = 15 * 60 # update site 4 time per hour (doesn't work)
COOLDOWN_FAILED_UPDATE = 3600 * 24 # do not try to update for a day if an update failed
TIME_TO_WAIT_BEFORE_HTTP_CHECK = 60 # wait 1 minutes before checking if everything work well

NIX_DATA_DIR = "/etc/nixos/"
NIX_LOCK_FILE = os.path.join(NIX_DATA_DIR, "flake.lock")
NIX_LOCK_BACKUP = os.path.join(NIX_DATA_DIR, "flake.lock.bak")
INDICATOR_RESTORE_BACKUP = os.path.join(NIX_DATA_DIR, "restore_backup_on_controller_start")

def get_backup_on_start():
    return os.path.isfile(INDICATOR_RESTORE_BACKUP)

def use_backup_on_start(use):
    if use:
        subprocess.check_call(["touch", INDICATOR_RESTORE_BACKUP])
    else:
        subprocess.check_call(["rm", INDICATOR_RESTORE_BACKUP])

def restore_lock_backup():
    subprocess.check_call(["cp", NIX_LOCK_BACKUP, NIX_LOCK_FILE])

def switch_test():
    subprocess.check_call(["nixos-rebuild", "test"])

def switch_boot():
    subprocess.check_call(["nixos-rebuild", "boot"])

def check_everything_work():
    wait(TIME_TO_WAIT_BEFORE_HTTP_CHECK)
    try:
        subprocess.check_call(["curl", "localhost"])
        return True
    except:
        return False

def save_current_lock_as_backup_lock():
    subprocess.check_call(["cp", NIX_LOCK_FILE, NIX_LOCK_BACKUP])

def timestamp():
    return time.time()

def full_lock_refresh():
    use_backup_on_start(True)
    subprocess.check_call(["nix", "flake", "update", NIX_DATA_DIR])

def site_lock_refresh():
    use_backup_on_start(True)
    #for some reason, this command doesn't work
    subprocess.check_call(["nix", "flake", "update", NIX_DATA_DIR, "--update-input", "github:marius851000/pmd_hack_weekly"])

def reboot():
    subprocess.check_call(["reboot"])

def wait(duration, log = True):
    if log:
        print("sleeping for {} second".format(duration))
    time.sleep(duration)

def backup_and_current_lock_are_same():
    try:
        subprocess.check_call(["cmp", "-s", NIX_LOCK_BACKUP, NIX_LOCK_FILE])
        print("not switching, as there is no change in the lock file")
        return True
    except:
        return False





def restore_previously_working_version():
    print("restoring previously working version")
    restore_lock_backup()
    switch_test()
    use_backup_on_start(False) #if rebooting, will reboot in a working version anyway
    print("restoration finished")
    if not check_everything_work():
        print("doesn't worked. Rebooting (in 3 minutes)...")
        wait(180)
        reboot()

def switch_after_flake_update(): #TODO: check if the backup is indentical to the current, in which case return True
    print("testing new configuration")
    if backup_and_current_lock_are_same():
        return True
    use_backup_on_start(True)
    switch_test()
    print("switched, testing...")
    if check_everything_work():
        print("new configuration work ! backuping it, and make it default boot.")
        save_current_lock_as_backup_lock()
        switch_boot()
        use_backup_on_start(False)
        print("done !")
        return True
    else:
        print("new configuration doesn't work. Rolling back.")
        restore_previously_working_version()
        return False

def main():
    print("controller started")
    do_not_perform_full_update_for = 0

    if get_backup_on_start():
        restore_previously_working_version()
        do_not_perform_full_update_for = INDICATOR_RESTORE_BACKUP
    
    timer_full_update = TIME_BETWEEN_FULL_UPDATE + 1
    timer_site_update = TIME_BETWEEN_SITE_UPDATE + 1

    while True:
        time_at_loop_start = timestamp()

        if timer_full_update > TIME_BETWEEN_FULL_UPDATE:
            if do_not_perform_full_update_for <= 0:
                print("trying to update system")
                full_lock_refresh()
                if not switch_after_flake_update():
                    do_not_perform_full_update_for = INDICATOR_RESTORE_BACKUP
            timer_full_update = 0
            timer_site_update = 0
        
#        if timer_site_update > TIME_BETWEEN_SITE_UPDATE:
#            print("trying to update site")
#            site_lock_refresh()
#            switch_after_flake_update()
#            timer_site_update = 0

        loop_time = timestamp() - time_at_loop_start


        wait(TIMER_WAIT_TIME, False)
        loop_total_time = TIMER_WAIT_TIME + loop_time
        timer_full_update += loop_total_time
        timer_site_update += loop_total_time
        do_not_perform_full_update_for -= loop_total_time

        print("time since last system update: {}, since last site update: {}".format(timer_full_update, timer_site_update))
    

if __name__ == "__main__":

    while True:
        try:
            main()
        except Exception as e:
            print("main thread crashed !")
            print(e)
            wait(120)

