import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { IUserRepository } from '../../domain/ports/user-repository.port';
import { User } from '../../domain/entities/user.entity';
import { AuthProvider } from '../../domain/value-objects/auth-provider.vo';
import { UserDocument, UserSchema } from './schemas/user.schema';

@Injectable()
export class MongoUserRepository implements IUserRepository {
  constructor(
    @InjectModel(UserSchema.name)
    private readonly userModel: Model<UserDocument>,
  ) {}

  async findByProviderId(
    provider: AuthProvider,
    providerId: string,
  ): Promise<User | null> {
    const doc = await this.userModel.findOne({ provider, providerId }).exec();
    if (!doc) return null;
    return this.toDomain(doc);
  }

  async upsert(user: User): Promise<User> {
    const updates: Record<string, unknown> = {};

    // mergeNonNil: only set fields that are non-null to avoid
    // overwriting stored data with null (Apple first-login semantics)
    if (user.email != null) {
      updates.email = user.email;
    }
    if (user.name != null) {
      updates.name = user.name;
    }

    const doc = await this.userModel
      .findOneAndUpdate(
        { provider: user.provider, providerId: user.providerId },
        {
          $set: updates,
          $setOnInsert: {
            provider: user.provider,
            providerId: user.providerId,
          },
        },
        { upsert: true, returnDocument: 'after' },
      )
      .exec();

    return this.toDomain(doc);
  }

  async findById(id: string): Promise<User | null> {
    const doc = await this.userModel.findById(id).exec();
    if (!doc) return null;
    return this.toDomain(doc);
  }

  async saveRefreshTokenHash(
    id: string,
    hash: string,
    previousHash: string,
  ): Promise<void> {
    const set: Record<string, unknown> = { refreshTokenHash: hash };

    // Only set previousRefreshTokenHash when rotating (non-empty previousHash)
    if (previousHash) {
      set.previousRefreshTokenHash = previousHash;
    }

    await this.userModel.findByIdAndUpdate(id, { $set: set }).exec();
  }

  async revokeAllTokens(id: string): Promise<void> {
    await this.userModel
      .findByIdAndUpdate(id, {
        $set: { refreshTokenHash: null, previousRefreshTokenHash: null },
      })
      .exec();
  }

  private toDomain(doc: UserDocument): User {
    return User.fromPersistence({
      id: doc._id.toString(),
      email: doc.email,
      name: doc.name,
      provider: doc.provider as AuthProvider,
      providerId: doc.providerId,
      refreshTokenHash: doc.refreshTokenHash,
      previousRefreshTokenHash: doc.previousRefreshTokenHash,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
    });
  }
}
