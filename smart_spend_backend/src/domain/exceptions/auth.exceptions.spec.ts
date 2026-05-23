import { InvalidCredentialsError, TokenRevokedError } from './auth.exceptions';

describe('Auth Exceptions', () => {
  describe('InvalidCredentialsError', () => {
    it('should have correct name', () => {
      const error = new InvalidCredentialsError();
      expect(error.name).toBe('InvalidCredentialsError');
    });

    it('should have default message', () => {
      const error = new InvalidCredentialsError();
      expect(error.message).toBe('Invalid credentials');
    });

    it('should accept custom message', () => {
      const error = new InvalidCredentialsError('Custom bad creds');
      expect(error.message).toBe('Custom bad creds');
    });

    it('should be an instance of Error', () => {
      const error = new InvalidCredentialsError();
      expect(error).toBeInstanceOf(Error);
    });

    it('should be catchable as Error', () => {
      expect(() => {
        throw new InvalidCredentialsError();
      }).toThrow(Error);
    });

    it('should be catchable specifically as InvalidCredentialsError', () => {
      expect(() => {
        throw new InvalidCredentialsError();
      }).toThrow(InvalidCredentialsError);
    });
  });

  describe('TokenRevokedError', () => {
    it('should have correct name', () => {
      const error = new TokenRevokedError();
      expect(error.name).toBe('TokenRevokedError');
    });

    it('should have default message', () => {
      const error = new TokenRevokedError();
      expect(error.message).toBe('Token has been revoked');
    });

    it('should accept custom message', () => {
      const error = new TokenRevokedError(
        'All tokens revoked due to theft detection',
      );
      expect(error.message).toBe('All tokens revoked due to theft detection');
    });

    it('should be an instance of Error', () => {
      const error = new TokenRevokedError();
      expect(error).toBeInstanceOf(Error);
    });

    it('should be catchable as Error', () => {
      expect(() => {
        throw new TokenRevokedError();
      }).toThrow(Error);
    });

    it('should be catchable specifically as TokenRevokedError', () => {
      expect(() => {
        throw new TokenRevokedError();
      }).toThrow(TokenRevokedError);
    });
  });
});
