#include "mex.h"
#include <math.h>
#include <string.h>

// Version 2.0: Correlation function numerator and denominator are computed without creating 
//              new variables (e.g., Xs, Ys, XsSQ, YsSQ, XsYs) for faster execution


// PROTOTYPE DECLARATIONS
void Intersect(int Xix[], int LenX, int Yix[], int LenY, long &Ix_i, int &Ix_e);
void CompCorr(double C[], double X[], int LenX, double Y[], int LenY, 
              double MaxLag, double MinLag, char Option[]);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
inline double square(double x) { return x * x; }
inline int square(int x) { return x * x; }
inline double product(double x, double y) { return x * y; }
inline int product(int x, int y) { return x * y; }



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
void CompCorr(double C[], double X[], int LenX, double Y[], int LenY, 
              double MaxLag, double MinLag, char *Option) {
   int MXL=int(MaxLag);
   int MNL=int(MinLag);
   int LenC = MXL-MNL+1;
   int k,l;
 
   for (k = 0; k < LenC; k++)
      C[k] = 0;

   double norm_fac;
   long  Ix_i; // beginning of intersection used in the following loops
   int Ix_e;   // end of intersection
   int cff_flg = strcmp(Option,"coeff");
   if (cff_flg == 0) {  // Correlation coefficient function (normalized)
      for (k=MNL; k<=MXL; k++) {
         int * Xix = new int [LenX]; // Indices of X arrays
         for (l=1; l<=LenX; l++)
            Xix[l-1] = l-1;
         int * Yix = new int [LenY]; // Indices of Y arrays
         for (l=1; l<=LenY; l++)
            Yix[l-1] = l+k-1;  // Y indices shifted for corr. computation

         // find intersection between arrays to locate elements to use
         Intersect(Xix, LenX, Yix, LenY, Ix_i, Ix_e);
         delete [] Xix; // Free assigned memory
         delete [] Yix; // Free assigned memory

         if (Ix_i == -2147483647) { // No intersection exists
            C[k-MNL] = 0;
            continue;
         }
         int ItsctLen = Ix_e-Ix_i+1;

         // First, the numerator of the normalized correlation function delay k
         double dnum = 0;
         for (l=0; l<=ItsctLen-1; l++)
            dnum += product(X[Ix_i + l],Y[Ix_i + l - k]); 
         // X elements to be used in corr comp: X[Ix_i + l]
         // Y elements to be used in corr comp: Y[Ix_i + l - k]

         // Now, the denominator of the denominator correlation function delay k
         double ddenX = 0;
         double ddenY = 0;
         for (l=0; l<=ItsctLen-1; l++) {
            ddenX += square(X[Ix_i + l]); 
            ddenY += square(Y[Ix_i + l - k]); 
         }
         // sqrt(ddenX*ddenY) is denominator

         double dden = sqrt(ddenX*ddenY);
         if (dden == 0)
            C[k-MNL] = 0;
         else
            C[k-MNL] = dnum/dden;
      }
   }
   else {  // Unnormalized correlation function
      for (k=MNL; k<=MXL; k++) {
         int * Xix = new int [LenX]; // Indices of X arrays
         for (l=1; l<=LenX; l++)
            Xix[l-1] = l-1;
         int * Yix = new int [LenY]; // Indices of Y arrays
         for (l=1; l<=LenY; l++)
            Yix[l-1] = l+k-1;  // Y indices shifted for corr. computation

         // find intersection between arrays to locate elements to use
         Intersect(Xix, LenX, Yix, LenY, Ix_i, Ix_e);
         delete [] Xix; // Free assigned memory
         delete [] Yix; // Free assigned memory

         if (Ix_i == -2147483647) { // No intersection exists
            C[k-MNL] = 0;
            continue;
         }
         int ItsctLen = Ix_e-Ix_i+1;
         double dsum = 0;
         for (l=0; l<=ItsctLen-1; l++)
            dsum += product(X[Ix_i + l],Y[Ix_i + l - k]); 
         // X elements to be used in corr comp: X[Ix_i + l]
         // Y elements to be used in corr comp: Y[Ix_i + l - k]
         // dsum is unnormalized correlation function at delay k

         C[k-MNL] = dsum;
      }
   }
   return;
}


// THE REQUIRED GATEWAY ROUTINE: mexFunction.
// THE NEXT FOUR LINES ARE THE REQUIRED ARGUMENTS.
void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[]) {
   double *C; // output
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
   if (nrhs != 5) {
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
   // Now convert 'Option' to a C++ string
   int Olen = (mxGetM(prhs[4]) * mxGetN(prhs[4])) + 1;
   char * O = new char [Olen];
   if (O == NULL)
      mexErrMsgTxt("Not enough heap space for Option.");
   // Copy the string data from prhs[4] and place it into O
   int status = mxGetString(prhs[4], O, Olen); 
   if (status != 0)
      mexErrMsgTxt("Could not write Option to string.");

   // create a double matrix for return argument
   int M_C = MX-MN+1; // Size of C
   int N_C = 1;  // Column vector
   plhs[0] = mxCreateDoubleMatrix(M_C,N_C,mxREAL); // First argument, of Size
   C = mxGetPr(plhs[0]);
   CompCorr(C, X, LenX, Y, LenY, MX, MN, O);
   delete [] O;
}
