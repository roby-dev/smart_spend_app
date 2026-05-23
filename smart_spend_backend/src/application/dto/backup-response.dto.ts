import { CompraData } from '../../domain/entities/backup.entity';

export class BackupResponseDto {
  compras: CompraData[];
  updatedAt: string;

  constructor(compras: CompraData[], updatedAt: Date) {
    this.compras = compras;
    this.updatedAt = updatedAt.toISOString();
  }
}
