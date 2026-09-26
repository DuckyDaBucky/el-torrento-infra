FROM node:22-bookworm-slim
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev
COPY worker.mjs ./
ENV PORT=9090
EXPOSE 9090
CMD ["node", "worker.mjs"]
