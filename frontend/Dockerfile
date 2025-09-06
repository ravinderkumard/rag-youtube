# Use official Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install

# Copy rest of the frontend code
COPY frontend/ .

# Build the Next.js app
RUN npm run build

# Expose frontend port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
