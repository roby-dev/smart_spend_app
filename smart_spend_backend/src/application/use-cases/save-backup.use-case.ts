import { Backup, CompraData } from '../../domain/entities/backup.entity';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';

export class SaveBackupUseCase {
  constructor(private readonly backupRepository: IBackupRepository) {}

  async execute(userId: string, compras: CompraData[]): Promise<Backup> {
    return this.backupRepository.upsertByUserId(userId, compras);
  }
}
