FROM node:carbon-alpine

# Set default values --build-arg
ARG NODE_ENV='zensoft-staging'

# Set env valuess
# example to set env values:
# docker build --build-arg NODE_ENV=env_name <path_to_dir>
ENV NODE_ENV ${NODE_ENV}

WORKDIR /home/app

COPY . .
RUN npm install
RUN echo $NODE_ENV

EXPOSE 8000
CMD [ "npm", "start" ]
