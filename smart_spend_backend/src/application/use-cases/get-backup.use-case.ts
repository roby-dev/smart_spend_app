import { Backup } from '../../domain/entities/backup.entity';
import { BackupNotFoundError } from '../../domain/exceptions/backup.exceptions';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';

export class GetBackupUseCase {
  constructor(private readonly backupRepository: IBackupRepository) {}

  async execute(userId: string): Promise<Backup> {
    const backup = await this.backupRepository.findByUserId(userId);
    if (!backup) {
      throw new BackupNotFoundError();
    }
    return backup;
  }
}
