# 1: to check running mods
lsmod | grep nvidia
# 2: kill the running mods
lsmod | grep nvidia | awk '$1~/nvidia/ {print $1}' | xargs sudo rmmod
# if error about mod in use arises
# 3: use to list all processes
sudo lsof /dev/nvidia* 
# 4: use to list all unique PIDs only
sudo lsof /dev/nvidia* | awk '!seen[$2]++'
# 5: use to kill the processes and rerun 2
sudo lsof /dev/nvidia* | awk '!seen[$2]++' | awk '{print $2}' | grep '[0-9]' | xargs sudo kill -9
# 6: initialize the drivers
nvidia-smi
