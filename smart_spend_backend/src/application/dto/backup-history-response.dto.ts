export class BackupHistoryResponseDto {
  id: string;
  createdAt: string;
  compraCount: number;

  constructor(id: string, createdAt: Date, compraCount: number) {
    this.id = id;
    this.createdAt = createdAt.toISOString();
    this.compraCount = compraCount;
  }
}
