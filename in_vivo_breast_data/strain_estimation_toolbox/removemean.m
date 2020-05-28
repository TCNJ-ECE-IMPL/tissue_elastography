function y = removemean(x,dim)
%REMOVEMEAN removes mean from a vector or matrix
%   REMOVEMEAN(X) subtract the mean of X to make it a 
%   zero-mean signal. If X is a matrix, this operation 
%   is performed on a column-by-column basis. 
%   REMOVEMEAN(X,1) also does it column-by-column.
%   REMOVEMEAN(X,2) perform the mean subtraction on a 
%   row-by-row basis. To subtract the overall mean of 
%   a matrix, REMOVEMEAN(X,'overall') should be used.
%   REMOVEMEAN(X,'default') uses the default option.
%
%   See also: MEAN.

%	Author:	S. K. Alam
%	Email: kalam@rrinyc.org
%	Written: 09-28-98
%	Revised: 09-28-98
%	Version: 1.0

if nargin==1
   option='default';
elseif nargin==2
   if isstr(dim) % if option is passed
      option=dim;
      clear dim
   elseif dim==2
      option='rowop';
   elseif dim==1
      option='default';
   else
      error('Cannot operate beyond two dimensions')
   end
end

if strcmpi(option,'default')
   [rowX,colX]=size(x);
   y=x-ones(rowX,1)*mean(x);  % subtract the mean
elseif strcmpi(option,'overall')
   y=x-mean(mean(x));
elseif strcmpi(option,'rowop')
   x=x.';  % transpose data for rowwise operation
   [rowX,colX]=size(x);
   y=x-ones(rowX,1)*mean(x);  % subtract the mean
   y=y.';  % transpose results to get back proper dimension
else
   error('Unknown OPTION')
end
   