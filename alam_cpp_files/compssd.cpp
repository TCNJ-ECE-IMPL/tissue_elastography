#include "mex.h"
#include <math.h>
#include <string.h>
#include <stdlib.h>

//#define pi (4*atan(1))
const double PI = (4*atan(1));

// Version 1.1: sum-absolute-difference on the same line (for faster execution)


// PROTOTYPE DECLARATIONS
void Intersect(int Xix[], int LenX, int Yix[], int LenY, long &Ix_i, long &Ix_e);
void CompSSD(double S[], double X[], int LenX, double Y[], int LenY, 
              double MaxLag, double MinLag);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
inline double square(double x) { return x * x; }
inline int square(int x) { return x * x; }


// FIND INTERSECTION BETWEEN ARRAY INDICES
void Intersect(int Xix[], int LenX, int Yix[], int LenY, long &Ix_i, long &Ix_e) {
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


// COMPUTE SUM-SQUARE-DIFFERENCE FUNCTIONS
void CompSSD(double S[], double X[], int LenX, double Y[], int LenY, 
              double MaxLag, double MinLag) {
   int MXL=int(MaxLag);
   int MNL=int(MinLag);
   int LenC = MXL-MNL+1;
   int k,l;
   
   //DECLARATION OF CONSTANT SIZE ARRAYS THAT WILL BE USED MANY TIMES
   int * Xix = new int [LenX];
   int * Yix = new int [LenY];
 
   //NO INITIALIZATION, BECAUSE NO INITIAL VALUE IS USED IN COMPUTATION
   //for (k = 0; k < LenC; k++)
   //   S[k] = 0;

   long Ix_i; // beginning of intersection used in the following loops
   long Ix_e;   // end of intersection
   for (k=MNL; k<=MXL; k++) {
      for (l=1; l<=LenX; l++)
         Xix[l-1] = l-1; // Indices of X arrays
      for (l=1; l<=LenY; l++)
         Yix[l-1] = l+k-1;  // Y indices shifted for corr. computation

      // find intersection between arrays to locate elements to use
      Intersect(Xix, LenX, Yix, LenY, Ix_i, Ix_e);
      if (Ix_i == -2147483647) {
         S[k-MNL] = 1.7977e+100; //largest floating point number on this machine/OS: 1.7977e+308
         continue;
      }
      int ItsctLen = Ix_e-Ix_i+1;
      double dsum = 0;
      for (l=0; l<=ItsctLen-1; l++)  // use the X and Y elements for delay = k
         dsum += square(X[Ix_i + l] - Y[Ix_i + l - k]); // SUM-SQUARE-DIFFERENCE at delay k
      S[k-MNL] = dsum;
   }
   delete [] Xix; // Free assigned memory
   delete [] Yix; // Free assigned memory
   return;
}


// THE REQUIRED GATEWAY ROUTINE: mexFunction.
// THE NEXT FOUR LINES ARE THE REQUIRED ARGUMENTS.
void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[]) {
   double *S; // output
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
           mexErrMsgTxt("Number of input arguments should be 4.");
   }

   // add check for proper type of arguments

   int LenX = mxGetNumberOfElements(prhs[0]);   // Assume LenX by 1 vector
   int LenY = mxGetNumberOfElements(prhs[1]);   // Assume LenY by 1 vector
   X = mxGetPr(prhs[0]);
   Y = mxGetPr(prhs[1]);
   MX = mxGetScalar(prhs[2]);
   MN = mxGetScalar(prhs[3]);

   // create a double matrix for return argument
   int M_C = MX-MN+1; // Size of S
   int N_C = 1;  // Column vector
   plhs[0] = mxCreateDoubleMatrix(M_C,N_C,mxREAL); // First argument, of Size
   S = mxGetPr(plhs[0]);
   CompSSD(S, X, LenX, Y, LenY, MX, MN);
}
