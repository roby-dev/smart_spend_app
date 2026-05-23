import { LogoutUseCase } from './logout.use-case';
import { IUserRepository } from '../../domain/ports/user-repository.port';

function makeMocks() {
  const userRepository: jest.Mocked<IUserRepository> = {
    findByProviderId: jest.fn(),
    upsert: jest.fn(),
    findById: jest.fn(),
    saveRefreshTokenHash: jest.fn(),
    revokeAllTokens: jest.fn(),
  };

  return { userRepository };
}

describe('LogoutUseCase', () => {
  let useCase: LogoutUseCase;
  let mocks: ReturnType<typeof makeMocks>;

  beforeEach(() => {
    mocks = makeMocks();
    useCase = new LogoutUseCase(mocks.userRepository);
  });

  // Scenario O1: Valid refresh token + valid auth header → 204, token revoked
  describe('valid logout (O1)', () => {
    it('should call revokeAllTokens on the user repository', async () => {
      mocks.userRepository.revokeAllTokens.mockResolvedValue();

      await useCase.execute('user-1');

      expect(mocks.userRepository.revokeAllTokens).toHaveBeenCalledWith(
        'user-1',
      );
      expect(mocks.userRepository.revokeAllTokens).toHaveBeenCalledTimes(1);
    });
  });

  // Scenario O2: Already-revoked token → 204 (idempotent)
  describe('idempotent logout (O2)', () => {
    it('should not throw when revoking an already-revoked session', async () => {
      mocks.userRepository.revokeAllTokens.mockResolvedValue();

      // First logout
      await useCase.execute('user-1');
      expect(mocks.userRepository.revokeAllTokens).toHaveBeenCalledTimes(1);

      // Second logout — idempotent, should not throw
      await useCase.execute('user-1');
      expect(mocks.userRepository.revokeAllTokens).toHaveBeenCalledTimes(2);
    });

    it('should propagate repository errors', async () => {
      mocks.userRepository.revokeAllTokens.mockRejectedValue(
        new Error('DB connection lost'),
      );

      await expect(useCase.execute('user-1')).rejects.toThrow(
        'DB connection lost',
      );
    });
  });
});
