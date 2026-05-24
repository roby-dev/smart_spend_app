import { BackupSnapshot } from '../../domain/entities/backup-snapshot.entity';
import { BackupNotFoundError } from '../../domain/exceptions/backup.exceptions';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';

export class GetBackupSnapshotUseCase {
  constructor(private readonly backupRepository: IBackupRepository) {}

  async execute(id: string): Promise<BackupSnapshot> {
    const snapshot = await this.backupRepository.findSnapshotById(id);
    if (!snapshot) {
      throw new BackupNotFoundError('Backup snapshot not found');
    }
    return snapshot;
  }
}
