import { Backup, CompraData } from '../entities/backup.entity';

export interface IBackupRepository {
  upsertByUserId(userId: string, compras: CompraData[]): Promise<Backup>;

  findByUserId(userId: string): Promise<Backup | null>;
}
