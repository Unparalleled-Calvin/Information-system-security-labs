gcc vulp.c -o vulp
gcc tool.c -o tool
sudo chown root vulp
sudo chmod 4755 vulp
sudo rm /tmp/XYZ
sudo rm /tmp/ABC
./tool & sh target_process.sh
