# Build stage
FROM golang:alpine AS builder

WORKDIR /build

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY sts_get_caller_identity.go ./

# Build the binary with static linking
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o sts-caller-identity sts_get_caller_identity.go

# Create non-root user and group
RUN echo "nonroot:x:65532:65532:nonroot:/:" > /etc/passwd.minimal && \
    echo "nonroot:x:65532:" > /etc/group.minimal

# Final stage
FROM scratch

LABEL org.opencontainers.image.source="https://github.com/neoshrew/sts-caller-identity-docker"
LABEL org.opencontainers.image.description="Minimal Go app to call AWS STS GetCallerIdentity"
LABEL org.opencontainers.image.licenses="MIT"

# Copy passwd and group files for non-root user
COPY --from=builder /etc/passwd.minimal /etc/passwd
COPY --from=builder /etc/group.minimal /etc/group

# Copy the binary from builder
COPY --from=builder /build/sts-caller-identity /sts-caller-identity

# Copy CA certificates for HTTPS requests to AWS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Use non-root user
USER nonroot:nonroot

ENTRYPOINT ["/sts-caller-identity"]
