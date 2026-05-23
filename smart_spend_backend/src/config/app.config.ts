import { registerAs } from '@nestjs/config';
import * as Joi from 'joi';

export const appConfig = registerAs('app', () => ({
  port: parseInt(process.env.PORT || '3000', 10),
}));

export const jwtConfig = registerAs('jwt', () => ({
  secret: process.env.JWT_SECRET,
  expiry: process.env.JWT_EXPIRY || '15m',
}));

export const googleConfig = registerAs('google', () => ({
  clientId: process.env.GOOGLE_CLIENT_ID,
}));

export const appleConfig = registerAs('apple', () => ({
  teamId: process.env.APPLE_TEAM_ID,
  keyId: process.env.APPLE_KEY_ID,
  privateKey: process.env.APPLE_PRIVATE_KEY,
  clientId: process.env.APPLE_CLIENT_ID,
}));

export const mongoConfig = registerAs('mongo', () => ({
  uri: process.env.MONGODB_URI,
}));

export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'production', 'test')
    .default('development'),
  PORT: Joi.number().default(3000),
  JWT_SECRET: Joi.string().required().min(16),
  JWT_EXPIRY: Joi.string().default('15m'),
  GOOGLE_CLIENT_ID: Joi.string().required(),
  // Apple Sign-In es opcional (requiere el Apple Developer Program pago).
  // Sin estas vars el backend arranca igual; solo se deshabilita el login con Apple.
  APPLE_TEAM_ID: Joi.string().optional(),
  APPLE_KEY_ID: Joi.string().optional(),
  APPLE_PRIVATE_KEY: Joi.string().optional(),
  APPLE_CLIENT_ID: Joi.string().optional(),
  MONGODB_URI: Joi.string().required().uri(),
});
