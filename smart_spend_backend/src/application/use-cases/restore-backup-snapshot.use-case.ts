import { CompraData } from '../../domain/entities/backup.entity';
import { BackupNotFoundError } from '../../domain/exceptions/backup.exceptions';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';

export class RestoreBackupSnapshotUseCase {
  constructor(private readonly backupRepository: IBackupRepository) {}

  async execute(id: string, comprasUuids?: string[]): Promise<CompraData[]> {
    const snapshot = await this.backupRepository.findSnapshotById(id);
    if (!snapshot) {
      throw new BackupNotFoundError('Backup snapshot not found');
    }

    if (!comprasUuids || comprasUuids.length === 0) {
      return snapshot.compras;
    }

    const compraMap = new Map(snapshot.compras.map((c) => [c.uuid, c]));
    const notFound: string[] = [];

    for (const uuid of comprasUuids) {
      if (!compraMap.has(uuid)) {
        notFound.push(uuid);
      }
    }

    if (notFound.length > 0) {
      throw new Error(
        `UUIDs not found in snapshot: ${notFound.join(', ')}`,
      );
    }

    return comprasUuids.map((uuid) => compraMap.get(uuid)!);
  }
}
