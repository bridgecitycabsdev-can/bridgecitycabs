export const OBJECT_STORAGE = Symbol('OBJECT_STORAGE');

export type ObjectStorage = {
  putObject(
    key: string,
    body: Buffer,
    contentType: string,
  ): Promise<void>;
  signedUrl(key: string, ttlSeconds: number): Promise<string>;
};
