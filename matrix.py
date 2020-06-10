import sys
from enum import Enum

debug = False
default_flags = dict(
  use_security=False,
  use_java=False,
  use_oci_ace_tao=False,
)

class Build:
  def __init__(self, ndk, api, arch=None, flags={}):
    self.ndk = ndk
    self.api = api
    self.arch = ("arm64" if api >= 21 else "arm") if arch is None else arch
    self.flags = default_flags.copy()
    self.flags.update(flags)

  def __str__(self):
    result = '{}-{}-{}'.format(self.ndk, self.arch, self.api)
    for k, v in self.flags.items():
      if k.startswith('use_'):
        flag = k[4:]
      else:
        flag = k
      if v != default_flags[k]:
        result += '-' + flag.replace('_', '-')
    return result

  def __repr__(self):
    return '<Build {}>'.format(str(self))

  def case_format(self, format_str, flag_convert):
    format_flags = {}
    for k, v in self.flags.items():
      format_flags[k] = flag_convert(v)
    return format_str.format(
      name=str(self), arch=self.arch, rev=self.ndk, api=self.api,
      **format_flags)


class Matrix:
  def __init__(self):
    self.ndks = []
    self.builds = []
    self.builds_by_ndk = {}
    self.skip_apis = [20, 25]
    self.apis = []

  def archs_for_build(self, ndk, api):
    archs = set()
    for build in matrix.builds_by_ndk[ndk]:
      if build.api == api:
        archs.add(build.arch)
    return archs

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
      flags = default_flags.copy()
      if i == 0 or i == last:
        flags.update(flags_on_edges)
      builds.append(Build(name, api, flags=flags))
    self.builds.extend(builds)
    if new_ndk:
      self.builds_by_ndk[name] = []
    self.builds_by_ndk[name].extend(builds)

matrix = Matrix()

# Matrix Definition ##########################################################
matrix.add_ndk("r21d", api_range=(16, 29),
  flags_on_edges=dict(
    use_security=True,
    use_java=True,
  ),
)
matrix.add_ndk("r21d", api_range=(16, 29),
  default_flags=dict(
    use_oci_ace_tao=True,
  ),
)
matrix.add_ndk("r20b", 16,                 28, 29)
matrix.add_ndk("r19c", 16,                 28)
matrix.add_ndk("r18b", 16,                 28)
matrix.add_ndk("r17c", 16,         26, 27, 28)
matrix.add_ndk("r15c", 16,     24, 26)
matrix.add_ndk("r14b", 16,     24)
matrix.add_ndk("r12b", 16, 21, 24)

if debug:
  for ndk in matrix.ndks:
    print(ndk)
    for build in matrix.builds_by_ndk[ndk]:
      print(' ', str(build))

def travis(matrix, file):
  for ndk in matrix.ndks:
    comment(file, Kind.TRAVIS, ndk, '========================================')
    for build in matrix.builds_by_ndk[ndk]:
      shell_boolean = lambda b: "true" if b else "false"
      print(build.case_format('''\
    - name: "{name}"
      env:
        - arch={arch}
        - ndk={rev}
        - api={api}''', shell_boolean), file=file)
      for k, v in build.flags.items():
        if v != default_flags[k]:
          print(build.case_format('''\
        - ''' + k + '''={''' + k + '''}''', shell_boolean), file=file)

def markdown(matrix, file):
  def print_row(cells):
    print('|', ' | '.join(cells), '|', file=file)
  # Print Table Header
  print_row(['NDK'] + list(map(str, matrix.apis)))
  print_row(['---'] * (len(matrix.apis) + 1))
  # Print Rows
  for ndk in matrix.ndks:
    cells = [ndk]
    for api in matrix.apis:
      archs = matrix.archs_for_build(ndk, api)
      cells.append(','.join(archs) if archs else '-')
    print_row(cells)

class Kind(Enum):
  TRAVIS = ('.travis.yml', '# {}', travis),
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

for kind in Kind:
  filename, before, after = read_file(kind)
  if debug:
    file_context = NullContext()
    file = sys.stdout
    print(kind, '################################################################')
  else:
    file_context = file = open(filename, 'w')
  with file_context:
    for line in before:
      print(line, end='', file=file)
    comment(file, kind, 'This part is generated by matrix.py')
    kind.value[0][2](matrix, file)
    for line in after:
      print(line, end='', file=file)
