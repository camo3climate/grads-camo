# camo26.2 インストールと配布物の選び方

現在はソースキットを配布しています。既成RPM・DEBは現在ダウンロードできません。
以下のパッケージ名・導入コマンドは、各OSでビルドした場合の説明です。
Linuxは各OSのビルド手順、macOSはMacPorts手順を参照してください。

[GitHub Release](https://github.com/camo3climate/grads-camo/releases/tag/v2.2.3-camo26.2)
から自分のOSに一致するファイルを取得する。Linuxはx86_64/amd64のみ。
EL10は標準のx86-64-v3環境が必要。Mint、Homebrew、Intel Mac、Linux ARM64は今回対象外。

| OS | インストールするファイル |
| --- | --- |
| AlmaLinux 8 | grads-2.2.3-1.camo26.2.el8.x86_64.rpm |
| AlmaLinux 9 | grads-2.2.3-1.camo26.2.el9.x86_64.rpm |
| AlmaLinux 10 | grads-2.2.3-1.camo26.2.el10.x86_64.rpm |
| Fedora 44 | grads-2.2.3-1.camo26.2.fc44.x86_64.rpm |
| Debian 13 | grads-camo_2.2.3+camo26.2-1.debian13.1_amd64.deb |
| Ubuntu 24.04 | grads-camo_2.2.3+camo26.2-1.ubuntu24.04.1_amd64.deb |
| Ubuntu 26.04 | grads-camo_2.2.3+camo26.2-1.ubuntu26.04.1_amd64.deb |
| macOS Apple Silicon | grads-2.2.3-camo26.2-buildkit.tar.gz内のMacPorts定義 |

AlmaLinuxでの試験をRocky/RHEL全体の保証とはしない。異なるOS版のRPM/DEBは流用しない。
GitHubの配布DEB名は`-1.debian13.1`等（`.`）だが、内部versionとネイティブbuild名は
`-1~debian13.1`等（`~`）のまま。GitHubのファイル名正規化に合わせた名前だけの変更で、
パッケージの内部versionはファイル名の変更では変わりません。
`src.rpm`は再ビルド用で、通常の利用には不要。デバッグパッケージは標準配布に含めない。

## Linux

取得したファイルと`SHA256SUMS`を同じディレクトリに置いて照合する。
全ファイル取得済みなら`sha256sum -c SHA256SUMS`。一部だけなら例えば:

```bash
grep '  grads-2.2.3-1.camo26.2.fc44.x86_64.rpm$' SHA256SUMS | sha256sum -c -
sudo dnf install ./grads-2.2.3-1.camo26.2.fc44.x86_64.rpm
# Debian 13の場合:
sudo apt install ./grads-camo_2.2.3+camo26.2-1.debian13.1_amd64.deb
```

AlmaLinuxではEPELおよびCRB（EL8はPowerTools）の依存が必要な場合がある。
各[EL8](BUILD-EL8.md)・[EL9](BUILD-EL9.md)・[EL10](BUILD-EL10.md)手順を参照。
`rpm -ivh`や`dpkg -i`単体より、依存解決する`dnf`/`apt`を使う。
既存GrADSとの競合・置換が表示されたら内容を確認する。旧版からの更新／削除試験は未実施。
配布物に独自のRPM/DEB署名は付けていない。checksumは転送照合用で、署名の代わりではない。

```bash
grads -blc 'q config'
grads -blc 'q gxconfig'
```

起動表示がcamo26.2であることと使用中のパスを確認する。
対話描画にはX11表示環境が必要。Ubuntu/DebianでDejaVuの斜体を使うなら、
`sudo apt install fonts-dejavu-extra`も検討する（任意、フォントは同梱しない）。

## macOS：MacPorts

MacPortsを導入後、共通buildkitを展開して
[Apple Silicon / MacPorts手順](BUILD-MACOS-ARM64.md)に従う。
ローカルPortを登録した後に`sudo port install grads-camo`を実行する構成で、
公式MacPortsに登録済みのPortではない。ソース・パッチはbuildkitに同梱。

camo26.2はMacPortsライブラリでのネイティブビルドとバッチ試験を確認済み。
MacPorts自身によるdestroot/導入/activationの最終確認は未完了。macOSバイナリは配布しない。
既存のMacPorts `grads`とは競合するため、切り替え手順も確認する。

## 動作・検証範囲

Linux 7環境で全12バッチsuite、導入、新規runtime環境での起動を確認したpre-release。
未実施項目は[検証一覧](VALIDATION-CAMO26.2.md)を参照。
EPS/PDFの従来の回転・余白は維持する。PNG/SVGと向きが異なることがある。
[機能紹介](https://camo3climate.github.io/grads-camo/grads-camo-features/ja/): 地理描画、配色、解析・出力。
