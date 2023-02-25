ARG VERSION=0.5.1

FROM rust:1.67.0-slim-buster AS builder
ARG VERSION
WORKDIR /build
RUN apt-get update
RUN apt-get install -y libssl-dev git
RUN git clone --depth 1 https://github.com/casey/ord.git .
# cargo under QEMU building for ARM can consumes 10s of GBs of RAM...
# Solution: https://users.rust-lang.org/t/cargo-uses-too-much-memory-being-run-in-qemu/76531/2
ENV CARGO_NET_GIT_FETCH_WITH_CLI true
RUN cargo build --release

FROM debian:buster-slim
EXPOSE 8066
COPY --from=builder /build/target/release/ord /bin/ord
USER 1000
ENTRYPOINT ["/bin/ord"]
CMD ["--data-dir", "/data/.bitcoin", "--cookie-file", "/data/.bitcoin/.cookie", "server", "--http-port", "8066"]
