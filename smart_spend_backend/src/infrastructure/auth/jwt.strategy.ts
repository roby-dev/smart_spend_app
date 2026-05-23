import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

export interface JwtPayload {
  sub: string;
  email: string | null;
  provider: string;
}

export interface JwtUser {
  userId: string;
  email: string | null;
  provider: string;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      // Accept expired tokens to support the refresh-token endpoint.
      // The actual security check is performed by RefreshTokenUseCase
      // (verifying the opaque refresh token against stored bcrypt hashes).
      ignoreExpiration: true,
      secretOrKey: configService.getOrThrow<string>('jwt.secret'),
    });
  }

  async validate(payload: JwtPayload): Promise<JwtUser> {
    return {
      userId: payload.sub,
      email: payload.email,
      provider: payload.provider,
    };
  }
}
