# vijitdua.com • archive • 2026-10-20

This is a static archive of vijitdua.com, built on 2026-10-20.

It's a read-only copy of the site, generated with vijitdua.com/archive. Some pages, images, and interactive features (forms, sign-in, media players) may be missing or not work.

If the live site is up, this archive redirects you to it automatically. You'll only see the archive if the live site is down, your connection is unstable, or whoever hosts this copy removed the redirect.

Why this exists: If vijitdua.com is ever retired or no longer maintained, either due to neglect, choice, or mine for whatever reason, this keeps a piece of Vijit's digital footprint readable a little longer.

A word of caution: Anyone can host a copy, and anyone can retroactively edit one. A copy is for reference but can't be authoritatively trusted.

I, Vijit, will also try to regularly keep a copy maintained at vijitdua.github.io, but that is not a guaranteed promise, and that copy might often be out of date. That is why I encourage you to create your own archive if you found my blogs, or any other written content on this webpage, useful.

Compare against the official exporter at vijitdua.com/archive. This snapshot includes manifest.json with the export time and file list.

Header and footer on every page show **vijitdua.com • archive • 2026-10-20**. Click that line (or **More info**) to read the same notice.

## How to browse locally

`vd-archive.sh` in this folder serves the copy on this computer and can replace these files with a newer ZIP. It does not upload the folder. Do not rely on double-clicking `index.html` (Safari in particular restricts `file://` pages).

```bash
sh vd-archive.sh serve
```

Then open http://127.0.0.1:4173/ . Leave that window open. `PORT=8080 sh vd-archive.sh serve` uses another port.

## How to host this as a static site

This folder is a normal static website (`index.html` at the root, nested `section/index.html` paths). Any static host works:

1. Unzip this archive.
2. Publish the unzipped files as the site root (not inside an extra folder).
3. Enable “rewrite directories to index.html” if your host needs it — GitHub Pages already serves `/blog/foo/index.html` at `/blog/foo/`.
4. Optional custom domain: add a `CNAME` file with e.g. `archive.vijitdua.com`.

## Where to put the files

The unzipped folder has to be the whole website, at the root of whatever host you use. Pages ask for `/_next/…` and other files from the top of the site. A host that adds an extra folder to the address, such as `example.com/some-name/`, cannot find those files. How you upload is up to you.

## Upgrade

Export a new ZIP from https://vijitdua.com/archive, then from this folder:

```bash
sh vd-archive.sh upgrade ~/Downloads/vijitdua-archive.zip
```

The upgrade keeps `.git` and replaces the other files. It does not download a ZIP by itself, and it does not upload the result.

## What the hosted copy does

Each page keeps the live HTML, CSS, and JavaScript, and adds a small script that asks `https://vijitdua.com/health/live` (CORS). If that answers `{"status":"ok"}`, you are sent to the same path on the live site, including from localhost. `?noredirect=1` stays on the archive. If the probe fails, a bar is added after the page loads: **vijitdua.com • archive • 2026-10-20**, plus **Open live site**.

## What works offline / on a static host

- Saved pages, images, CSS, fonts, and the page JavaScript (client nav is a full page load so it does not ask the archive host for React Server payloads).
- Uploaded files keep a normal suffix (`.png`, `.mp3`, `.pdf`, …). GitHub Pages and other static hosts use that suffix for the content type. `content-types.json` is only for `vd-archive.sh` on this computer.
- Navigation between included pages. Links to pages that were not saved go to https://vijitdua.com.
- PDF copies of blog posts (`blog/<slug>/article.pdf`) and a “View PDF version” link on each post.

## What does NOT work

- Blog/music subscribe forms, admin tools, sign-in, comments/reactions.
- Hover-only extras that were not expanded at capture time (some role previews are opened for the snapshot).
- YouTube and other embedded players (links may remain external).
- Large music files unless you enabled “Include large media” when exporting.
- Private or unlisted pages (`/p/…`, `/private/…`) — never included.
- Scratch apps under `/app/<slug>/` — never included.

Re-run the export after the site changes for a fresher copy. Export again from https://vijitdua.com/archive (Chrome on a computer).
