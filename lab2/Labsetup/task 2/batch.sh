sudo sysctl -w fs.protected_symlinks=0
sudo sysctl fs.protected_regular=0
# sudo sysctl -w fs.protected_symlinks=1
gcc vulp.c -o vulp
gcc tool.c -o tool
sudo chown root vulp
sudo chmod 4755 vulp
sudo rm /tmp/XYZ
sudo rm /tmp/ABC
./tool & sh target_process.sh
