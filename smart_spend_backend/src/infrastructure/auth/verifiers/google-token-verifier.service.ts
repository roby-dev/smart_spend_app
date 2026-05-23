import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OAuth2Client } from 'google-auth-library';
import {
  ITokenVerifier,
  TokenVerificationResult,
} from '../../../application/ports/token-verifier.port';
import { InvalidCredentialsError } from '../../../domain/exceptions/auth.exceptions';

@Injectable()
export class GoogleTokenVerifier implements ITokenVerifier {
  private readonly client: OAuth2Client;

  constructor(private readonly configService: ConfigService) {
    const clientId = this.configService.getOrThrow<string>('google.clientId');
    this.client = new OAuth2Client(clientId);
  }

  async verify(idToken: string): Promise<TokenVerificationResult> {
    try {
      const clientId = this.configService.getOrThrow<string>('google.clientId');
      const ticket = await this.client.verifyIdToken({
        idToken,
        audience: clientId,
      });
      const payload = ticket.getPayload();
      if (!payload || !payload.sub) {
        throw new InvalidCredentialsError(
          'Google token verification failed: missing sub claim',
        );
      }

      return {
        sub: payload.sub,
        email: payload.email ?? null,
        name: payload.name ?? null,
      };
    } catch (error) {
      if (error instanceof InvalidCredentialsError) {
        throw error;
      }
      throw new InvalidCredentialsError(
        `Google token verification failed: ${(error as Error).message}`,
      );
    }
  }
}
