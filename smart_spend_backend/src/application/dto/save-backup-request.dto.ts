import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsISO8601,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';

export class CompraDetalleDto {
  @IsString()
  nombre: string;

  @IsNumber()
  precio: number;

  @IsISO8601()
  fecha: string;
}

export class CompraDto {
  @IsString()
  titulo: string;

  @IsISO8601()
  fecha: string;

  @IsBoolean()
  archivado: boolean;

  @IsOptional()
  @IsNumber()
  presupuesto: number | null;

  @IsNumber()
  orden: number;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CompraDetalleDto)
  detalles: CompraDetalleDto[];
}

export class SaveBackupRequestDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CompraDto)
  compras: CompraDto[];
}
