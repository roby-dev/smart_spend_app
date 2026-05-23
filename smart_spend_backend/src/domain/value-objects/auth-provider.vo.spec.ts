import {
  isAuthProvider,
  assertAuthProvider,
  AUTH_PROVIDERS,
} from './auth-provider.vo';

describe('AuthProvider value object', () => {
  describe('isAuthProvider', () => {
    it('should return true for "google"', () => {
      expect(isAuthProvider('google')).toBe(true);
    });

    it('should return true for "apple"', () => {
      expect(isAuthProvider('apple')).toBe(true);
    });

    it('should return false for invalid provider', () => {
      expect(isAuthProvider('facebook')).toBe(false);
    });

    it('should return false for empty string', () => {
      expect(isAuthProvider('')).toBe(false);
    });

    it('should return false for null', () => {
      expect(isAuthProvider(null)).toBe(false);
    });

    it('should return false for undefined', () => {
      expect(isAuthProvider(undefined)).toBe(false);
    });

    it('should return false for numbers', () => {
      expect(isAuthProvider(42)).toBe(false);
    });
  });

  describe('assertAuthProvider', () => {
    it('should not throw for "google"', () => {
      expect(() => assertAuthProvider('google')).not.toThrow();
    });

    it('should not throw for "apple"', () => {
      expect(() => assertAuthProvider('apple')).not.toThrow();
    });

    it('should throw for invalid provider with descriptive message', () => {
      expect(() => assertAuthProvider('facebook')).toThrow(
        'Invalid auth provider: "facebook". Must be one of: google, apple',
      );
    });

    it('should throw for empty string with descriptive message', () => {
      expect(() => assertAuthProvider('')).toThrow(
        'Invalid auth provider: "". Must be one of: google, apple',
      );
    });
  });

  describe('AUTH_PROVIDERS', () => {
    it('should contain exactly google and apple', () => {
      expect(AUTH_PROVIDERS).toEqual(['google', 'apple']);
    });

    it('should be readonly (frozen)', () => {
      expect(Object.isFrozen(AUTH_PROVIDERS)).toBe(true);
    });
  });
});
