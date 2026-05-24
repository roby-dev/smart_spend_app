import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';
import { Backup, CompraData } from '../../domain/entities/backup.entity';
import { BackupSnapshot } from '../../domain/entities/backup-snapshot.entity';
import { BackupDocument, BackupSchema } from './schemas/backup.schema';
import {
  BackupSnapshotDocument,
  BackupSnapshotSchema,
} from './schemas/backup-snapshot.schema';

@Injectable()
export class MongoBackupRepository implements IBackupRepository {
  constructor(
    @InjectModel(BackupSchema.name)
    private readonly backupModel: Model<BackupDocument>,
    @InjectModel(BackupSnapshotSchema.name)
    private readonly snapshotModel: Model<BackupSnapshotDocument>,
  ) {}

  async upsertByUserId(userId: string, compras: CompraData[]): Promise<Backup> {
    const doc = await this.backupModel
      .findOneAndUpdate(
        { userId },
        { $set: { compras }, $setOnInsert: { userId } },
        { upsert: true, returnDocument: 'after' },
      )
      .exec();

    return this.toDomain(doc);
  }

  async findByUserId(userId: string): Promise<Backup | null> {
    const doc = await this.backupModel.findOne({ userId }).exec();
    if (!doc) return null;
    return this.toDomain(doc);
  }

  async createSnapshot(
    userId: string,
    compras: CompraData[],
  ): Promise<BackupSnapshot> {
    const doc = await this.snapshotModel.create({ userId, compras });
    return this.toSnapshotDomain(doc);
  }

  async findSnapshotsByUserId(userId: string): Promise<BackupSnapshot[]> {
    const docs = await this.snapshotModel
      .find({ userId })
      .sort({ createdAt: -1 })
      .exec();
    return docs.map((doc) => this.toSnapshotDomain(doc));
  }

  async findSnapshotById(id: string): Promise<BackupSnapshot | null> {
    const doc = await this.snapshotModel.findById(id).exec();
    if (!doc) return null;
    return this.toSnapshotDomain(doc);
  }

  private toDomain(doc: BackupDocument): Backup {
    return Backup.fromPersistence({
      userId: doc.userId,
      compras: doc.compras,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
    });
  }

  private toSnapshotDomain(doc: BackupSnapshotDocument): BackupSnapshot {
    return BackupSnapshot.fromPersistence({
      id: doc._id.toString(),
      userId: doc.userId,
      compras: doc.compras,
      createdAt: doc.createdAt,
    });
  }
}
