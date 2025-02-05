# Use a specific Node.js version on Alpine base image
FROM node:16-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (before the rest of the code)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy only the necessary files (excluding unwanted files from .dockerignore)
COPY src/ ./src/
COPY public/ ./public/

# Expose the port the app will run on
EXPOSE 3000

# Define the command to start your app (make sure it's set in package.json scripts)
CMD ["npm", "run", "start"]
