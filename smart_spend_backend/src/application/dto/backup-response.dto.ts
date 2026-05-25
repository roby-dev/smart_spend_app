import { CompraData } from '../../domain/entities/backup.entity';

export class BackupResponseDto {
  id?: string;
  name?: string;
  compras: CompraData[];
  updatedAt: string;

  constructor(
    compras: CompraData[],
    updatedAt: Date,
    id?: string,
    name?: string,
  ) {
    this.compras = compras;
    this.updatedAt = updatedAt.toISOString();
    if (id) {
      this.id = id;
    }
    if (name) {
      this.name = name;
    }
  }
}
