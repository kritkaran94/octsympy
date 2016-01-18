%% Copyright (C) 2016 Colin B. Macdonald and Lagu
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File}  {@var{r} =} intersect (@var{A}, @var{B})
%% @deftypefnx {Function File}  {@var{r} =} intersect (@var{A}, @var{B}, @dots{}, 'intervals')
%% Return the common elements of two sets.
%%
%% @seealso{union, setdiff, setxor, unique, ismember}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = intersect(varargin)


  if strcmp(varargin{nargin}, 'intervals')

    if nargin < 3
      r = varargin;
      return
    end
    
    while (iscell(varargin{1}))
      varargin = varargin{:};
    end

    varargin(nargin)=[];

    cmd = {
           'x = _ins'
           '#'
           'if isinstance(x[0], sp.Set):'
           '    t = x[0]'
           'elif not isinstance(x[0], sp.MatrixBase):'
           '    t = Interval(x[0], x[0])'
           'elif len(x[i]) == 1:'
           '    t = Interval(x[0], x[0])'
           'else:'
           '    t = Interval(*x[0])'
           '#'
           'for i in range(1, len(x)):'
           '    if isinstance(x[i], sp.Set):'
           '        t = t.intersect(x[i])'
           '    elif not isinstance(x[i], sp.MatrixBase):'
           '        t = Interval(x[i], x[i]).intersect(t)'
           '    elif len(x[i]) == 1:'
           '        t = Interval(x[i], x[i]).intersect(t)'
           '    else:'
           '        t = Interval(*x[i]).intersect(t)'
           'return t,'
          };

    r = python_cmd (cmd, varargin{:});
  
  else

    varargin = sym(varargin);

    cmd = {
           'for i in _ins:'
           '    if isinstance(i, sp.Set):'
           '        return 1,'
           'return 0,'
          };

    if python_cmd (cmd, varargin{:});
      r = intersect(varargin{:}, 'intervals');
      return
    end

    % FIXME: is it worth splitting out a "private/set_helper"?

    cmd = { 'a, b = _ins'
            'A = sp.FiniteSet(*(list(a) if isinstance(a, sp.MatrixBase) else [a]))'
            'B = sp.FiniteSet(*(list(b) if isinstance(b, sp.MatrixBase) else [b]))'
            'C = A.intersect(B)'
            'return sp.Matrix([[list(C)]]),' };

    r = python_cmd (cmd, varargin{:});
    r = horzcat(r{:});

    % reshape to column if both inputs are
    if (iscolumn(varargin{1}) && iscolumn(varargin{2}))
      r = reshape(r, length(r), 1);
    end

  end

end


%!test
%! A = sym([1 2 3]);
%! B = sym([1 2 4]);
%! C = intersect(A, B);
%! D = sym([1 2]);
%! assert (isequal (C, D))

%!test
%! % one nonsym
%! A = sym([1 2 3]);
%! B = [1 2 4];
%! C = intersect(A, B);
%! D = sym([1 2]);
%! assert (isequal (C, D))

%!test
%! % empty
%! A = sym([1 2 3]);
%! C = intersect(A, A);
%! assert (isequal (C, A))

%!test
%! % empty input
%! A = sym([1 2]);
%! C = intersect(A, []);
%! assert (isequal (C, sym([])))

%!test
%! % scalar
%! syms x
%! assert (isequal (intersect([x 1], x), x))
%! assert (isequal (intersect(x, x), x))

%!test
%! A = interval(sym(1), 3);
%! B = interval(sym(2), 5);
%! C = intersect(A, B);
%! assert( isequal( C, interval(sym(2), 3)))
