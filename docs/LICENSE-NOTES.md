# License notes

The upstream `COPYRIGHT` file states that GrADS may be redistributed and/or
modified under version 2 of the GNU General Public License. The complete text
is preserved as this repository's `LICENSE` and remains in the upstream source
archive. The linked-list mergesort code in upstream `src/bufrstn.c` carries a
separate MIT notice; it is preserved in the source and copied to
`LICENSES/MIT-Simon-Tatham.txt`. The RPM license expression therefore uses
`GPL-2.0-only AND MIT`.

Unless a file says otherwise, the CAMO patches and packaging files are
distributed under GPL-2.0-only, consistent with the modified upstream work.
The binary RPM should be published together with its source RPM and build kit
so recipients can obtain the corresponding source and build material.

No proprietary fonts are bundled. The font-family command only refers to
fonts installed on the target system. If a font is added in a future release,
its redistribution terms must be reviewed and its license text included; only
clearly redistributable fonts should be considered.

The source tree also contains third-party build macros and uses system
libraries with their own licenses. This note is a packaging summary, not legal
advice. Before broad public distribution, the maintainer should review the
complete source archive, every patch's provenance, and all linked-library
license obligations.
