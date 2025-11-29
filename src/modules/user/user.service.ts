import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto.js';
import { user_status } from '../../../generated/prisma/enums.js'
import * as bcrypt from 'bcrypt'
import { PrismaService } from '../../prisma/prisma.service.js'
import { users } from '../../../generated/prisma/client.js';
import { Prisma } from '../../../generated/prisma/client.js';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class UserService {
  constructor(
    private prisma: PrismaService,
    private config: ConfigService
  ) { }

  /**
   * 
   * @param id 
   * @param includeDeleted 
   * @returns 
   */
  async findById(id: number, includeDeleted = false): Promise<users> {
    const user = await this.prisma.users.findFirst({
      where: {
        id,
        ...(includeDeleted ? {} : { deleted_at: null }),
      },
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return user;
  }

  /**
   * 
   * @param email 
   * @returns 
   */
  async findByEmail(email: string): Promise<users> {
    const user = await this.prisma.users.findFirst({
      where: { email }
    })
    if (!user) {
      throw new NotFoundException(`User with Email ${email} not found `)
    }
    return user;
  }

  /**
   * 
   * @param plain 
   * @param hashed 
   * @returns 
   */
  async validatePassword(plain: string, hashed: string): Promise<any> {
    return bcrypt.compare(plain, hashed)
  }

  /**
   * 
   * @param passsword 
   * @returns string
   */
  async hashPassword(passsword: string): Promise<string> {
    const saltRounds = this.config.get<number>('SALT_ROUNDS') || 10;
    return bcrypt.hash(passsword, saltRounds)
  }

  /**
   * 
   * @param userId 
   */
  async incrementFailedLogin(userId: number): Promise<void> {
    const user = await this.findById(userId);

    const failtAttempts = user.failed_login_attempts + 1;

    const updateData: Prisma.usersUpdateInput = {
      failed_login_attempts: failtAttempts,
    }

    if (failtAttempts >= 5) {
      updateData.locked_until = new Date(Date.now() + 30 * 60 * 1000);
      updateData.status = user_status.locked;
    }

    await this.prisma.users.update({
      where: { id: userId },
      data: updateData
    })
  }
  /**
   * 
   * @param userId 
   * @param ipAddress 
   * @param userAgent 
   */
  async updateLastLogin(userId: number, ipAddress?: string, userAgent?: string): Promise<void> {
    await this.prisma.users.update({
      where: { id: userId },
      data: {
        last_login_at: new Date(),
        last_login_ip: ipAddress,
        last_login_user_agent: userAgent,
        failed_login_attempts: 0,
      }
    })
  }


}
