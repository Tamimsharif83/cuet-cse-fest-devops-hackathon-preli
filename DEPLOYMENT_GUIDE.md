# E-Commerce Microservices - DevOps Implementation

A fully containerized microservices-based e-commerce backend with Docker, featuring secure networking, data persistence, and production-ready DevOps practices.

## 🏗️ Architecture

```
                    ┌─────────────────┐
                    │   Client/User   │
                    └────────┬────────┘
                             │
                             │ HTTP (port 5921)
                             │
                    ┌────────▼────────┐
                    │    Gateway      │
                    │  (port 5921)    │
                    │   [Exposed]     │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
         ┌──────────▼──────────┐      │
         │   Private Network   │      │
         │  (Docker Network)   │      │
         └──────────┬──────────┘      │
                    │                 │
         ┌──────────┴──────────┐      │
         │                     │      │
    ┌────▼────┐         ┌──────▼──────┐
    │ Backend │         │   MongoDB   │
    │(port    │◄────────┤  (port      │
    │ 3847)   │         │  27017)     │
    │[Not     │         │ [Not        │
    │Exposed] │         │ Exposed]    │
    └─────────┘         └─────────────┘
```

## 🔑 Key Features

### Security
- ✅ **Network Isolation**: Only Gateway exposed to public network
- ✅ **Non-root User**: All services run as non-root users
- ✅ **Security Options**: `no-new-privileges`, read-only filesystems (production)
- ✅ **Resource Limits**: CPU and memory constraints in production
- ✅ **Health Checks**: Automated health monitoring for all services

### DevOps Best Practices
- ✅ **Multi-stage Builds**: Optimized Docker images with separate build stages
- ✅ **Layer Caching**: Efficient Docker layer caching for faster builds
- ✅ **Environment Separation**: Distinct dev/prod configurations
- ✅ **Data Persistence**: MongoDB data persists across container restarts
- ✅ **Hot Reload**: Development environment with automatic code reloading
- ✅ **Signal Handling**: Proper signal handling with dumb-init
- ✅ **.dockerignore**: Optimized build context

### Operational Excellence
- ✅ **Comprehensive Makefile**: Easy-to-use commands for all operations
- ✅ **Dependency Management**: Service dependencies with health checks
- ✅ **Logging**: Centralized logging with docker compose logs
- ✅ **Restart Policies**: Automatic restart on failure (production)
- ✅ **Backup/Restore**: Database backup capabilities

## 📁 Project Structure

```
.
├── backend/
│   ├── Dockerfile              # Production build
│   ├── Dockerfile.dev          # Development build with hot-reload
│   ├── .dockerignore           # Build optimization
│   └── src/                    # TypeScript source code
├── gateway/
│   ├── Dockerfile              # Production build
│   ├── Dockerfile.dev          # Development build with hot-reload
│   ├── .dockerignore           # Build optimization
│   └── src/                    # JavaScript source code
├── docker/
│   ├── compose.development.yaml    # Development configuration
│   └── compose.production.yaml     # Production configuration
├── Makefile                    # CLI automation
├── .env                        # Environment variables (not committed)
└── README.md                   # This file
```

## 🚀 Quick Start

### Prerequisites
- Docker (v20.10+)
- Docker Compose (v2.0+)
- Make

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd cuet-cse-fest-devops-hackathon-preli
   ```

2. **Environment variables are already set in `.env`**
   ```bash
   cat .env  # Verify the configuration
   ```

### Development Mode

```bash
# Start all services (builds images on first run)
make dev-up

# View logs
make dev-logs

# View logs for specific service
make logs SERVICE=backend

# Open shell in backend container
make backend-shell

# Open shell in gateway container
make gateway-shell

# Open MongoDB shell
make mongo-shell

# Check running containers
make dev-ps

# Restart services
make dev-restart

# Stop services
make dev-down
```

### Production Mode

```bash
# Start production environment
make prod-up

# View production logs
make prod-logs

# Stop production environment
make prod-down
```

## 🧪 Testing

### Health Checks

```bash
# Gateway health
curl http://localhost:5921/health

# Backend health via gateway
curl http://localhost:5921/api/health
```

### Product Management

```bash
# Create a product
curl -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":99.99}'

# Get all products
curl http://localhost:5921/api/products
```

### Security Verification

```bash
# This should FAIL (backend not directly accessible)
curl http://localhost:3847/api/products
```

### Data Persistence

```bash
# Create a product
curl -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Persistent Product","price":49.99}'

# Restart services
make dev-restart

# Verify data persisted
curl http://localhost:5921/api/products
```

## 📝 Available Make Commands

### Development
- `make dev-up` - Start development environment
- `make dev-down` - Stop development environment
- `make dev-build` - Build development containers
- `make dev-logs` - View development logs
- `make dev-restart` - Restart development services
- `make dev-ps` - Show running development containers

### Production
- `make prod-up` - Start production environment
- `make prod-down` - Stop production environment
- `make prod-build` - Build production containers
- `make prod-logs` - View production logs
- `make prod-restart` - Restart production services

### Utilities
- `make backend-shell` - Open shell in backend container
- `make gateway-shell` - Open shell in gateway container
- `make mongo-shell` - Open MongoDB shell
- `make health` - Check service health
- `make status` - Show container status

### Database
- `make db-backup` - Backup MongoDB database
- `make db-reset` - Reset database (deletes all data)

### Cleanup
- `make clean` - Remove containers and networks
- `make clean-volumes` - Remove all volumes (deletes data)
- `make clean-all` - Complete cleanup (containers, volumes, images)

### Backend
- `make backend-install` - Install backend dependencies
- `make backend-build` - Build backend TypeScript
- `make backend-type-check` - Type check backend code
- `make backend-dev` - Run backend locally (not in Docker)

### Help
- `make help` - Display all available commands

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MONGO_INITDB_ROOT_USERNAME` | MongoDB admin username | admin |
| `MONGO_INITDB_ROOT_PASSWORD` | MongoDB admin password | SecurePassword123 |
| `MONGO_URI` | MongoDB connection string | mongodb://admin:SecurePassword123@mongo:27017/ecommerce?authSource=admin |
| `MONGO_DATABASE` | Database name | ecommerce |
| `BACKEND_PORT` | Backend service port | 3847 (DO NOT CHANGE) |
| `GATEWAY_PORT` | Gateway service port | 5921 (DO NOT CHANGE) |
| `NODE_ENV` | Environment mode | production |

### Port Configuration

- **5921**: Gateway (ONLY port exposed to host)
- **3847**: Backend (internal network only)
- **27017**: MongoDB (internal network only)

## 🏗️ Docker Images

### Production Images
- **Backend**: Multi-stage build with TypeScript compilation
  - Builder stage: Full dependencies + TypeScript build
  - Production stage: Production dependencies only + compiled JS
  - Non-root user, health checks, signal handling

- **Gateway**: Optimized Node.js image
  - Production dependencies only
  - Non-root user, health checks, signal handling

- **MongoDB**: Official mongo:7.0-jammy image
  - Persistent volumes for data and config
  - Health checks via mongosh

### Development Images
- Hot-reload enabled with volume mounts
- Full dependencies including devDependencies
- Source code mounted for live updates

## 🔐 Security Features

1. **Network Segmentation**
   - Private Docker network
   - Only Gateway exposed to host
   - Backend and MongoDB isolated

2. **Container Security**
   - Non-root users in all containers
   - Read-only filesystems (production)
   - No new privileges flag
   - Resource limits

3. **Data Security**
   - MongoDB authentication enabled
   - Credentials via environment variables
   - Named volumes for data persistence

## 📊 Monitoring

### Health Checks
All services have automated health checks:
- **MongoDB**: 30s interval, mongosh ping
- **Backend**: 30s interval, HTTP health endpoint
- **Gateway**: 30s interval, HTTP health endpoint

### Viewing Logs
```bash
# All services
make dev-logs

# Specific service
make logs SERVICE=backend MODE=dev

# Follow logs in production
make prod-logs
```

## 💾 Backup and Restore

### Backup Database
```bash
make db-backup
```
Creates timestamped backup in `backups/` directory.

### Restore Database
```bash
# Stop services
make dev-down

# Restore from backup
docker compose -f docker/compose.development.yaml run --rm mongo \
  mongorestore --username=admin --password=SecurePassword123 \
  --authenticationDatabase=admin --archive < backups/mongo-backup-YYYYMMDD-HHMMSS.archive

# Restart services
make dev-up
```

## 🚨 Troubleshooting

### Services won't start
```bash
# Check logs
make dev-logs

# Check specific service
docker logs ecommerce-backend-dev
docker logs ecommerce-gateway-dev
docker logs ecommerce-mongo-dev
```

### Port conflicts
```bash
# Check if ports are in use
netstat -tuln | grep -E '5921|3847|27017'

# Stop other services using those ports
```

### Database connection issues
```bash
# Reset database
make db-reset

# Restart services
make dev-up
```

### Clean slate
```bash
# Complete cleanup and restart
make clean-all
make dev-up
```

## 🎯 Best Practices Implemented

1. **Infrastructure as Code**: All configuration in version control
2. **Immutable Infrastructure**: Containers are ephemeral, data in volumes
3. **Separation of Concerns**: Gateway, Backend, Database as separate services
4. **Zero-downtime Updates**: Health checks ensure readiness
5. **Resource Optimization**: Multi-stage builds, .dockerignore
6. **Security First**: Network isolation, non-root users, read-only filesystems
7. **Observability**: Health checks, structured logging
8. **Developer Experience**: Makefile for common tasks, hot-reload in dev
9. **Production Ready**: Restart policies, resource limits, health checks

## 📚 Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MongoDB Docker Guide](https://hub.docker.com/_/mongo)

## 🤝 Contributing

This is a hackathon project. For production use, consider:
- Adding SSL/TLS termination
- Implementing rate limiting
- Adding request validation and sanitization
- Setting up monitoring (Prometheus/Grafana)
- Implementing CI/CD pipelines
- Adding automated testing
- Using secrets management (Docker secrets, HashiCorp Vault)

## 📄 License

This project is created for the CUET CSE Fest DevOps Hackathon.
