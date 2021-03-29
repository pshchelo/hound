FROM alpine:3.11.7 AS builder

ENV GOPATH /go

COPY . /go/src/github.com/hound-search/hound

RUN apk update \
	&& apk add go libc-dev \
	&& cd /go/src/github.com/hound-search/hound \
	&& go mod download \
	&& go install github.com/hound-search/hound/cmds/houndd

FROM alpine:3.11.7
COPY --from=builder /go/bin/houndd /go/bin/houndd
RUN apk update \
        && apk add git subversion mercurial bzr openssh tini\
        && rm -f /var/cache/apk/*
VOLUME ["/data"]

EXPOSE 6080

ENTRYPOINT ["/sbin/tini", "--", "/go/bin/houndd", "-conf", "/data/config.json"]
