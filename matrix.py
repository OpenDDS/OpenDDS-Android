#!/usr/bin/env python3

import sys
from enum import Enum
import re
from functools import cmp_to_key

debug = False
default_default_flags = dict(
  use_security=False,
  use_java=False,
  use_toolchain=False,
)


def get_matrices():
  def latest_ndk(matrix, extras=False):
    ndk = 'r22'
    maxapi = 30
    # Build all APIs using NDK directly with security and Java on max and min
    # APIs.
    matrix.add_ndk(ndk, api_range=(16, maxapi),
      flags_on_edges=dict(
        use_security=extras,
        use_java=extras,
      ),
    )
    # Build Max API using standalone toolchain.
    matrix.add_ndk(ndk, maxapi,
      default_flags=dict(
        use_toolchain=True,
      ),
    )

  # DOC Group master branch
  doc_group_master_matrix = Matrix(
    'doc_group_master', mark='M',
    ace_tao='doc_group_master',
  )
  latest_ndk(doc_group_master_matrix, extras=True)
  doc_group_master_matrix.add_ndk("r21d", 16, 29) # TODO: r21d is marked as an "LTS" so maybe test it more?
  doc_group_master_matrix.add_ndk("r20b", 16, 29)
  doc_group_master_matrix.add_ndk("r19c", 16, 28)
  doc_group_master_matrix.add_ndk("r18b", 16, 28,
    default_flags=dict(
      use_toolchain=True,
    ),
  )

  # DOC Group master ace6_tao2 branch
  doc_group_ace6_tao2_matrix = Matrix(
    'doc_group_ace6_tao2', mark='6',
    ace_tao='doc_group_ace6_tao2',
  )
  latest_ndk(doc_group_ace6_tao2_matrix)
  doc_group_ace6_tao2_matrix.add_ndk("r19c", 16, 28)
  doc_group_ace6_tao2_matrix.add_ndk("r18b", 16, 28,
    default_flags=dict(
      use_toolchain=True,
    ),
  )
  doc_group_ace6_tao2_matrix.add_ndk("r12b", 16, 24,
    default_flags=dict(
      use_toolchain=True,
    ),
  )

  # OCI ACE/TAO Latest Release
  oci_matrix = Matrix(
    'oci', mark='O',
    ace_tao='oci',
    use_toolchain=True,
  )
  latest_ndk(oci_matrix)

  return [
    doc_group_master_matrix,
    doc_group_ace6_tao2_matrix,
    oci_matrix,
  ]


class Build:
  builtin_properties = ['name', 'arch', 'ndk', 'api']

  def __init__(self, ndk, api, arch=None, flags={}):
    self.ndk = ndk
    self.api = api
    self.arch = ("arm64" if api >= 21 else "arm") if arch is None else arch
    self.flags = flags
    self.all_properties = self.builtin_properties + list(self.flags.keys())

  def __str__(self):
    result = '{}-{}-{}'.format(self.ndk, self.arch, self.api)
    for k, v in self.flags.items():
      if k.startswith('use_'):
        flag = k[4:]
      else:
        flag = k
      if k in default_default_flags and v != default_default_flags[k]:
        result += '-' + flag.replace('_', '-')
      elif isinstance(v, str):
        result += '-' + v.replace('_', '-')
    return result

  def __repr__(self):
    return '<Build {}>'.format(str(self))

  def case_format(self, format_str, flag_convert):
    format_flags = {}
    for k, v in self.flags.items():
      format_flags[k] = flag_convert(v)
    return format_str.format(
      name=str(self), arch=self.arch, ndk=self.ndk, api=self.api,
      **format_flags)


class Matrix:
  def __init__(self, name, mark=None, **default_flags):
    self.name = name
    self.mark = name[0] if mark is None else mark
    self.ndks = []
    self.builds = []
    self.builds_by_ndk = {}
    self.skip_apis = [20, 25]
    self.apis = []
    self.default_flags = default_default_flags.copy()
    self.default_flags.update(default_flags)

  def archs_for_build(self, ndk, api):
    archs = set()
    for build in matrix.builds_by_ndk[ndk]:
      if build.api == api:
        archs.add(build.arch)
    return archs

  def has_build_for(self, ndk, api):
    if ndk in self.builds_by_ndk:
      for build in self.builds_by_ndk[ndk]:
        if build.api == api:
          return True
    return False

  def add_ndk(self, name, *apis, api_range=None, default_flags={}, flags_on_edges={}):
    new_ndk = name not in self.ndks
    if new_ndk:
      self.ndks.append(name)
    builds = []
    api_list=list(apis)
    if api_range:
      for api in range(api_range[0], api_range[1] + 1):
        if api not in apis and api not in self.skip_apis:
          api_list.append(api)
    api_list.sort(reverse=True)
    self.apis = list(set(self.apis) | set(api_list))
    self.apis.sort()
    last = len(api_list) - 1
    for i, api in enumerate(api_list):
      flags = self.default_flags.copy()
      flags.update(default_flags)
      if i == 0 or i == last:
        flags.update(flags_on_edges)
      builds.append(Build(name, api, flags=flags))
    self.builds.extend(builds)
    if new_ndk:
      self.builds_by_ndk[name] = []
    self.builds_by_ndk[name].extend(builds)


def shell_value(value):
  if isinstance(value, bool):
    return "true" if value else "false"
  elif isinstance(value, str):
    return '"{}"'.format(value)
  else:
    raise TypeError('Unexpected Type: ' + repr(type(value)))

def fill_line(line, char, length = 80):
  if line:
    if (len(line) + 2 > length):
      return line
    line += ' '
    line += char * (length - len(line))
    return line
  return char * length


def github(matrices, file):
  for matrix in matrices:
    comment(file, Kind.GITHUB, fill_line(matrix.name, '='))
    for ndk in matrix.ndks:
      comment(file, Kind.GITHUB, fill_line(ndk, '-'))
      for build in matrix.builds_by_ndk[ndk]:
        first = True
        for prop in build.all_properties:
          if first:
            print('          - ', end='', file=file)
            first = False
          else:
            print('            ', end='',  file=file)
          print(build.case_format(prop + ': {' + prop + '}', shell_value), file=file)


ndk_regex = re.compile(r'^r(\d+)([a-z]?)(?:-beta(\d+))?$')
def compare_ndk(a, b):
  def convert(r):
    m = ndk_regex.match(r)
    if m is None:
      raise ValueError(r)
    r = m.groups()
    return (
      int(r[0]),
      0 if not r[1] else ord(r[1]) - ord('a'),
      None if r[2] is None else int(r[2]),
    )
  a = convert(a)
  b = convert(b)
  if a[0] == b[0]:
    if a[1] == b[1]:
      if a[2] is None and b[2] is None:
        return 0
      if a[2] is None and b[2] is not None:
        return 1
      elif a[2] is not None and b[2] is None:
        return -1
      elif a[2] > b[2]:
        return 1
      elif a[2] < b[2]:
        return -1
      else:
        return 0
    else:
      return 1 if a[1] > b[1] else -1
  else:
    return 1 if a[0] > b[0] else -1


def sort_ndks(ndks):
  return sorted(ndks, key=cmp_to_key(compare_ndk), reverse=True)


def markdown(matrices, file):
  def print_row(cells):
    print('|', ' | '.join(cells), '|', file=file)

  # Get All APIs
  apis = []
  for matrix in matrices:
    for api in matrix.apis:
      if api not in apis:
        apis.append(api)
  apis.sort()

  # Get All NDKs
  ndks = set()
  for matrix in matrices:
    for ndk in matrix.ndks:
      ndks |= {ndk}
  ndks = sort_ndks(list(ndks))

  # Print Legend
  for matrix in matrices:
    print('{} = {}'.format(matrix.mark, matrix.name), file=file)

  # Print Table Header
  print_row([''] + list(map(str, apis)))
  print_row(['---'] * (len(apis) + 1))
  # Print Rows
  for ndk in ndks:
    cells = [ndk]
    for api in apis:
      marks = []
      for matrix in matrices:
        if matrix.has_build_for(ndk, api):
          marks.append(matrix.mark)
      cells.append(','.join(marks) if marks else '-')
    print_row(cells)


class Kind(Enum):
  GITHUB = ('.github/workflows/matrix.yml', '# {}', github),
  MARKDOWN = ('README.md', '<!-- {} -->', markdown),


def get_comment(kind, *args, **kw):
  kind = Kind(kind)
  sep = kw['sep'] if 'sep' in kw else ' '
  return kind.value[0][1].format(sep.join(args))


def comment(file, kind, *args, **kw):
  print(get_comment(kind, *args, **kw), file=file, **kw)


def read_file(kind):
  kind = Kind(kind)
  begin = get_comment(kind, 'BEGIN MATRIX') + '\n'
  end = get_comment(kind, 'END MATRIX') + '\n'
  mode = 0
  before = []
  after = []
  filename = kind.value[0][0]
  with open(filename) as file:
    for line in file:
      if mode == 0:
        before.append(line)
        if line == begin:
          mode = 1
      elif mode == 1:
        if line == end:
          after.append(line)
          mode = 2
      else:
        after.append(line)
  return (filename, before, after)


class NullContext:
  def __enter__(self):
    pass
  def __exit__(self, *args):
    pass


matrices = get_matrices()
for matrix in matrices:
  if debug:
    print(matrix.name)
    for ndk in matrix.ndks:
      print(' ', ndk)
      for build in matrix.builds_by_ndk[ndk]:
        print('   ', str(build))


for kind in Kind:
  filename, before, after = read_file(kind)
  if debug:
    file_context = NullContext()
    file = sys.stdout
    print(fill_line(str(kind), '#'))
  else:
    file_context = file = open(filename, 'w')
  with file_context:
    for line in before:
      print(line, end='', file=file)
    comment(file, kind, 'This part is generated by matrix.py')
    kind.value[0][2](matrices, file)
    for line in after:
      print(line, end='', file=file)
