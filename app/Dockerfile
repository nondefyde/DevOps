FROM node:16

# Create app directory
WORKDIR /app

COPY package*.json /app
COPY yarn.lock /app

COPY ./app/app.js /app

# Install app dependencies
RUN yarn install

EXPOSE 8000
CMD [ "node", "app.js" ]