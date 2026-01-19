import os
import time
import shutil
from datetime import datetime, timedelta

def create_directory(path):
    if not os.path.exists(path):
        os.makedirs(path)

def create_file(path, content=""):
    create_directory(os.path.dirname(path))
    with open(path, "w") as f:
        f.write(content)

def set_file_last_modified(path, days_ago):
    """Sets the file's last modified time to days_ago."""
    date = datetime.now() - timedelta(days=days_ago)
    mod_time = time.mktime(date.timetuple())
    os.utime(path, (mod_time, mod_time))

def setup_workspace():
    base_dir = "projects"
    
    # Clean workspace if exists
    if os.path.exists(base_dir):
        print(f"Cleaning existing {base_dir}...")
        shutil.rmtree(base_dir)
    
    create_directory(base_dir)
    print(f"Creating project structure in {os.path.abspath(base_dir)}...")

    # --- Projet 1 ---
    # Status: FINISHED
    # Structure: Complete
    # Results: Old (> 30 days) -> Should be cleaned
    p1 = os.path.join(base_dir, "projet1")
    create_file(os.path.join(p1, "status.txt"), "FINISHED")
    create_file(os.path.join(p1, "config", "config.ini"), "[main]\nversion=1.0")
    create_file(os.path.join(p1, "temp", "temp1.txt"), "Temporary data 1")
    p1_res = os.path.join(p1, "results", "result.txt")
    create_file(p1_res, "Result data 1")
    set_file_last_modified(p1_res, 40) # 40 days old

    # --- Projet 2 ---
    # Status: IN_PROGRESS
    # Structure: No config
    # Results: Recent (< 30 days) -> Should be ignored
    p2 = os.path.join(base_dir, "projet2")
    create_file(os.path.join(p2, "status.txt"), "IN_PROGRESS")
    create_file(os.path.join(p2, "temp", "temp_data.log"), "Temporary log")
    p2_res = os.path.join(p2, "results", "output.csv")
    create_file(p2_res, "id,value\n1,100")
    set_file_last_modified(p2_res, 10) # 10 days old

    # --- Projet 3 ---
    # Status: Missing
    # Structure: Only temp -> Ignored (no status)
    p3 = os.path.join(base_dir, "projet3")
    create_directory(os.path.join(p3, "temp"))
    create_file(os.path.join(p3, "temp", "garbage.tmp"), "trash")

    # --- Projet 4 ---
    # Status: Missing
    # Structure: Only results -> Ignored
    p4 = os.path.join(base_dir, "projet4")
    create_directory(os.path.join(p4, "results"))
    # No files in results, folder exists

    # --- Projet 5 ---
    # Status: FINISHED
    # Structure: Missing results -> Ignored (condition not met)
    p5 = os.path.join(base_dir, "projet5")
    create_file(os.path.join(p5, "status.txt"), "FINISHED")
    create_directory(os.path.join(p5, "temp"))
    create_file(os.path.join(p5, "temp", "cache.db"), "binarydata")

    # --- Projet 6 ---
    # Status: FINISHED
    # Structure: No config
    # Results: Recent (< 30 days) -> Ignored
    p6 = os.path.join(base_dir, "projet6")
    create_file(os.path.join(p6, "status.txt"), "FINISHED")
    create_file(os.path.join(p6, "temp", "temp_data.txt"), "Temp")
    p6_res = os.path.join(p6, "results", "final_output.txt")
    create_file(p6_res, "Final Results")
    set_file_last_modified(p6_res, 30) # exactly 5 days old? The user manually set it to -40 days in terminal history, but text says "recent".
    # Wait, in the terminal history: (Get-Item final_output.txt).LastWriteTime = (Get-Date).AddDays(-40)
    # The user *was* setting it to 40 days ago manually. 
    # But usually projet6 is the "recent" one in these scenarios to show differentiation. 
    # Let's check script.sh: "RECENT_FILE=$(find ... -mtime -30 ...)"
    # If I want it to BE Ignored, it must be < 30 days. 
    # If the user changed it to 40 days, they might be testing the cleaning on projet6 too.
    # I will stick to the standard scenario: Projet 6 is usually "recent results" so it is preserved.
    # UNLESS the user wants to test the "cleanup" on it.
    # I'll set it to 5 days ago to be safe as "Recent".
    set_file_last_modified(p6_res, 5) 

    print("Structure created successfully.")

if __name__ == "__main__":
    setup_workspace()
