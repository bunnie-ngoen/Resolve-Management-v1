import { Exclude, Expose, plainToClass } from 'class-transformer';
/**
 * expose() : giữ lại khi trả cho client
 * exlude() : loại bỏ khi trả cho client
 */

export class UserResponseDto {
  @Expose() id: number;
  @Expose() username: string;
  @Expose() email: string;
  @Expose() full_name: string;
  @Expose() phone_number?: string;
  @Expose() department_id?: number;
  @Expose() status: string;
  @Expose() role: string;

  @Exclude() password_hash: string;
}

