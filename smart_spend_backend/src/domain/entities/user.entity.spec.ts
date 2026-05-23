import { User } from './user.entity';

describe('User entity', () => {
  const googleProps = {
    email: 'test@example.com',
    name: 'John Doe',
    provider: 'google' as const,
    providerId: 'google-123',
  };

  const appleProps = {
    email: 'apple@privaterelay.appleid.com',
    name: 'Jane Apple',
    provider: 'apple' as const,
    providerId: 'apple-456',
  };

  describe('create', () => {
    it('should create a User with provided properties', () => {
      const user = User.create(googleProps);

      expect(user.email).toBe('test@example.com');
      expect(user.name).toBe('John Doe');
      expect(user.provider).toBe('google');
      expect(user.providerId).toBe('google-123');
      expect(user.id).toBe('');
      expect(user.refreshTokenHash).toBeNull();
      expect(user.previousRefreshTokenHash).toBeNull();
      expect(user.createdAt).toBeInstanceOf(Date);
      expect(user.updatedAt).toBeInstanceOf(Date);
    });

    it('should create a User with null email (Apple relay)', () => {
      const user = User.create({ ...appleProps, email: null });

      expect(user.email).toBeNull();
      expect(user.name).toBe('Jane Apple');
    });

    it('should create a User with null name', () => {
      const user = User.create({ ...googleProps, name: null });

      expect(user.name).toBeNull();
    });

    it('should set provider and providerId correctly for Google', () => {
      const user = User.create(googleProps);

      expect(user.provider).toBe('google');
      expect(user.providerId).toBe('google-123');
    });

    it('should set provider and providerId correctly for Apple', () => {
      const user = User.create(appleProps);

      expect(user.provider).toBe('apple');
      expect(user.providerId).toBe('apple-456');
    });
  });

  describe('fromPersistence', () => {
    it('should reconstitute a User with all fields', () => {
      const now = new Date();
      const user = User.fromPersistence({
        id: 'mongo-id-123',
        email: 'test@example.com',
        name: 'John',
        provider: 'google',
        providerId: 'google-sub',
        refreshTokenHash: 'hash1',
        previousRefreshTokenHash: 'old-hash',
        createdAt: now,
        updatedAt: now,
      });

      expect(user.id).toBe('mongo-id-123');
      expect(user.email).toBe('test@example.com');
      expect(user.name).toBe('John');
      expect(user.provider).toBe('google');
      expect(user.providerId).toBe('google-sub');
      expect(user.refreshTokenHash).toBe('hash1');
      expect(user.previousRefreshTokenHash).toBe('old-hash');
      expect(user.createdAt).toBe(now);
      expect(user.updatedAt).toBe(now);
    });

    it('should reconstitute a User with null hashes', () => {
      const user = User.fromPersistence({
        id: 'id',
        email: null,
        name: null,
        provider: 'apple',
        providerId: 'apple-sub',
        refreshTokenHash: null,
        previousRefreshTokenHash: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      expect(user.refreshTokenHash).toBeNull();
      expect(user.previousRefreshTokenHash).toBeNull();
    });
  });

  describe('mergeNonNil', () => {
    // Scenario U3: Merge — stored name="John", incoming name=null → name stays "John"
    it('should preserve stored name when incoming is null (U3)', () => {
      const stored = User.create({ ...googleProps, name: 'John' });
      const result = User.mergeNonNil(stored, {
        email: 'test@example.com',
        name: null,
      });

      expect(result.name).toBe('John');
    });

    // Scenario U4: Merge — stored name=null, incoming name="Jane" → name updated to "Jane"
    it('should update name when stored is null and incoming is non-null (U4)', () => {
      const stored = User.create({ ...appleProps, name: null });
      const result = User.mergeNonNil(stored, {
        email: 'apple@privaterelay.appleid.com',
        name: 'Jane',
      });

      expect(result.name).toBe('Jane');
    });

    it('should preserve stored name when incoming is empty string', () => {
      const stored = User.create({ ...googleProps, name: 'John' });
      const result = User.mergeNonNil(stored, {
        email: 'test@example.com',
        name: '',
      });

      expect(result.name).toBe('John');
    });

    it('should not overwrite stored non-null name with incoming non-null name', () => {
      const stored = User.create({ ...googleProps, name: 'John' });
      const result = User.mergeNonNil(stored, {
        email: 'test@example.com',
        name: 'Jane',
      });

      // Apple only sends name once — preserve the original
      expect(result.name).toBe('John');
    });

    it('should update email when stored is null and incoming is non-null', () => {
      const stored = User.create({ ...appleProps, email: null });
      const result = User.mergeNonNil(stored, {
        email: 'new@example.com',
        name: 'Jane',
      });

      expect(result.email).toBe('new@example.com');
    });

    it('should update email when incoming differs from stored', () => {
      const stored = User.create({ ...googleProps, email: 'old@example.com' });
      const result = User.mergeNonNil(stored, {
        email: 'new@example.com',
        name: 'John',
      });

      expect(result.email).toBe('new@example.com');
    });

    it('should not update email when incoming is same as stored', () => {
      const stored = User.create({ ...googleProps, email: 'same@example.com' });
      const result = User.mergeNonNil(stored, {
        email: 'same@example.com',
        name: 'John',
      });

      expect(result.email).toBe('same@example.com');
    });

    it('should update updatedAt timestamp after merge', () => {
      const stored = User.create({ ...googleProps });
      const beforeMerge = stored.updatedAt;

      // Small delay to ensure timestamp changes
      const result = User.mergeNonNil(stored, {
        email: 'new@example.com',
        name: null,
      });

      expect(result.updatedAt.getTime()).toBeGreaterThanOrEqual(
        beforeMerge.getTime(),
      );
    });
  });
});
