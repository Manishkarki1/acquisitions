# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Node.js Express API for an acquisitions system built with:
- **Express.js** - Web framework
- **Drizzle ORM** - Database ORM with PostgreSQL
- **Neon Database** - Serverless PostgreSQL provider
- **JWT + Cookies** - Authentication system
- **Zod** - Schema validation
- **Winston** - Logging
- **ES Modules** - Modern JavaScript modules with path imports

## Common Development Commands

### Development Server
```bash
npm run dev              # Start development server with hot reload using --watch
```

### Code Quality
```bash
npm run lint             # Run ESLint
npm run lint:fix         # Auto-fix ESLint issues
npm run format           # Format code with Prettier
npm run format:check     # Check formatting without changes
```

### Database Operations
```bash
npm run db:generate      # Generate Drizzle migrations from schema changes
npm run db:migrate       # Apply migrations to database
npm run db:studio        # Open Drizzle Studio (database GUI)
```

## Architecture Overview

### Project Structure
The codebase follows a clean layered architecture with path imports for better organization:

```
src/
├── config/          # Configuration (database, logger)
├── controllers/     # Request handlers and route logic
├── middleware/      # Express middleware (currently none implemented)
├── models/          # Drizzle database schemas
├── routes/          # Express route definitions
├── services/        # Business logic and data access
├── utils/           # Utility functions (JWT, cookies, formatting)
└── validations/     # Zod schema validations
```

### Path Import System
The project uses Node.js subpath imports defined in `package.json`:
- `#config/*` → `./src/config/*`
- `#controllers/*` → `./src/controllers/*`
- `#middleware/*` → `./src/middleware/*`
- `#models/*` → `./src/models/*`
- `#routes/*` → `./src/routes/*`
- `#services/*` → `./src/services/*`
- `#utils/*` → `./src/utils/*`
- `#validations/*` → `./src/validations/*`

Always use these path imports instead of relative paths when importing across directories.

### Database Architecture
- **ORM**: Drizzle ORM with Neon Database (serverless PostgreSQL)
- **Migrations**: Located in `/drizzle/` directory, managed by Drizzle Kit
- **Models**: Defined in `src/models/` using Drizzle's schema syntax
- **Connection**: Configured in `src/config/database.js`

Current schema includes:
- `users` table with authentication fields (id, name, email, password, role, timestamps)

### Authentication Flow
- Uses JWT tokens stored in HTTP-only cookies
- Password hashing with bcrypt (salt rounds: 10)
- Role-based access (user/admin roles)
- Cookie settings configured for security (httpOnly, secure in production, sameSite: strict)
- Token expiration: 1 day default (configurable via JWT_EXPIRES_IN)

### Validation Strategy
- All input validation uses Zod schemas
- Validation schemas are centralized in `src/validations/`
- Validation errors are formatted consistently using `formatValidationError` utility
- Controllers handle validation before passing data to services

### Logging System
- Winston logger configured in `src/config/logger.js`
- Logs to files: `logs/error.log` and `logs/combined.log`
- Console logging in non-production environments
- Request logging via Morgan middleware

## Environment Configuration

Key environment variables (defined in `.env`):
- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `LOG_LEVEL` - Winston log level (default: info)
- `DATABASE_URL` - Neon PostgreSQL connection string
- `JWT_SECRET` - JWT signing secret (defaults to 'jwt_secret' - change in production)
- `JWT_EXPIRES_IN` - Token expiration (default: '1d')

## Development Guidelines

### Code Style
- ESLint configuration enforces:
  - 2-space indentation
  - Single quotes
  - Semicolons required
  - No unused variables (except with `_` prefix)
  - Prefer const/arrow functions
- Prettier handles formatting
- Windows line endings configured for cross-platform compatibility

### Adding New Features
1. **Routes**: Define in `src/routes/` and register in `src/app.js`
2. **Controllers**: Handle HTTP requests, validation, and responses
3. **Services**: Implement business logic and database operations
4. **Models**: Add database schemas in `src/models/`
5. **Validations**: Create Zod schemas in `src/validations/`
6. **Database Changes**: Run `npm run db:generate` after model changes, then `npm run db:migrate`

### Database Workflow
1. Modify schema files in `src/models/`
2. Generate migrations: `npm run db:generate`
3. Review generated SQL in `/drizzle/` directory
4. Apply migrations: `npm run db:migrate`
5. Use `npm run db:studio` for visual database management

### Testing Database Changes
Currently no test database setup exists. When implementing tests, consider:
- Separate test database configuration
- Database seeding for consistent test data
- Transaction rollbacks between tests

## Security Considerations

- JWT tokens are stored in HTTP-only cookies to prevent XSS
- CORS and Helmet middleware configured for security headers
- Password hashing with bcrypt
- Environment variables for sensitive configuration
- Input validation with Zod schemas prevents injection attacks