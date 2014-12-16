#include "analyse.h"

#include <iostream>

using namespace std;

int main()
{
  char* orig = new char[7]{'(', '2', '+', '5', ')', '+', '3'};
  char* ret = new char[14];

  shuntingYard(orig, ret, 7);

  for(int i = 0; i < 14; ++i) {
    cout << ret[i] << endl;
  }

  return 0;
}
