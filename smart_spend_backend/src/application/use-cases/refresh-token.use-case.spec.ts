import { RefreshTokenUseCase } from './refresh-token.use-case';
import { IUserRepository } from '../../domain/ports/user-repository.port';
import { ITokenService } from '../ports/token-service.port';
import { User } from '../../domain/entities/user.entity';
import {
  InvalidCredentialsError,
  TokenRevokedError,
} from '../../domain/exceptions/auth.exceptions';

function makeUser(
  overrides: Partial<{
    id: string;
    refreshTokenHash: string | null;
    previousRefreshTokenHash: string | null;
  }> = {},
) {
  return User.fromPersistence({
    id: overrides.id ?? 'user-1',
    email: 'test@example.com',
    name: 'Test User',
    provider: 'google',
    providerId: 'google-123',
    refreshTokenHash: overrides.refreshTokenHash ?? '$2b$current',
    previousRefreshTokenHash: overrides.previousRefreshTokenHash ?? null,
    createdAt: new Date('2026-01-01'),
    updatedAt: new Date('2026-01-01'),
  });
}

function makeMocks() {
  const userRepository: jest.Mocked<IUserRepository> = {
    findByProviderId: jest.fn(),
    upsert: jest.fn(),
    findById: jest.fn(),
    saveRefreshTokenHash: jest.fn(),
    revokeAllTokens: jest.fn(),
  };

  const tokenService: jest.Mocked<ITokenService> = {
    generateAccessToken: jest.fn(),
    generateRefreshToken: jest.fn(),
    verifyRefresh: jest.fn(),
  };

  return { userRepository, tokenService };
}

describe('RefreshTokenUseCase', () => {
  let useCase: RefreshTokenUseCase;
  let mocks: ReturnType<typeof makeMocks>;

  beforeEach(() => {
    mocks = makeMocks();
    useCase = new RefreshTokenUseCase(mocks.userRepository, mocks.tokenService);
  });

  // Scenario R1: Valid non-expired refresh token — normal rotation
  describe('normal rotation (R1)', () => {
    it('should rotate tokens and return new pair', async () => {
      const user = makeUser();
      mocks.userRepository.findById.mockResolvedValue(user);

      // Current hash matches
      mocks.tokenService.verifyRefresh.mockResolvedValueOnce(true);

      mocks.tokenService.generateRefreshToken.mockResolvedValue({
        token: 'new-refresh-token',
        hash: '$2b$new',
      });
      mocks.tokenService.generateAccessToken.mockResolvedValue(
        'new-access-token',
      );
      mocks.userRepository.saveRefreshTokenHash.mockResolvedValue();
      mocks.userRepository.revokeAllTokens.mockResolvedValue();

      const result = await useCase.execute('user-1', 'valid-refresh-token');

      // Should verify against current hash
      expect(mocks.tokenService.verifyRefresh).toHaveBeenCalledWith(
        'valid-refresh-token',
        '$2b$current',
      );

      // Should rotate: save new hash, move current to previous
      expect(mocks.userRepository.saveRefreshTokenHash).toHaveBeenCalledWith(
        'user-1',
        '$2b$new',
        '$2b$current',
      );

      expect(result).toEqual({
        accessToken: 'new-access-token',
        refreshToken: 'new-refresh-token',
      });
    });
  });

  // Scenario R2: Expired/invalid refresh token
  describe('invalid token (R2)', () => {
    it('should throw InvalidCredentialsError when token does not match current hash', async () => {
      const user = makeUser();
      mocks.userRepository.findById.mockResolvedValue(user);

      // Neither current nor previous matches
      mocks.tokenService.verifyRefresh.mockResolvedValue(false);

      await expect(
        useCase.execute('user-1', 'expired-refresh-token'),
      ).rejects.toThrow(InvalidCredentialsError);
    });
  });

  // Scenario R3: Already-revoked refresh token (no active session)
  describe('no active session (R3)', () => {
    it('should throw InvalidCredentialsError when user has no refresh token hash', async () => {
      const user = makeUser({
        refreshTokenHash: null,
        previousRefreshTokenHash: null,
      });
      mocks.userRepository.findById.mockResolvedValue(user);

      await expect(useCase.execute('user-1', 'any-token')).rejects.toThrow(
        InvalidCredentialsError,
      );
    });

    it('should throw InvalidCredentialsError when user not found', async () => {
      mocks.userRepository.findById.mockResolvedValue(null);

      await expect(useCase.execute('nonexistent', 'any-token')).rejects.toThrow(
        InvalidCredentialsError,
      );
    });
  });

  // Scenario R4: Reuse of already-rotated token — theft detection
  describe('theft detection (R4)', () => {
    it('should revoke all tokens when a previously-rotated token is reused', async () => {
      const user = makeUser({
        refreshTokenHash: '$2b$current',
        previousRefreshTokenHash: '$2b$previous',
      });
      mocks.userRepository.findById.mockResolvedValue(user);

      // Current hash — NO match
      mocks.tokenService.verifyRefresh.mockResolvedValueOnce(false);
      // Previous hash — MATCH (theft detection!)
      mocks.tokenService.verifyRefresh.mockResolvedValueOnce(true);

      mocks.userRepository.revokeAllTokens.mockResolvedValue();

      await expect(
        useCase.execute('user-1', 'stolen-refresh-token'),
      ).rejects.toThrow(TokenRevokedError);

      // Should revoke all tokens
      expect(mocks.userRepository.revokeAllTokens).toHaveBeenCalledWith(
        'user-1',
      );
    });

    it('should not do theft detection when previousRefreshTokenHash is null', async () => {
      const user = makeUser({
        refreshTokenHash: '$2b$current',
        previousRefreshTokenHash: null,
      });
      mocks.userRepository.findById.mockResolvedValue(user);

      // Current hash — no match, and no previous hash to check
      mocks.tokenService.verifyRefresh.mockResolvedValueOnce(false);

      // Should throw InvalidCredentialsError, not TokenRevokedError
      await expect(useCase.execute('user-1', 'unknown-token')).rejects.toThrow(
        InvalidCredentialsError,
      );
      // revokeAllTokens should NOT be called
      expect(mocks.userRepository.revokeAllTokens).not.toHaveBeenCalled();
    });
  });

  describe('access token generation', () => {
    it('should generate new access token with the user entity', async () => {
      const user = makeUser();
      mocks.userRepository.findById.mockResolvedValue(user);
      mocks.tokenService.verifyRefresh.mockResolvedValueOnce(true);
      mocks.tokenService.generateRefreshToken.mockResolvedValue({
        token: 'new-rt',
        hash: '$2b$new',
      });
      mocks.tokenService.generateAccessToken.mockResolvedValue('new-at');
      mocks.userRepository.saveRefreshTokenHash.mockResolvedValue();

      await useCase.execute('user-1', 'valid-token');

      expect(mocks.tokenService.generateAccessToken).toHaveBeenCalledWith(user);
    });
  });
});
