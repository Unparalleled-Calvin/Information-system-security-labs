rm *.bin
rm attack
python3 exploit.py
gcc -o attack attack.c
attack
