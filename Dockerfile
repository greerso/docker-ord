ARG VERSION=v0.9.10
FROM rust:1.67.0-slim-buster AS builder
WORKDIR /build
RUN apt-get upgrade
RUN apt-get install -y gcc curl openssl-dev musl-dev git
RUN git clone https://github.com/casey/ord.git .
# cargo under QEMU building for ARM can consumes 10s of GBs of RAM...
# Solution: https://users.rust-lang.org/t/cargo-uses-too-much-memory-being-run-in-qemu/76531/2
ENV CARGO_NET_GIT_FETCH_WITH_CLI true
RUN cargo build --release

FROM debian:buster-slim
EXPOSE 8066
COPY --from=build /build/target/release/ord /bin/ord
USER 1000
# ENTRYPOINT ["/bin/ord", "--data-dir", "/data/index-data", "--cookie-file", ".cookie", "server", "--http-port", "8066"]