import { Provider } from '@nestjs/common';
import { AuthProvider } from '../../../domain/value-objects/auth-provider.vo';
import { ITokenVerifier } from '../../../application/ports/token-verifier.port';
import { GoogleTokenVerifier } from './google-token-verifier.service';
import { AppleTokenVerifier } from './apple-token-verifier.service';

export const VERIFIER_REGISTRY = 'VERIFIER_REGISTRY';

export const verifierRegistryProvider: Provider = {
  provide: VERIFIER_REGISTRY,
  useFactory: (
    googleVerifier: GoogleTokenVerifier,
    appleVerifier: AppleTokenVerifier,
  ): Record<AuthProvider, ITokenVerifier> => ({
    google: googleVerifier,
    apple: appleVerifier,
  }),
  inject: [GoogleTokenVerifier, AppleTokenVerifier],
};
