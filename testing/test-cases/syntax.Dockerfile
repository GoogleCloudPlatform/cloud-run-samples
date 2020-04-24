# Doesn't include a version tag
FROM node

# Lowercase instruction
workdir /usr/src/app

# Uses ADD instead of COPY
ADD package*.json ./

# Lowercase instruction
run npm install --only=production

COPY . ./

# Sets the PORT env var
ENV PORT 9000

# Uses ENTRYPOINT over CMD
ENTRYPOINT [ "npm", "start" ]