export class InvalidCredentialsError extends Error {
  constructor(message = 'Invalid credentials') {
    super(message);
    this.name = 'InvalidCredentialsError';
  }
}

export class TokenRevokedError extends Error {
  constructor(message = 'Token has been revoked') {
    super(message);
    this.name = 'TokenRevokedError';
  }
}
