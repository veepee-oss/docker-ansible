ARG ANSIBLE_VERSION="2.15"

FROM docker.registry.vptech.eu/python:3.10-alpine AS base

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

ENV ANSIBLE_215_LATEST="2.15.4"
ENV ANSIBLE_211_LATEST="2.11.12"
ENV ANSIBLE_210_LATEST="2.10.7"
ENV ANSIBLE_29_LATEST="2.9.27"

ENV ANSIBLE_COMMUNITY_GENERAL_VERSION="7.4.0"
ENV _GALAXY_ARTIFACT_URL="https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts"

# that's how you match patterns in sh! xD
FROM base AS install-2.15
RUN \
  case ${ANSIBLE_215_LATEST} in \
    ${ANSIBLE_VERSION}*) \
      pip3 install --quiet "ansible-core==${ANSIBLE_215_LATEST}";; \
  esac

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
    pip3 install --quiet hvac openshift psycopg2

# this fails in some legacy ansible version : ansible-galaxy collection install community.general --force
# emulate it...
RUN set -x && \
  wget "${_GALAXY_ARTIFACT_URL}/community-general-${ANSIBLE_COMMUNITY_GENERAL_VERSION}.tar.gz" \
    -O community_general.tgz --quiet && \
  ansible-galaxy collection install ./community_general.tgz && \
  rm community_general.tgz

RUN apk del --no-cache --quiet \
      build-base \
      gcc \
      cargo \
      make  && \
    rm -rf /var/cache/apk/*

CMD [ "ansible", "--version" ]

HEALTHCHECK NONE
# EOF
