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
  save    %sp,-96,%sp

  /* Initialisation */
  mov     %i1, %g2

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
  %l5 = Inconnu
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
  save  %sp,-96,%sp

  /* Initialisation */
  mov   0, %l4                  ! Taille du code genere

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
  /*set   noeud, %o0
  mov   %i0, %o1
  mov   %l0, %o2
  mov   %l1, %o3
  mov   %l2, %o4
  mov   %l3, %o5
  call  printf
  nop*/

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

  /* DEBUG */
  /*set   numero, %o0
  mov   %l1, %o1
  call  printf
  nop*/

  ba    compileRecFin
  nop

/* compiler le noeud si celui-ci est un operateur */
compileOperateur:
  /* compiler le noeud de gauche */
  mov   %l2, %o0
  mov   %i1, %o1
  call  compileRec            ! compiler le noeud de gauche
  nop

  add   %o0, %l4, %l4         ! Concerver le taille du code genere

  /* compiler le noeud de droite */
  mov   %l3, %o0
  mov   %i1, %o1
  call  compileRec            ! compiler le noeud de droite
  nop

  add   %o0, %l4, %l4         ! Concerver le taille du code genere

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

  /* DEBUG */
  /*set   operateur, %o0
  mov   %l1, %o1
  call  printf
  nop*/

  ba    compileRecFin
  nop


/* compiler le noeud si celui-ci est une variable */
compileVariable:
  set   variable, %o0
  call  printf
  nop


compileRecFin:
  /*set   suivi, %o0
  mov   %l4, %o1
  mov   %g2, %o2
  call  printf
  nop*/

  mov   %l4, %i0  ! Retour

  ret
  restore


.section ".rodata"
  .align  4

operateur:  .asciz "Compilation operateur : %d\n"
numero:     .asciz "Compilation numero %d\n"
suivi:      .asciz "Taille code : %d  POS : %d\n"
noeud:      .asciz "Noeud: %d, Type: %d, Valeur: %d, Gauche: %d, Droite: %d\n"
variable:   .asciz "Variable...\n"
