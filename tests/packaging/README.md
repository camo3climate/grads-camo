# Packaging checks

Run `bash tests/packaging/run.sh` from the development checkout. It copies the
maintained inputs into an ignored `outputs/packaging-test.*` fixture directory.
It checks version/patch drift, rejection of misleading RPM names/versions,
buildkit contents and source hashes, and refusal to overwrite an existing
versioned directory. No system package or public release is created or changed.

`fake-rpm.sh` simulates only the metadata query using text fixtures. These tests
do **not** validate real RPM headers, dependency resolution, Linux compilation,
MacPorts installation or package installation. Test the real helper on EL
against reviewed binary/source RPMs before publication. Never use the fake
query command for that operation.
