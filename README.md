# BSV Whalewatch

A single-file browser dashboard that scans BSV mainnet blocks in a UTC date range and ranks
transactions by the **value leaving their sender**: every output that does not pay back to a key that
signed the transaction. It also totals the flows per address. There is no backend and no build step: open
`bsv_whale_scanner.html` in a browser (or serve it statically) and start a scan.

Data comes live from public explorer APIs. Nothing is fabricated, and a scan that runs out of
request budget is reported as partial.

## Providers

**Bitails** (`api.bitails.io`)
- Lists block summaries and skips any block whose total output value is below the threshold
  (no single output can exceed the total).
- In the remaining blocks, skips any transaction whose `sumOfOutputsSatoshis` is below the threshold.
- Downloads each remaining transaction raw (`/download/tx/{txid}/hex`), checks that its
  double-SHA256 equals the TXID, and parses the outputs itself.
- The free tier allows 1,000 requests a day without a key.

**WhatsOnChain** (`api.whatsonchain.com`)
- Finds the height range by binary search on median-time-past, which is non-decreasing by
  consensus (BIP113).
- Filters each block by its own timestamp.
- Fetches transactions in batches of 20 (`POST /txs`).
- The free tier allows 3 requests a second; a key goes in the `Authorization` header.

An API key is optional, stays in the open tab and is sent only to the chosen provider. Never
put a key into a hosted copy of the file.

## Value leaving the sender

Large addresses often spend one big coin, pay a small amount out and send the rest back to themselves.
Ranked by largest output, a 0.7 BSV payment would show as a 1,521 BSV movement.

- Each standard (P2PKH) input reveals its public key. An output paying the hash160 of one of those keys
  goes back to the sender and is shown as **back to sender** (likely change).
- **Leaving sender** is every other non-data output; the table ranks by it and still shows the largest
  output.
- A transaction qualifies when its largest output or its value leaving the sender reaches the threshold.
  Both are bounded by the output sum, so pruning by output sum stays sound.
- Inputs of other types reveal no key. Their rows are flagged `INPUTS UNIDENTIFIED`, and change
  to them counts as leaving.
- A same-key output is not proof of change: a sender can pay its own address on purpose, and change can go
  to a fresh address.

The **address flows** table totals, per address over the scan's qualifying transactions, what it sent to
others, what came back to it, and what it received from transactions it did not sign. A transaction
signed by several keys counts under the group of its signing addresses. Hash160 uses Web Crypto SHA-256
and a built-in RIPEMD-160, so no extra API requests are needed.

## Coverage and caveats

- A block counts as covered only when it was skipped by a provable bound, or when every
  transaction in it was checked.
- A 14-day scan of the whole chain can need far more requests than a free tier allows. The
  coverage bar shows how much was actually verified.
- The WhatsOnChain lower bound on the date range assumes the network's 2-hour
  future-timestamp limit and honest timestamps. Every block is still filtered by its own time.
- A large output is not proof of a payment to another owner. Change outputs, custody
  reshuffles and self-transfers often top the ranking. The tool never identifies owners.

## Export

The CSV export lists each TXID, block height, timestamp, value leaving the sender, value back to the
sender, largest and total output (in satoshis), output count, sender addresses, whether every input was
identified, the provider and whether the scan was complete.

## Hosting

The repo deploys as-is to CapRover: `captain-definition` points to a `Dockerfile` that serves
`bsv_whale_scanner.html` as `index.html` from `nginx:1.27-alpine`. Serve it over HTTPS (the page uses
`crypto.subtle` to hash-check downloaded transactions). Never bake an API key into a hosted copy.

## License

MIT. See [LICENSE](LICENSE).
