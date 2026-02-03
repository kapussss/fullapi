# Sử dụng Node.js LTS làm base image
FROM node:18-alpine

# Tạo thư mục ứng dụng
WORKDIR /app

# Sao chép package files
COPY package*.json ./

# Cài đặt dependencies
RUN npm ci --only=production

# Sao chép source code
COPY . .

# Tạo non-root user để chạy ứng dụng
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 3002

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "const http = require('http'); const req = http.get('http://localhost:3002/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }); req.on('error', () => { process.exit(1); });"

# Khởi chạy ứng dụng
CMD ["node", "server.js"]
