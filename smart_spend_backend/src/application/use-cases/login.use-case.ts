import { User } from '../../domain/entities/user.entity';
import { IUserRepository } from '../../domain/ports/user-repository.port';
import { InvalidCredentialsError } from '../../domain/exceptions/auth.exceptions';
import {
  AuthProvider,
  isAuthProvider,
} from '../../domain/value-objects/auth-provider.vo';
import { TokenPair } from '../../domain/value-objects/token-pair.vo';
import { ITokenVerifier } from '../ports/token-verifier.port';
import { ITokenService } from '../ports/token-service.port';

export class LoginUseCase {
  constructor(
    private readonly verifiers: Record<AuthProvider, ITokenVerifier>,
    private readonly userRepository: IUserRepository,
    private readonly tokenService: ITokenService,
  ) {}

  async execute(dto: {
    provider: string;
    idToken: string;
  }): Promise<TokenPair> {
    // 1. Validate provider
    if (!isAuthProvider(dto.provider)) {
      throw new InvalidCredentialsError(`Unknown provider: ${dto.provider}`);
    }

    const provider = dto.provider;
    const verifier = this.verifiers[provider];

    // 2. Verify idToken with the provider
    const payload = await verifier.verify(dto.idToken);

    // 3. Find or create user
    let user = await this.userRepository.findByProviderId(
      provider,
      payload.sub,
    );

    if (user) {
      // Returning user — merge non-nil fields preserving Apple's first-login name
      user = User.mergeNonNil(user, {
        email: payload.email,
        name: payload.name ?? null,
      });
      user = await this.userRepository.upsert(user);
    } else {
      // New user
      const newUser = User.create({
        provider,
        providerId: payload.sub,
        email: payload.email,
        name: payload.name ?? null,
      });
      user = await this.userRepository.upsert(newUser);
    }

    // 4. Generate token pair
    const accessToken = await this.tokenService.generateAccessToken(user);
    const { token: refreshToken, hash: refreshHash } =
      await this.tokenService.generateRefreshToken();

    // 5. Save refresh token hash (empty string for previousHash on first login)
    await this.userRepository.saveRefreshTokenHash(
      user.id,
      refreshHash,
      user.refreshTokenHash ?? '',
    );

    return { accessToken, refreshToken };
  }
}
