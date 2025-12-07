import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service.js';
import { LoginDto } from './dto/login.dto.js';
import { JwtPayload, TokenResponse,LoginResponse } from 'src/common/interfaces/jwt-payload.interface.js';
import { UserService } from '../user/user.service.js';
import { audit_action, audit_status } from 'generated/prisma/enums.js';
import { v4 as uuidv4 } from 'uuid';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private users: UserService,
    private jwt: JwtService,
    private config: ConfigService,
  ) {}

  async login(
    dto: LoginDto,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<LoginResponse> {
    const user = await this.users.findByEmail(dto.email);

    if (user.locked_until && user.locked_until > new Date()) {
      throw new UnauthorizedException('Account is locked')
    }

    if (user.status === 'suspended') {
      throw new UnauthorizedException('Account is suspended')
    }
    if (user.status === 'inactive') {
      throw new UnauthorizedException('Account is inactive')
    }

    const valid = await this.users.validatePassword(dto.password, user.password_hash);  ///

    if (!valid) {
      await this.users.incrementFailedLogin(user.id);
      await this.logLoginAttempt(user.email, false, ipAddress, userAgent, 'invalid password', user.id)
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    }

    // nếu đúng password update lại và reset failedLogin về 0
    await this.users.updateLastLogin(user.id, ipAddress, userAgent);
    await this.logLoginAttempt(user.email, true, ipAddress, userAgent, "", user.id);

    //
    await this.createAuditLog({
      user_id: user.id,
      action: 'LOGIN',
      status: 'success',
      ip_address: ipAddress,
      user_agent: userAgent,
      error_message: '',
      resource_type: 'USER',
      resource_id: user.id.toString(),
      metadata: { email: dto.email },
    });

    
    const tokens = await this.generateTokens(
      user.id,
      user.email,
      user.username,
      user.role,
      ipAddress,
      userAgent,
    );
    const {password_hash ,...userInfo} = user;

    return {
      ...tokens,
      user : userInfo
    }

  }

  private async logLoginAttempt(
    email: string,
    success: boolean,
    ipAddress?: string,
    userAgent?: string,
    errorMessage?: string,
    userId?: number,
  ): Promise<void> {
    await this.prisma.login_attempts.create({
      data: {
        user_id: userId,
        email,
        ip_address: ipAddress || 'unknown',
        user_agent: userAgent,
        success,
        error_message: errorMessage,
      },
    });
  }

  private async createAuditLog(data: {
    user_id?: number;
    action: audit_action;
    status?: audit_status;
    ip_address?: string;
    user_agent?: string;
    error_message?: string;
    resource_type?: string;
    resource_id?: string;
    metadata?: Record<string, any>;
  }): Promise<void> {
    try {
      await this.prisma.audit_logs.create({
        data: {
          user_id: data.user_id || null,
          action: data.action,
          status: data.status || 'success',
          ip_address: data.ip_address || null,
          user_agent: data.user_agent || null,
          correlation_id: uuidv4(),
          error_message: data.error_message || null,
          resource_type: data.resource_type || null,
          resource_id: data.resource_id || null,
          metadata: data.metadata || undefined,
        },
      });
    } catch (err) {
      console.error('Failed to create audit log:', err);
      // Không throw ra, tránh làm ảnh hưởng flow login
    }
  }



  private async generateTokens(
    userId: number,
    email: string,
    username: string,
    role: any,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<TokenResponse> {
    const jti = uuidv4();

    const payload: JwtPayload = {
      sub: userId,
      email,
      username,
      role,
      jti,
    };

    const accessToken = this.jwt.sign(payload, {
      expiresIn: this.config.get('jwt.accessTokenExpiry')
    });

    const refreshToken = this.jwt.sign(
      { sub: userId, jti },
      { expiresIn: this.config.get('jwt.refreshTokenExpiry') },
    );

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await this.prisma.sessions.create({
      data: {
        user_id: userId,
        refresh_token: refreshToken,
        access_token_jti: jti,
        ip_address: ipAddress,
        user_agent: userAgent,
        expires_at: expiresAt,
        is_active: true,
      },
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: 3600,
    };
  }

}
