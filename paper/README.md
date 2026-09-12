# Paper Draft Package

This directory contains the first paper draft for the AdaptiveWidthMemoryPass
research artifact.

## Files

- `main.tex` - LaTeX source for the paper draft.
- `references.bib` - bibliography entries used by the draft.
- `tables/` - checked-in tables generated from the current metrics snapshot.

## Build

If a TeX distribution is installed:

```bash
cd paper
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

The draft intentionally avoids broad claims. Current evaluation numbers are from
the repository's fixtures and small C kernels, not a large external benchmark
suite.

