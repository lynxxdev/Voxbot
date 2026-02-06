ARG NODE_VERSION=18.18.2-slim
FROM node:${NODE_VERSION} as base

ENV USER=VOX

RUN groupadd -r ${USER} && \
    useradd --create-home --home /home/VOX -r -g ${USER} ${USER}

USER ${USER}
WORKDIR /home/VOX

FROM base as build

COPY --chown=${USER}:${USER}  . .
RUN npm ci
RUN npm run build

RUN rm -rf node_modules && \
    npm ci --omit=dev

FROM node:${NODE_VERSION} as prod

COPY --chown=${USER}:${USER} package*.json ./
COPY --from=build --chown=${USER}:${USER} /home/VOX/node_modules ./node_modules
COPY --from=build --chown=${USER}:${USER} /home/VOX/dist ./dist

CMD [ "node", "./dist/index.js" ]