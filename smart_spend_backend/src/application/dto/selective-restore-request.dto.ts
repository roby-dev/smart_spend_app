import { IsArray, IsOptional, IsString } from 'class-validator';

export class SelectiveRestoreRequestDto {
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  comprasUuids?: string[];
}
