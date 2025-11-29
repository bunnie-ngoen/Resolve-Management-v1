import { IsEmail, IsNotEmpty, MinLength, IsString } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email: string;

  @IsNotEmpty()
  @MinLength(6)
  password: string;

  @IsNotEmpty()
  @IsString()
  username: string;

  @IsString()
  full_name: string;
}
