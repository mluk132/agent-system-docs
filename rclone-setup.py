#!/usr/bin/env python3
"""
Rclone Proton Drive Upload Helper
Uploads Docker images and artifacts to Proton Drive
"""

import subprocess
import sys
from pathlib import Path

def upload_to_proton(local_path, remote_folder):
    """Upload file/folder to Proton Drive using rclone"""
    cmd = ["rclone", "copy", local_path, f"proton:{remote_folder}"]
    try:
        subprocess.run(cmd, check=True)
        print(f"✅ Uploaded {local_path} to proton:{remote_folder}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to upload: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print("❌ rclone not found. Install with: sudo apt-get install rclone")
        print("Then configure: rclone config")
        sys.exit(1)

def check_rclone_configured():
    """Check if rclone is configured with proton remote"""
    try:
        result = subprocess.run(
            ["rclone", "listremotes"],
            capture_output=True,
            text=True,
            check=True
        )
        if "proton:" in result.stdout:
            return True
        else:
            print("❌ Proton remote not configured in rclone")
            print("Run: rclone config")
            return False
    except FileNotFoundError:
        print("❌ rclone not installed")
        return False

if __name__ == "__main__":
    if not check_rclone_configured():
        sys.exit(1)
    
    # Example usage
    if len(sys.argv) > 2:
        local_path = sys.argv[1]
        remote_folder = sys.argv[2]
        upload_to_proton(local_path, remote_folder)
    else:
        print("Usage: python3 rclone-setup.py <local_path> <remote_folder>")
        print("Example: python3 rclone-setup.py ./Dockerfile docker-images/myproject/")
