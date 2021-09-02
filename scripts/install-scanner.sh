apt update
apt install clamav
clamscan --version

# Stop freshclam daemon
systemctl stop clamav-freshclam

# Manually update signatures db
freshclam
