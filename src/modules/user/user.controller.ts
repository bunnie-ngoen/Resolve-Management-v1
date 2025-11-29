import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { UserService } from './user.service.js';
import { CreateUserDto } from './dto/create-user.dto.js';
import { users } from 'generated/prisma/client.js';
import { plainToInstance } from 'class-transformer';
import { UserResponseDto } from './dto/user-response.dto.js';
@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}
  
  @Get(':id')
  async getUserById(@Param('id') id:string){
    const user = await this.userService.findById(Number(id));
    return plainToInstance(UserResponseDto,user)
  }

}
