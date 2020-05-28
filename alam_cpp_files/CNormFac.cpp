#include "mex.h"
#include <math.h>
#include <string.h>
#define pi (4*atan(1))

// VERSION 1.0: first release version


// PROTOTYPE DECLARATIONS
double sum(double X[], int length);
void Intersect(int Xix[], int LenX, int Yix[], int LenY, long &Ix_i, int &Ix_e);
void CNormFac(double NormFac[], double X[], int LenX, double Y[], int LenY, 
              double MaxLag, double MinLag);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
inline double square(double x) { return x * x; }
inline int square(int x) { return x * x; }
inline double product(double x, double y) { return x * y; }
inline int product(int x, int y) { return x * y; }


// COMPUTE THE SUM OF ELEMENTS
double sum(double X[], int length) {
   double S=0;
   for (int k=0; k<length; k++)
      S += X[k];

   return S;
}


// FIND INTERSECTION BETWEEN ARRAY INDICES
// Alternatively, intersect.m can be compiled with -ire option, but less desirable 
void Intersect(int Xix[], int LenX, int Yix[], int LenY, long &Ix_i, int &Ix_e) {
   if (Xix[0] > Yix[LenY-1]) { // No intersection
      Ix_i = -2147483647; // To denote this to be a useless index
      return;
   }
   else if (Xix[LenX-1] < Yix[0]) { // No intersection
      Ix_i = -2147483647; // To denote this to be a useless index
      return;
   }
   else if (Xix[0] > Yix[0]) {
      if (Xix[LenX-1] > Yix[LenY-1]) {
         Ix_i = Xix[0];
         Ix_e = Yix[LenY-1];
      }
      else {
         Ix_i = Xix[0];
         Ix_e = Xix[LenX-1];
      }
   }
   else {
      if (Xix[LenX-1] > Yix[LenY-1]) {
         Ix_i = Yix[0];
         Ix_e = Yix[LenY-1];
      }
      else {
         Ix_i = Yix[0];
         Ix_e = Xix[LenX-1];
      }
   }
}


// COMPUTE CORRELATION FUNCTIONS
void CNormFac(double NormFac[], double X[], int LenX, double Y[], int LenY, 
              double MaxLag, double MinLag) {
   int MXL=int(MaxLag);
   int MNL=int(MinLag);
   int LenC = MXL-MNL+1;
   int k,l,m,n;
 
   for (k = 0; k < LenC; k++)
      NormFac[k] = 0;

   //DECLARATION OF CONSTANT SIZE ARRAYS THAT WILL BE USED MANY TIMES
   int * Xix = new int [LenX]; // Indices of X arrays
   int * Yix = new int [LenY]; // Indices of Y arrays
   
   double norm_fac;
   long  Ix_i; // beginning of intersection used in the following loops
   int Ix_e;   // end of intersection
   for (k=MNL; k<=MXL; k++) {
      for (l=1; l<=LenX; l++)
         Xix[l-1] = l-1;
      for (l=1; l<=LenY; l++)
         Yix[l-1] = l+k-1;  // Y indices shifted for corr. computation

      // find intersection between arrays to locate elements to use
      Intersect(Xix, LenX, Yix, LenY, Ix_i, Ix_e);
      if (Ix_i == -2147483647) {continue;} // No intersection

      int ItsctLen = Ix_e-Ix_i+1;
         double ddenX = 0;
         double ddenY = 0;
         for (l=0; l<=ItsctLen-1; l++) {
            ddenX += square(X[Ix_i + l]); 
            ddenY += square(Y[Ix_i + l - k]); 
         }
         double dden = sqrt(ddenX*ddenY);
		 NormFac[k-MNL] = dden; 
         // X elements to be used in corr comp: X[Ix_i + l]
         // Y elements to be used in corr comp: Y[Ix_i + l - k]
         // Normalization factor for the correlation function at delay k

   }
   
   delete [] Xix; // Free assigned memory
   Xix = NULL;
   delete [] Yix; // Free assigned memory
   Yix = NULL;
   return;
}


// THE REQUIRED GATEWAY ROUTINE: mexFunction.
// THE NEXT FOUR LINES ARE THE REQUIRED ARGUMENTS.
void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[]) {
   double *NormFac; // output
   // rest are inputs
   double *X;
   double *Y;
   double MX;
   double MN;

   // Check number of arguments
   if (nlhs != 1) {
           mexPrintf("Number of output arguments: %d.\n",nlhs);
           mexErrMsgTxt("Number of output arguments should be 1.");
   }
   if (nrhs != 4) {
           mexPrintf("Number of input arguments: %d.\n",nrhs);
           mexErrMsgTxt("Number of input arguments should be 5.");
   }

   // add check for proper type of arguments

   int LenX = mxGetNumberOfElements(prhs[0]);   // Assume LenX by 1 vector
   int LenY = mxGetNumberOfElements(prhs[1]);   // Assume LenY by 1 vector
   X = mxGetPr(prhs[0]);
   Y = mxGetPr(prhs[1]);
   MX = mxGetScalar(prhs[2]);
   MN = mxGetScalar(prhs[3]);

   // create a double matrix for return argument
   int M_C = MX-MN+1; // Size of NormFac
   int N_C = 1;  // Column vector
   plhs[0] = mxCreateDoubleMatrix(M_C,N_C,mxREAL); // First argument, of Size
   NormFac = mxGetPr(plhs[0]);
   CNormFac(NormFac, X, LenX, Y, LenY, MX, MN);
}
