import { GetBackupHistoryUseCase } from './get-backup-history.use-case';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';
import { BackupSnapshot } from '../../domain/entities/backup-snapshot.entity';

function makeRepo(): jest.Mocked<IBackupRepository> {
  return {
    upsertByUserId: jest.fn(),
    findByUserId: jest.fn(),
    createSnapshot: jest.fn(),
    findSnapshotsByUserId: jest.fn(),
    findSnapshotById: jest.fn(),
  };
}

describe('GetBackupHistoryUseCase', () => {
  let useCase: GetBackupHistoryUseCase;
  let repo: jest.Mocked<IBackupRepository>;

  beforeEach(() => {
    repo = makeRepo();
    useCase = new GetBackupHistoryUseCase(repo);
  });

  it('should return all snapshots for a user', async () => {
    const snapshots = [
      BackupSnapshot.fromPersistence({
        id: 'snap-1',
        userId: 'user-1',
        compras: [],
        createdAt: new Date('2026-05-14'),
      }),
      BackupSnapshot.fromPersistence({
        id: 'snap-2',
        userId: 'user-1',
        compras: [],
        createdAt: new Date('2026-05-15'),
      }),
    ];
    repo.findSnapshotsByUserId.mockResolvedValue(snapshots);

    const result = await useCase.execute('user-1');

    expect(repo.findSnapshotsByUserId).toHaveBeenCalledWith('user-1');
    expect(result).toHaveLength(2);
    expect(result[0].id).toBe('snap-1');
  });

  it('should return empty array when no snapshots exist', async () => {
    repo.findSnapshotsByUserId.mockResolvedValue([]);

    const result = await useCase.execute('user-1');

    expect(result).toEqual([]);
  });

  it('should propagate repository errors', async () => {
    repo.findSnapshotsByUserId.mockRejectedValue(new Error('mongo down'));

    await expect(useCase.execute('user-1')).rejects.toThrow('mongo down');
  });
});
