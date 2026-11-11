# IP records

Evidence of authorship registered through iptrust.org (iptrust/1): hash-only, signed by the author's key, anchored on
BSV (NotaryHash) and Bitcoin (OpenTimestamps). A record is evidence that the content existed by the anchoring block
and that the signer made the statement; it does not itself create or register any right.

| Date | Covers | Type | Record hash | Signer | Git tag |
|---|---|---|---|---|---|
| 2026-11-11 | BSV Whalewatch: `bsv_whale_scanner.html`, `README.md`, `LICENSE` (3 files). Authors: Gregory J. Ward, Bryan W. Daugherty, Shawn M. Ryan. | software (published 2026-11-11, this repo) | [`2067fcc907f9ba279f1e3e6b21e742bf0fde4503aa2205430cc6779da763184e`](https://iptrust.org/v/2067fcc907f9ba279f1e3e6b21e742bf0fde4503aa2205430cc6779da763184e) | Gregory J. Ward | `ip-2026-11-11` (commit `29cec25`) |

The private evidence (`opening.json`, `manifest.json`) is kept outside this public repo (`.iptrust/` is ignored).

## Verify

With the `.iptrust/` evidence folder at hand, in a separate worktree so the working copy is untouched:

```sh
git worktree add /tmp/at-tag-bsv-whale-watch ip-2026-11-11 && cp -r .iptrust /tmp/at-tag-bsv-whale-watch/
(cd /tmp/at-tag-bsv-whale-watch && iptrust2 verify 2067fcc907f9ba279f1e3e6b21e742bf0fde4503aa2205430cc6779da763184e --fetch-headers)   # expect: valid, matched
git worktree remove --force /tmp/at-tag-bsv-whale-watch
```

If `--fetch-headers` fails (often a block-explorer rate limit, HTTP 429), that is not a verdict on the record: rerun
without it to check `content: matched`, and fetch headers later.
