# Static hosting for BSV Whalewatch (CapRover: captain-definition points here).
FROM nginx:1.27-alpine
COPY bsv_whale_scanner.html /usr/share/nginx/html/index.html
EXPOSE 80
