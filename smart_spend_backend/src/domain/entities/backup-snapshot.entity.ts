import { CompraData } from './backup.entity';

export class BackupSnapshot {
  public readonly id?: string;
  public readonly userId: string;
  public compras: CompraData[];
  public readonly createdAt: Date;

  private constructor(props: {
    id?: string;
    userId: string;
    compras: CompraData[];
    createdAt: Date;
  }) {
    this.id = props.id;
    this.userId = props.userId;
    this.compras = props.compras;
    this.createdAt = props.createdAt;
  }

  static create(userId: string, compras: CompraData[]): BackupSnapshot {
    return new BackupSnapshot({ userId, compras, createdAt: new Date() });
  }

  static fromPersistence(props: {
    id: string;
    userId: string;
    compras: CompraData[];
    createdAt: Date;
  }): BackupSnapshot {
    return new BackupSnapshot(props);
  }
}
