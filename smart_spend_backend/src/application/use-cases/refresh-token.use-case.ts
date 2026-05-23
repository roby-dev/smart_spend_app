import { IUserRepository } from '../../domain/ports/user-repository.port';
import { ITokenService } from '../ports/token-service.port';
import { TokenPair } from '../../domain/value-objects/token-pair.vo';
import {
  InvalidCredentialsError,
  TokenRevokedError,
} from '../../domain/exceptions/auth.exceptions';

export class RefreshTokenUseCase {
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly tokenService: ITokenService,
  ) {}

  async execute(userId: string, refreshToken: string): Promise<TokenPair> {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new InvalidCredentialsError('User not found');
    }

    if (!user.refreshTokenHash) {
      throw new InvalidCredentialsError('No active session');
    }

    // 1. Verify against current refresh token hash
    const currentValid = await this.tokenService.verifyRefresh(
      refreshToken,
      user.refreshTokenHash,
    );

    if (currentValid) {
      // Normal rotation: generate new token pair, rotate hashes
      const { token: newRefreshToken, hash: newHash } =
        await this.tokenService.generateRefreshToken();
      const accessToken = await this.tokenService.generateAccessToken(user);

      // Move current hash to previous, store new hash as current
      await this.userRepository.saveRefreshTokenHash(
        user.id,
        newHash,
        user.refreshTokenHash,
      );

      return { accessToken, refreshToken: newRefreshToken };
    }

    // 2. Check if the token matches the previously-rotated hash (theft detection)
    if (user.previousRefreshTokenHash) {
      const previousValid = await this.tokenService.verifyRefresh(
        refreshToken,
        user.previousRefreshTokenHash,
      );

      if (previousValid) {
        // TOKEN THEFT — revoke all user tokens
        await this.userRepository.revokeAllTokens(user.id);
        throw new TokenRevokedError(
          'Token reuse detected — all sessions revoked',
        );
      }
    }

    // 3. Token doesn't match either hash
    throw new InvalidCredentialsError('Invalid or expired refresh token');
  }
}
