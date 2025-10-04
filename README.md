# Acquisitions Application

A Node.js Express application with Drizzle ORM and Neon Database integration, fully dockerized for both development and production environments.

## 🏗 Architecture Overview

This application is designed to work differently in development and production:

- **Development**: Uses Neon Local proxy for ephemeral database branches
- **Production**: Connects directly to Neon Cloud Database

## 📋 Prerequisites

- Docker & Docker Compose
- A Neon Cloud account and project
- Your Neon API key and project ID

## 🛠 Getting Started

### 1. Clone and Setup

```bash
git clone <repository-url>
cd acquisitions
```

### 2. Configure Environment Variables

#### For Development

1. Copy the development environment template:
   ```bash
   cp .env.development .env.development.local
   ```

2. Update `.env.development.local` with your Neon credentials:
   ```env
   NEON_API_KEY=your_actual_neon_api_key
   NEON_PROJECT_ID=your_actual_neon_project_id
   PARENT_BRANCH_ID=your_main_branch_id
   ARCJET_KEY=your_arcjet_key
   ```

#### For Production

1. Copy the production environment template:
   ```bash
   cp .env.production .env.production.local
   ```

2. Update `.env.production.local` with your production values:
   ```env
   DATABASE_URL=postgresql://neondb_owner:your_password@your-endpoint.neon.tech/neondb?sslmode=require&channel_binding=require
   ARCJET_KEY=your_production_arcjet_key
   ```

## 🚀 Development Environment

The development setup uses Neon Local, which creates ephemeral database branches that are automatically created when you start and deleted when you stop.

### Start Development Environment

```bash
# Use your local environment file
docker-compose --env-file .env.development.local -f docker-compose.dev.yml up --build
```

### What This Gives You

- **Application**: http://localhost:3000
- **Neon Local Proxy**: localhost:5432
- **Hot Reload**: Source code changes are reflected immediately
- **Fresh Database**: Each startup creates a new ephemeral branch from your main branch

### Optional: Start with Database Studio

```bash
# Start with Drizzle Studio for database management
docker-compose --env-file .env.development.local -f docker-compose.dev.yml --profile tools up --build
```

- **Drizzle Studio**: http://localhost:4983

### Development Workflow

1. **Start the environment**: `docker-compose --env-file .env.development.local -f docker-compose.dev.yml up`
2. **Your app connects to**: `postgres://neon:npg@neon-local:5432/neondb`
3. **Neon Local handles**: Authentication and routing to your Neon project
4. **Database changes**: Are made on an ephemeral branch, perfect for testing
5. **Stop the environment**: `Ctrl+C` (ephemeral branch is automatically deleted)

## 🏭 Production Environment

The production setup connects directly to your Neon Cloud database without any proxy.

### Deploy to Production

```bash
# Use your production environment file
docker-compose --env-file .env.production.local -f docker-compose.prod.yml up --build -d
```

### Production Features

- **Direct Neon Connection**: No proxy, connects straight to Neon Cloud
- **Health Checks**: Automatic application health monitoring
- **Resource Limits**: Memory and CPU constraints for stability
- **Restart Policies**: Automatic restart on failure

### Optional: Start with Reverse Proxy

```bash
# Start with Traefik reverse proxy and SSL
docker-compose --env-file .env.production.local -f docker-compose.prod.yml --profile proxy up --build -d
```

### Optional: Start with Monitoring

```bash
# Start with Prometheus monitoring
docker-compose --env-file .env.production.local -f docker-compose.prod.yml --profile monitoring up --build -d
```

## 📊 Database Configuration

The application automatically detects the environment and configures the database connection accordingly:

### Development (Neon Local)
- Uses HTTP-based communication
- Disables secure WebSocket
- Allows self-signed certificates
- Provides detailed logging

### Production (Neon Cloud)
- Uses secure WebSocket when available
- Enforces SSL certificate validation
- Optimized for performance

## 🔧 Available Scripts

```bash
# Development
npm run dev          # Start with hot reload
npm start           # Start production server
npm run lint        # Run ESLint
npm run format      # Format with Prettier

# Database
npm run db:generate # Generate database migrations
npm run db:migrate  # Run database migrations
npm run db:studio   # Open Drizzle Studio
```

## 🔄 Environment Switching

The application uses these environment files:

- `.env.development` - Development template (committed)
- `.env.production` - Production template (committed)
- `.env.development.local` - Your dev secrets (gitignored)
- `.env.production.local` - Your prod secrets (gitignored)

## 📁 Important Files

```
.
├── Dockerfile                    # Multi-stage Docker build
├── docker-compose.dev.yml        # Development with Neon Local
├── docker-compose.prod.yml       # Production with Neon Cloud
├── .env.development              # Dev environment template
├── .env.production               # Prod environment template
├── src/config/database.js        # Smart database configuration
└── drizzle.config.js            # Database schema configuration
```

## 🔍 Troubleshooting

### Development Issues

**Neon Local not connecting?**
1. Verify your `NEON_API_KEY` and `NEON_PROJECT_ID` are correct
2. Check that your `PARENT_BRANCH_ID` exists in your Neon project
3. Look at Neon Local container logs: `docker logs acquisitions-neon-local`

**App can't connect to database?**
1. Ensure Neon Local container is healthy: `docker ps`
2. Check if DATABASE_URL points to `neon-local:5432`
3. Verify the containers are on the same Docker network

### Production Issues

**Database connection failed?**
1. Verify your production `DATABASE_URL` is correct
2. Check Neon Cloud dashboard for connection limits
3. Ensure your connection string includes `sslmode=require`

**Application won't start?**
1. Check container logs: `docker logs acquisitions-app-prod`
2. Verify all required environment variables are set
3. Test database connection manually

### General Docker Issues

**Port conflicts?**
```bash
# Check what's using the ports
netstat -tulpn | grep :3000
netstat -tulpn | grep :5432

# Stop conflicting services or change ports in docker-compose files
```

**Permission issues?**
```bash
# Reset Docker volumes
docker-compose down -v
docker system prune -f
```

## 🔐 Security Notes

1. **Never commit secrets**: Use `.local` files for sensitive data
2. **Production SSL**: Always use `sslmode=require` for Neon Cloud
3. **Container security**: Application runs as non-root user
4. **Network isolation**: Services use isolated Docker networks

## 📚 Learn More

- [Neon Local Documentation](https://neon.com/docs/local/neon-local)
- [Drizzle ORM Documentation](https://orm.drizzle.team/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Test locally: `docker-compose --env-file .env.development.local -f docker-compose.dev.yml up`
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

## 📄 License

This project is licensed under the ISC License.