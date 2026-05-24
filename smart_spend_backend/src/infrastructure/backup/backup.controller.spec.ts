import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule, getModelToken } from '@nestjs/mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import { Model } from 'mongoose';
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
import { BackupDocument, BackupSchema } from '../persistence/schemas/backup.schema';
import {
  BackupSnapshotDocument,
  BackupSnapshotSchema,
} from '../persistence/schemas/backup-snapshot.schema';
import { UserDocument, UserSchema } from '../persistence/schemas/user.schema';

const sampleCompras = [
  {
    titulo: 'Mercado',
    fecha: '2025-06-22T10:44:53.388Z',
    archivado: false,
    presupuesto: null,
    orden: 0,
    uuid: 'compra-uuid-1',
    detalles: [
      { nombre: 'Pollo', precio: 12.5, fecha: '2026-03-05T21:57:56.829Z', uuid: 'det-uuid-1' },
      { nombre: 'Lechuga', precio: 3, fecha: '2026-03-29T08:45:25.827Z', uuid: 'det-uuid-2' },
    ],
  },
  {
    titulo: 'Plaza vea',
    fecha: '2025-09-14T18:03:48.262Z',
    archivado: true,
    presupuesto: 100,
    orden: 1,
    uuid: 'compra-uuid-2',
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

    it('B10: POST /backup dual-write → writes to old backups AND backup_snapshots', async () => {
      const providerId = 'g-dual-1';
      const { accessToken } = await loginAndGetTokens(providerId, 'dual1@test.com');

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      const userModel = app.get<Model<UserDocument>>(
        getModelToken(UserSchema.name),
      );
      const user = await userModel.findOne({ providerId });
      expect(user).not.toBeNull();
      const userId = user!._id.toString();

      const backupModel = app.get<Model<BackupDocument>>(
        getModelToken(BackupSchema.name),
      );
      const snapshotModel = app.get<Model<BackupSnapshotDocument>>(
        getModelToken(BackupSnapshotSchema.name),
      );

      const oldBackup = await backupModel.findOne({ userId });
      const snapshots = await snapshotModel.find({ userId });

      expect(oldBackup).not.toBeNull();
      expect(oldBackup!.compras).toHaveLength(2);
      expect(snapshots).toHaveLength(1);
      expect(snapshots[0].compras).toHaveLength(2);
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

    it('B11: GET /backup falls back to old collection when no snapshots exist', async () => {
      const providerId = 'g-fallback-1';
      const { accessToken } = await loginAndGetTokens(providerId, 'fallback1@test.com');

      const userModel = app.get<Model<UserDocument>>(
        getModelToken(UserSchema.name),
      );
      const user = await userModel.findOne({ providerId });
      expect(user).not.toBeNull();
      const userId = user!._id.toString();

      const backupModel = app.get<Model<BackupDocument>>(
        getModelToken(BackupSchema.name),
      );

      // Directly insert into old backups collection (simulate pre-migration state)
      await backupModel.create({
        userId: userId,
        compras: sampleCompras,
      });

      // No snapshots were created, so GET should fall back to old collection
      const res = await request(app.getHttpServer())
        .get('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.compras).toHaveLength(2);
      expect(res.body.compras[0].titulo).toBe('Mercado');
    });
  });

  describe('GET /backup/history', () => {
    it('H1: no snapshots → 200 with empty array', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-hist-1',
        'hist1@test.com',
      );

      const res = await request(app.getHttpServer())
        .get('/backup/history')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body).toEqual([]);
    });

    it('H2: after POST → lists snapshots with compraCount', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-hist-2',
        'hist2@test.com',
      );

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      const res = await request(app.getHttpServer())
        .get('/backup/history')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body).toHaveLength(1);
      expect(res.body[0].compraCount).toBe(2);
      expect(typeof res.body[0].id).toBe('string');
      expect(typeof res.body[0].createdAt).toBe('string');
    });

    it('H3: multiple POSTs → multiple snapshots newest-first', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-hist-3',
        'hist3@test.com',
      );

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: [sampleCompras[0]] })
        .expect(200);

      await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      const res = await request(app.getHttpServer())
        .get('/backup/history')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body).toHaveLength(2);
      expect(res.body[0].compraCount).toBe(2); // newest first
      expect(res.body[1].compraCount).toBe(1);
    });
  });

  describe('GET /backup/:id', () => {
    it('S1: existing snapshot → 200 with full data', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-snap-1',
        'snap1@test.com',
      );

      const postRes = await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      const snapshotId = postRes.body.id;

      const res = await request(app.getHttpServer())
        .get(`/backup/${snapshotId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.compras).toHaveLength(2);
      expect(res.body.id).toBe(snapshotId);
    });

    it('S2: non-existent snapshot → 404', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-snap-2',
        'snap2@test.com',
      );

      await request(app.getHttpServer())
        .get('/backup/000000000000000000000000')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(404);
    });
  });

  describe('POST /backup/:id/restore', () => {
    it('R1: full restore → 200 with all compras', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-restore-1',
        'restore1@test.com',
      );

      const postRes = await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      const snapshotId = postRes.body.id;

      const res = await request(app.getHttpServer())
        .post(`/backup/${snapshotId}/restore`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({})
        .expect(200);

      expect(res.body.compras).toHaveLength(2);
    });

    it('R2: selective restore → 200 with selected compras', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-restore-2',
        'restore2@test.com',
      );

      const postRes = await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      const snapshotId = postRes.body.id;

      const res = await request(app.getHttpServer())
        .post(`/backup/${snapshotId}/restore`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ comprasUuids: [sampleCompras[0].uuid] })
        .expect(200);

      // Verify selective restore returns only the requested compra
      expect(res.body.compras).toHaveLength(1);
      expect(res.body.compras[0].uuid).toBe(sampleCompras[0].uuid);
    });

    it('R3: invalid snapshot id → 404', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-restore-3',
        'restore3@test.com',
      );

      await request(app.getHttpServer())
        .post('/backup/000000000000000000000000/restore')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({})
        .expect(404);
    });

    it('R4: selective restore with UUID not in snapshot → 400', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-restore-4',
        'restore4@test.com',
      );

      const postRes = await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      const snapshotId = postRes.body.id;

      const res = await request(app.getHttpServer())
        .post(`/backup/${snapshotId}/restore`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ comprasUuids: ['non-existent-uuid'] })
        .expect(400);

      expect(res.body.message).toContain('UUIDs not found in snapshot');
    });

    it('R5: selective restore with mixed valid/invalid UUIDs → 400', async () => {
      const { accessToken } = await loginAndGetTokens(
        'g-restore-5',
        'restore5@test.com',
      );

      const postRes = await request(app.getHttpServer())
        .post('/backup')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ compras: sampleCompras })
        .expect(200);

      const snapshotId = postRes.body.id;

      const res = await request(app.getHttpServer())
        .post(`/backup/${snapshotId}/restore`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ comprasUuids: [sampleCompras[0].uuid, 'bad-uuid'] })
        .expect(400);

      expect(res.body.message).toContain('UUIDs not found in snapshot: bad-uuid');
    });
  });
});
