# This is a standard Dockerfile for building a Go app.
# It is a multi-stage build: the first stage compiles the Go source into a binary, and
#   the second stage copies only the binary into an alpine base.

# -- Stage 1 -- #
# Compile the app.
FROM ubuntu as builder
WORKDIR /app
# The build context is set to the directory where the repo is cloned.
# This will copy all files in the repo to /app inside the container.
# If your app requires the build context to be set to a subdirectory inside the repo, you
#   can use the source_dir app spec option, see: https://www.digitalocean.com/docs/app-platform/references/app-specification-reference/
COPY . .

RUN apt-get -y update && apt-get install -y
RUN apt install golang 
RUN apt install clang 
RUN apt install build-essential 
RUN apt install make 
RUN apt install libmysql++-dev 
RUN apt install libargon2-dev
RUN go build -mod=vendor -o bin/hello

# Install C++ dependencies for SKO-Server
RUN apt-get -y install libmysql++-dev libargon2-dev

# -- Stage 2 -- #
# Create the final environment with the compiled binary.
FROM ubuntu
# Install any required dependencies.
RUN apt-get -y update && apt-get install -y
RUN apt install ca-certificates
RUN apt install golang 
RUN apt install libmysql++-dev 
RUN apt install libargon2-dev

WORKDIR /root/

# Copy the binary from the builder stage and set it as the default command.
COPY --from=builder /app/bin/hello /usr/local/bin/
COPY --from=builder /app/skoserver-dev .
COPY --from=builder /app/SKO_Content/* SKO_Content/

CMD ["hello"]
