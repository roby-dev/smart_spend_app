import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Schema as MongooseSchema } from 'mongoose';
import { CompraData } from '../../../domain/entities/backup.entity';

export type BackupDocument = HydratedDocument<BackupSchema>;

@Schema({ timestamps: true, collection: 'backups' })
export class BackupSchema {
  @Prop({ required: true, unique: true, index: true })
  userId: string;

  @Prop({ type: [MongooseSchema.Types.Mixed], default: [] })
  compras: CompraData[];

  // Managed by Mongoose timestamps option
  @Prop({ type: Date })
  createdAt: Date;

  @Prop({ type: Date })
  updatedAt: Date;
}

export const BackupMongooseSchema = SchemaFactory.createForClass(BackupSchema);
