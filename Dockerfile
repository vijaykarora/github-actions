# Base Image
FROM golang:1.19-alpine as builder

# Add non root user
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "10001" \
    "github-actions"

# Copy everything in the root directory
# into our /go/src/github-actions directory
ADD . /go/src/github-actions

# We now wish to execute any further commands
# inside our /go/src/github-actions directory
WORKDIR /go/src/github-actions

# Download all dependencies. Dependencies will be cached if the go.mod and the go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the working directory inside the container
COPY . .

# Run go build to compile the binary
# executable of our Program
RUN CGO_ENABLED=0 GOOS=linux go build -o github-actions-linux cmd/main.go

# Start a new stage from scratch
FROM alpine:latest

# We now wish to execute any further commands
# inside our root directory
WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /go/src/github-actions .

EXPOSE 8080

ENTRYPOINT [ "./github-actions-linux"]