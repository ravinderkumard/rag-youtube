# Use official Node.js image
FROM node:18-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json ./
RUN npm install

<<<<<<< HEAD
# Copy the rest of the frontend code
COPY . .
=======
# Copy rest of the code
COPY frontend/ .
>>>>>>> 4847b4f (Add terraform script)

# Pass API URL as build argument
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

# Build the Next.js app
RUN npm run build

# Expose frontend port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
