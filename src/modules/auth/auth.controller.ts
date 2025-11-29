import { Controller, Get, Post, Body, Patch, Param, Delete, HttpCode, HttpStatus ,Req } from '@nestjs/common';
import { AuthService } from './auth.service.js';
import { Public } from '../../common/decorators/public.decorator.js'
import { LoginDto } from './dto/login.dto.js';
import type { Request } from 'express';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}
  
  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() dto: LoginDto, @Req() req: Request) {
    const tokens = await this.authService.login(dto, req.ip, req.headers['user-agent']);
    return {
      success: true,
      message: 'Login successful',
      data: tokens,
    };
  }
}
