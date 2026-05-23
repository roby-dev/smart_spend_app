import { LoginUseCase } from './login.use-case';
import { IUserRepository } from '../../domain/ports/user-repository.port';
import { ITokenVerifier } from '../ports/token-verifier.port';
import { ITokenService } from '../ports/token-service.port';
import { User } from '../../domain/entities/user.entity';
import { InvalidCredentialsError } from '../../domain/exceptions/auth.exceptions';

function makeMocks() {
  const googleVerifier: jest.Mocked<ITokenVerifier> = {
    verify: jest.fn(),
  };

  const appleVerifier: jest.Mocked<ITokenVerifier> = {
    verify: jest.fn(),
  };

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

  return { googleVerifier, appleVerifier, userRepository, tokenService };
}

describe('LoginUseCase', () => {
  let useCase: LoginUseCase;
  let mocks: ReturnType<typeof makeMocks>;

  beforeEach(() => {
    mocks = makeMocks();
    useCase = new LoginUseCase(
      { google: mocks.googleVerifier, apple: mocks.appleVerifier },
      mocks.userRepository,
      mocks.tokenService,
    );
  });

  describe('provider validation', () => {
    it('should throw InvalidCredentialsError for unknown provider', async () => {
      await expect(
        useCase.execute({ provider: 'facebook', idToken: 'token' }),
      ).rejects.toThrow(InvalidCredentialsError);
    });
  });

  describe('Google login', () => {
    const googlePayload = {
      sub: 'google-123',
      email: 'test@gmail.com',
      name: 'John Doe',
    };

    // Scenario L1: New Google user
    it('should create new user and return token pair (L1)', async () => {
      mocks.googleVerifier.verify.mockResolvedValue(googlePayload);
      mocks.userRepository.findByProviderId.mockResolvedValue(null);

      const newUser = User.create({
        provider: 'google',
        providerId: 'google-123',
        email: 'test@gmail.com',
        name: 'John Doe',
      });
      // Simulate persistence assigning an id
      Object.defineProperty(newUser, 'id', { value: 'mongo-id-1' });
      mocks.userRepository.upsert.mockResolvedValue(newUser);

      mocks.tokenService.generateAccessToken.mockResolvedValue('access-abc');
      mocks.tokenService.generateRefreshToken.mockResolvedValue({
        token: 'refresh-xyz',
        hash: '$2b$hash',
      });
      mocks.userRepository.saveRefreshTokenHash.mockResolvedValue();

      const result = await useCase.execute({
        provider: 'google',
        idToken: 'google-id-token',
      });

      expect(mocks.googleVerifier.verify).toHaveBeenCalledWith(
        'google-id-token',
      );
      expect(mocks.userRepository.findByProviderId).toHaveBeenCalledWith(
        'google',
        'google-123',
      );
      expect(mocks.userRepository.upsert).toHaveBeenCalled();
      expect(mocks.tokenService.generateAccessToken).toHaveBeenCalledWith(
        newUser,
      );
      expect(mocks.tokenService.generateRefreshToken).toHaveBeenCalled();
      expect(mocks.userRepository.saveRefreshTokenHash).toHaveBeenCalledWith(
        'mongo-id-1',
        '$2b$hash',
        '',
      );
      expect(result).toEqual({
        accessToken: 'access-abc',
        refreshToken: 'refresh-xyz',
      });
    });

    // Scenario L2: Returning Google user
    it('should find existing user and return token pair (L2)', async () => {
      mocks.googleVerifier.verify.mockResolvedValue(googlePayload);

      const existing = User.fromPersistence({
        id: 'mongo-id-2',
        email: 'test@gmail.com',
        name: 'John Old',
        provider: 'google',
        providerId: 'google-123',
        refreshTokenHash: '$2b$old',
        previousRefreshTokenHash: null,
        createdAt: new Date('2026-01-01'),
        updatedAt: new Date('2026-01-01'),
      });
      mocks.userRepository.findByProviderId.mockResolvedValue(existing);
      mocks.userRepository.upsert.mockResolvedValue(existing);

      mocks.tokenService.generateAccessToken.mockResolvedValue('access-def');
      mocks.tokenService.generateRefreshToken.mockResolvedValue({
        token: 'refresh-uvw',
        hash: '$2b$new',
      });
      mocks.userRepository.saveRefreshTokenHash.mockResolvedValue();

      const result = await useCase.execute({
        provider: 'google',
        idToken: 'google-id-token',
      });

      expect(mocks.userRepository.findByProviderId).toHaveBeenCalledWith(
        'google',
        'google-123',
      );
      // Returning user — upsert called
      expect(mocks.userRepository.upsert).toHaveBeenCalled();
      expect(mocks.userRepository.saveRefreshTokenHash).toHaveBeenCalledWith(
        'mongo-id-2',
        '$2b$new',
        '$2b$old', // previousHash is the old refresh hash
      );
      expect(result).toEqual({
        accessToken: 'access-def',
        refreshToken: 'refresh-uvw',
      });
    });
  });

  describe('Apple login', () => {
    const applePayloadWithName = {
      sub: 'apple-456',
      email: 'apple@privaterelay.appleid.com',
      name: 'Jane Apple',
    };

    const applePayloadNoName = {
      sub: 'apple-456',
      email: 'apple@privaterelay.appleid.com',
    };

    // Scenario L3: New Apple user with name
    it('should create new Apple user with name (L3)', async () => {
      mocks.appleVerifier.verify.mockResolvedValue(applePayloadWithName);
      mocks.userRepository.findByProviderId.mockResolvedValue(null);

      const newUser = User.create({
        provider: 'apple',
        providerId: 'apple-456',
        email: 'apple@privaterelay.appleid.com',
        name: 'Jane Apple',
      });
      Object.defineProperty(newUser, 'id', { value: 'mongo-id-3' });
      mocks.userRepository.upsert.mockResolvedValue(newUser);

      mocks.tokenService.generateAccessToken.mockResolvedValue('access-ghi');
      mocks.tokenService.generateRefreshToken.mockResolvedValue({
        token: 'refresh-rst',
        hash: '$2b$hash',
      });
      mocks.userRepository.saveRefreshTokenHash.mockResolvedValue();

      await useCase.execute({ provider: 'apple', idToken: 'apple-id-token' });

      const upsertedUser = mocks.userRepository.upsert.mock.calls[0][0];
      expect(upsertedUser.name).toBe('Jane Apple');
      expect(upsertedUser.email).toBe('apple@privaterelay.appleid.com');
    });

    // Scenario L4: Returning Apple user — name preserved (mergeNonNil)
    it('should preserve stored name when Apple returns without name (L4)', async () => {
      mocks.appleVerifier.verify.mockResolvedValue(applePayloadNoName);

      const existing = User.fromPersistence({
        id: 'mongo-id-4',
        email: 'apple@privaterelay.appleid.com',
        name: 'Jane Stored',
        provider: 'apple',
        providerId: 'apple-456',
        refreshTokenHash: null,
        previousRefreshTokenHash: null,
        createdAt: new Date('2026-01-01'),
        updatedAt: new Date('2026-01-01'),
      });
      mocks.userRepository.findByProviderId.mockResolvedValue(existing);
      mocks.userRepository.upsert.mockImplementation(async (u) => u);

      mocks.tokenService.generateAccessToken.mockResolvedValue('access-jkl');
      mocks.tokenService.generateRefreshToken.mockResolvedValue({
        token: 'refresh-mno',
        hash: '$2b$hash',
      });
      mocks.userRepository.saveRefreshTokenHash.mockResolvedValue();

      await useCase.execute({ provider: 'apple', idToken: 'apple-id-token-2' });

      const upsertedUser = mocks.userRepository.upsert.mock.calls[0][0];
      // Name must be preserved — Apple omits name on subsequent logins
      expect(upsertedUser.name).toBe('Jane Stored');
    });
  });

  describe('error propagation', () => {
    it('should propagate verifier errors', async () => {
      mocks.googleVerifier.verify.mockRejectedValue(
        new InvalidCredentialsError('Token expired'),
      );

      await expect(
        useCase.execute({ provider: 'google', idToken: 'bad-token' }),
      ).rejects.toThrow(InvalidCredentialsError);
    });
  });
});
