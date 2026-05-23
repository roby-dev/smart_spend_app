import { IUserRepository } from '../../domain/ports/user-repository.port';

export class LogoutUseCase {
  constructor(private readonly userRepository: IUserRepository) {}

  async execute(userId: string): Promise<void> {
    await this.userRepository.revokeAllTokens(userId);
  }
}
