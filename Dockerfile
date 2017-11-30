FROM node:carbon-stretch

WORKDIR /home/app

COPY . .
RUN npm install

EXPOSE 8000
CMD [ "npm", "start" ]
