import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthModule } from '../auth/auth.module';
import { BackupController } from './backup.controller';
import { MongoBackupRepository } from '../persistence/mongo-backup.repository';
import {
  BackupSchema,
  BackupMongooseSchema,
} from '../persistence/schemas/backup.schema';
import {
  BackupSnapshotSchema,
  BackupSnapshotMongooseSchema,
} from '../persistence/schemas/backup-snapshot.schema';
import {
  SaveBackupUseCase,
  GetBackupUseCase,
  CreateBackupSnapshotUseCase,
  GetBackupHistoryUseCase,
  GetBackupSnapshotUseCase,
  RestoreBackupSnapshotUseCase,
} from '../../application';

@Module({
  imports: [
    AuthModule,
    MongooseModule.forFeature([
      { name: BackupSchema.name, schema: BackupMongooseSchema },
      { name: BackupSnapshotSchema.name, schema: BackupSnapshotMongooseSchema },
    ]),
  ],
  controllers: [BackupController],
  providers: [
    MongoBackupRepository,
    {
      provide: SaveBackupUseCase,
      useFactory: (backupRepo: MongoBackupRepository) =>
        new SaveBackupUseCase(backupRepo),
      inject: [MongoBackupRepository],
    },
    {
      provide: GetBackupUseCase,
      useFactory: (backupRepo: MongoBackupRepository) =>
        new GetBackupUseCase(backupRepo),
      inject: [MongoBackupRepository],
    },
    {
      provide: CreateBackupSnapshotUseCase,
      useFactory: (backupRepo: MongoBackupRepository) =>
        new CreateBackupSnapshotUseCase(backupRepo),
      inject: [MongoBackupRepository],
    },
    {
      provide: GetBackupHistoryUseCase,
      useFactory: (backupRepo: MongoBackupRepository) =>
        new GetBackupHistoryUseCase(backupRepo),
      inject: [MongoBackupRepository],
    },
    {
      provide: GetBackupSnapshotUseCase,
      useFactory: (backupRepo: MongoBackupRepository) =>
        new GetBackupSnapshotUseCase(backupRepo),
      inject: [MongoBackupRepository],
    },
    {
      provide: RestoreBackupSnapshotUseCase,
      useFactory: (backupRepo: MongoBackupRepository) =>
        new RestoreBackupSnapshotUseCase(backupRepo),
      inject: [MongoBackupRepository],
    },
  ],
})
export class BackupModule {}
