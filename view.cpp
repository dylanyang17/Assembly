#include<iostream>
#include<cstdio>
#include<cstring>
#include<algorithm>
using namespace std;

FILE *file ;
int main(int argc, char *argv[]){
	if(argc<2) {
		cout << "Please specify the file name.\n" ;
		return 0 ;
	}
	file = fopen(argv[1],"rb") ;
	if(file==NULL){
		cout << "An error occured while reading the file.\n" ;
		return 0 ;
	}
	int t;
	while(fread(&t,4,1,file)){
		cout << t << ' ' ;
	}
	cout << '\n' ;
	fclose(file) ;
	return 0 ;
}
