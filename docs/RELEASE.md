# Release procedure

First-time maintainers should read [PUBLISH-GITHUB.md](PUBLISH-GITHUB.md)
before using this checklist.

1. Update the version globals at the top of `rpm/grads.spec`. This is the
   central version setting.
2. Build in a clean AlmaLinux 8 environment with `./rpm/build-el8.sh`.
3. Run `./rpm/check-rpm.sh PATH_TO_BINARY_RPM` and the basic GrADS tests.
4. Run `./rpm/make-release-assets.sh` to create the build kit and
   `SHA256SUMS`.
5. Review `release/v2.2.1-camo26.0/` and the build log.
6. Commit the reviewed source and packaging files, then tag:

```bash
git tag v2.2.1-camo26.0
git push origin v2.2.1-camo26.0
```

7. Create a GitHub Release from that tag and initially mark it as a
   pre-release until it has broader testing.
8. Upload:

```text
grads-2.2.1-1.camo26.0.el8.x86_64.rpm
grads-2.2.1-1.camo26.0.el8.src.rpm
grads-2.2.1-camo26.0-buildkit.tar.gz
SHA256SUMS
RELEASE_NOTES.md
rpmbuild.log (optional)
```

Do not silently replace published files. Correct a published release by
incrementing the CAMO release, for example `v2.2.1-camo26.1`. Use a larger
series bump such as `v2.2.1-camo27.0` for a deliberate behavior change.
