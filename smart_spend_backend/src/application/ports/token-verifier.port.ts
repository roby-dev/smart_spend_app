export interface TokenVerificationResult {
  sub: string;
  email: string | null;
  name?: string | null;
}

export interface ITokenVerifier {
  verify(idToken: string): Promise<TokenVerificationResult>;
}
