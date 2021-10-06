FROM openjdk:11-jdk-slim

ENV VERSION 10.0.4_PUBLIC
ENV GHIDRA_SHA 1ce9bdf2d7f6bdfe5dccd06da828af31bc74acfd800f71ade021d5211e820d5e
ENV GHIDRA_URL https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.0.4_build/ghidra_10.0.4_PUBLIC_20210928.zip

RUN apt-get update && apt-get install -y wget unzip dnsutils --no-install-recommends \
    && wget --progress=bar:force -O /tmp/ghidra.zip ${GHIDRA_URL} \
    && echo "$GHIDRA_SHA /tmp/ghidra.zip" | sha256sum -c - \
    && unzip /tmp/ghidra.zip \
    && mv ghidra_${VERSION} /ghidra \
    && chmod +x /ghidra/ghidraRun \
    && echo "===> Clean up unnecessary files..." \
    && apt-get purge -y --auto-remove wget unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives /tmp/* /var/tmp/* /ghidra/docs /ghidra/Extensions/Eclipse /ghidra/licenses

RUN useradd -r -d /ghidra -s /bin/bash -u 1000 ghidra

WORKDIR /ghidra

COPY entrypoint.sh /entrypoint.sh

COPY server.conf /ghidra/server/server.conf

RUN mkdir /repos

RUN chown -R ghidra:ghidra /repos /ghidra

USER ghidra

EXPOSE 13100 13101 13102

ENTRYPOINT ["/entrypoint.sh"]

CMD ["server"]

