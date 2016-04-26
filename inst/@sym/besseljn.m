%% Copyright (C) 2016 Utkarsh Gautam 
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
%% @documentencoding UTF-8
%% @deftypefn  {Function File} {@var{Y} =} besseljn (@var{alpha}, @var{x})
%% Symbolic Spherical Bessel function of the first kind.
%%
%% Example:
%% @example
%% @group
%% syms n x
%% A = besseljn(n, x)
%%   @result{} A = (sym) jn(n, x)
%% diff(A)
%%   @result{} ans = (sym)
%%     
%%                      (n + 1)⋅jn(n, x)
%%       jn(n - 1, x) - ────────────────
%%                           x  
%% @end group
%% @end example
%%
%% @seealso{besselj, besseli, besselk, besselyn}
%% @end deftypefn

function Y = besseljn(n, x)
  if (nargin ~= 2)
    print_usage ();
  end
  Y = binop_helper(n, x, 'jn');
end


%!test
%! % roundtrip
%! if (python_cmd ('return Version(spver) >= Version("1.0")'))
%! syms x
%! A = double(besseljn(sym(2), sym(9)));
%! q = besseljn(sym(2), x);
%! h = function_handle(q);
%! B = h(9);
%! assert (abs (A - B) <= eps)
%! end

%!error jn(sym('x'))
