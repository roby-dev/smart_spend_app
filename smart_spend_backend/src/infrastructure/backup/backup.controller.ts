import {
  Controller,
  Post,
  Get,
  Body,
  Req,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { Request } from 'express';
import {
  SaveBackupUseCase,
  GetBackupUseCase,
  CreateBackupSnapshotUseCase,
  GetBackupHistoryUseCase,
  GetBackupSnapshotUseCase,
  RestoreBackupSnapshotUseCase,
  SaveBackupRequestDto,
  BackupResponseDto,
  BackupHistoryResponseDto,
  BackupSnapshotResponseDto,
  SelectiveRestoreRequestDto,
} from '../../application';
import { BackupNotFoundError } from '../../domain/exceptions/backup.exceptions';
import { JwtAccessGuard } from '../auth/jwt-access.guard';
import { ApiBearerAuth } from '@nestjs/swagger';

interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string | null;
    provider: string;
  };
}

@Controller('backup')
@UseGuards(JwtAccessGuard)
@ApiBearerAuth()
export class BackupController {
  constructor(
    private readonly saveBackupUseCase: SaveBackupUseCase,
    private readonly getBackupUseCase: GetBackupUseCase,
    private readonly createBackupSnapshotUseCase: CreateBackupSnapshotUseCase,
    private readonly getBackupHistoryUseCase: GetBackupHistoryUseCase,
    private readonly getBackupSnapshotUseCase: GetBackupSnapshotUseCase,
    private readonly restoreBackupSnapshotUseCase: RestoreBackupSnapshotUseCase,
  ) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  async save(
    @Req() req: RequestWithUser,
    @Body() dto: SaveBackupRequestDto,
  ): Promise<BackupResponseDto> {
    // Dual-write: create snapshot + compat upsert to old collection
    const [snapshot] = await Promise.all([
      this.createBackupSnapshotUseCase.execute(req.user.userId, dto.compras),
      this.saveBackupUseCase.execute(req.user.userId, dto.compras),
    ]);

    return new BackupResponseDto(snapshot.compras, snapshot.createdAt, snapshot.id);
  }

  @Get()
  async get(@Req() req: RequestWithUser): Promise<BackupResponseDto> {
    try {
      // Try snapshots first (newest)
      const snapshots = await this.getBackupHistoryUseCase.execute(
        req.user.userId,
      );
      if (snapshots.length > 0) {
        return new BackupResponseDto(
          snapshots[0].compras,
          snapshots[0].createdAt,
        );
      }
    } catch {
      // Fallback to old backup collection
    }

    const backup = await this.getBackupUseCase.execute(req.user.userId);
    return new BackupResponseDto(backup.compras, backup.updatedAt);
  }

  @Get('history')
  async getHistory(
    @Req() req: RequestWithUser,
  ): Promise<BackupHistoryResponseDto[]> {
    const snapshots = await this.getBackupHistoryUseCase.execute(
      req.user.userId,
    );
    return snapshots.map(
      (s) => new BackupHistoryResponseDto(s.id!, s.createdAt, s.compras.length),
    );
  }

  @Get(':id')
  async getById(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ): Promise<BackupSnapshotResponseDto> {
    try {
      const snapshot = await this.getBackupSnapshotUseCase.execute(id);
      return new BackupSnapshotResponseDto(
        snapshot.id!,
        snapshot.compras,
        snapshot.createdAt,
      );
    } catch (error) {
      if (error instanceof BackupNotFoundError) {
        throw new NotFoundException(error.message);
      }
      throw error;
    }
  }

  @Post(':id/restore')
  @HttpCode(HttpStatus.OK)
  async restore(
    @Param('id') id: string,
    @Body() dto: SelectiveRestoreRequestDto,
  ): Promise<BackupSnapshotResponseDto> {
    // [LOG] Punto 3 — qué recibe el backend
    console.log('[BACKUP] ═══════════════════════════════════════');
    console.log(`[BACKUP] 📥 POST /backup/${id}/restore`);
    console.log(`[BACKUP]    comprasUuids: ${dto.comprasUuids?.length ?? 0} (${JSON.stringify(dto.comprasUuids)})`);
    console.log('[BACKUP] ═══════════════════════════════════════');

    try {
      const compras = await this.restoreBackupSnapshotUseCase.execute(
        id,
        dto.comprasUuids,
      );

      // [LOG] Punto 4 — qué devuelve el use case
      console.log('[BACKUP] 📤 Restore exitoso — compras devueltas:');
      console.log('[BACKUP]    cantidad: ' + compras.length);
      console.log('[BACKUP]    uuids: [' + compras.map(c => c.uuid).join(', ') + ']');

      return new BackupSnapshotResponseDto(id, compras, new Date());
    } catch (error) {
      if (error instanceof BackupNotFoundError) {
        throw new NotFoundException(error.message);
      }
      if (error instanceof Error && error.message.startsWith('UUIDs not found')) {
        throw new BadRequestException(error.message);
      }
      throw error;
    }
  }
}
