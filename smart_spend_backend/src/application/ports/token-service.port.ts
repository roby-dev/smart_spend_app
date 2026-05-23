import { User } from '../../domain/entities/user.entity';

export interface ITokenService {
  generateAccessToken(user: User): Promise<string>;

  /** Returns a raw opaque refresh token and its bcrypt hash. */
  generateRefreshToken(): Promise<{ token: string; hash: string }>;

  /** Verifies a raw refresh token against a stored bcrypt hash. */
  verifyRefresh(token: string, hash: string): Promise<boolean>;
}
