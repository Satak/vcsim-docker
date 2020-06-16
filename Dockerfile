FROM golang:latest AS builder

LABEL name="builder"
LABEL builder=true

RUN go get -u github.com/vmware/govmomi/vcsim

FROM vmware/photon:latest

LABEL name="vCenter Appliance Simulator"
LABEL description="A VMware vCenter API mock server based on govmomi"
LABEL maintainer="satak"

COPY --from=builder /go/bin/vcsim .
CMD ["./vcsim", "-l", "0.0.0.0:443"]
