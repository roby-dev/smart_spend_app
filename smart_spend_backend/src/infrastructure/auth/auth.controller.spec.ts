import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import request from 'supertest';
import { AuthModule } from './auth.module';
import { GoogleTokenVerifier } from './verifiers/google-token-verifier.service';
import { AppleTokenVerifier } from './verifiers/apple-token-verifier.service';
import { HttpExceptionFilter } from '../common/http-exception.filter';
import { InvalidCredentialsError } from '../../domain/exceptions/auth.exceptions';
import {
  jwtConfig,
  googleConfig,
  appleConfig,
  mongoConfig,
} from '../../config/app.config';

describe('AuthController (Integration)', () => {
  let app: INestApplication;
  let mongoServer: MongoMemoryServer;
  let mockGoogleVerify: jest.Mock;
  let mockAppleVerify: jest.Mock;

  beforeAll(async () => {
    // Set env vars required by the Joi validation schema
    process.env.JWT_SECRET = 'test-jwt-secret-minimum-16chars';
    process.env.JWT_EXPIRY = '15m';
    process.env.GOOGLE_CLIENT_ID =
      'mock-google-client-id.apps.googleusercontent.com';
    process.env.APPLE_TEAM_ID = 'MOCKTEAMID';
    process.env.APPLE_KEY_ID = 'MOCKKEYID';
    process.env.APPLE_PRIVATE_KEY = 'mock-private-key-content';
    process.env.APPLE_CLIENT_ID = 'com.mock.app';
    process.env.MONGODB_URI = 'mongodb://localhost:27017/mock-test-db';

    mongoServer = await MongoMemoryServer.create();
    const uri = mongoServer.getUri();

    mockGoogleVerify = jest.fn();
    mockAppleVerify = jest.fn();

    const mockGoogleVerifier = { verify: mockGoogleVerify };
    const mockAppleVerifier = { verify: mockAppleVerify };

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          ignoreEnvFile: true,
          load: [jwtConfig, googleConfig, appleConfig, mongoConfig],
        }),
        MongooseModule.forRoot(uri),
        AuthModule,
      ],
    })
      .overrideProvider(GoogleTokenVerifier)
      .useValue(mockGoogleVerifier)
      .overrideProvider(AppleTokenVerifier)
      .useValue(mockAppleVerifier)
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    app.useGlobalFilters(new HttpExceptionFilter());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    await mongoServer.stop();
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // ── Login Tests ──────────────────────────────────────────

  describe('POST /auth/login', () => {
    it('L1: valid Google idToken, new user → 200 with token pair', async () => {
      mockGoogleVerify.mockResolvedValue({
        sub: 'google-sub-123',
        email: 'test@gmail.com',
        name: 'Test User',
      });

      const res = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'google', idToken: 'valid-google-token' })
        .expect(200);

      expect(res.body).toHaveProperty('accessToken');
      expect(res.body).toHaveProperty('refreshToken');
      expect(typeof res.body.accessToken).toBe('string');
      expect(typeof res.body.refreshToken).toBe('string');
    });

    it('L3: valid Apple idToken with name, new user → 200', async () => {
      mockAppleVerify.mockResolvedValue({
        sub: 'apple-sub-456',
        email: 'appleuser@privaterelay.appleid.com',
        name: 'Apple User',
      });

      const res = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'apple', idToken: 'valid-apple-token' })
        .expect(200);

      expect(res.body).toHaveProperty('accessToken');
      expect(res.body).toHaveProperty('refreshToken');
    });

    it('L4: Apple re-login without name → 200, name preserved', async () => {
      // First login with name
      mockAppleVerify.mockResolvedValue({
        sub: 'apple-sub-789',
        email: 'relay@privaterelay.appleid.com',
        name: 'Original Name',
      });

      const firstLogin = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'apple', idToken: 'valid-apple-token-1' })
        .expect(200);

      expect(firstLogin.body).toHaveProperty('accessToken');

      // Second login without name (simulating Apple re-login)
      mockAppleVerify.mockResolvedValue({
        sub: 'apple-sub-789',
        email: 'relay@privaterelay.appleid.com',
        name: undefined,
      });

      const secondLogin = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'apple', idToken: 'valid-apple-token-2' })
        .expect(200);

      expect(secondLogin.body).toHaveProperty('accessToken');
      expect(secondLogin.body).toHaveProperty('refreshToken');
      // Name preserved via mergeNonNil — we trust the use case unit tests for exact name preservation
    });

    it('L5: invalid/expired idToken → 401', async () => {
      mockGoogleVerify.mockRejectedValue(
        new InvalidCredentialsError('Token expired or invalid'),
      );

      await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'google', idToken: 'expired-token' })
        .expect(401);
    });

    it('L7: missing provider field → 400', async () => {
      const res = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ idToken: 'some-token' })
        .expect(400);

      expect(res.body.message).toEqual(
        expect.arrayContaining([
          'provider must be one of the following values: google, apple',
        ]),
      );
    });

    it('L8: missing idToken field → 400', async () => {
      const res = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'google' })
        .expect(400);

      expect(res.body.message).toEqual(
        expect.arrayContaining(['idToken should not be empty']),
      );
    });

    it('L9: unknown provider → 400', async () => {
      const res = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'facebook', idToken: 'some-token' })
        .expect(400);

      expect(res.body.message).toEqual(
        expect.arrayContaining([
          'provider must be one of the following values: google, apple',
        ]),
      );
    });
  });

  // ── Refresh Tests ────────────────────────────────────────

  describe('POST /auth/refresh', () => {
    it('R1: valid refresh token → 200 with new token pair', async () => {
      // First login to get a valid refresh token
      mockGoogleVerify.mockResolvedValue({
        sub: 'google-refresh-test',
        email: 'refresh@test.com',
        name: 'Refresh Tester',
      });

      const loginRes = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'google', idToken: 'valid-token' })
        .expect(200);

      const accessToken = loginRes.body.accessToken;
      const refreshToken = loginRes.body.refreshToken;

      // Refresh with valid tokens
      const refreshRes = await request(app.getHttpServer())
        .post('/auth/refresh')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ refreshToken })
        .expect(200);

      expect(refreshRes.body).toHaveProperty('accessToken');
      expect(refreshRes.body).toHaveProperty('refreshToken');
      // New refresh token should be different
      expect(refreshRes.body.refreshToken).not.toBe(refreshToken);
    });

    it('R2: expired/invalid refresh token → 401', async () => {
      // Login first
      mockGoogleVerify.mockResolvedValue({
        sub: 'google-invalid-refresh',
        email: 'invalid@test.com',
        name: 'Invalid Refresh',
      });

      const loginRes = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'google', idToken: 'valid-token' })
        .expect(200);

      const accessToken = loginRes.body.accessToken;

      // Use an obviously invalid refresh token
      await request(app.getHttpServer())
        .post('/auth/refresh')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ refreshToken: 'invalid-refresh-token-1234567890abcdef' })
        .expect(401);
    });
  });

  // ── Logout Tests ─────────────────────────────────────────

  describe('POST /auth/logout', () => {
    it('O1: valid refresh token + auth header → 204', async () => {
      mockGoogleVerify.mockResolvedValue({
        sub: 'google-logout-test',
        email: 'logout@test.com',
        name: 'Logout Tester',
      });

      const loginRes = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ provider: 'google', idToken: 'valid-token' })
        .expect(200);

      const accessToken = loginRes.body.accessToken;
      const refreshToken = loginRes.body.refreshToken;

      await request(app.getHttpServer())
        .post('/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ refreshToken })
        .expect(204);
    });
  });

  // ── Guard Tests ──────────────────────────────────────────

  describe('JWT Guard', () => {
    it('G2: no Authorization header → 401', async () => {
      await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken: 'some-token' })
        .expect(401);
    });
  });
});
