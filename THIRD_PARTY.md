# Third-party components

This repository vendors two unmodified helper scripts so a complete mpv setup
can be installed reproducibly:

- `extras/mpv/scripts/thumbfast.lua` from
  <https://github.com/po5/thumbfast> at commit
  `0f711de3138c9bd6718209d819ac54022c23ded2`, licensed under MPL-2.0. The
  license notice is retained at the top of the file and the full text is in
  `LICENSES/thumbfast-MPL-2.0.txt`.
- `extras/mpv/scripts/autocrop.lua` from
  <https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autocrop.lua> at
  commit `e76a35ec95b27f5cf2d27b043b5e2e0d90e468ae`. It is distributed under
  mpv's project licensing terms; see
  <https://github.com/mpv-player/mpv/blob/master/Copyright> and
  `LICENSES/mpv-LGPL-2.1.txt`.

`mpv-mpris` is not vendored. The installer uses the distribution package from
<https://github.com/hoyon/mpv-mpris>, which is MIT licensed.
