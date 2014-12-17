#include "analyse.h"

#include <iostream>
#include <stdio.h>
#include <bitset>
#include <cmath>

using namespace std;

static size_t octets = 0;

extern "C" int compile(Noeud* noeud, char* codeCompile);

// Prototype et POC
/*int compile(Noeud* noeud, char* codeCompile)
{
  if(noeud->type == TYPE_NOMBRE) {

    // PUSH
    char octet = 1 << 6; // Format 01
    codeCompile[octets++] = octet;
    codeCompile[octets++] = (noeud->valeur & 0x0000FF00);
    codeCompile[octets++] = (noeud->valeur & 0x000000FF);

    cout << "PUSH -> 1: " << bitset<8>(octet);
    cout << " 2: " << bitset<8>((noeud->valeur & 0x0000FF00));
    cout << " 3: " << bitset<8>((noeud->valeur & 0x000000FF));
    cout << " VAL: " << noeud->valeur << " NVP: " << octets << endl;
    return 3;

  } else if(noeud->type == TYPE_OPERATEUR) {

    int tailleCode = 0;

    // Operateur
    // On va generer le code petit a petit recursivement
    tailleCode += compile(noeud->gauche, codeCompile);
    tailleCode += compile(noeud->droite, codeCompile);

    // Creer l'operateur
    char octet = (2 << 5) + (noeud->valeur + 2 << 2) + (0 << 1) + 0;
    codeCompile[octets++] = octet;
    tailleCode++;

    // Output
    //cout << "OPPE -> 1: " << bitset<8>(octet) << " VAL: " << noeud->valeur << " NVP: " << octets << endl;
    return tailleCode;

  } else if(noeud->type == TYPE_VARIABLE) {
    // Non supporte pour le moment
    return 0;
  }
}*/

int main()
{
  // Lire une equation en entree
  string equation;
  cin >> equation;

  char* result = new char[equation.length()];

  // Faire l'arbre syntaxique
  shuntingYard((char*)equation.c_str(), result, equation.length());

  /*for(int i = 0; i < strlen(result); ++i) {
    cout << i << " - ";
    if(result[i] <= 10) {
      cout << (int)result[i];
    } else {
      cout << result[i];
    }
    cout << endl;
  }*/

  // Creer l'arbre
  Noeud* noeud =  makeTree(result);

  // Le compiler
  char* codeCompile = new char[equation.length()*4+2];
  int nombreOctetsCodeCompile = compile(noeud, codeCompile);

  for(int i = 0; i < nombreOctetsCodeCompile; ++i) {
    printf("%x\n", codeCompile[i]);
  }

  // WRITE
  codeCompile[nombreOctetsCodeCompile] = (4 << 3) + (1 << 0);
  nombreOctetsCodeCompile++;

  // HALT
  codeCompile[nombreOctetsCodeCompile] = 0;
  nombreOctetsCodeCompile++;

  // Afficher le nombre d'octets que prends le code compile
  cout << nombreOctetsCodeCompile << endl;

  // Afficher le contenu du code compile en Hexa
  for(int i = 0; i < nombreOctetsCodeCompile; ++i) {
    printf("%x\n", codeCompile[i]);
  }

  // Liberer l'espace utilise
  deleteTree(noeud);

  return 0;
}
