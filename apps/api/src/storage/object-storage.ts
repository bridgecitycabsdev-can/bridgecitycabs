export const OBJECT_STORAGE = Symbol('OBJECT_STORAGE');

export type ObjectStorage = {
  putObject(
    key: string,
    body: Buffer,
    contentType: string,
  ): Promise<void>;
  signedUrl(key: string, ttlSeconds: number): Promise<string>;
  /** Keys under `prefix` (inclusive). Used by nightly backup prune. */
  listObjectKeys(prefix: string): Promise<string[]>;
  deleteObject(key: string): Promise<void>;
};
