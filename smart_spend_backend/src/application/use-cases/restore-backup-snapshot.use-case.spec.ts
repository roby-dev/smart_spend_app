import { RestoreBackupSnapshotUseCase } from './restore-backup-snapshot.use-case';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';
import { BackupSnapshot } from '../../domain/entities/backup-snapshot.entity';
import { CompraData } from '../../domain/entities/backup.entity';
import { BackupNotFoundError } from '../../domain/exceptions/backup.exceptions';

function makeRepo(): jest.Mocked<IBackupRepository> {
  return {
    upsertByUserId: jest.fn(),
    findByUserId: jest.fn(),
    createSnapshot: jest.fn(),
    findSnapshotsByUserId: jest.fn(),
    findSnapshotById: jest.fn(),
  };
}

const sampleCompras: CompraData[] = [
  {
    titulo: 'Mercado',
    fecha: '2025-06-22T10:44:53.388Z',
    archivado: false,
    presupuesto: null,
    orden: 0,
    uuid: 'a',
    detalles: [
      { nombre: 'Pollo', precio: 12.5, fecha: '2026-03-05T21:57:56.829Z' },
    ],
  },
  {
    titulo: 'Plaza',
    fecha: '2025-06-23T10:44:53.388Z',
    archivado: false,
    presupuesto: null,
    orden: 1,
    uuid: 'b',
    detalles: [],
  },
  {
    titulo: 'Otros',
    fecha: '2025-06-24T10:44:53.388Z',
    archivado: false,
    presupuesto: null,
    orden: 2,
    uuid: 'c',
    detalles: [],
  },
];

describe('RestoreBackupSnapshotUseCase', () => {
  let useCase: RestoreBackupSnapshotUseCase;
  let repo: jest.Mocked<IBackupRepository>;

  beforeEach(() => {
    repo = makeRepo();
    useCase = new RestoreBackupSnapshotUseCase(repo);
  });

  it('should return all compras for full restore (no UUID filter)', async () => {
    const snapshot = BackupSnapshot.fromPersistence({
      id: 'snap-1',
      userId: 'user-1',
      compras: sampleCompras,
      createdAt: new Date('2026-05-14'),
    });
    repo.findSnapshotById.mockResolvedValue(snapshot);

    const result = await useCase.execute('snap-1');

    expect(repo.findSnapshotById).toHaveBeenCalledWith('snap-1');
    expect(result).toHaveLength(3);
    expect(result[0].uuid).toBe('a');
  });

  it('should return only selected compras for selective restore', async () => {
    const snapshot = BackupSnapshot.fromPersistence({
      id: 'snap-1',
      userId: 'user-1',
      compras: sampleCompras,
      createdAt: new Date('2026-05-14'),
    });
    repo.findSnapshotById.mockResolvedValue(snapshot);

    const result = await useCase.execute('snap-1', ['a', 'c']);

    expect(result).toHaveLength(2);
    expect(result.map((c) => c.uuid)).toEqual(['a', 'c']);
  });

  it('should throw BackupNotFoundError when snapshot not found', async () => {
    repo.findSnapshotById.mockResolvedValue(null);

    await expect(useCase.execute('snap-999')).rejects.toThrow(
      BackupNotFoundError,
    );
  });

  it('should throw error when UUID not found in snapshot', async () => {
    const snapshot = BackupSnapshot.fromPersistence({
      id: 'snap-1',
      userId: 'user-1',
      compras: sampleCompras,
      createdAt: new Date('2026-05-14'),
    });
    repo.findSnapshotById.mockResolvedValue(snapshot);

    await expect(useCase.execute('snap-1', ['x'])).rejects.toThrow(
      'UUIDs not found in snapshot: x',
    );
  });

  it('should throw error when some UUIDs are invalid', async () => {
    const snapshot = BackupSnapshot.fromPersistence({
      id: 'snap-1',
      userId: 'user-1',
      compras: sampleCompras,
      createdAt: new Date('2026-05-14'),
    });
    repo.findSnapshotById.mockResolvedValue(snapshot);

    await expect(useCase.execute('snap-1', ['a', 'x'])).rejects.toThrow(
      'UUIDs not found in snapshot: x',
    );
  });
});
