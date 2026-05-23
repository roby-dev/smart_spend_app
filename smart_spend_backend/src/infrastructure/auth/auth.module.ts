import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthController } from './auth.controller';
import { GoogleTokenVerifier } from './verifiers/google-token-verifier.service';
import { AppleTokenVerifier } from './verifiers/apple-token-verifier.service';
import {
  VERIFIER_REGISTRY,
  verifierRegistryProvider,
} from './verifiers/verifier-registry.provider';
import { TokenService } from './token.service';
import { JwtStrategy } from './jwt.strategy';
import { JwtAccessStrategy } from './jwt-access.strategy';
import { JwtAuthGuard } from './jwt-auth.guard';
import { JwtAccessGuard } from './jwt-access.guard';
import {
  LoginUseCase,
  RefreshTokenUseCase,
  LogoutUseCase,
} from '../../application';
import { AuthProvider } from '../../domain/value-objects/auth-provider.vo';
import { ITokenVerifier } from '../../application/ports/token-verifier.port';
import { MongoUserRepository } from '../persistence/mongo-user.repository';
import {
  UserSchema,
  UserMongooseSchema,
} from '../persistence/schemas/user.schema';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.getOrThrow<string>('jwt.secret'),
        signOptions: {
          expiresIn: configService.get<string>('jwt.expiry', '15m') as any,
        },
      }),
    }),
    MongooseModule.forFeature([
      { name: UserSchema.name, schema: UserMongooseSchema },
    ]),
  ],
  controllers: [AuthController],
  providers: [
    GoogleTokenVerifier,
    AppleTokenVerifier,
    verifierRegistryProvider,
    TokenService,
    JwtStrategy,
    JwtAccessStrategy,
    JwtAuthGuard,
    JwtAccessGuard,
    MongoUserRepository,
    {
      provide: LoginUseCase,
      useFactory: (
        verifiers: Record<AuthProvider, ITokenVerifier>,
        userRepo: MongoUserRepository,
        tokenSvc: TokenService,
      ) => new LoginUseCase(verifiers, userRepo, tokenSvc),
      inject: [VERIFIER_REGISTRY, MongoUserRepository, TokenService],
    },
    {
      provide: RefreshTokenUseCase,
      useFactory: (userRepo: MongoUserRepository, tokenSvc: TokenService) =>
        new RefreshTokenUseCase(userRepo, tokenSvc),
      inject: [MongoUserRepository, TokenService],
    },
    {
      provide: LogoutUseCase,
      useFactory: (userRepo: MongoUserRepository) =>
        new LogoutUseCase(userRepo),
      inject: [MongoUserRepository],
    },
  ],
  exports: [JwtAuthGuard, JwtAccessGuard],
})
export class AuthModule {}
