import { CompraData } from '../../domain/entities/backup.entity';

export class BackupSnapshotResponseDto {
  id: string;
  compras: CompraData[];
  createdAt: string;

  constructor(id: string, compras: CompraData[], createdAt: Date) {
    this.id = id;
    this.compras = compras;
    this.createdAt = createdAt.toISOString();
  }
}
