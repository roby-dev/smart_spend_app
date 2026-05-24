export interface CompraDetalleData {
  nombre: string;
  precio: number;
  fecha: string;
  uuid?: string;
}

export interface CompraData {
  titulo: string;
  fecha: string;
  archivado: boolean;
  presupuesto: number | null;
  orden: number;
  uuid?: string;
  detalles: CompraDetalleData[];
}

export class Backup {
  public readonly userId: string;
  public compras: CompraData[];
  public readonly createdAt: Date;
  public updatedAt: Date;

  private constructor(props: {
    userId: string;
    compras: CompraData[];
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.userId = props.userId;
    this.compras = props.compras;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static create(userId: string, compras: CompraData[]): Backup {
    const now = new Date();
    return new Backup({ userId, compras, createdAt: now, updatedAt: now });
  }

  static fromPersistence(props: {
    userId: string;
    compras: CompraData[];
    createdAt: Date;
    updatedAt: Date;
  }): Backup {
    return new Backup(props);
  }
}
