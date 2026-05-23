import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { randomBytes } from 'crypto';
import * as bcrypt from 'bcrypt';
import { ITokenService } from '../../application/ports/token-service.port';
import { User } from '../../domain/entities/user.entity';

@Injectable()
export class TokenService implements ITokenService {
  constructor(private readonly jwtService: JwtService) {}

  async generateAccessToken(user: User): Promise<string> {
    const payload = {
      sub: user.id,
      email: user.email,
      provider: user.provider,
    };
    return this.jwtService.signAsync(payload);
  }

  async generateRefreshToken(): Promise<{ token: string; hash: string }> {
    const token = randomBytes(32).toString('hex');
    const hash = await bcrypt.hash(token, 10);
    return { token, hash };
  }

  async verifyRefresh(token: string, hash: string): Promise<boolean> {
    return bcrypt.compare(token, hash);
  }
}
