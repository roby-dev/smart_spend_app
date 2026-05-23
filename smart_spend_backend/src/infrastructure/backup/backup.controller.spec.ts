import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import request from 'supertest';
import { AuthModule } from '../auth/auth.module';
import { BackupModule } from './backup.module';
import { GoogleTokenVerifier } from '../auth/verifiers/google-token-verifier.service';
import { AppleTokenVerifier } from '../auth/verifiers/apple-token-verifier.service';
import { HttpExceptionFilter } from '../common/http-exception.filter';
import {
  jwtConfig,
  googleConfig,
  appleConfig,
  mongoConfig,
} from '../../config/app.config';

const sampleCompras = [
  {
    titulo: 'Mercado',
    fecha: '2025-06-22T10:44:53.388Z',
    archivado: false,
    presupuesto: null,
    orden: 0,
    detalles: [
      { nombre: 'Pollo', precio: 12.5, fecha: '2026-03-05T21:57:56.829Z' },
      { nombre: 'Lechuga', precio: 3, fecha: '2026-03-29T08:45:25.827Z' },
    ],
  },
  {
    titulo: 'Plaza vea',
    fecha: '2025-09-14T18:03:48.262Z',
    archivado: true,
    presupuesto: 100,
    orden: 1,
    detalles: [],
  },
];

describe('BackupController (Integration)', () => {
  let app: INestApplication;
  let mongoServer: MongoMemoryServer;
  let mockGoogleVerify: jest.Mock;

  async function loginAndGetTokens(sub: string, email: string) {
    mockGoogleVerify.mockResolvedValue({ sub, email, name: 'Tester' });
    const res = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ provider: 'google', idToken: 'valid-token' })
      .expect(200);
    return res.body as { accessToken: string; refreshToken: string };
  }

  beforeAll(async () => {
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
    const mockAppleVerify = jest.fn();

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          ignoreEnvFile: true,
          load: [jwtConfig, googleConfig, appleConfig, mongoConfig],
        }),
        MongooseModule.forRoot(uri),
        AuthModule,
        BackupModule,
      ],
    })
      .overrideProvider(GoogleTokenVerifier)
      .useValue({ verify: mockGoogleVerify })
      .overrideProvider(AppleTokenVerifier)
      .useValue({ verify: mockAppleVerify })
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

  describe('Guard', () => {
    it('B1: no Authorization header → 401', async () => {
      await request(app.getHttpServer())
        .post('/backup')
        .send({ compras: sampleCompras })
        .expect(401);
    });

    it('B2: GET without token → 401', async () => {
      await request(app.getHttpServer()).get('/backup').expect(401);
    });
  });

  describe('POST /backup', () => {
    it('B3: valid token + valid body → 200 with compras and updatedAt', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-save-1',
        'save1@test.com',
      );

      const res = await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      expect(res.body.compras).toHaveLength(2);
      expect(res.body.compras[0].titulo).toBe('Mercado');
      expect(typeof res.body.updatedAt).toBe('string');
    });

    it('B4: second POST overwrites the previous snapshot', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-save-2',
        'save2@test.com',
      );

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: [sampleCompras[0]] })
        .expect(200);

      const res = await request(app.getHttpServer())
        .get('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.compras).toHaveLength(1);
    });

    it('B5: invalid body (compra missing titulo) → 400', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-save-3',
        'save3@test.com',
      );

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: [{ fecha: '2025-01-01T00:00:00.000Z' }] })
        .expect(400);
    });

    it('B6: missing compras field → 400', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-save-4',
        'save4@test.com',
      );

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({})
        .expect(400);
    });
  });

  describe('GET /backup', () => {
    it('B7: no backup yet → 404', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-get-1',
        'get1@test.com',
      );

      await request(app.getHttpServer())
        .get('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(404);
    });

    it('B8: after POST → 200 round-trips the saved compras', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-get-2',
        'get2@test.com',
      );

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      const res = await request(app.getHttpServer())
        .get('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.compras).toEqual(sampleCompras);
    });

    it('B9: backups are isolated per user', async () => {
      const userA = await loginAndGetTokens('g-iso-a', 'isoa@test.com');
      const userB = await loginAndGetTokens('g-iso-b', 'isob@test.com');

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${userA.accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      // User B has no backup of their own
      await request(app.getHttpServer())
        .get('/backup')
        .set('Authorization', `Bearer ${userB.accessToken}`)
        .expect(404);
    });
  });
});
