import { CompraData } from '../../domain/entities/backup.entity';

export class BackupResponseDto {
  id?: string;
  compras: CompraData[];
  updatedAt: string;

  constructor(compras: CompraData[], updatedAt: Date, id?: string) {
    this.compras = compras;
    this.updatedAt = updatedAt.toISOString();
    if (id) {
      this.id = id;
    }
  }
}
