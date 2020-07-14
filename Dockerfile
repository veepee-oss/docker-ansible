# Copyright (c) 2019 , Veepee
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

FROM alpine:3.12.0

ARG ANSIBLE_VERSION="2.9.10"

RUN apk add --no-cache --quiet --virtual \
      .build-deps \
      bash \
      ca-certificates \
      curl \
      gcc \
      git \
      libc-dev \
      libffi-dev \
      make \
      openssh-client \
      openssl-dev \
      postgresql-client \
      postgresql-dev \
      postgresql-libs \
      python3 \
      python3-dev \
      unzip

RUN pip3 install --quiet --upgrade pip && \
    pip3 install --quiet ansible==${ANSIBLE_VERSION} && \
    pip3 install --quiet hvac && \
    pip3 install --quiet openshift && \
    pip3 install --quiet psycopg2

RUN apk del --no-cache --quiet \
      gcc \
      make  && \
    rm -rf /var/cache/apk/*

CMD [ "ansible", "--version" ]

HEALTHCHECK NONE
# EOF