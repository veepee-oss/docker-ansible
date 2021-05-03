# Copyright (c) 2019, Veepee
#
# Permission  to use,  copy, modify,  and/or distribute  this software  for any
# purpose  with or  without  fee is  hereby granted,  provided  that the  above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS  SOFTWARE INCLUDING ALL IMPLIED  WARRANTIES OF MERCHANTABILITY
# AND FITNESS.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL  DAMAGES OR ANY DAMAGES  WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER  TORTIOUS ACTION,  ARISING OUT  OF  OR IN  CONNECTION WITH  THE USE  OR
# PERFORMANCE OF THIS SOFTWARE.

ARG ANSIBLE_VERSION="2.11"

FROM docker.registry.vptech.eu/python:3.9-alpine AS base

RUN apk add --no-cache --quiet \
      bash \
      build-base \
      ca-certificates \
      curl \
      gcc \
      git \
      libc-dev \
      libffi-dev \
      make \
      cargo \
      openssh-client \
      openssl-dev \
      postgresql-client \
      postgresql-dev \
      postgresql-libs \
      unzip

ENV ANSIBLE_211_LATEST="2.11.0"
ENV ANSIBLE_210_LATEST="2.10.7"
ENV ANSIBLE_29_LATEST="2.9.17"

# that's how you match patterns in sh! xD
FROM base AS install-2.11
RUN \
  case ${ANSIBLE_211_LATEST} in \
    ${ANSIBLE_VERSION}*) \
      pip3 install --quiet "ansible-core==${ANSIBLE_211_LATEST}";; \
  esac

FROM base AS install-2.10
RUN \
  case ${ANSIBLE_210_LATEST} in \
    ${ANSIBLE_VERSION}*) \
      pip3 install --quiet "ansible==${ANSIBLE_210_LATEST}";; \
  esac

FROM base AS install-2.9
RUN \
  case ${ANSIBLE_29_LATEST} in \
    ${ANSIBLE_VERSION}*) \
      pip3 install --quiet "ansible==${ANSIBLE_29_LATEST}";; \
  esac

FROM install-${ANSIBLE_VERSION} AS final

RUN pip3 install --quiet --upgrade pip && \
    pip3 install --quiet hvac && \
    pip3 install --quiet openshift && \
    pip3 install --quiet psycopg2

RUN ansible-galaxy collection install community.general

RUN apk del --no-cache --quiet \
      build-base \
      gcc \
      cargo \
      make  && \
    rm -rf /var/cache/apk/*

CMD [ "ansible", "--version" ]

HEALTHCHECK NONE
# EOF
