make clean
make
echo Part A
echo Task 3
./exploit.py --length 32 --start 304 --ret 0xffffcb3c --offset 112 --task 3
./stack-L1
echo Task 4
./exploit.py --length 32 --start 432 --ret 0xffffcbbc --offset 112 --task 4
./stack-L2
echo Task 5
./exploit.py --length 64 --start 432 --ret 0x7fffffffde80 --offset 216 --task 5
./stack-L3
echo Task 6
./exploit.py --length 64 --start 432 --ret 0x7fffffffde86 --offset 18 --task 6
./stack-L4
echo That\'s all.
echo Thank you!
