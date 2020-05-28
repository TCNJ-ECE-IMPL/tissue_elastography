#include "mex.h"
#include <math.h>
#define pi (4*atan(1))

// version 1.1: in this version, memory allocated for PhaseChangeR and PhaseChangeI are freed, so no memory leak. 

void phaseshiftR(double ScatSpecR[], double ScatSpecI[], double ScatAmpl[], double ScatPos[], double ScatSize, double Size);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

void phaseshiftR(double ScatSpecR[], double ScatSpecI[], 
                 double ScatAmpl[], double ScatPos[], double ScatSize, double Size) {
   int SizeHalf=int(Size/2);
   double * f_unit = new double [SizeHalf+1];
   
   int k;
   for (k = 0; k <=SizeHalf; k++)
      f_unit[k] = 2*pi*k/Size;
 
   for (k = 0; k < Size; k++) {
      ScatSpecR[k] = 0;
      ScatSpecI[k] = 0;
   }
   
   int iSize = (int) (Size + 0.5);
   double * PhaseChangeR = new double [iSize];
   double * PhaseChangeI = new double [iSize];

   int l;
   for (k = 0; k < ScatSize; k++) {
      for (l = 0; l <= SizeHalf; l++) {
         PhaseChangeR[l] = cos(ScatPos[k]*f_unit[l]);
         PhaseChangeI[l] = -sin(ScatPos[k]*f_unit[l]);
      }
      for (l = SizeHalf-1; l >= 1; l--) {
         PhaseChangeR[int(Size)-l] = PhaseChangeR[l]; // modify for odd Size
         PhaseChangeI[int(Size)-l] = -PhaseChangeI[l]; // modify for odd Size
      }
      for (l = 0; l < Size; l++) {
         ScatSpecR[l] = ScatSpecR[l] + ScatAmpl[k]*PhaseChangeR[l];
         ScatSpecI[l] = ScatSpecI[l] + ScatAmpl[k]*PhaseChangeI[l];
      }
   }
   delete [] PhaseChangeR; // free allocated memory to prevent memory leak
   delete [] PhaseChangeI; // free allocated memory to prevent memory leak
   PhaseChangeR = NULL; PhaseChangeI = NULL; // Clear a to prevent using invalid memory reference
   return;
}

// every mex file has to have a function called mexFunction.
// the next four lines are the required arguments.
void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[]) {
   double *SSR, *SSI; // outputs
   // rest are inputs
   double *SA;
   double *SP;
   double SS, S;
   unsigned int m, n;

   // add check for proper number of arguments
   // add check for proper type of arguments

   m = mxGetM(prhs[0]);
   n = mxGetN(prhs[0]);
   SA = mxGetPr(prhs[0]);
   SP = mxGetPr(prhs[1]);
   SS = mxGetScalar(prhs[2]);
   S = mxGetScalar(prhs[3]);  // Size

   // create double matrix for return argument
   plhs[0] = mxCreateDoubleMatrix(S,n,mxREAL); // First argument, of Size
   SSR = mxGetPr(plhs[0]);
   plhs[1] = mxCreateDoubleMatrix(S,n,mxREAL); // Second argument
   SSI = mxGetPr(plhs[1]);
   phaseshiftR(SSR, SSI, SA, SP, SS, S);

}
// End of file

//for ij=1:ScatSize
//   PhaseChangeR=cos(ScatPos(ij)*f_unit);
//   PhaseChangeI=-sin(ScatPos(ij)*f_unit);
//   PhaseChangeR=[PhaseChangeR' flipud(PhaseChangeR(2:SizeHalf))']';
//   PhaseChangeI=[PhaseChangeI' -flipud(PhaseChangeI(2:SizeHalf))']';
//   ScatSpecR=ScatSpecR+ScatAmpl(ij)*PhaseChangeR;
//   ScatSpecI=ScatSpecI+ScatAmpl(ij)*PhaseChangeI;
//end

