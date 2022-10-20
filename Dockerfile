# Base Image
FROM golang:1.19-alpine as builder

# Add non root user
ENV USER=appuser
ENV UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

RUN apt-get update; \
    apt-get install -y ca-certificates

# We now wish to execute any further commands
# inside our /github-actions directory
WORKDIR /github-actions

# Copy everything in the root directory
# into our /github-actions directory
COPY . ./

# Download all dependencies. Dependencies will be cached if the go.mod and the go.sum files are not changed.
RUN go mod tidy

# Run go build to compile the binary
# executable of our Program
RUN CGO_ENABLED=0 go build -o github-actions-linux cmd/main.go

# Start a new stage from scratch
FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

USER appuser:appuser

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /github-actions /github-actions

EXPOSE 8080

CMD [ "./github-actions-linux"]