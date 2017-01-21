FROM alpine

ADD out/ngrok /ngrok

ENTRYPOINT ["/ngrok"]
