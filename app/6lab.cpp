#include<iostream>
#include<stdlib.h>
#include<cstdlib>
#include<omp.h>
#include<unistd.h>
#include<string>

int main(int argc, char** argv)
{
    setlocale(LC_ALL, "rus");
    int n, v,o;
    int **matA, **matB, **matC;
    std::string str="";
    str=argv[1];
    n=atoi(str.c_str());
    str="";
    str=argv[2];
    v=atoi(str.c_str());
    str="";
    str=argv[3];
    o=atoi(str.c_str());
    
    switch(o){
        case 1:
#pragma omp parallel num_threads(v)
{
     int **matA, **matB, **matC;
    matA=new int*[n];
    matB=new int*[n];
    matC=new int*[n];

for(int i=0;i<n;i++) 
{
    matA[i]=new int[n];
    matB[i]=new int[n];
    matC[i]=new int[n];
}
for (int i=0;i<n;i++) 
{
    for (int j=0;j<n;j++)    
    {
        matA[i][j]=rand()%10;
        matB[i][j]=rand()%10;
        
    } 
}

     #pragma omp for 
   for(int i=0;i<n;i++) 
    {
    for(int j=0;j<n;j++) 
        {
        matC[i][j]=0;
        for(int k=0;k<n;k++) 
            {
            matC[i][j]+=matA[i][k]*matB[k][j];
            } 
        }
   }  
}
            break;
        case 2:
    matA=new int*[n];
    matB=new int*[n];
    matC=new int*[n];

for(int i=0;i<n;i++) 
{
    matA[i]=new int[n];
    matB[i]=new int[n];
    matC[i]=new int[n];
}
for (int i=0;i<n;i++) 
{
    for (int j=0;j<n;j++)    
    {
        matA[i][j]=rand()%10;
        matB[i][j]=rand()%10;
        
    } 
}
#pragma omp parallel shared(matA, matB, matC, n) num_threads(v)
{
     #pragma omp for 
   for(int i=0;i<n;i++) 
    {
    for(int j=0;j<n;j++) 
        {
        matC[i][j]=0;
        for(int k=0;k<n;k++) 
            {
            matC[i][j]+=matA[i][k]*matB[k][j];
            } 
        }
   }  
}
            break;
        case 3:
              matA=new int*[n];
    matB=new int*[n];
    matC=new int*[n];

for(int i=0;i<n;i++) 
{
    matA[i]=new int[n];
    matB[i]=new int[n];
    matC[i]=new int[n];
}
for (int i=0;i<n;i++) 
{
    for (int j=0;j<n;j++)    
    {
        matA[i][j]=rand()%10;
        matB[i][j]=rand()%10;
        
    } 
}
omp_lock_t lock;
omp_init_lock(&lock);

#pragma omp parallel num_threads(v)
{
     #pragma omp for
   for(int i=0;i<n;i++) 
    {
    for(int j=0;j<n;j++) 
        {
        matC[i][j]=0;
        for(int k=0;k<n;k++) 
            {
           omp_set_lock(&lock);
            matC[i][j]+=matA[i][k]*matB[k][j];
            omp_unset_lock(&lock);
 
            } 
        }
   }  
}
            break;
        case 4:     matA=new int*[n];
    matB=new int*[n];
    matC=new int*[n];

for(int i=0;i<n;i++) 
{
    matA[i]=new int[n];
    matB[i]=new int[n];
    matC[i]=new int[n];
}
srand(time(0));
for (int i=0;i<n;i++) 
{
    for (int j=0;j<n;j++)    
    {
        matA[i][j]=rand()%10;
        matB[i][j]=rand()%10;
        
    } 
}

   for(int i=0;i<n;i++) 
    {
    for(int j=0;j<n;j++) 
        {
        matC[i][j]=0;
        for(int k=0;k<n;k++) 
            {
            matC[i][j]+=matA[i][k]*matB[k][j];
 
            } 
        }
   }  

break;
        default: std::cout<<"Вы ввели неверный пункт";
        exit (0);
    }
  /*  
   // srand(time(NULL));

*/

std::cout<<"Работа программы завершена "<<std::endl;
return 0;
}