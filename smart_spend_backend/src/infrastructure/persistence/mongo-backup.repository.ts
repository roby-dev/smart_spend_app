import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { IBackupRepository } from '../../domain/ports/backup-repository.port';
import { Backup, CompraData } from '../../domain/entities/backup.entity';
import { BackupDocument, BackupSchema } from './schemas/backup.schema';

@Injectable()
export class MongoBackupRepository implements IBackupRepository {
  constructor(
    @InjectModel(BackupSchema.name)
    private readonly backupModel: Model<BackupDocument>,
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

  private toDomain(doc: BackupDocument): Backup {
    return Backup.fromPersistence({
      userId: doc.userId,
      compras: doc.compras,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
    });
  }
}
