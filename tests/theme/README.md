# Theme lifecycle regressions

Run with a Cairo-backed development executable and its reconstructed source:

```bash
FC=/opt/local/bin/gfortran bash tests/theme/run.sh \
  "$PWD/work/macos-local/install/bin/grads" \
  "$PWD/work/macos-local/grads-2.2.3/src"
```

The runner uses the existing Fortran geographic fixture, never original data.
It retains the evidence under a new ignored `outputs/theme-test.*` directory.
For an executable outside an installation layout, set `GADDIR` to the matching
installed data/plug-in table directory before running.

- `state.c` includes the actual theme implementation. It checks the startup
  backend-pointer initialization order; unavailable display/printing fonts and
  absent backends fall back to Hershey. A whole-struct comparison verifies that
  experimental paper changes only its documented presentation fields. Palette
  definitions, levels, output selection, scale and aspect remain unchanged.
- `check.gs` starts without setting a theme, tests modern startup, clear/open
  override preservation, reset/reinit, classic, paper data-setting preservation,
  safe `q gxout` selection and the Shaded2/Shaded2b labels. It exports one modern
  PNG and paper PNG/PDF/SVG. Export existence is not a visual comparison; inspect
  `paper.png` and optionally the vector exports before accepting design changes.

Paper is a small opt-in preset, not a new rendering backend. It sets a white
background, generic sans-serif (or Hershey when unsupported), thin map/grid and
compact axis/text labels. It does not define colors, change colormaps, contour
levels, output selection or projection/aspect. Apply it before drawing, then
`clear` to start a white page. As usual, set per-plot contour levels after clear.
Use one font family per page until export completes.

`reset` and `reinit` return to modern/cividis/shaded defaults; reset preserves
the background and reinit returns it to black, maintaining that GrADS convention.
Explicit classic/modern leave background and gxout alone. Theme commands apply
presets, not saved snapshots of all styling. Individual `set` overrides remain
available, and clear/open do not reapply a theme.
