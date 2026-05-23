import { GetBackupUseCase } from './get-backup.use-case';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';
import { Backup } from '../../domain/entities/backup.entity';
import { BackupNotFoundError } from '../../domain/exceptions/backup.exceptions';

function makeRepo(): jest.Mocked<IBackupRepository> {
  return {
    upsertByUserId: jest.fn(),
    findByUserId: jest.fn(),
  };
}

describe('GetBackupUseCase', () => {
  let useCase: GetBackupUseCase;
  let repo: jest.Mocked<IBackupRepository>;

  beforeEach(() => {
    repo = makeRepo();
    useCase = new GetBackupUseCase(repo);
  });

  it('should return the backup when one exists', async () => {
    const stored = Backup.fromPersistence({
      userId: 'user-1',
      compras: [],
      createdAt: new Date('2026-01-01'),
      updatedAt: new Date('2026-05-14'),
    });
    repo.findByUserId.mockResolvedValue(stored);

    const result = await useCase.execute('user-1');

    expect(repo.findByUserId).toHaveBeenCalledWith('user-1');
    expect(result).toBe(stored);
  });

  it('should throw BackupNotFoundError when no backup exists', async () => {
    repo.findByUserId.mockResolvedValue(null);

    await expect(useCase.execute('user-1')).rejects.toThrow(
      BackupNotFoundError,
    );
  });
});
