export class BackupHistoryResponseDto {
  id: string;
  name?: string;
  createdAt: string;
  compraCount: number;

  constructor(
    id: string,
    createdAt: Date,
    compraCount: number,
    name?: string,
  ) {
    this.id = id;
    this.createdAt = createdAt.toISOString();
    this.compraCount = compraCount;
    if (name) {
      this.name = name;
    }
  }
}
