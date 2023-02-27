FROM --platform=linux/amd64 node:16

# Create app directory
WORKDIR /app

COPY package*.json ./
COPY yarn.lock ./

COPY ./ci/app.js ./

# Install app dependencies
RUN yarn install

EXPOSE 8000
EXPOSE 4443
CMD [ "node", "app.js" ]