export class BackupNotFoundError extends Error {
  constructor(message = 'No backup found for this user') {
    super(message);
    this.name = 'BackupNotFoundError';
  }
}
