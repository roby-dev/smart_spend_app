import { User } from '../entities/user.entity';
import { AuthProvider } from '../value-objects/auth-provider.vo';

export interface IUserRepository {
  findByProviderId(
    provider: AuthProvider,
    providerId: string,
  ): Promise<User | null>;

  upsert(user: User): Promise<User>;

  findById(id: string): Promise<User | null>;

  saveRefreshTokenHash(
    id: string,
    hash: string,
    previousHash: string,
  ): Promise<void>;

  revokeAllTokens(id: string): Promise<void>;
}
