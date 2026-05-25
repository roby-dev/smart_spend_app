import { BackupSnapshot } from '../../domain/entities/backup-snapshot.entity';
import { CompraData } from '../../domain/entities/backup.entity';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';

export class CreateBackupSnapshotUseCase {
  constructor(private readonly backupRepository: IBackupRepository) {}

  async execute(
    userId: string,
    compras: CompraData[],
    name?: string,
  ): Promise<BackupSnapshot> {
    return this.backupRepository.createSnapshot(userId, compras, name);
  }
}
