import { CompraData } from './backup.entity';

export class BackupSnapshot {
  public readonly id?: string;
  public readonly userId: string;
  public compras: CompraData[];
  public readonly name?: string;
  public readonly createdAt: Date;

  private constructor(props: {
    id?: string;
    userId: string;
    compras: CompraData[];
    name?: string;
    createdAt: Date;
  }) {
    this.id = props.id;
    this.userId = props.userId;
    this.compras = props.compras;
    this.name = props.name;
    this.createdAt = props.createdAt;
  }

  static create(
    userId: string,
    compras: CompraData[],
    name?: string,
  ): BackupSnapshot {
    return new BackupSnapshot({ userId, compras, name, createdAt: new Date() });
  }

  static fromPersistence(props: {
    id: string;
    userId: string;
    compras: CompraData[];
    name?: string;
    createdAt: Date;
  }): BackupSnapshot {
    return new BackupSnapshot(props);
  }
}
