import { CompraData } from '../../domain/entities/backup.entity';

export class BackupSnapshotResponseDto {
  id: string;
  name?: string;
  compras: CompraData[];
  createdAt: string;

  constructor(
    id: string,
    compras: CompraData[],
    createdAt: Date,
    name?: string,
  ) {
    this.id = id;
    this.compras = compras;
    this.createdAt = createdAt.toISOString();
    if (name) {
      this.name = name;
    }
  }
}
