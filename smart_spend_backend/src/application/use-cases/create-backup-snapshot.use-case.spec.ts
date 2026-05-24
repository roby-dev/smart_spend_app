import { CreateBackupSnapshotUseCase } from './create-backup-snapshot.use-case';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';
import { BackupSnapshot } from '../../domain/entities/backup-snapshot.entity';
import { CompraData } from '../../domain/entities/backup.entity';

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
    uuid: 'abc-123',
    detalles: [
      { nombre: 'Pollo', precio: 12.5, fecha: '2026-03-05T21:57:56.829Z', uuid: 'det-1' },
    ],
  },
];

describe('CreateBackupSnapshotUseCase', () => {
  let useCase: CreateBackupSnapshotUseCase;
  let repo: jest.Mocked<IBackupRepository>;

  beforeEach(() => {
    repo = makeRepo();
    useCase = new CreateBackupSnapshotUseCase(repo);
  });

  it('should create a snapshot and return it', async () => {
    const stored = BackupSnapshot.fromPersistence({
      id: 'snap-1',
      userId: 'user-1',
      compras: sampleCompras,
      createdAt: new Date('2026-01-01'),
    });
    repo.createSnapshot.mockResolvedValue(stored);

    const result = await useCase.execute('user-1', sampleCompras);

    expect(repo.createSnapshot).toHaveBeenCalledWith('user-1', sampleCompras);
    expect(result).toBe(stored);
  });

  it('should create a snapshot with empty compras array', async () => {
    const stored = BackupSnapshot.create('user-1', []);
    repo.createSnapshot.mockResolvedValue(stored);

    const result = await useCase.execute('user-1', []);

    expect(repo.createSnapshot).toHaveBeenCalledWith('user-1', []);
    expect(result.compras).toEqual([]);
  });

  it('should propagate repository errors', async () => {
    repo.createSnapshot.mockRejectedValue(new Error('mongo down'));

    await expect(useCase.execute('user-1', sampleCompras)).rejects.toThrow(
      'mongo down',
    );
  });
});
