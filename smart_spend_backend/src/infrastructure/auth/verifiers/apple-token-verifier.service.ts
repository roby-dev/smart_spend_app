import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { verifyIdToken } from 'apple-signin-auth';
import {
  ITokenVerifier,
  TokenVerificationResult,
} from '../../../application/ports/token-verifier.port';
import { InvalidCredentialsError } from '../../../domain/exceptions/auth.exceptions';

@Injectable()
export class AppleTokenVerifier implements ITokenVerifier {
  constructor(private readonly configService: ConfigService) {}

  async verify(idToken: string): Promise<TokenVerificationResult> {
    try {
      const clientId = this.configService.getOrThrow<string>('apple.clientId');
      const payload = await verifyIdToken(idToken, {
        audience: clientId,
        ignoreExpiration: false,
      });

      if (!payload || !payload.sub) {
        throw new InvalidCredentialsError(
          'Apple token verification failed: missing sub claim',
        );
      }

      // apple-signin-auth returns a typed payload; access optional fields
      // via unknown cast since AppleIdTokenType has no index signature.
      const rawPayload = payload as unknown as Record<string, unknown>;

      return {
        sub: payload.sub,
        email: rawPayload.email != null ? String(rawPayload.email) : null,
        name: rawPayload.name != null ? String(rawPayload.name) : undefined,
      };
    } catch (error) {
      if (error instanceof InvalidCredentialsError) {
        throw error;
      }
      throw new InvalidCredentialsError(
        `Apple token verification failed: ${(error as Error).message}`,
      );
    }
  }
}
