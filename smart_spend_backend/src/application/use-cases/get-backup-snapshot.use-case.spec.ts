import { GetBackupSnapshotUseCase } from './get-backup-snapshot.use-case';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';
import { BackupSnapshot } from '../../domain/entities/backup-snapshot.entity';
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

describe('GetBackupSnapshotUseCase', () => {
  let useCase: GetBackupSnapshotUseCase;
  let repo: jest.Mocked<IBackupRepository>;

  beforeEach(() => {
    repo = makeRepo();
    useCase = new GetBackupSnapshotUseCase(repo);
  });

  it('should return the snapshot when found', async () => {
    const snapshot = BackupSnapshot.fromPersistence({
      id: 'snap-1',
      userId: 'user-1',
      compras: [],
      createdAt: new Date('2026-05-14'),
    });
    repo.findSnapshotById.mockResolvedValue(snapshot);

    const result = await useCase.execute('snap-1');

    expect(repo.findSnapshotById).toHaveBeenCalledWith('snap-1');
    expect(result).toBe(snapshot);
  });

  it('should throw BackupNotFoundError when snapshot not found', async () => {
    repo.findSnapshotById.mockResolvedValue(null);

    await expect(useCase.execute('snap-999')).rejects.toThrow(
      BackupNotFoundError,
    );
  });

  it('should propagate repository errors', async () => {
    repo.findSnapshotById.mockRejectedValue(new Error('mongo down'));

    await expect(useCase.execute('snap-1')).rejects.toThrow('mongo down');
  });
});
