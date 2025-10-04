import 'dotenv/config';
import { neon, neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import logger from './logger.js';

// Configure Neon based on environment
const configureNeon = () => {
  const isDevelopment = process.env.NODE_ENV === 'development';
  const isNeonLocal = process.env.DATABASE_URL?.includes('neon-local');
  
  if (isDevelopment && isNeonLocal) {
    // Configuration for Neon Local proxy
    logger.info('Configuring database for Neon Local development environment');
    
    // For JavaScript applications using Neon Local, we need special SSL configuration
    neonConfig.fetchEndpoint = process.env.DATABASE_URL.includes('neon-local:5432') 
      ? 'http://neon-local:5432/sql' 
      : 'http://localhost:5432/sql';
    neonConfig.useSecureWebSocket = false;
    neonConfig.poolQueryViaFetch = true;
    
    // SSL configuration for self-signed certificates in development
    neonConfig.ssl = {
      rejectUnauthorized: false
    };
  } else {
    // Configuration for production Neon Cloud
    logger.info('Configuring database for Neon Cloud production environment');
    
    // Use secure WebSocket and standard fetch endpoint for production
    neonConfig.useSecureWebSocket = true;
    neonConfig.poolQueryViaFetch = true;
    
    // Production SSL settings (secure)
    neonConfig.ssl = {
      rejectUnauthorized: true
    };
  }
};

// Apply configuration
configureNeon();

// Validate DATABASE_URL
if (!process.env.DATABASE_URL) {
  logger.error('DATABASE_URL environment variable is required');
  throw new Error('DATABASE_URL environment variable is required');
}

logger.info(`Connecting to database: ${process.env.DATABASE_URL.replace(/:\/\/[^:]+:[^@]+@/, '://***:***@')}`);

// Initialize Neon SQL client
const sql = neon(process.env.DATABASE_URL);

// Initialize Drizzle ORM with the SQL client
const db = drizzle(sql, {
  logger: process.env.NODE_ENV === 'development'
});

// Test database connection
const testConnection = async () => {
  try {
    await sql`SELECT 1 as test`;
    logger.info('Database connection established successfully');
  } catch (error) {
    logger.error('Failed to connect to database:', error.message);
    throw error;
  }
};

// Test connection on startup
testConnection().catch(error => {
  logger.error('Database connection test failed:', error);
  process.exit(1);
});

export { db, sql };
