export type AuthProvider = 'google' | 'apple';

export const AUTH_PROVIDERS: ReadonlyArray<AuthProvider> = Object.freeze([
  'google',
  'apple',
]);

export function isAuthProvider(value: unknown): value is AuthProvider {
  return (
    typeof value === 'string' && AUTH_PROVIDERS.includes(value as AuthProvider)
  );
}

export function assertAuthProvider(
  value: unknown,
): asserts value is AuthProvider {
  if (!isAuthProvider(value)) {
    throw new Error(
      `Invalid auth provider: "${String(value)}". Must be one of: ${AUTH_PROVIDERS.join(', ')}`,
    );
  }
}
