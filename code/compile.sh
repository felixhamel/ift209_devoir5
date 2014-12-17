gas -Av8 tp5.asm -o tp5.o
g++ tp5.cc tp5.o analyse.o -o tp5

# Clean up
rm -f tp5.o

# Prototype
#g++ tp5.cc analyse.o -o tp5
