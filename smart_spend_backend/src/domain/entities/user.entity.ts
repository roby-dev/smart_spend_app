import { AuthProvider } from '../value-objects/auth-provider.vo';

export interface CreateUserProps {
  email: string | null;
  name: string | null;
  provider: AuthProvider;
  providerId: string;
}

export class User {
  public readonly id: string;
  public email: string | null;
  public name: string | null;
  public readonly provider: AuthProvider;
  public readonly providerId: string;
  public refreshTokenHash: string | null;
  public previousRefreshTokenHash: string | null;
  public readonly createdAt: Date;
  public updatedAt: Date;

  private constructor(
    props: CreateUserProps & { id: string; createdAt: Date; updatedAt: Date },
  ) {
    this.id = props.id;
    this.email = props.email;
    this.name = props.name;
    this.provider = props.provider;
    this.providerId = props.providerId;
    this.refreshTokenHash = null;
    this.previousRefreshTokenHash = null;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static create(props: CreateUserProps): User {
    const now = new Date();
    return new User({
      ...props,
      id: '', // assigned by persistence layer
      createdAt: now,
      updatedAt: now,
    });
  }

  /**
   * Reconstitutes a User from persistence.
   */
  static fromPersistence(props: {
    id: string;
    email: string | null;
    name: string | null;
    provider: AuthProvider;
    providerId: string;
    refreshTokenHash: string | null;
    previousRefreshTokenHash: string | null;
    createdAt: Date;
    updatedAt: Date;
  }): User {
    const user = new User({
      email: props.email,
      name: props.name,
      provider: props.provider,
      providerId: props.providerId,
      id: props.id,
      createdAt: props.createdAt,
      updatedAt: props.updatedAt,
    });
    user.refreshTokenHash = props.refreshTokenHash;
    user.previousRefreshTokenHash = props.previousRefreshTokenHash;
    return user;
  }

  /**
   * Merges non-nil incoming values into the stored user.
   * - Only overwrite stored name if incoming is non-null AND stored is currently null/empty.
   *   This preserves Apple's name from first login (it's only sent once).
   * - Email: if incoming is non-null and differs from stored, update.
   */
  static mergeNonNil(
    stored: User,
    incoming: { email: string | null; name: string | null },
  ): User {
    if (
      incoming.name != null &&
      incoming.name !== '' &&
      (stored.name == null || stored.name === '')
    ) {
      stored.name = incoming.name;
    }

    if (
      incoming.email != null &&
      incoming.email !== '' &&
      stored.email !== incoming.email
    ) {
      stored.email = incoming.email;
    }

    stored.updatedAt = new Date();
    return stored;
  }
}
