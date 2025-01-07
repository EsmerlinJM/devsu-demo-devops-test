ARG NODE_VERSION=22
ARG WORK_DIR=/usr/src/app
ARG USER=node
ARG PORT=8000

# Pining node version for all stages
FROM node:${NODE_VERSION}-slim AS base
ARG WORK_DIR
ARG USER
ARG PORT

RUN mkdir -p ${WORK_DIR} && \
    chown -R ${USER}:${USER} ${WORK_DIR} && \
    chmod -R 744 ${WORK_DIR}

# Building stage with caches for reinstall dependecies.
FROM base AS deps
WORKDIR ${WORK_DIR}
COPY package*.json ./
RUN npm ci

FROM base as builder
ARG WORK_DIR
WORKDIR ${WORK_DIR}

COPY --from=deps ${WORK_DIR}/node_modules ./node_modules
COPY . .
RUN npm run build

# Runtime stage
FROM base AS runtime
ARG WORK_DIR
ARG USER
ARG PORT

ENV DATABASE_NAME ${DATABASE_NAME}
ENV DATABASE_USER ${DATABASE_USER}
ENV DATABASE_PASSWORD ${DATABASE_PASSWORD}

WORKDIR ${WORK_DIR}
USER ${USER}:${USER}
ENV NODE_ENV=production
COPY --from=builder --chown=${USER}:${USER} ${WORK_DIR} .
COPY --from=builder --chown=${USER}:${USER} ${WORK_DIR}/node_modules ./node_modules

CMD [ "node", "src/index.js" ]

# Setting healcheck
EXPOSE ${PORT}
HEALTHCHECK --interval=5s --timeout=10s --retries=3 CMD curl --silent --fail curl --fail http://localhost:${PORT}/ping || exit 1

