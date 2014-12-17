gas -Av8 tp5pile.asm -o tp5pile.o
g++ tp5.cc tp5pile.o analyse.o -o tp5pile

# Clean up
rm -f tp5pile.o

# Prototype
#g++ tp5.cc analyse.o -o tp5
