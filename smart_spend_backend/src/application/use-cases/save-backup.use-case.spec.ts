import { SaveBackupUseCase } from './save-backup.use-case';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';
import { Backup, CompraData } from '../../domain/entities/backup.entity';

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
    titulo: 'Ahorro',
    fecha: '2025-03-15T20:37:25.290Z',
    archivado: false,
    presupuesto: null,
    orden: 0,
    detalles: [
      { nombre: 'Abril', precio: 3280, fecha: '2026-03-15T15:32:46.881Z' },
    ],
  },
];

describe('SaveBackupUseCase', () => {
  let useCase: SaveBackupUseCase;
  let repo: jest.Mocked<IBackupRepository>;

  beforeEach(() => {
    repo = makeRepo();
    useCase = new SaveBackupUseCase(repo);
  });

  it('should upsert the backup for the given user and return it', async () => {
    const stored = Backup.fromPersistence({
      userId: 'user-1',
      compras: sampleCompras,
      createdAt: new Date('2026-01-01'),
      updatedAt: new Date('2026-05-14'),
    });
    repo.upsertByUserId.mockResolvedValue(stored);

    const result = await useCase.execute('user-1', sampleCompras);

    expect(repo.upsertByUserId).toHaveBeenCalledWith('user-1', sampleCompras);
    expect(result).toBe(stored);
  });

  it('should support overwriting with an empty compras array', async () => {
    const stored = Backup.create('user-1', []);
    repo.upsertByUserId.mockResolvedValue(stored);

    await useCase.execute('user-1', []);

    expect(repo.upsertByUserId).toHaveBeenCalledWith('user-1', []);
  });

  it('should propagate repository errors', async () => {
    repo.upsertByUserId.mockRejectedValue(new Error('mongo down'));

    await expect(useCase.execute('user-1', sampleCompras)).rejects.toThrow(
      'mongo down',
    );
  });
});
