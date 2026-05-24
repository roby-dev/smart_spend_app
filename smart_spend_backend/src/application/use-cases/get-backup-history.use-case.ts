import { BackupSnapshot } from '../../domain/entities/backup-snapshot.entity';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';

export class GetBackupHistoryUseCase {
  constructor(private readonly backupRepository: IBackupRepository) {}

  async execute(userId: string): Promise<BackupSnapshot[]> {
    return this.backupRepository.findSnapshotsByUserId(userId);
  }
}
