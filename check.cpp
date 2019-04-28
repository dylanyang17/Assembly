#include<iostream>
#include<cstring>
#include<cstdio>
#include<algorithm>
#include<ctime>
using namespace std;

int rd(int l,int r){
	return (unsigned)rand()*rand()%(r-l+1)+l ;
}

FILE *input, *output ;
char inputName[]="a.in" , outputName[]="a.out" ;
int n , A[1005] ;

int writeInt(int a, FILE* file){
	return fwrite(&a, sizeof(int), 1, file) ;
}

int readInt(int &a, FILE* file){
	return fread(&a, sizeof(int), 1, file) ;
}

int main(){
	srand(time(NULL)+(long long)new int) ;
	for(int i=1;i<=1000000;++i){
		cout << "#" << i << ":" << '\n' ;
		//生成数据
		input  = fopen(inputName, "wb") ;
		int n=rd(5,10) ;
		writeInt(n, input) ;
		for(int i=1;i<=n;++i){
			A[i]=rd(1,10000) ;
			writeInt(A[i],input) ;
		}
		fclose(input) ;

		//执行并检查
		system("java -jar Mars4_5.jar BubbleSort.s > log") ;
		output = fopen(outputName,"rb") ;
		int a ;
		for(int i=1;i<=n;++i){
			if(!readInt(a,output) || a!=A[i]){
				cout << "Wrong answer!\n" ;
				return 0 ;
			}
		}
		if(readInt(a,output)){
			cout << "Longer than std.\n" ;
			return 0 ;
		}
		fclose(output) ;
		cout << "Accepted!!!\n" ;
		cout << '\n' ;
	}
	return 0 ;
}
