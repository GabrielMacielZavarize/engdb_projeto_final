# syntax=docker/dockerfile:1
# ==========================================================================
# Metabase + driver Starburst/Trino (não incluído na imagem oficial).
# O driver é baixado no build a partir da release oficial, tornando a
# instalação reprodutível e persistente (fica embutida na imagem, sobrevive
# à recriação dos containers) sem versionar o binário .jar no Git.
# ==========================================================================
FROM metabase/metabase:v0.50.32

# Release 5.0.0 do driver = compilada com Metabase v1.50.9, ou seja, a linha
# 0.50.x usada neste projeto (v0.50.32). NÃO trocar por versão aleatória.
ARG STARBURST_DRIVER_VERSION=5.0.0

ADD --chmod=644 \
    https://github.com/starburstdata/metabase-driver/releases/download/${STARBURST_DRIVER_VERSION}/starburst-${STARBURST_DRIVER_VERSION}.metabase-driver.jar \
    /plugins/starburst-${STARBURST_DRIVER_VERSION}.metabase-driver.jar
