# Use the official OpenFlagr image as the base image
ARG FLAGR_IMAGE_TAG=1.1.16

FROM ghcr.io/openflagr/flagr:${FLAGR_IMAGE_TAG} AS base

COPY --chown=root:root ./flagr/data/demo.db /data/db/demo.db

USER root
# Expose the necessary ports if your application requires it
EXPOSE 18000
