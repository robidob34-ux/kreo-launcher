# Kreo Launcher — Official Website

A single self-contained site (`index.html`, no build step, works offline) that lets
**anyone on the internet** download your real Kreo Launcher build.

## What's inside

| File | Purpose |
|---|---|
| `index.html` | The complete website (HTML + CSS + JS + embedded aurora background) |
| `downloads/` | Put your **real** launcher builds here (served by the site) |
| `make_release.sh` | Copies a build into `downloads/`, computes real size + SHA-256, rewrites the site |
| `.nojekyll` | Tells GitHub Pages to serve the folder as-is |

---

## Step 1 — Add your real launcher build

You told me you already have the launcher. Copy it into `downloads/` using the packager:

```bash
cd kreo-launcher
bash make_release.sh /path/to/KreoLauncher-Setup-2.4.1.exe windows
bash make_release.sh /path/to/KreoLauncher-2.4.1.dmg        macos
bash make_release.sh /path/to/KreoLauncher-2.4.1.AppImage   linux
```

This is what makes the download button **real** — it computes the true SHA-256 and
file size and embeds them into the site. Upload all three for full OS coverage, or
just the platforms you build for.

> **File size note:** GitHub blocks git pushes of files larger than **100 MB**.
> If your installer is bigger, see "Big files" at the bottom.

## Step 2 — Create the GitHub repo (free)

1. Go to https://github.com/new
2. Repository name: `kreo-launcher` → **Public** → Create repository
3. Push this folder:

```bash
cd kreo-launcher
git init
git add .
git commit -m "Kreo Launcher website"
git branch -M main
git remote add origin https://github.com/robidob34-ux/kreo-launcher.git
git push -u origin main
```

(Or without git: on the repo page use **Add file → Upload files** and drag the whole
folder contents in.)

## Step 3 — Turn on GitHub Pages (free hosting)

1. Repo → **Settings → Pages**
2. Source: **Deploy from a branch** → Branch: **main** → Folder: **/ (root)** → Save
3. Wait ~1 minute. Your site is live at:

```
https://robidob34-ux.github.io/kreo-launcher/
```

That URL is public — anyone on Chrome/Google can open it and download Kreo. Done.

### Optional: custom domain (e.g. kreo.gg)

1. Buy the domain anywhere (Namecheap, Cloudflare…)
2. Repo → Settings → Pages → **Custom domain** → enter it → save
3. At your registrar: CNAME `www` → `robidob34-ux.github.io`, and A records `@` →
   `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
4. Tick **Enforce HTTPS** once it propagates.

## Step 4 — Updating the launcher later

Every time you ship a new build:

```bash
bash make_release.sh /path/to/new-build.exe windows   # updates hash + size
git add . && git commit -m "Release 2.4.2" && git push
```

Pages redeploys automatically.

## Big files (>100 MB installers)

Use **GitHub Releases** instead of `downloads/`:

1. Repo → **Releases → Create a new release** → tag `v2.4.1`
2. Attach your `.exe` / `.dmg` / `.AppImage` as release assets → Publish
3. In `index.html` change the download handler to:
   `window.location.assign('https://github.com/robidob34-ux/kreo-launcher/releases/latest/download/<FILENAME>')`

Direct `…/releases/latest/download/<FILENAME>` links always serve the newest upload.

## Microsoft login (auth) reminder

Sine you chose Microsoft-account auth for the launcher itself: players will sign in
with their own Microsoft account, so Kreo can verify game ownership with Mojang's
services. You need a free **Azure app registration** (portal.azure.com → App
registrations → New → "Kreo Launcher") with the **personal Microsoft accounts**
audience, and its **Application (client) ID** embedded in the launcher. Without that
ID the launcher can't complete the login flow — everything on the website works
regardless, this is launcher-side.

## Before you go public — honest checklist

- [ ] `downloads/` contains the REAL build you tested on a fresh PC
- [ ] Stats/claims you keep or remove (current site avoids invented player counts)
- [ ] Version tag in `index.html` (`v2.4.1 "Aurora"`) matches your actual build
- [ ] Disclaimer stays — Kreo is a third-party client, not affiliated with Mojang/Microsoft
- [ ] Links in footer (Discord, Terms, Privacy) point to real pages or are removed
