import { BackupSnapshot } from './backup-snapshot.entity';

describe('BackupSnapshot entity', () => {
  describe('create', () => {
    it('should build a snapshot with userId, compras, and createdAt', () => {
      const compras = [
        { titulo: 'Test', fecha: '2025-01-01', archivado: false, presupuesto: null, orden: 0, detalles: [] },
      ];

      const snapshot = BackupSnapshot.create('user-1', compras);

      expect(snapshot.userId).toBe('user-1');
      expect(snapshot.compras).toBe(compras);
      expect(snapshot.createdAt).toBeInstanceOf(Date);
    });

    it('should accept an empty compras array', () => {
      const snapshot = BackupSnapshot.create('user-1', []);

      expect(snapshot.compras).toEqual([]);
    });
  });

  describe('fromPersistence', () => {
    it('should reconstitute a snapshot preserving all fields', () => {
      const createdAt = new Date('2026-01-01T00:00:00.000Z');
      const compras = [
        { titulo: 'Test', fecha: '2025-01-01', archivado: false, presupuesto: null, orden: 0, detalles: [] },
      ];

      const snapshot = BackupSnapshot.fromPersistence({
        id: 'snap-1',
        userId: 'user-2',
        compras,
        createdAt,
      });

      expect(snapshot.id).toBe('snap-1');
      expect(snapshot.userId).toBe('user-2');
      expect(snapshot.compras).toBe(compras);
      expect(snapshot.createdAt).toBe(createdAt);
    });
  });
});
