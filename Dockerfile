FROM golang:1.23.1

RUN apt-get update && \
    apt-get -y --no-install-recommends install postgresql-client libxrender1 libjpeg62 libfontconfig

RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb
RUN apt-get -y --no-install-recommends install -f ./wkhtmltox_0.12.6.1-3.bookworm_amd64.deb
RUN wkhtmltopdf --version
RUN whereis wkhtmltopdf

ENV GOPATH=/go
ENV GOPROXY=direct
ENV GOSUMDB=sum.golang.org
ENV GONOSUMDB=github.com/go-swagger/go-swagger

# Prerequisites
RUN curl -sSL https://raw.githubusercontent.com/wallester/internal-linter-image/master/custom-gcl.sh | bash -s -- -b $(go env GOPATH)/bin
RUN curl -sfL https://raw.githubusercontent.com/securego/gosec/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.18.2
RUN go install github.com/tebeka/go2xunit@latest
RUN go install github.com/go-swagger/go-swagger/cmd/swagger@v0.31.0
RUN go install github.com/wallester/godotenv/cmd/godotenv@latest
RUN go install github.com/zricethezav/gitleaks/v8@v8.18.3
