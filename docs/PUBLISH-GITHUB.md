# Publish on GitHub

This guide assumes that GitHub and software publication are new to the
maintainer. GitHub uses two related but separate areas:

- **Repository:** source tarball, patches, spec, scripts, license, and docs.
- **Release:** finished RPM/SRPM and downloadable release archives.

Do not place built RPM files in the normal repository history.

## 1. Prepare the repository files

Do **not** upload the entire Codex workspace. It contains old RPMs, logs,
figures, and temporary analysis directories. Instead, extract the clean build
kit:

```bash
tar xzf grads-2.2.1-camo26.0-buildkit.tar.gz
cd grads-2.2.1-camo26.0
```

The following content belongs in the repository root:

```text
README.md
CHANGELOG.md
NOTICE.md
LICENSE
LICENSES/
RELEASE_NOTES_TEMPLATE.md
SHA256SUMS
docs/
rpm/
SOURCES/
```

Do not upload `work/`, `.rpmbuild/`, built RPMs, unrelated logs, bundled
`supplibs`/`supptools`, proprietary fonts, or personal test data.

## 2. Create the GitHub repository

While signed in to GitHub:

1. Open **New repository**.
2. Select the `camo3climate` owner, if that is the intended public owner.
3. Use repository name `grads-packaging`.
4. Set visibility to **Public**.
5. Do not ask GitHub to create another README, `.gitignore`, or license because
   this project already supplies them.
6. Create the repository.

The expected URL is:

```text
https://github.com/camo3climate/grads-packaging
```

Official GitHub reference: [Creating a new repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository).

## 3. Upload the source repository

For the first upload, the web interface is sufficient:

1. On the empty repository page, choose **uploading an existing file**, or
   **Add file > Upload files**.
2. Drag the contents of the extracted build-kit directory into the page. The
   repository top level should show `README.md`, not another enclosing
   `grads-2.2.1-camo26.0` directory.
3. Use a commit message such as `Initial GrADS 2.2.1 CAMO packaging`.
4. Commit the files to the `main` branch.

A **commit** is a recorded snapshot of the repository. Later documentation or
patch edits become additional commits rather than replacements of history.

Official GitHub reference: [Adding a file to a repository](https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository).

## 4. Build the release RPMs

Build the exact public version on AlmaLinux 8:

```bash
./rpm/build-el8.sh
./rpm/check-rpm.sh .rpmbuild/RPMS/x86_64/grads-2.2.1-1.camo26.0.el8.x86_64.rpm
./rpm/make-release-assets.sh
```

Do not publish the older `grads-2.2.1-1.el8.x86_64.rpm` as CAMO 26.0. It does
not have the CAMO RPM release identity and may not include the final help and
startup changes.

After a successful build, use the files collected under:

```text
release/v2.2.1-camo26.0/
```

## 5. Create the GitHub Release

On the repository page:

1. Open **Releases** and choose **Draft a new release**.
2. Choose **Create new tag** and enter `v2.2.1-camo26.0`, targeting `main`.
3. Use title `GrADS 2.2.1 CAMO build camo26.0`.
4. Paste the content of `RELEASE_NOTES.md` into the description.
5. Initially select **Set as a pre-release**.
6. Attach these files from `release/v2.2.1-camo26.0/`:

```text
grads-2.2.1-1.camo26.0.el8.x86_64.rpm
grads-2.2.1-1.camo26.0.el8.src.rpm
grads-2.2.1-camo26.0-buildkit.tar.gz
SHA256SUMS
RELEASE_NOTES.md
```

`rpmbuild.log` is optional. Debuginfo and debugsource RPMs are not needed for
normal users and do not need to be attached to the first public release.

Publishing the source RPM and build kit beside the binary RPM also makes the
corresponding source and build instructions readily available to recipients.

Official GitHub reference: [Managing releases in a repository](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).

## 6. After publication

Do not silently replace an attached RPM or build kit. If release contents must
change, update the central version in `rpm/grads.spec`, rebuild, create a new
tag such as `v2.2.1-camo26.1`, and publish a new release.

Repository documentation may be corrected through a new commit. A correction
that changes already published package contents requires a new release.
