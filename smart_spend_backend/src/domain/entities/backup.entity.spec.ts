import { Backup, CompraData } from './backup.entity';

const sampleCompras: CompraData[] = [
  {
    titulo: 'Mercado',
    fecha: '2025-06-22T10:44:53.388Z',
    archivado: false,
    presupuesto: null,
    orden: 0,
    detalles: [
      { nombre: 'Pollo', precio: 12.5, fecha: '2026-03-05T21:57:56.829Z' },
    ],
  },
];

const sampleComprasWithUuid: CompraData[] = [
  {
    titulo: 'Mercado',
    fecha: '2025-06-22T10:44:53.388Z',
    archivado: false,
    presupuesto: null,
    orden: 0,
    uuid: 'abc-123',
    detalles: [
      { nombre: 'Pollo', precio: 12.5, fecha: '2026-03-05T21:57:56.829Z', uuid: 'det-1' },
    ],
  },
];

describe('Backup entity', () => {
  describe('create', () => {
    it('should build a backup with the given userId and compras', () => {
      const backup = Backup.create('user-1', sampleCompras);

      expect(backup.userId).toBe('user-1');
      expect(backup.compras).toBe(sampleCompras);
    });

    it('should set createdAt and updatedAt to the same instant', () => {
      const backup = Backup.create('user-1', sampleCompras);

      expect(backup.createdAt).toBeInstanceOf(Date);
      expect(backup.updatedAt).toBeInstanceOf(Date);
      expect(backup.createdAt.getTime()).toBe(backup.updatedAt.getTime());
    });

    it('should accept an empty compras array', () => {
      const backup = Backup.create('user-1', []);

      expect(backup.compras).toEqual([]);
    });

    it('should preserve uuid on compras and detalles when present', () => {
      const backup = Backup.create('user-1', sampleComprasWithUuid);

      expect(backup.compras[0].uuid).toBe('abc-123');
      expect(backup.compras[0].detalles[0].uuid).toBe('det-1');
    });

    it('should work without uuid for backward compatibility', () => {
      const backup = Backup.create('user-1', sampleCompras);

      expect(backup.compras[0].uuid).toBeUndefined();
      expect(backup.compras[0].detalles[0].uuid).toBeUndefined();
    });
  });

  describe('fromPersistence', () => {
    it('should reconstitute a backup preserving all fields', () => {
      const createdAt = new Date('2026-01-01T00:00:00.000Z');
      const updatedAt = new Date('2026-05-14T22:35:37.000Z');

      const backup = Backup.fromPersistence({
        userId: 'user-2',
        compras: sampleCompras,
        createdAt,
        updatedAt,
      });

      expect(backup.userId).toBe('user-2');
      expect(backup.compras).toBe(sampleCompras);
      expect(backup.createdAt).toBe(createdAt);
      expect(backup.updatedAt).toBe(updatedAt);
    });
  });
});
