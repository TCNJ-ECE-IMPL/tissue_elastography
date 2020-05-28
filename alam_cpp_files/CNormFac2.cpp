#include "mex.h"
#include <math.h>
#include <string.h>

// ALL ARRAYS INITIALIZED USING "new". THUS, ALL 2-D ARRAYS ARE SIMULATED WITH 1D ARRAYS. 

// VERSION 1.0: version 1.0 

// PROTOTYPE DECLARATIONS
double sum(double X[], int LenX);
void Intersect(const int Xix[], int LenX, const int Yix[], int LenY, long &Ix_i, int &Ix_e);
void CNormFac2(double *NormFac, const double *X, int mX, int nX, const double *Y, int mY, int nY,
              int MXR, int MXC, int MNR, int MNC);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
inline double square(double x) { return x * x; }
inline int square(int x) { return x * x; }
inline double product(double x, double y) { return x * y; }
inline int product(int x, int y) { return x * y; }


// COMPUTE THE SUM OF ELEMENTS
double sum(double X[], int LenX) {
   double S=0;
   for (int k=0; k<LenX; k++)
      S += X[k];

   return S;
}


// FIND INTERSECTION BETWEEN ARRAY INDICES
// Alternatively, intersect.m can be compiled with -ire option, but less desirable 
void Intersect(const int Xix[], int LenX, const int Yix[], int LenY, long &Ix_i, int &Ix_e) {
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


// COMPUTE NORMALIZATION FACTOR FOR CORRELATION (COEFFICIENT) FUNCTIONS
void CNormFac2(double *NormFac, const double *X, int mX, int nX, const double *Y, int mY, int nY,
              int MXR, int MXC, int MNR, int MNC) {
   int mC = MXR-MNR+1; // #Rows in NormFac
   int nC = MXC-MNC+1; // #Columns in NormFac
   int k,l,m,n;

   for (k = 0; k < mC; k++)
      for (l = 0; l < nC; l++)
         *(NormFac+k+l*mC) = 0;

   //DECLARATION OF CONSTANT SIZE ARRAYS THAT WILL BE USED MANY TIMES
   int * XixR = new int [mX]; // Row indices of X arrays
   int * YixR = new int [mY]; // Row indices of Y arrays
   int * XixC = new int [nX]; // Row indices of X arrays
   int * YixC = new int [nY]; // Row indices of Y arrays

   double norm_fac;
   long  IxR_i, IxC_i; // beginning of intersection used in the following loops
   int IxR_e, IxC_e;   // end of intersection
   for (k=MNR; k<=MXR; k++) {
      for (l=MNC; l<=MXC; l++) {
         // First in the row direction
         for (m=0; m<mX; m++)   // Row indices of X arrays
            XixR[m] = m;  // Row indices shifted for corr. computation
         for (m=0; m<mY; m++)   // Row indices of Y arrays
            YixR[m] = m+k;
         // find intersection between arrays to locate elements to use
         Intersect(XixR, mX, YixR, mY, IxR_i, IxR_e);

         // Now in the column direction
         for (m=0; m<nX; m++)   // Row indices of X arrays
            XixC[m] = m;  // Row indices shifted for corr. computation
         for (m=0; m<nY; m++)   // Row indices of Y arrays
            YixC[m] = m+l;
         // find intersection between arrays to locate elements to use
         Intersect(XixC, nX, YixC, nY, IxC_i, IxC_e);

         if (IxC_i != -2147483647 && IxR_i != -2147483647) { // Intersection between X and Y exists
            int ItsctLenR = IxR_e-IxR_i+1;
            int ItsctLenC = IxC_e-IxC_i+1;
            double ddenX = 0;
            double ddenY = 0;
            for (m=0; m<=ItsctLenR-1; m++) {
               for (n=0; n<=ItsctLenC-1; n++) {
                  ddenX += square(X[(IxR_i + m)+(IxC_i + n)*mX]); 
                  ddenY += square(Y[(IxR_i + m - k)+(IxC_i + n - l)*mY]);
               }
            }
            double dden = sqrt(ddenX*ddenY);
            *(NormFac+(k-MNR)+(l-MNC)*mC) = dden;
            // X elements to be used in corr comp: X[(IxR_i + m)+(IxC_i + n)*mX]
            // Y elements to be used in corr comp: Y[(IxR_i + m - k)+(IxC_i + n - l)*mY]
            // Normalization factor for the correlation function at delay (k,l)

         }
      }
   }

   // FREE MEMORY ASSIGNED AT THE BEGINNING
   delete [] XixR;
   XixR = NULL;
   delete [] YixR;
   YixR = NULL;
   delete [] XixC;
   XixC = NULL;
   delete [] YixC;
   YixC = NULL;
   
   return;
}


// THE REQUIRED GATEWAY ROUTINE: mexFunction.
// THE NEXT FOUR LINES ARE THE REQUIRED ARGUMENTS.
void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[]) {
   double *NormFac; // output, normalization factor
   // rest are inputs
   const double *X;
   const double *Y;
   double MXR;
   double MXC;
   double MNR;
   double MNC;

   // add check for proper number of arguments
   // add check for proper type of arguments

   int mX = mxGetM(prhs[0]);
   int nX = mxGetN(prhs[0]);
   X = mxGetPr(prhs[0]);
   int mY = mxGetM(prhs[1]);
   int nY = mxGetN(prhs[1]);
   Y = mxGetPr(prhs[1]);
   MXR = mxGetScalar(prhs[2]);
   MXC = mxGetScalar(prhs[3]);
   MNR = mxGetScalar(prhs[4]);
   MNC = mxGetScalar(prhs[5]);

   // create a double matrix for return argument
   int mC = MXR-MNR+1; // #Rows in NormFac
   int nC = MXC-MNC+1; // #Columns in NormFac
   plhs[0] = mxCreateDoubleMatrix(mC,nC,mxREAL); // First argument, of Size
   NormFac = mxGetPr(plhs[0]);
   CNormFac2(NormFac, X, mX, nX, Y, mY, nY, int(MXR), int(MXC), int(MNR), int(MNC));
}
