FROM golang:latest as builder

LABEL name="vCenter Appliance Simulator"
LABEL description="A VMware vCenter API mock server based on govmomi"
LABEL url="https://github.com/vmware/govmomi/tree/master/vcsim"
LABEL maintainer="satak"

RUN go get -u github.com/vmware/govmomi/vcsim
RUN go get -u github.com/vmware/govmomi/govc

FROM vmware/photon:latest

COPY --from=builder /go/bin/govc .
COPY --from=builder /go/bin/vcsim .
ADD /ssl/untrusted_cert.pem ./untrusted_cert.pem
ADD /ssl/untrusted_key.pem ./untrusted_key.pem

ENTRYPOINT ["./vcsim"]
CMD ["-l", "0.0.0.0:443", "-tls", "-tlscert", "/untrusted_cert.pem", "-tlskey", "/untrusted_key.pem"]
