%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {[@var{A}, @var{info}] =} python_ipc_system (@dots{})
%% Private helper function for Python IPC.
%%
%% @var{A} is the resulting object, which might be an error code.
%%
%% @var{info} usually contains diagnostics to help with debugging
%% or error reporting.
%%
%% @code{@var{info}.prelines}: the number of lines of header code
%% before the command starts.
%%
%% @code{@var{info}.raw}: the raw output, for debugging.
%% @end deftypefn

function [A, info] = python_ipc_system(what, cmd, mktmpfile, varargin)

  persistent show_msg

  info = [];

  if (strcmp(what, 'reset'))
    show_msg = [];
    A = true;
    return
  end

  if ~(strcmp(what, 'run'))
    error('unsupported command')
  end

  verbose = ~sympref('quiet');

  if (verbose && isempty(show_msg))
    fprintf('OctSymPy v%s: this is free software without warranty, see source.\n', ...
            sympref('version'))
    disp('You are using the slower system() communications with SymPy.')
    disp('Warning: this will be *SLOW*.  Every round-trip involves executing a')
    disp('new python process and many operations involve several round-trips.')
    show_msg = true;
  end

  newl = sprintf('\n');

  %% Headers
  headers = python_header();

  %% load all the inputs into python as pickles
  s1 = python_copy_vars_to('_ins', true, varargin{:});

  % the number of lines of code before the command itself
  info.prelines = numel(strfind(headers, newl)) + numel(strfind(s1, newl));

  %% The actual command
  % cmd will be a snippet of python code that does something
  % with _ins and produce _outs.
  s2 = python_format_cmd(cmd);

  %% output, or perhaps a thrown error
  s3 = python_copy_vars_from('_outs');

  % join all the cell arrays with newlines
  s = strjoin([s1 s2 s3], newl);

  pyexec = sympref('python');
  if (isempty(pyexec))
    pyexec = 'python';
  end

  %% FIXME: Issue #63: with new regexp code on Matlab
  % workaround:
  % sympref python 'LD_LIBRARY_PATH="" python'
  % to prevent a conflict with the expat shipped with Matlab 2014a
  % See here with oracle
  % https://bugzilla.redhat.com/show_bug.cgi?id=821337
  % FIXME: make this the default on Matlab install?

  bigs = [headers s];

  if (~mktmpfile)
    %% paste all the commands into the system() command line
    % escaping: cmd or inputs might have \"
    % " -> \"
    % \" -> \\\"
    % \n -> \\n
    bigs = strrep(bigs, '\', '\\');
    bigs = strrep(bigs, '"', '\"');
    [status,out] = system([pyexec ' -c "' bigs '"']);
  else
    %% Generate a temp .py file then execute it with system()
    % can be useful for debugging, or if "python -c" fails for you
    fname = 'tmp_python_cmd.py';
    fd = fopen(fname, 'w');
    fprintf(fd, '# temporary autogenerated code\n\n');
    % we just added two more lines at the top
    info.prelines = info.prelines + 2;
    fputs(fd, bigs);
    fclose(fd);
    [status,out] = system([pyexec ' ' fname]);
  end

  if status ~= 0
    status
    out
    error('system() call failed!');
  end

  % there should be two blocks
  ind = strfind(out, '<output_block>');
  assert(length(ind) == 2)
  out1 = out(ind(1):(ind(2)-1));
  % could extractblock here, but just search for keyword instead
  if (isempty(strfind(out1, 'successful')))
    error('failed to import variables to python?')
  end
  A = extractblock(out(ind(2):end));
  info.raw = out;
