#!/bin/bash

# Hata durumunda betiğin çalışmasını durdurur.
set -e

# Gerekli araçların yüklü olup olmadığını kontrol eder (curl, jq, grep).
echo "Gerekli araçlar kontrol ediliyor..."
tdnf install -y curl jq grep > /dev/null 2>&1

# Docker CLI eklentileri için dizin yolunu belirler.
DOCKER_CLI_PLUGINS_DIR="/root/.docker/cli-plugins"

# Gerekli dizini oluşturur.
echo "Docker CLI eklenti dizini oluşturuluyor: ${DOCKER_CLI_PLUGINS_DIR}"
mkdir -p "${DOCKER_CLI_PLUGINS_DIR}"

# En son Docker Buildx sürümünü GitHub API'sinden alır.
echo "En güncel Docker Buildx sürümü tespit ediliyor..."
LATEST_VERSION=$(curl -s -L "https://api.github.com/repos/docker/buildx/releases/latest" | jq -r '.tag_name')

if [ -z "$LATEST_VERSION" ]; then
    echo "HATA: En güncel Docker Buildx sürümü tespit edilemedi. Lütfen internet bağlantınızı ve GitHub API erişimini kontrol edin."
    exit 1
fi

echo "En güncel sürüm: ${LATEST_VERSION}"

# Sistem mimarisini belirler.
ARCH=$(uname -m)
case ${ARCH} in
    x86_64)
        TARGET_ARCH="linux-amd64"
        ;;
    aarch64)
        TARGET_ARCH="linux-arm64"
        ;;
    *)
        echo "HATA: Desteklenmeyen sistem mimarisi: ${ARCH}"
        exit 1
        ;;
esac

echo "Sistem mimarisi için uygun dosya indirilecek: ${TARGET_ARCH}"

# Docker Buildx'i indirir ve doğru yola taşır.
DOWNLOAD_URL="https://github.com/docker/buildx/releases/download/${LATEST_VERSION}/buildx-${LATEST_VERSION}.${TARGET_ARCH}"
DESTINATION_PATH="${DOCKER_CLI_PLUGINS_DIR}/docker-buildx"

echo "Docker Buildx indiriliyor: ${DOWNLOAD_URL}"
curl -s -L "${DOWNLOAD_URL}" -o "${DESTINATION_PATH}"

# İndirilen dosyaya çalıştırma izni verir.
echo "Çalıştırma izni veriliyor..."
chmod +x "${DESTINATION_PATH}"

echo "Kurulum tamamlandı."

# Kurulumu doğrular.
echo "Docker Buildx sürümü doğrulanıyor:"
docker buildx version

echo -e "\nDocker Buildx başarıyla kuruldu. Artık 'docker buildx' komutunu kullanabilirsiniz."