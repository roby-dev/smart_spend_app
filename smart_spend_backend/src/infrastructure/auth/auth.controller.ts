import {
  Controller,
  Post,
  Body,
  Req,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiBearerAuth } from '@nestjs/swagger';
import { Request } from 'express';
import { LoginRequestDto } from '../../application/dto/login-request.dto';
import { RefreshRequestDto } from '../../application/dto/refresh-request.dto';
import { TokenResponseDto } from '../../application/dto/token-response.dto';
import {
  LoginUseCase,
  RefreshTokenUseCase,
  LogoutUseCase,
} from '../../application';
import { JwtAuthGuard } from './jwt-auth.guard';

interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string | null;
    provider: string;
  };
}

@Controller('auth')
export class AuthController {
  constructor(
    private readonly loginUseCase: LoginUseCase,
    private readonly refreshTokenUseCase: RefreshTokenUseCase,
    private readonly logoutUseCase: LogoutUseCase,
  ) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() dto: LoginRequestDto): Promise<TokenResponseDto> {
    return this.loginUseCase.execute(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  async refresh(
    @Req() req: RequestWithUser,
    @Body() dto: RefreshRequestDto,
  ): Promise<TokenResponseDto> {
    const userId = req.user.userId;
    return this.refreshTokenUseCase.execute(userId, dto.refreshToken);
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  async logout(
    @Req() req: RequestWithUser,
    @Body() dto: RefreshRequestDto,
  ): Promise<void> {
    const userId = req.user.userId;
    await this.logoutUseCase.execute(userId);
  }
}
