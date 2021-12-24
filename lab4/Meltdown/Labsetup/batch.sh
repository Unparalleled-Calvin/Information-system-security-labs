make
sudo insmod MeltdownKernel.ko
dmesg | grep 'secret data address'
