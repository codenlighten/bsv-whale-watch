# BSV Whalewatch

A single-file browser dashboard that scans BSV mainnet blocks in a UTC date range and ranks
transactions by their **largest single output**. There is no backend and no build step: open
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

The CSV export lists each TXID, block height, timestamp, largest and total output (in
satoshis), output count, provider and whether the scan was complete.

## Hosting

The repo deploys as-is to CapRover: `captain-definition` points to a `Dockerfile` that serves
`bsv_whale_scanner.html` as `index.html` from `nginx:1.27-alpine`. Serve it over HTTPS (the page uses
`crypto.subtle` to hash-check downloaded transactions). Never bake an API key into a hosted copy.

## License

MIT. See [LICENSE](LICENSE).
