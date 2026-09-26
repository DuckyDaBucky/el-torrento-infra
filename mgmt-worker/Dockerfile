FROM node:22-bookworm-slim
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev
COPY worker.mjs policy.mjs ./
ENV PORT=9090
EXPOSE 9090
USER node
CMD ["node", "worker.mjs"]
