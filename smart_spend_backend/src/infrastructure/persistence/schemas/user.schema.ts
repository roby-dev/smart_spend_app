import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UserDocument = HydratedDocument<UserSchema>;

@Schema({ timestamps: true })
export class UserSchema {
  @Prop({ type: String, default: null })
  email: string | null;

  @Prop({ type: String, default: null })
  name: string | null;

  @Prop({ required: true })
  provider: string;

  @Prop({ required: true })
  providerId: string;

  @Prop({ type: String, default: null })
  refreshTokenHash: string | null;

  @Prop({ type: String, default: null })
  previousRefreshTokenHash: string | null;

  // Managed by Mongoose timestamps option
  @Prop({ type: Date })
  createdAt: Date;

  @Prop({ type: Date })
  updatedAt: Date;
}

export const UserMongooseSchema = SchemaFactory.createForClass(UserSchema);

// Compound unique index on { provider, providerId }
UserMongooseSchema.index({ provider: 1, providerId: 1 }, { unique: true });

// Sparse unique index on email — allows multiple null emails (Apple relay users)
UserMongooseSchema.index({ email: 1 }, { unique: true, sparse: true });
