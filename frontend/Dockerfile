FROM node:18-alpine AS builder
WORKDIR /app

# Copy package.json from the context (./frontend)
COPY package.json ./
RUN npm install

# Copy all frontend files
COPY . .

ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

RUN npm run build

# Serve with production-ready image
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app ./
EXPOSE 3000
CMD ["npm", "start"]
