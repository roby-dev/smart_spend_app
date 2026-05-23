import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigService } from '@nestjs/config';
import {
  envValidationSchema,
  appConfig,
  jwtConfig,
  googleConfig,
  appleConfig,
  mongoConfig,
} from './config/app.config';
import { AuthModule } from './infrastructure/auth/auth.module';
import { BackupModule } from './infrastructure/backup/backup.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
      load: [appConfig, jwtConfig, googleConfig, appleConfig, mongoConfig],
      validationSchema: envValidationSchema,
    }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        uri: configService.getOrThrow<string>('mongo.uri'),
      }),
    }),
    AuthModule,
    BackupModule,
  ],
})
export class AppModule {}
