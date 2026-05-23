import {
  Controller,
  Post,
  Get,
  Body,
  Req,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { Request } from 'express';
import {
  SaveBackupUseCase,
  GetBackupUseCase,
  SaveBackupRequestDto,
  BackupResponseDto,
} from '../../application';
import { JwtAccessGuard } from '../auth/jwt-access.guard';

interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string | null;
    provider: string;
  };
}

@Controller('backup')
@UseGuards(JwtAccessGuard)
export class BackupController {
  constructor(
    private readonly saveBackupUseCase: SaveBackupUseCase,
    private readonly getBackupUseCase: GetBackupUseCase,
  ) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  async save(
    @Req() req: RequestWithUser,
    @Body() dto: SaveBackupRequestDto,
  ): Promise<BackupResponseDto> {
    const backup = await this.saveBackupUseCase.execute(
      req.user.userId,
      dto.compras,
    );
    return new BackupResponseDto(backup.compras, backup.updatedAt);
  }

  @Get()
  async get(@Req() req: RequestWithUser): Promise<BackupResponseDto> {
    const backup = await this.getBackupUseCase.execute(req.user.userId);
    return new BackupResponseDto(backup.compras, backup.updatedAt);
  }
}
