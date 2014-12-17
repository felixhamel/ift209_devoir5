/*
  Code pour la fonction compile.
  IFT209 - TP5

  Fait par :
   - Félix Hamel (14 080 665)

  Universite de Sherbrooke, Automne 2014
*/

.global compile
.section ".text"

compile:
  save    %sp,-128,%sp

  /* Initialisation */
  mov     %i1, %g2
  mov     0, %l4     ! Taille du code genere

  /* Lancer la compilation */
  mov     %i0,%o0
  call	  compileRec
  mov    	%i1,%o1

  mov    	%o0,%i0
  ret
  restore


/*
  Utilisation des registres
  --------------------------
  %l0 = type du noeud
  %l1 = valeur du noeud
  %l2 = adresse du noeud a gauche
  %l3 = adresse du noeud a droite
  %l4 = Taille du code generer
  %l5 = Creer instruction
  %l6 = Temporaire

  %g2 = Emplacement dans le tableau de char

  Entree :
  --------------------------
  %i0 = noeud courant (adresse)
  ~ %i1 = tableau de chars pour le code compile (Deja reçu dans compile)

  Sortie :
  --------------------------
  %i0 = Taille du code genere
*/

compileRec:
  /* %o -> %i (0-1) */
  mov   %o0, %i0
  mov   %o1, %i1
  mov   %o7, %i7

  /* Si jamais il n'y a pas de noeud, on ne va pas le lire */
  tst   %i0
  be    compileRecFin
  nop

  /* Extraire l'information du noeud */
  ld  [%i0], %l0              ! Type du noeud
  ld  [%i0+4], %l1            ! Valeur du noeud
  ld  [%i0+8], %l2            ! Adresse du noeud de gauche
  ld  [%i0+12], %l3           ! Adresse du noeud de droite

  /* DEBUG */
  set   noeud, %o0
  mov   %i0, %o1
  mov   %l0, %o2
  mov   %l1, %o3
  mov   %l2, %o4
  mov   %l3, %o5
  call  printf
  nop

  set   compileSwitch, %l6      ! Choisir quel operation faire
  umul  %l0, 4, %l7             ! Adresse
  jmp   %l6+%l7                 ! Sauter sur cette operation
  nop

/* Choisir quoi faire avec ce noeud */
compileSwitch:
  ba,a  compileNombre
  ba,a  compileOperateur
  ba,a  compileVariable

/* compiler le noeud si celui-ci est un nombre */
compileNombre:

  /* DEBUG */
  set   numero, %o0
  mov   %l1, %o1
  mov   %i0, %o2
  call  printf
  nop

  /* Format de l'instruction */
  mov   1, %l5              ! Format 01
  sll   %l5, 6, %l5
  stb   %l5, [%g2]          ! Conserver

  /* Deuxieme immediat de 16 bits */
  mov   0, %l5
  and   %l1, 0xFF, %l5
  stb   %l5, [%g2+2]          ! Conserver

  /* Premier immediat de 16 bits */
  mov   0, %l5
  srl   %l1, 8, %l1           ! Immediat de 13 bits oblige
  and   %l1, 0xFF, %l5
  stb   %l5, [%g2+1]          ! Conserver

  inc   3, %l4                ! + 3 octets
  inc   3, %g2                ! Emplacement dans le tableau de chars

  ba    compileRecFin
  nop

/* compiler le noeud si celui-ci est un operateur */
compileOperateur:

  /* DEBUG */
  set   operateur, %o0
  mov   %l1, %o1
  mov   %i7, %o2
  call  printf
  nop

  /* Conserver certaines informations */
  dec   4, %sp
  st    %o7, [%sp]
  dec   4, %sp
  st    %i7, [%sp]
  dec   4, %sp
  st    %i1, [%sp]
  dec   4, %sp
  st    %l3, [%sp]

  ld    [%sp], %l3
  inc   4, %sp
  ld    [%sp], %i1
  inc   4, %sp

  /* DEBUG i7 (o7) */
  set   debug, %o0
  mov   %sp, %o1
  mov   %l3, %o2
  mov   %i1, %o3
  mov   %o7, %o4
  mov   %i7, %o5
  call  printf
  nop

  /* compiler le noeud de gauche */
  mov   %l2, %o0
  mov   %i1, %o1
  call  compileRec            ! compiler le noeud de gauche
  nop

  add   %o0, %l4, %l4         ! Concerver le taille du code genere

  /* Recuperer certaines informations */
  ld    [%sp], %l3
  inc   4, %sp
  ld    [%sp], %i1
  inc   4, %sp

  set   debug2, %o0
  mov   %l3, %o1
  mov   %i1, %o2
  mov   %sp, %o3
  call  printf
  nop

  /* compiler le noeud de droite */
  mov   %l3, %o0
  mov   %i1, %o1
  call  compileRec            ! compiler le noeud de droite
  nop

  add   %o0, %l4, %l4         ! Concerver le taille du code genere

  /* Recuperer certaines informations */
  ld    [%sp], %i7
  inc   4, %sp
  ld    [%sp], %o7
  inc   4, %sp

  /* DEBUG i7 (o7) */
  set   debug, %o0
  mov   %sp, %o1
  mov   %l3, %o2
  mov   %i1, %o3
  mov   %i7, %o4
  mov   %o7, %o5
  call  printf
  nop

  /* Ajouter l'instruction de l'operateur */
  mov   2, %l5
  sll   %l5, 5, %l5
  mov   %l1, %l6
  add   %l6, 2, %l6
  sll   %l6, 2, %l6
  add   %l5, %l6, %l5         ! Creer l instruction

  stb   %l5, [%g2]            ! Conserver l instruction
  inc   1, %l4
  inc   1, %g2

  ba    compileRecFin
  nop


/* compiler le noeud si celui-ci est une variable */
compileVariable:
  set   variable, %o0
  call  printf
  nop


compileRecFin:
  set   suivi, %o0
  mov   %l4, %o1
  mov   %g2, %o2
  mov   %i7, %o3
  call  printf
  nop

  mov   %l4, %o0  ! Retour
  mov   %i7, %o7

  retl
  nop

.section ".rodata"
  .align  4

operateur:  .asciz "Compilation operateur : %d | i7 = %x\n"
numero:     .asciz "Compilation numero %d - Adresse : %d\n"
suivi:      .asciz "Taille code : %d  POS : %d | i7 = %x\n"
noeud:      .asciz "Noeud: %d, Type: %d, Valeur: %d, Gauche: %d, Droite: %d\n"
variable:   .asciz "Variable...\n"
addsortie:  .asciz "i7 = %x\n"
debug:      .asciz "sp = %x | l3 = %d | i1 = %d | o7 = %x | i7 = %x\n"
debug2:     .asciz "l3 = %x | i1 = %x | sp = %x \n"
