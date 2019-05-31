# Use the official Node image.
# https://hub.docker.com/_/node
FROM node:10-alpine

# Create and change to the app directory.
WORKDIR /usr/src/app

# [START run_system_package_alpine]
RUN apk --no-cache add graphviz ttf-ubuntu-font-family
# [END run_system_package_alpine]

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./

# Install production dependencies.
RUN npm install --only=production

# Copy local code to the container image.
COPY . .

# Run the web service on container startup.
CMD [ "npm", "start" ]
