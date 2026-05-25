import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Schema as MongooseSchema } from 'mongoose';
import { CompraData } from '../../../domain/entities/backup.entity';

export type BackupSnapshotDocument = HydratedDocument<BackupSnapshotSchema>;

@Schema({ timestamps: true, collection: 'backup_snapshots' })
export class BackupSnapshotSchema {
  @Prop({ required: true, index: true })
  userId: string;

  @Prop({ type: String })
  name?: string;

  @Prop({ type: [MongooseSchema.Types.Mixed], default: [] })
  compras: CompraData[];

  // Managed by Mongoose timestamps option
  @Prop({ type: Date })
  createdAt: Date;

  @Prop({ type: Date })
  updatedAt: Date;
}

export const BackupSnapshotMongooseSchema = SchemaFactory.createForClass(BackupSnapshotSchema);
