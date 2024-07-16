FROM node:22.4.1 AS build

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./
RUN npm install
COPY . ./
CMD ["npm", "run", "dev", "--","--host"]