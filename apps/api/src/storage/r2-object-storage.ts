import {
  GetObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { ObjectStorage } from './object-storage.js';

@Injectable()
export class R2ObjectStorage implements ObjectStorage {
  private readonly logger = new Logger(R2ObjectStorage.name);
  private readonly client: S3Client;
  private readonly bucket: string;

  constructor(config: ConfigService) {
    const accountId = config.getOrThrow<string>('R2_ACCOUNT_ID').trim();
    const accessKeyId = config.getOrThrow<string>('R2_ACCESS_KEY_ID').trim();
    const secretAccessKey = config
      .getOrThrow<string>('R2_SECRET_ACCESS_KEY')
      .trim();
    this.bucket = config.getOrThrow<string>('R2_BUCKET').trim();
    this.client = new S3Client({
      region: 'auto',
      endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
      credentials: { accessKeyId, secretAccessKey },
    });
  }

  async putObject(key: string, body: Buffer, contentType: string) {
    await this.client.send(
      new PutObjectCommand({
        Bucket: this.bucket,
        Key: key,
        Body: body,
        ContentType: contentType,
      }),
    );
    this.logger.debug(`Uploaded s3://${this.bucket}/${key} (${body.length} B)`);
  }

  signedUrl(key: string, ttlSeconds: number) {
    return getSignedUrl(
      this.client,
      new GetObjectCommand({ Bucket: this.bucket, Key: key }),
      { expiresIn: Math.max(60, Math.floor(ttlSeconds)) },
    );
  }
}
