FROM node:16

# Create app directory
WORKDIR /app

COPY package*.json ./
COPY yarn.lock ./

COPY ./app/app.js ./

# Install app dependencies
RUN yarn install

EXPOSE 8000
CMD [ "node", "app.js" ]