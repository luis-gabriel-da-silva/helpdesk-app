FROM ubuntu:24.04 AS build

ARG FLUTTER_VERSION=3.47.8
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/flutter/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git libglu1-mesa unzip xz-utils zip \
    && rm -rf /var/lib/apt/lists/* \
    && curl --fail --location --retry 3 \
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        --output /tmp/flutter.tar.xz \
    && tar -xJf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz

# The official SDK archive preserves its source ownership. Trust that SDK
# repository at system scope so Git accepts it during the root build.
RUN git config --system --add safe.directory /opt/flutter \
    && git -C /opt/flutter rev-parse --show-toplevel

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter precache --web
RUN flutter pub get

COPY . .

ARG API_BASE_URL=http://localhost:8080/api
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
