# Use Node.js as base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first
COPY package.json package-lock.json ./

# Install all dependencies (including devDependencies)
RUN npm install

# Copy the entire project
COPY . .

# Declare build arguments
ARG NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ARG CLERK_SECRET_KEY
ARG NEXT_PUBLIC_CLERK_SIGN_IN_URL
ARG NEXT_PUBLIC_CLERK_SIGN_UP_URL
ARG NEXT_PUBLIC_CLERK_FRONTEND_API_URL

# Set environment variables from build arguments
ENV NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=$NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ENV CLERK_SECRET_KEY=$CLERK_SECRET_KEY
ENV NEXT_PUBLIC_CLERK_SIGN_IN_URL=$NEXT_PUBLIC_CLERK_SIGN_IN_URL
ENV NEXT_PUBLIC_CLERK_SIGN_UP_URL=$NEXT_PUBLIC_CLERK_SIGN_UP_URL
ENV NEXT_PUBLIC_CLERK_FRONTEND_API_URL=$NEXT_PUBLIC_CLERK_FRONTEND_API_URL

# Build the Next.js app (environment variables are available at build time)
RUN npm run build

# Expose the port Next.js runs on
EXPOSE 3000

# Start the Next.js app (environment variables are available at runtime)
CMD ["npm", "run", "start"]