import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthModule } from '../auth/auth.module';
import { BackupController } from './backup.controller';
import { MongoBackupRepository } from '../persistence/mongo-backup.repository';
import {
  BackupSchema,
  BackupMongooseSchema,
} from '../persistence/schemas/backup.schema';
import { SaveBackupUseCase, GetBackupUseCase } from '../../application';

@Module({
  imports: [
    AuthModule,
    MongooseModule.forFeature([
      { name: BackupSchema.name, schema: BackupMongooseSchema },
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
  ],
})
export class BackupModule {}
