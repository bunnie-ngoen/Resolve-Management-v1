import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from 'src/modules/user/user.service.js';
import { JwtPayload, AuthenticatedUser } from '../../../common/interfaces/jwt-payload.interface.js';
import { user_status } from 'generated/prisma/enums.js';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
    constructor(
        private config: ConfigService,
        private users: UserService,
    ) {
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
            secretOrKey: config.getOrThrow<string>('jwt.secret'),
        });
    }

    async validate(payload: JwtPayload): Promise<AuthenticatedUser> {
        const user = await this.users.findById(payload.sub);

        if (!user) {
            throw new UnauthorizedException('User not found');
        }

        if (user.status !== user_status.active) {
            throw new UnauthorizedException(`Account is ${user.status}`);
        }

        if (user.locked_until && user.locked_until > new Date()) {
            throw new UnauthorizedException('Account is temporarily locked');
        }

        return {
            id: user.id,
            email: user.email,
            username: user.username,
            role: user.role,
        };
    }
}