import { IsIn, IsString, IsNotEmpty } from 'class-validator';

export class LoginRequestDto {
  @IsIn(['google', 'apple'])
  @IsNotEmpty()
  provider: 'google' | 'apple';

  @IsString()
  @IsNotEmpty()
  idToken: string;
}
