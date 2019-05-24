FROM alpine:3.9
LABEL maintainer="Django Cass <dj.cass44@gmail.com>"

# Import the require OS dependencies
RUN apk add --update nginx nodejs npm
# Setup NGINX dirs
RUN mkdir -p /var/log/nginx && mkdir -p /var/www/html
# Copy our custom config
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /app
# Install npm packages (this is seperate for caching)
COPY package*.json ./
RUN npm install

COPY . .
# Build production optimised files
RUN npm run build

RUN cp -r dist/* /var/www/html
RUN chown nginx:nginx /var/www/html

EXPOSE 80
# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
