# FROM node:16.17.0-alpine as builder
# WORKDIR /app
# COPY ./package.json .
# COPY ./yarn.lock .
# RUN yarn install
# COPY . .
# ARG TMDB_V3_API_KEY
# ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
# ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
# RUN yarn build

# FROM nginx:stable-alpine
# WORKDIR /usr/share/nginx/html
# RUN rm -rf ./*
# COPY --from=builder /app/dist .
# EXPOSE 80
# ENTRYPOINT ["nginx", "-g", "daemon off;"]


# Build stage
FROM node:16.17.0-alpine AS builder

WORKDIR /app

# Copy dependency files first to leverage Docker cache
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy rest of the application
COPY . .

# Use build arg for API key
# WARNING: Build args are visible in image history
# For production, use runtime secrets management instead
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the application
RUN yarn install
# Production stage
FROM nginx:stable-alpine

WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy built assets from builder stage
COPY --from=builder /app/dist .

# Expose port 80
EXPOSE 80

# Start nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]
