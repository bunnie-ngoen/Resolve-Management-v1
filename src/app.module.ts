import { Module } from '@nestjs/common';
import { UserModule } from './modules/user/user.module.js';
import { AuthModule } from './modules/auth/auth.module.js';
import { ConfigModule } from '@nestjs/config';
import jwtConfig from './config/jwt.config.js';
@Module({
  imports: [
    //tác dụng : có thể load được .env
    ConfigModule.forRoot({
      isGlobal :true,
      load: [jwtConfig],
    }),
    UserModule,
    AuthModule
  ],
})
export class AppModule {}
