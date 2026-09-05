# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal academic website for Constantinos Xenophontos, built with **Quarto** (1.10.x at
`/usr/local/bin/quarto`) and served by **GitHub Pages** as a user site. The repo name
`cxen/cxen.github.io` is load-bearing — a GitHub user site must exactly match the account name,
so don't rename it. History was deliberately wiped in Aug 2026 to restart from a clean Quarto
scaffold; there is nothing to migrate from the old rmarkdown site or from the abandoned
`cxenophontos.github.io` / `hugo-personal-website` template repos.

Content was populated on 2026-08-27 from verifiable sources only — the user's ORCID record
(0000-0001-9340-9566), public GitHub repos, and the user's master CV at
`~/Documents/Academia/_. Curriculum Vitae/CV_Constantinos Xenophontos_v3.4.md` (the file
version number increments; look for the newest; a copy sits in the companion folder's `cv-master/`). **That markdown CV is the source of truth for
`cv.qmd`** — when asked to update the CV, diff against it rather than editing facts by hand,
and never copy its Referees section (private contact details of other people) to the site.
Anything not verifiable is left as an `<!-- TODO -->` comment in the `.qmd`. Don't invent
biographical details, affiliations, dates, or publications; add a TODO and ask.

## Commands

```sh
quarto preview            # live-reloading local server
quarto render             # build to _site/ (git-ignored)
quarto publish gh-pages --no-prompt --no-browser   # deploy
```

There are no tests or linters. `quarto check` verifies the Quarto install if rendering
misbehaves.

## Branches and deployment

- `main` — Quarto source only. This is the only branch to edit.
- `gh-pages` — rendered output, written entirely by `quarto publish gh-pages`. **Never
  hand-edit or commit to it.** There is no GitHub Actions workflow; deploys are manual from
  the local machine via the publish command above.
- Deploy loop: edit `.qmd` on `main` → commit/push → `quarto publish gh-pages --no-prompt --no-browser`.
- Known quirk: GitHub Pages has failed to auto-rebuild after a source-branch change. If the
  live site looks stale after a successful publish, force a build before debugging anything
  else: `gh api -X POST repos/cxen/cxen.github.io/pages/builds`.

## Layout

Flat Quarto website project, no computations (no `_freeze`).

- `_quarto.yml` — site config. `project.render: ["*.qmd"]` is deliberate: it stops the
  git-ignored `TODO.md`/`NOTES.md` from being rendered as pages. Site-wide `bibliography`
  and `csl` live here so both `publications.qmd` and `cv.qmd` share them. Theme is
  `flatly`/`darkly` with `custom.scss` layered on both.
- `index.qmd` — homepage using Quarto's `about: template: trestles` (photo + links left,
  bio right). Contact links are in the `about.links` YAML, not the body.
- `publications.qmd` — two lists via the `multibib` extension (`_extensions/pandoc-ext`,
  committed): `references.bib` → `#refs-articles`, `preprints.bib` → `#refs-preprints`, with
  `citeproc: false` and `validate-yaml: false` (the filter runs citeproc itself). `cv.qmd`
  uses the site-wide `references.bib` alone with `nocite: '@*'` + `::: {#refs}`, so the PDF
  lists peer-reviewed articles only. **Add papers to the right `.bib`, never as hand-written
  HTML.** `assets/apa-cv.csl` (APA CV variant: no in-text keys, DOIs linked) does the
  formatting. Page-level `description:` is emitted as the `<meta>` description and hidden
  from the title block by `custom.scss`.
- `cv.qmd` renders HTML *and* a Typst PDF (`Constantinos-Xenophontos-CV.pdf`). The PDF link
  is a `.cv-download` button in an HTML-only block under the title, with `format-links:
  false` (Quarto's own format link and `other-links` sidebar were dropped: the sidebar entry
  was too small for the page's main action, and a custom `format-links` entry produced a
  duplicate default "Typst" link). `citeproc: true` on the typst format is required — Typst's
  native bibliography ignores the `#refs` div and leaves Publications empty.
- CV rows are `::::: {.columns .cv-entry}` with two `.column` children: `.cv-when` (date,
  `width="16%"`) and the entry, whose secondary line is a `[...]{.cv-detail}` span. In HTML
  this is Quarto's inline-block columns + `custom.scss` (stacks below 576px). Quarto emits
  only nested `#block[]` for `.columns` in Typst, so `assets/cv-typst.lua` (Typst-only)
  rewrites each `.cv-entry` into a `#grid(columns: (7.5em, 1fr), ...)`, `.cv-detail`
  into smaller grey text, and the `.cv-photo` image into a `#place(top + right, ...)` beside
  the title. Keep the two-column structure or the filter falls through.
- `software.qmd` + `software.yml` — a Quarto `listing` (grid) fed by the YAML. Add a tool by
  adding an item to `software.yml`. Private repos get `subtitle: Private repository` and no
  `path:`; Quarto still wraps such cards in an empty `<a>`, so `assets/unlink-cards.html`
  (included after the body) unwraps them and adds `.card-unlinked` for the dashed border.
- `custom.scss` — single accent colour (`$accent`; lifted to `#45b5ad` in the dark theme so
  links pass WCAG AA on `#222`), translucent navbar, pill-style about links, `.tagline` and
  `.recent` on the homepage, `.cv-entry` rows, `.cv-download` button, listing cards.
  Site-wide overrides go here, not a `.css`. Lato is self-hosted from `fonts/` (woff2,
  `$web-font-path: false` disables Bootswatch's Google Fonts import); Quarto copies the
  files next to the compiled CSS, so the `@font-face` URLs are relative to `site_libs/`.
- `assets/email.html` — included after the body on every page. The contact address is **not**
  written anywhere in the HTML sources: navbar and about links use `href: "#email"` and this
  script rewrites them to a `mailto:` from a ROT13 string at load time (anti-scraping). To
  change the address, regenerate the ROT13 string in this file and update the plain-text
  contact line in `cv.qmd` (Typst-only block — the PDF does carry the address in clear).
- `_extensions/schochastics/academicons` — provides `{{< ai orcid >}}` etc. for the ORCID
  icon in the navbar and about links (Bootstrap Icons has no ORCID glyph). Committed.
- `images/profile.jpg` — the site portrait (2024 Humanitas photo, 1200px), used by the
  homepage and the CV page/PDF. Full-size originals live in the private notes repo (below).
  To change it: `sips -s format jpeg -Z 1200 <original> --out images/profile.jpg`. Never put
  originals in `images/` — everything there is published. (`_photos/`, `TODO.md`, `NOTES.md`
  stay in `.gitignore` as a safety net, but nothing should live there any more.)

## Private companion folder

**`~/GitHub/instructions-and-notes/personal-webpage/`** (private repo `cxen/instructions-and-notes`)
holds everything about the site that must not be public: `TODO.md` (decisions, content
roadmap, design direction, inspiration sites — read it before content or design work and
update it rather than duplicating its lists), `photos/` (portrait originals), `cv-master/`
(copy of the master CV markdown incl. referees), and a deploy cheat-sheet. Commit changes
there with the repo's `topic: description` message style (`personal-webpage: …`).

## Design rules (from the companion `TODO.md` — check there for current state)

- Name/role and the research pitch stay in the first viewport; no full-bleed hero.
- One restrained accent colour; avoid template boilerplate.
- The PhD (FSU Jena/iDiv, research period 2016–2020) is **not yet awarded** as of 2026-08-27 —
  the CV says "PhD researcher" and the bio says "doctoral research", not "completed my PhD".
  Don't add an award year.
- Prose style: no em dashes anywhere in site text (use commas, colons or a new sentence).
- Open items: footer accessibility statement, custom domain (undecided — no `CNAME`).
  `FriendChip` and `plate-functions` are private repos; their cards are marked private and
  unlinked until they are made public (add `path:`, drop `subtitle:`). The homepage `Recent`
  list is hand-maintained: keep it to the three or four newest items.
