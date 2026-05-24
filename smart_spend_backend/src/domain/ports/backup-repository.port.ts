import { Backup, CompraData } from '../entities/backup.entity';
import { BackupSnapshot } from '../entities/backup-snapshot.entity';

export interface IBackupRepository {
  upsertByUserId(userId: string, compras: CompraData[]): Promise<Backup>;

  findByUserId(userId: string): Promise<Backup | null>;

  createSnapshot(userId: string, compras: CompraData[]): Promise<BackupSnapshot>;

  findSnapshotsByUserId(userId: string): Promise<BackupSnapshot[]>;

  findSnapshotById(id: string): Promise<BackupSnapshot | null>;
}
