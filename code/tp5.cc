#include "analyse.h"

#include <iostream>
#include <stdio.h>


using namespace std;

int compile(Noeud* noeud, unsigned char* codeCompile)
{
  int nbBits = 0;
  if(noeud->type == 1) {
    nbBits += compile(noeud->gauche, codeCompile);
    nbBits += compile(noeud->droite, codeCompile);

    codeCompile[nbBits] = 2;
    codeCompile[nbBits] >> 4;
    codeCompile[nbBits] += (noeud->valeur & 0x0000FFFF) + 2;
    codeCompile[nbBits] >> 2;
    codeCompile[nbBits+1] = 0;
    codeCompile[nbBits+2] = 0;

    nbBits += 3;

  } else {
    // Ajouter le nombre
    codeCompile[nbBits+3] = (noeud->valeur & 0x000000FF);
    codeCompile[nbBits+2] = (noeud->valeur & 0x0000FF00);
    codeCompile[nbBits+1] = (noeud->valeur & 0x00FF0000);
    codeCompile[nbBits]   = 1;
    codeCompile[nbBits]   >> 5;
    codeCompile[nbBits]   += 0000; // PUSH
    codeCompile[nbBits]   >> 2;

    nbBits += 4;
  }

  return nbBits;
}

int main()
{
  cout << "Veuillez entrer une équation de nombre entier : ";

  // Lire une equation en entré
  string equation;
  cin >> equation;

  char* result = new char[equation.length()];

  // Faire l'arbre syntaxique
  shuntingYard((char*)equation.c_str(), result, equation.length());

  for(int i = 0; i < strlen(result); ++i) {
    cout << i << " - ";
    if(result[i] <= 10) {
      cout << (int)result[i];
    } else {
      cout << result[i];
    }
    cout << endl;
  }

  // Créer l'arbre
  Noeud* noeud =  makeTree(result);

  // Le compiler
  unsigned char* codeCompile = new unsigned char[equation.length()*4+2];
  int nombreOctetsCodeCompile = compile(noeud, codeCompile);

  cout << nombreOctetsCodeCompile << endl;

  // Afficher le contenu du code compilé en Hexa
  for(int i = 0; i < nombreOctetsCodeCompile; ++i) {
    printf("%x\n", codeCompile[i]);
  }

  return 0;
}
