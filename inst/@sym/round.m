%% Copyright (C) 2016 Lagu
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
%% @deftypefn  {Function File} {@var{y} =} round (@var{x})
%% Symbolic round function.
%%
%% Example:
%% @example
%% @group
%% y = round(sym(-27)/10)
%%   @result{} y = -3
%% @end group
%% @end example
%%
%% @seealso{ceil, floor, fix, frac}
%% @end deftypefn

function y = round(x)
  y = uniop_helper (x, 'round');
end

%!test
%! d = 3/2;
%! x = sym('3/2');
%! f1 = round(x);
%! f2 = round(d);
%! assert (isequal (f1, f2))

%!test
%! D = [1.1 4.6; -3.4 -8.9];
%! A = [sym(11)/10 sym(46)/10; sym(-34)/10 sym(-89)/10];
%! f1 = round(A);
%! f2 = round(D);
%! assert( isequal (f1, f2))

%!test
%! d = sym(-11)/10;
%! c = -1;
%! assert (isequal (round (d), c))

%!test
%! d = sym(-19)/10;
%! c = -2;
%! assert (isequal (round (d), c))
